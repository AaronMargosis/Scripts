<#
.SYNOPSIS
Adds the current file system directory to the Path environment variable for the current PowerShell session.

.DESCRIPTION
# By way of example: adding the Windows Debugging Tools directory to the path for this PowerShell session:

pushd 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64'
AddCurrDirToPath
popd
# Now windbg.exe is in the Path...

.NOTES
Another SysNocturnals script by Aaron Margosis.

.LINK
https://github.com/AaronMargosis/Aaron-Margosis-SysNocturnals-Tools
#>

$env:Path += ";" + $pwd.Path
