#=========================================================
# SystemSection.psm1
# System information report section
#=========================================================

function Get-SystemSection {

    $Info = Get-SystemInfo
    $DiskStatus = "ok"

    if ([double]$Info.DiskFree -lt 10) {

        $DiskStatus = "error"

    }
    elseif ([double]$Info.DiskFree -lt 20) {

        $DiskStatus = "warn"

    }
    #---------------------------------------------------------
    # Overall system status
    #---------------------------------------------------------

    $SystemStatus = "HEALTHY"

    if ($DiskStatus -eq "error") {

        $SystemStatus = "CRITICAL"

    }
    elseif ($DiskStatus -eq "warn") {

        $SystemStatus = "WARNING"

    }

    @"
    
<div class="system-status $DiskStatus">

    <div class="card-title">Overall System Status</div>

    <div class="status-value">$SystemStatus</div>

</div>

<h2>System Information</h2>

<div class="dashboard">

    <div class="card">
        <div class="card-title">Computer</div>
        <div class="card-value">$($Info.ComputerName)</div>
    </div>

    <div class="card">
        <div class="card-title">Windows</div>
        <div class="card-value">$($Info.Windows)</div>
    </div>

    <div class="card">
        <div class="card-title">CPU</div>
        <div class="card-value">$($Info.CPU)</div>
    </div>

    <div class="card">
        <div class="card-title">RAM</div>
        <div class="card-value">$($Info.RAM) GB</div>
    </div>

    <div class="card $DiskStatus">
        <div class="card-title">Free Disk</div>
        <div class="card-value">$($Info.DiskFree) GB</div>
    </div>

    <div class="card">
        <div class="card-title">Uptime</div>
        <div class="card-value">$($Info.Uptime)</div>
    </div>

</div>

<br>

"@

}

Export-ModuleMember -Function *