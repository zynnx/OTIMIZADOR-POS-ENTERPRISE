function Get-PowerPlanStatus {
    [PSCustomObject]@{ Name = 'Power Plan'; Status = 'Available'; OptimizeFunction = 'Invoke-PowerPlanOptimization' }
}
function Invoke-PowerPlanOptimization {
    # Do not create a duplicate Balanced plan and label it High Performance.
    & powercfg.exe /setactive '8c5e7fda-e8f1-4140-ba8b-d5943ac5b513' | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'High Performance is unavailable on this device; existing plan retained.' }
    New-OperationResult 'Power Plan' Success -Changed 1
}
Export-ModuleMember -Function Get-PowerPlanStatus, Invoke-PowerPlanOptimization
