function Get-OptimizationItems {
    return @(Get-ModuleItems -SubFolder 'Optimization' -FunctionPattern 'Get-*Status')
}
function Start-Optimization {
    [CmdletBinding(SupportsShouldProcess)]
    param([string[]]$Only)
    Invoke-MaintenanceCategory -Category 'Optimization' -Only $Only -WhatIf:$WhatIfPreference
}
Export-ModuleMember -Function Get-OptimizationItems, Start-Optimization
