<#
.SYNOPSIS
Equivalent to *nix "touch" command: creates a new empty file, or updates the LastWriteTime of an existing file.

.NOTES
Another SysNocturnals script by Aaron Margosis.

.LINK
https://github.com/AaronMargosis/Aaron-Margosis-SysNocturnals-Tools
#>

param(
	[parameter(Mandatory=$true)]
	[string]
	$filespec
)

if (Test-Path $filespec)
{
	(Get-ChildItem $filespec).LastWriteTime = [datetime]::Now 
}
else
{
	New-Item -ItemType File -Path $filespec | Out-Null
}
