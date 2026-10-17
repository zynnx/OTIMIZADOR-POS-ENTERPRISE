function Get-CleaningItems {
    return @(Get-ModuleItems -SubFolder 'Cleaning' -FunctionPattern 'Get-*Analysis')
}
function Start-Cleaning {
    [CmdletBinding(SupportsShouldProcess)]
    param([string[]]$Only)
    Invoke-MaintenanceCategory -Category 'Cleaning' -Only $Only -WhatIf:$WhatIfPreference
}
Export-ModuleMember -Function Get-CleaningItems, Start-Cleaning
