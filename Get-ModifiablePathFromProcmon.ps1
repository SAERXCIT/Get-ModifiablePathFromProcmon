#Requires -Version 2

function Get-ModifiablePathFromProcmon {
    <#
    .SYNOPSIS

    Parses Procmon CSV output and returns the file/registry paths where the current user has modification rights using PrivescCheck's Get-Modifiable*Path functions.

    Author: @SAERXCIT
    License: BSD 3-Clause

    .DESCRIPTION

    Creates a list of unique filesystem (by parsing `CreateFile` operations) and registry (by parsing `RegOpenKey` operations) paths accessed.
    Filesystem paths are fed to `Get-ModifiablePath`, registry paths are fed to `Get-ModifiableRegistryPath`.
    These two functions need to be imported from PrivescCheck prior to the execution of this function.
    Optionally, operations using impersonation can be filtered out.

    .PARAMETER CSVPath

    Path to the Procmon CSV output to parse. Required

    .PARAMETER IgnoreImpersonate

    Switch. Ignore operations using impersonation.

    .EXAMPLE

    PS C:\> Get-ModifiablePathFromProcmon -CSVPath "C:\PathTo\Logfile.CSV"

    Modifiable filesystem paths


    ModifiablePath    : C:\WritablePath
    IdentityReference : BUILTIN\Users
    Permissions       : {WriteAttributes, AppendData/AddSubdirectory, WriteExtendedAttributes, WriteData/AddFile}



    Modifiable registry paths


    ModifiablePath    : {Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock}
    IdentityReference : NT AUTHORITY\INTERACTIVE
    Permissions       : {ReadControl, AppendData/AddSubdirectory, WriteData/AddFile}



    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)] [String[]] $CSVPath,
        [Switch] $IgnoreImpersonate = $false
    )

    BEGIN {
        if (-not (Get-Command 'Get-ModifiablePath' -errorAction SilentlyContinue) -or -not (Get-Command 'Get-ModifiableRegistryPath' -errorAction SilentlyContinue)) {
            Write-Error "PrivescCheck functions not found. Please import Get-ModifiablePath and Get-ModifiableRegistryPath from PrivescCheck (https://github.com/itm4n/PrivescCheck)"
            break
        }
    }

    PROCESS {
        $CSVData = Import-Csv $CSVPath
        $ModifiableFSPaths = $CSVData | Where-Object { $_.Operation -eq "CreateFile" -and ((-not $IgnoreImpersonate) -or (-not $_.Detail.Contains("Impersonating:"))) } | Select-Object -Property Path -Unique | ForEach-Object {
            $_ | Get-ModifiablePath
        }
        $ModifiableRegPaths = $CSVData | Where-Object { $_.Operation -eq "RegOpenKey" -and ((-not $IgnoreImpersonate) -or (-not $_.Detail.Contains("Impersonating:"))) } | Select-Object -Property Path -Unique | ForEach-Object {
            "Registry::$($_.Path)" | Get-ModifiableRegistryPath
        }
    }

    END {
        Write-Host "Modifiable filesystem paths"
        $ModifiableFSPaths | Format-List
        Write-Host "Modifiable registry paths"
        $ModifiableRegPaths | Format-List
    }
}
