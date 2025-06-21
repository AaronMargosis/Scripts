<#
.SYNOPSIS
Set the title of the current console (or Terminal tab) to the current username, prepended with "Admin:" if appropriate

.NOTES
Another SysNocturnals script by Aaron Margosis.

.LINK
https://github.com/AaronMargosis/Aaron-Margosis-SysNocturnals-Tools
#>

$prepend = ""

$id = [Security.Principal.WindowsIdentity]::GetCurrent()
if (([Security.Principal.WindowsPrincipal] $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	$prepend = "Admin: "
}

$host.UI.RawUI.WindowTitle = $prepend + $id.Name

