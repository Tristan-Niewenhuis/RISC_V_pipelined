$buildDir = ".\build\src"
$objcopy = "C:\AMDDesignTools\2026.1\gnu\riscv\nt\bin\riscv64-unknown-elf-objcopy.exe"

function Convert-BinToWordHex {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BinFile,
        [Parameter(Mandatory = $true)]
        [string]$HexFile
    )

    [byte[]]$bytes = [System.IO.File]::ReadAllBytes($BinFile)

    # Make each image a whole number of 32-bit words, matching the COE images.
    $remainder = $bytes.Length % 4
    if ($remainder -ne 0) {
        $padding = 4 - $remainder
        $bytes += New-Object byte[] $padding
        [System.IO.File]::WriteAllBytes($BinFile, $bytes)
    }

    $words = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $bytes.Length; $i += 4) {
        # Bytes are shown most-significant first, so each line is the RV32 word
        # value (for example, bytes 13 00 00 00 become the instruction 00000013).
        $words.Add(("{0:X2}{1:X2}{2:X2}{3:X2}" -f `
            $bytes[$i + 3], $bytes[$i + 2], $bytes[$i + 1], $bytes[$i]))
    }

    [System.IO.File]::WriteAllLines($HexFile, $words, [System.Text.Encoding]::ASCII)
}

if (-not (Test-Path $buildDir)) {
    throw "Build output directory not found: $buildDir. Run the elf target first."
}
if (-not (Test-Path $objcopy)) {
    throw "objcopy not found: $objcopy"
}

Get-ChildItem $buildDir -Directory | ForEach-Object {
    $dir = $_
    $exe = Get-ChildItem $dir.FullName -Filter "*.exe" | Select-Object -First 1

    if ($exe) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($exe.Name)
        $romBin = Join-Path $dir.FullName "${baseName}_rom.bin"
        $ramBin = Join-Path $dir.FullName "${baseName}_ram.bin"
        $romHex = Join-Path $dir.FullName "${baseName}_rom.hex"
        $ramHex = Join-Path $dir.FullName "${baseName}_ram.hex"

        Write-Host "Exporting Python-friendly ROM/RAM images for $($exe.Name)"

        & $objcopy -O binary --only-section=.text $exe.FullName $romBin
        if ($LASTEXITCODE -ne 0) {
            throw "objcopy failed while extracting ROM from $($exe.FullName)"
        }

        & $objcopy -O binary --only-section=.rodata --only-section=.data $exe.FullName $ramBin
        if ($LASTEXITCODE -ne 0) {
            throw "objcopy failed while extracting RAM from $($exe.FullName)"
        }

        Convert-BinToWordHex $romBin $romHex
        Convert-BinToWordHex $ramBin $ramHex

        Write-Host "  ROM: $romBin and $romHex"
        Write-Host "  RAM: $ramBin and $ramHex"
    }
}
