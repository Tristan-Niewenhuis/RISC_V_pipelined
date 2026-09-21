$buildDir = ".\build\src"
$objdump = "C:\AMDDesignTools\2026.1\gnu\riscv\nt\bin\riscv64-unknown-elf-objdump.exe"

Get-ChildItem $buildDir -Directory | ForEach-Object {
    $exe = Get-ChildItem $_.FullName -Filter "*.exe" | Select-Object -First 1

    if ($exe) {
        $dis = [System.IO.Path]::ChangeExtension($exe.FullName, ".dis")

        Write-Host "Disassembling $($exe.FullName)"

        & $objdump -d -M no-aliases,numeric $exe.FullName |
            Out-File -Encoding ascii $dis

        Write-Host "Created $dis"
    }
}