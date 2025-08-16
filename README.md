# Aaron Margosis' SysNocturnals Scripts

The **"SysNocturnals Scripts"** are a set of helpful PowerShell scripts for the Windows platform that are part of the **"SysNocturnals Tools"** suite.

Like the rest of the SysNocturnals tools, these scripts are entirely free for use under the terms of the MIT license, and the versions in the Release zip file are digitally signed.

## The SysNocturnals scripts

|Script name|Synopsis and Description|
|---|---|
|**AddCurrDirToPath.ps1**|Adds the current file system directory to the Path environment variable for the current PowerShell session.<br><br>For example, adding the Windows Debugging Tools directory to the path for this PowerShell session:<br><br>`pushd 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64'`<br>`AddCurrDirToPath`<br>`popd`<br>`# Now windbg.exe is in the Path...`|
|**DownloadAaronLockerV2.ps1**|Download the latest AaronLockerV2 tools to "C:\Program Files\AaronLockerV2" and ensure that directory is in the Path.<br>Requires administrative rights.|
|**DownloadSCTTools.ps1**|Download Microsoft Security Compliance Toolkit tools to "C:\Program Files\SCT" and ensure that directory is in the Path.<br>Requires administrative rights.|
|**DownloadSysinternals.ps1**|Download the latest Sysinternals tools to "C:\Program Files\Sysinternals" and ensure that directory is in the Path.<br>Requires administrative rights.|
|**DownloadSysNocturnals.ps1**|Download the latest SysNocturnals tools to "C:\Program Files\SysNocturnals" and ensure that directory is in the Path.<br>Requires administrative rights.|
|**IsAdmin.ps1**|Outputs a [System.Boolean] to indicate whether the current PowerShell session is executing with administrative rights.|
|**ise.ps1**|Start Windows PowerShell ISE with zero or more files.<br><br>"Fixes" the problem where PowerShell ISE requires multiple files to be comma-separated and doesn't process wildcards.<br>Mostly intended for use with PowerShell 7 (where "ise" is not already an alias) and when VS Code is not installed.<br>Can also be used with Windows PowerShell to replace the "ise" alias (you might want to rename this script).<br><br>For example, starting PowerShell ISE and opening all the d*.ps1 and t*.ps1 files in the current directory:<br><br>`ise.ps1 d*.ps1 t*.ps1`|
|**List-Archive.ps1**|Output a listing of the contents of a zip file without extracting any files.|
|**title.ps1**|Set the title of the current console (or Terminal tab) to the input text, prepended with "Admin:" if appropriate.|
|**titlecd.ps1**|Set the title of the current console (or Terminal tab) to the current path, prepended with "Admin:" if appropriate, and trimmed so that taskbar preview doesn't truncate the end of the path.|
|**titleuser.ps1**|Set the title of the current console (or Terminal tab) to the current username, prepended with "Admin:" if appropriate|
|**touch.ps1**|Equivalent to *nix "touch" command: creates a new empty file, or updates the LastWriteTime of an existing file.|


