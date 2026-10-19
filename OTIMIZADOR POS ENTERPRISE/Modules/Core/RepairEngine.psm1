function Get-RepairItems {
    return @(Get-ModuleItems -SubFolder 'Repair' -FunctionPattern 'Get-*Status')
}
function Start-Repair {
    [CmdletBinding(SupportsShouldProcess)]
    param([string[]]$Only)
    Invoke-MaintenanceCategory -Category 'Repair' -Only $Only -WhatIf:$WhatIfPreference
}
Export-ModuleMember -Function Get-RepairItems, Start-Repair
