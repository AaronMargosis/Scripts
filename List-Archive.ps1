<#
.SYNOPSIS
Output a listing of the contents of a zip file without extracting any files.

.PARAMETER zipPath
The relative or absolute path to the zip file.

.PARAMETER Directory
List only directory names, not files.

.PARAMETER File
List only file names, not directory names.

.PARAMETER DontFilterArchiveAttr
By default, "Archive" attribute filtered out. This switch removes that filtering.

.PARAMETER RawAttributes
Output Attributes as a hexadecimal number rather than with names

.NOTES
Another SysNocturnals script by Aaron Margosis.

.LINK
https://github.com/AaronMargosis/Aaron-Margosis-SysNocturnals-Tools
#>

[CmdletBinding(DefaultParameterSetName="__AllParameterSets")]
param(
    [string]
    [parameter(Mandatory, Position=0)]
    $zipPath,

    [switch]
    [parameter(ParameterSetName="DirectoriesOnly")]
    $Directory,

    [switch]
    [parameter(ParameterSetName="FilesOnly")]
    $File,

    [switch]
    $DontFilterArchiveAttr,

    [switch]
    $RawAttributes
    )

Add-Type -AssemblyName System.IO.Compression.FileSystem

# Documentation for ZipFile::OpenRead says path can be absolute or relative, but that seems to be wrong, so get the absolute path.
$fullpath = (Get-Item -LiteralPath $zipPath).FullName

# Open the archive file
$zip = [System.IO.Compression.ZipFile]::OpenRead($fullpath)

if ($null -eq $zip)
{
    exit
}


# Define names for non-Windows file system attributes
# Shift everything left 16 bits for file attributes in zip files
[Flags()]
enum NixFileSystemAttributes {
    S_IFMT     = 0xF000 -shl 16  # File type mask
    S_IFSOCK   = 0xC000 -shl 16  # Socket
    S_IFLNK    = 0xA000 -shl 16  # Symbolic link
    S_IFREG    = 0x8000 -shl 16  # Regular file
    S_IFBLK    = 0x6000 -shl 16  # Block device
    S_IFDIR    = 0x4000 -shl 16  # Directory
    S_IFCHR    = 0x2000 -shl 16  # Character device
    S_IFIFO    = 0x1000 -shl 16  # FIFO

    S_ISUID    = 0x0800 -shl 16  # Set user ID on execution
    S_ISGID    = 0x0400 -shl 16  # Set group ID on execution
    S_ISVTX    = 0x0200 -shl 16  # Save swapped text after use (sticky)

    S_IRWXU    = 0x01C0 -shl 16  # rwx by owner/user
    S_IRUSR    = 0x0100 -shl 16  # Read by owner/user
    S_IWUSR    = 0x0080 -shl 16  # Write by owner/user
    S_IXUSR    = 0x0040 -shl 16  # Execute by owner/user

    S_IRWXG    = 0x0038 -shl 16  # rwx by group
    S_IRGRP    = 0x0020 -shl 16  # Read by group
    S_IWGRP    = 0x0010 -shl 16  # Write by group
    S_IXGRP    = 0x0008 -shl 16  # Execute by group

    S_IRWXO    = 0x0007 -shl 16  # rwx by other
    S_IROTH    = 0x0004 -shl 16  # Read by other
    S_IWOTH    = 0x0002 -shl 16  # Write by other
    S_IXOTH    = 0x0001 -shl 16  # Execute by other
}

Set-Variable -Name NixFsFlags -Value 0xFFFF0000 -Option Constant

function HasNixFsFlags([int] $fsBits)
{
    ($fsBits -band $NixFsFlags) -ne 0
}

function NixFSAttrCharToAppend([int] $fsBits, [int] $flag, [string] $chrIfFlag)
{
    if ($flag -eq ($fsBits -band $flag)) { Write-Output $chrIfFlag } else { Write-Output "-" }
}

$attribsToChars = @(
    @{ f = [NixFileSystemAttributes]::S_IFDIR; c = "d" },

    @{ f = [NixFileSystemAttributes]::S_IRUSR; c = "r" },
    @{ f = [NixFileSystemAttributes]::S_IWUSR; c = "w" },
    @{ f = [NixFileSystemAttributes]::S_IXUSR; c = "x" },

    @{ f = [NixFileSystemAttributes]::S_IRGRP; c = "r" },
    @{ f = [NixFileSystemAttributes]::S_IWGRP; c = "w" },
    @{ f = [NixFileSystemAttributes]::S_IXGRP; c = "x" },

    @{ f = [NixFileSystemAttributes]::S_IROTH; c = "r" },
    @{ f = [NixFileSystemAttributes]::S_IWOTH; c = "w" },
    @{ f = [NixFileSystemAttributes]::S_IXOTH; c = "x" }
)

function TranslateNixFSBits([int] $fsBits)
{
    [System.Text.StringBuilder] $sOutput = ""
    $attribsToChars | ForEach-Object {
        [void]$sOutput.Append((NixFSAttrCharToAppend -fsBits $fsBits -flag $_.f -chrIfFlag $_.c))
    }
    Write-Output $sOutput.ToString()
}

# Had expected file-system flags to indicate whether something is a directory or not, but sometimes all the ExternalAttributes are 0.
# The "Name" property always appears to be empty for a directory, and populated for files.
if ($Directory)
{
    $entriesOfInterest = $zip.Entries | Where-Object { $_.Name.Length -eq 0 }
    #$entriesOfInterest = $zip.Entries | Where-Object { 0 -ne ($_.ExternalAttributes -band ([System.IO.FileAttributes]::Directory.value__ -bor [NixFileSystemAttributes]::S_IFDIR.value__)) }
}
elseif ($File)
{
    $entriesOfInterest = $zip.Entries | Where-Object { $_.Name.Length -ne 0 }
    #$entriesOfInterest = $zip.Entries | Where-Object { 0 -eq ($_.ExternalAttributes -band ([System.IO.FileAttributes]::Directory.value__ -bor [NixFileSystemAttributes]::S_IFDIR.value__)) }
}
else
{
    $entriesOfInterest = $zip.Entries
}


function AttributesText(
    [int] $externalAttributes,
    [bool] $raw,
    [bool] $inclArchive)
{
    if ($raw)
    {
        Write-Output $externalAttributes.ToString("X8")
    }
    else
    {
        if (HasNixFsFlags $externalAttributes)
        {
            TranslateNixFSBits -fsBits $externalAttributes
        }
        else
        {
            # By default, remove noisy "Archive" [0x20]; if that's the only attribute, blank it out (result is "0" otherwise).
            # Filter just the lower bits
            if (-not $inclArchive)
            { 
                $externalAttributes = $externalAttributes -band 0x3FFDF 
            }
            if (0 -ne $externalAttributes)
            {
                Write-Output ([System.IO.FileAttributes]$externalAttributes)
            }
            else
            {
                Write-Output ""
            }
        }
    }
}

$entriesOfInterest | Select-Object @{Label="Attributes"; Expression={ (AttributesText -externalAttributes $_.ExternalAttributes -raw $RawAttributes -inclArchive $DontFilterArchiveAttr) }},
    @{Label="LastWriteTime (UTC)"; Expression={$_.LastWriteTime.UtcDateTime.ToString("yyyy-MM-dd HH:mm:ss")}},
    Length,
    @{Label="Filename"; Expression={$_.Name}},
    FullName,
    @{Label="Extension"; Expression={$ix=$_.Name.LastIndexOf("."); if ($ix -gt 0) {$_.Name.Substring($ix)} else {""}}}

$zip.Dispose()
