<#
.SYNOPSIS
Set the title of the current console (or Terminal tab) to the input text, prepended with "Admin:" if appropriate.

.NOTES
Another SysNocturnals script by Aaron Margosis.

.LINK
https://github.com/AaronMargosis/Aaron-Margosis-SysNocturnals-Tools
#>

param(
    ## New window title text
	[parameter(Mandatory=$false)]
	[string]
	$windowTitle = ""
)

Set-StrictMode -Version Latest


$prepend = ""

if ($windowTitle.Length -eq 0)
{
	$host.UI.RawUI.WindowTitle
}
else
{
	if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
	{
		$prepend = "Admin: "
	}

	$host.UI.RawUI.WindowTitle = $prepend + $windowTitle
}
