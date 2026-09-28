$buildDir = ".\build\src"

$objcopy = "C:\AMDDesignTools\2026.1\gnu\riscv\nt\bin\riscv64-unknown-elf-objcopy.exe"

Get-ChildItem $buildDir -Directory | ForEach-Object {

    $dir = $_
    $exe = Get-ChildItem $dir.FullName -Filter "*.exe" | Select-Object -First 1

    if ($exe) {

        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($exe.Name)

        $romBin = Join-Path $dir.FullName "${baseName}_rom.bin"
        $ramBin = Join-Path $dir.FullName "${baseName}_ram.bin"

        $romCoe = Join-Path $dir.FullName "${baseName}_rom.coe"
        $ramCoe = Join-Path $dir.FullName "${baseName}_ram.coe"


        Write-Host "Creating ROM image for $($exe.FullName)"

        # Extract all .text.* sections into the ROM image.
        & $objcopy `
            -O binary `
            --only-section=.text `
            $exe.FullName `
            $romBin

        if ($LASTEXITCODE -ne 0) {
            Write-Error "objcopy failed for ROM: $($exe.FullName)"
            return
        }


        Write-Host "Creating RAM image for $($exe.FullName)"

        # Extract RAM-resident sections.
        & $objcopy `
            -O binary `
            --only-section=.rodata `
            --only-section=.data `
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