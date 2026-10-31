param(
    [string]$RomOrigin = "0x00001000"
)

$buildDir = ".\build\src"

$objcopy = "C:\AMDDesignTools\2026.1\gnu\riscv\nt\bin\riscv64-unknown-elf-objcopy.exe"

if ($RomOrigin -match '^0[xX]([0-9a-fA-F]+)$') {
    $romOriginBytes = [Convert]::ToInt32($Matches[1], 16)
}
else {
    $romOriginBytes = [int]::Parse($RomOrigin)
}

if ($romOriginBytes -lt 0 -or ($romOriginBytes % 4) -ne 0) {
    throw "ROM_ORIGIN must be a non-negative, 4-byte-aligned byte address: $RomOrigin"
}

Write-Host ("Padding each ROM COE with {0} zero bytes before .text (ROM_ORIGIN={1})" -f $romOriginBytes, $RomOrigin)

Get-ChildItem $buildDir -Directory | ForEach-Object {

    $dir = $_
    $exe = Get-ChildItem $dir.FullName -Filter "*.exe" | Select-Object -First 1

    if ($exe) {

        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($exe.Name)

        $romBin = Join-Path $dir.FullName "${baseName}_rom.bin"
        $romTextBin = Join-Path $dir.FullName "${baseName}_rom_text.bin"
        $ramBin = Join-Path $dir.FullName "${baseName}_ram.bin"

        $romCoe = Join-Path $dir.FullName "${baseName}_rom.coe"
        $ramCoe = Join-Path $dir.FullName "${baseName}_ram.coe"


        Write-Host "Creating ROM image for $($exe.FullName)"

        # Extract .text. This raw section starts at offset zero, so add leading
        # bytes matching its linked ROM address before converting to COE.
        & $objcopy `
            -O binary `
            --only-section=.text `
            $exe.FullName `
            $romTextBin

        if ($LASTEXITCODE -ne 0) {
            Write-Error "objcopy failed for ROM: $($exe.FullName)"
            return
        }

        $textBytes = [System.IO.File]::ReadAllBytes($romTextBin)
        [byte[]]$romBytes = New-Object byte[] ($romOriginBytes + $textBytes.Length)
        [System.Array]::Copy($textBytes, 0, $romBytes, $romOriginBytes, $textBytes.Length)
        [System.IO.File]::WriteAllBytes($romBin, $romBytes)
        Remove-Item -LiteralPath $romTextBin


        Write-Host "Creating RAM image for $($exe.FullName)"

        # Extract RAM-resident sections.
        & $objcopy `
            -O binary `
            --only-section=.rodata `
            '--only-section=.srodata*' `
            --only-section=.data `
            '--only-section=.sdata*' `
            $exe.FullName `
            $ramBin

        if ($LASTEXITCODE -ne 0) {
            Write-Error "objcopy failed for RAM: $($exe.FullName)"
            return
        }


        function Convert-BinToCoe {
            param (
                [string]$BinFile,
                [string]$CoeFile
            )

            $bytes = [System.IO.File]::ReadAllBytes($BinFile)

            # Pad to a complete 32-bit word.
            $remainder = $bytes.Length % 4

            if ($remainder -ne 0) {
                $padding = 4 - $remainder
                $bytes += New-Object byte[] $padding
            }

            $words = @()

            for ($i = 0; $i -lt $bytes.Length; $i += 4) {

                # Convert little-endian bytes to a 32-bit hex word.
                $word = "{0:X2}{1:X2}{2:X2}{3:X2}" -f `
                    $bytes[$i + 3],
                    $bytes[$i + 2],
                    $bytes[$i + 1],
                    $bytes[$i]

                $words += $word
            }


            $output = @(
                "memory_initialization_radix = 16;"
                "memory_initialization_vector ="
            )

            for ($i = 0; $i -lt $words.Count; $i++) {

                if ($i -eq $words.Count - 1) {
                    $output += "$($words[$i]);"
                }
                else {
                    $output += "$($words[$i]),"
                }
            }

            Set-Content `
                -Path $CoeFile `
                -Value $output `
                -Encoding ascii
        }


        Convert-BinToCoe $romBin $romCoe
        Convert-BinToCoe $ramBin $ramCoe


        Remove-Item $romBin
        Remove-Item $ramBin


        Write-Host "Created $romCoe"
        Write-Host "Created $ramCoe"
    }
}
