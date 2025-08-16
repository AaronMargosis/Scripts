<#
.SYNOPSIS
Download Microsoft Security Compliance Toolkit tools to "C:\Program Files\SCT" and ensure that directory is in the Path.
Requires administrative rights.

.NOTES
Another SysNocturnals script by Aaron Margosis.

.LINK
https://github.com/AaronMargosis/Aaron-Margosis-SysNocturnals-Tools
#>

$baseurl = "https://download.microsoft.com/download/8/5/c/85c25433-a1b0-4ffa-9429-7e023e7da8d8/"
$zipFiles = @(
    "PolicyAnalyzer.zip",
    "LGPO.zip",
    "SetObjectSecurity.zip"
    )
$targDir = 'C:\Program Files\SCT'

# Check for admin rights first
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Error "This script requires administrative rights."
    exit
}

# create target only if it doesn't already exist
if (-not (Test-Path -Path $targDir))
{
    mkdir $targDir | Out-Null
}

foreach ($zipFile in $zipFiles)
{
    $url = $baseurl + $zipFile
    $fLocal = $env:TEMP + '\' + $zipFile

    Write-Host "Downloading..." -ForegroundColor Cyan
    Write-Host "  from: $url" -ForegroundColor Cyan
    Write-Host "  to  : $fLocal" -ForegroundColor Cyan
    $webReqError = $null
    try {
        Invoke-WebRequest -Uri $url -OutFile $fLocal -ErrorVariable webReqError -ErrorAction SilentlyContinue
    }
    catch 
    {
        #Write-Error "Error downloading to $fLocal from $url"
        $webReqError | %{ Write-Error $_ }
        exit
    }

    # Extract files from the zip to the target directory
    Write-Host "Extracting to $targDir" -ForegroundColor Cyan
    Expand-Archive -Path $fLocal -DestinationPath $targDir -Force -ErrorAction Continue

    # Delete the zip file.
    Write-Host "Deleting $fLocal" -ForegroundColor Cyan
    Remove-Item $fLocal # -Force ?
}

# The files are in subdirectories. Move them to the target directory, and then delete the subdirectories.
$filesToMove = Get-ChildItem -Path $targDir -Include *.exe, *.ps1, *.pdf -Recurse
$dirsToDelete = Get-ChildItem -Path $targDir -Directory
Move-Item -Path $filesToMove -Destination $targDir -Force
Remove-Item -Path $dirsToDelete.FullName -Recurse

# append target to $env:PATH globally if it hasn't been done already.
$machinePath = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').Path
if ($null -eq $machinePath -or "" -eq $machinePath)
{
    Write-Error "Couldn't get machine path"
}
else
{
    if (-not $machinePath.Contains($targDir))
    {
        Write-Host "Adding $targDir to the PATH" -ForegroundColor Cyan
        # Append to the machine-wide PATH var for future processes
        setx.exe /M PATH ("$machinePath;$targDir;") | Out-Null
        # Append to the PATH var for this process
        $env:Path += ";$targDir;"
    }
}
