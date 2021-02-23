# Get-ModifiablePathFromProcmon

A simple PowerShell function parsing a [Procmon](https://docs.microsoft.com/en-us/sysinternals/downloads/procmon) CSV output to extract accessed filesystem and registry paths and using @itm4n's [PrivescCheck](https://github.com/itm4n/PrivescCheck/)'s functions `Get-ModifiablePath` and `Get-ModifiableRegistryPath` to find paths modifiable by the user.

This is useful to find if a program performs privileged operations on user-writable files/directories or registry paths (the flag `-IgnoreImpersonate` can be passed to prevent false positives).

## Usage

From a PowerShell prompt:

```
PS C:\Temp\> Set-ExecutionPolicy Bypass -Scope process -Force
PS C:\Temp\> Import-Module .\PrivescCheck.ps1
PS C:\Temp\> Import-Module .\Get-ModifiablePathFromProcmon.ps1
PS C:\Temp\> Get-ModifiablePathFromProcmon -CSVPath "C:\PathTo\Logfile.CSV" [-IgnoreImpersonate]
```
