Write-Host "Packaging..."

$ErrorActionPreference = "Stop"

$msbuild = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"
$deploySrcFolder = "..\deploy\"
$srcWebProj = "..\ExampleApp\ExampleApp.csproj"
$packagedWebsiteFolder = "..\ExampleApp\obj\Debug\Package\PackageTmp\"
$packageFolder = "..\webPackage\"
$packageFolderFullPath = [System.IO.Path]::GetFullPath((Join-Path (pwd) $packageFolder))
$packageWebFolder = [io.path]::combine($packageFolder, "web")
$packageZip = "..\webPackage.zip"
$packageZipFullPath = [System.IO.Path]::GetFullPath((Join-Path (pwd) $packageZip))

Write-Host "Packaging site"
& $msbuild $srcWebProj /target:Package /p:VisualStudioVersion=14.0
if ($LastExitCode -ne 0) { throw "msbuild failed" }

if (Test-Path $packageZip)
{
	Write-Host "Removing old package zip"
	Remove-Item -Recurse -Force $packageZip
}

if (Test-Path $packageFolder)
{
	Write-Host "Removing old package folder"
	Remove-Item -Recurse -Force $packageFolder
}

Write-Host "Copy deploy files to package folder"
Copy-Item $deploySrcFolder $packageFolder -Recurse -Force

Write-Host "Copy site files to package web folder"
Copy-Item $packagedWebsiteFolder $packageWebFolder -Recurse -Force

Write-Host "Creating package zip from folder"
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($packageFolderFullPath, $packageZipFullPath) 

if (Test-Path $packageFolder)
{
	Write-Host "Removing package folder"
	Remove-Item -Recurse -Force $packageFolder
}

Write-Host ("Package: " + $packageZipFullPath)

Write-Host "Packaging finished"