<#
.SYNOPSIS
Set the title of the current console (or Terminal tab) to the current path, prepended with "Admin:" if appropriate, and trimmed so that taskbar preview doesn't truncate the end of the path.

.NOTES
Another SysNocturnals script by Aaron Margosis.

.LINK
https://github.com/AaronMargosis/Aaron-Margosis-SysNocturnals-Tools
#>

$prepend = ""

if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	$prepend = "Admin: "
}

if ($prepend.Length + $pwd.Path.Length -le 35)
{
	$host.UI.RawUI.WindowTitle = $prepend + $pwd.Path
}
else
{
	$host.UI.RawUI.WindowTitle = $prepend + "..." + $pwd.Path.Substring($prepend.Length + $pwd.Path.Length - 28)
}
