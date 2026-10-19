#=========================================================
# FileSystem.psm1
# File system helper functions
#=========================================================

function Test-Folder {

    param(
        [string]$Path
    )

    try {

        return (Test-Path $Path)

    }
    catch {

        return $false

    }

}

#---------------------------------------------------------

function Get-FolderSize {

    param(
        [string]$Path
    )

    if (!(Test-Folder $Path)) {
        return 0
    }

    try {

        $Size = (
            Get-ChildItem `
                -Path $Path `
                -Force `
                -Recurse `
                -File `
                -ErrorAction SilentlyContinue |
            Measure-Object Length -Sum
        ).Sum

        if ($null -eq $Size) {
            return 0
        }

        return [Int64]$Size

    }
    catch {

        return 0

    }

}

#---------------------------------------------------------

function Get-FilesCount {

    param(
        [string]$Path
    )

    if (!(Test-Folder $Path)) {
        return 0
    }

    try {

        return (
            Get-ChildItem `
                -Path $Path `
                -Force `
                -Recurse `
                -File `
                -ErrorAction SilentlyContinue
        ).Count

    }
    catch {

        return 0

    }

}

#---------------------------------------------------------

function Remove-FolderContent {
    param([Parameter(Mandatory)][string]$Path)
    Remove-CleanupContent -Path $Path
}
function Remove-FileSafe {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Force -ErrorAction Stop }
}
function Get-FreeSpace {

    param(
        [string]$Drive = "C"
    )

    try {

        $Disk = Get-CimInstance Win32_LogicalDisk |
                Where-Object DeviceID -eq "$Drive`:"

        return [Int64]$Disk.FreeSpace

    }
    catch {

        return 0

    }

}

#---------------------------------------------------------

function Get-UsedSpace {

    param(
        [string]$Drive = "C"
    )

    try {

        $Disk = Get-CimInstance Win32_LogicalDisk |
                Where-Object DeviceID -eq "$Drive`:"

        return [Int64]($Disk.Size - $Disk.FreeSpace)

    }
    catch {

        return 0

    }

}

#---------------------------------------------------------

function Get-DiskSize {

    param(
        [string]$Drive = "C"
    )

    try {

        $Disk = Get-CimInstance Win32_LogicalDisk |
                Where-Object DeviceID -eq "$Drive`:"

        return [Int64]$Disk.Size

    }
    catch {

        return 0

    }

}

#---------------------------------------------------------

Export-ModuleMember -Function *
