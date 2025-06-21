<#
.SYNOPSIS
Start Windows PowerShell ISE with zero or more files.

.DESCRIPTION
"Fixes" the problem where PowerShell ISE requires multiple files to be comma-separated and doesn't process wildcards.
Mostly intended for use with PowerShell 7 (where "ise" is not already an alias) and when VS Code is not installed.
Can also be used with Windows PowerShell to replace the "ise" alias (you might want to rename this script).

By way of example: starting PowerShell ISE and opening all the d*.ps1 and t*.ps1 files in the current directory:

ise d*.ps1 t*.ps1

.PARAMETER filespecs
Zero or more file specifications, which can be relative or absolute paths and can include wildcards.

.NOTES
Another SysNocturnals script by Aaron Margosis.

.LINK
https://github.com/AaronMargosis/Aaron-Margosis-SysNocturnals-Tools
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)]
	[string[]]
	$filespecs
)

# Resolve the file specifications into an array of full paths
$filepaths = @(
	foreach($filespec in $filespecs)
	{
		$files = @(Get-ChildItem $filespec -ErrorAction SilentlyContinue)
		if ($files.Count -gt 0)
		{
			$files.FullName
		}
		else
		{
			Write-Warning "Not found: $filespec"
		}
	}
	)

Write-Verbose ($filepaths -join "`n")

if ($filepaths.Count -gt 0)
{
    # powershell_ise.exe requires comma-separation to accept multiple files on the command line
	powershell_ise.exe ($filepaths -join ",")
}
else
{
    # No files specified; just start a new instance of powershell_ise.exe
	powershell_ise.exe
}
