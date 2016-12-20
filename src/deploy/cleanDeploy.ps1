Write-Host "Cleaning the deploy folder..."

$ErrorActionPreference = "Stop"

$deployPath = "c:\ExampleApp\deploy\"

if (Test-Path $deployPath -pathType container)
{
    Write-Host "Delete deploy folder"
    &cmd.exe /c rd /s /q $deployPath
}