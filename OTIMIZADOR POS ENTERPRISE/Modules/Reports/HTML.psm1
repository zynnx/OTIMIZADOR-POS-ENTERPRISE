#=========================================================
# HTML.psm1
# Base HTML report structure
#=========================================================

function Get-HTMLHeader {

    @"
<!DOCTYPE html>
<html lang="pt">

<head>

<meta charset="utf-8">

<title>OTIMIZADOR POS ENTERPRISE</title>

<style>

body{

    font-family:Segoe UI,Arial;
    background:#f4f4f4;
    margin:30px;

}
:root{

    --primary:#005a9e;
    --success:#2e7d32;
    --warning:#f9a825;
    --danger:#c62828;
    --light:#f5f7fa;
    --border:#d9dee5;

}
.container{

    max-width:1400px;
    margin:auto;
    background:white;
    border-radius:12px;
    padding:30px;
    box-shadow:0 8px 25px rgba(0,0,0,.08);

}

h1{

    margin:0;
    color:var(--primary);
    font-size:34px;

}

.subtitle{

    color:#666;
    margin-bottom:25px;

}

h2{

    border-bottom:1px solid #ddd;
    padding-bottom:5px;

}

table{

    width:100%;
    border-collapse:collapse;

}

td,th{

    border:1px solid #ddd;
    padding:8px;

}

th{

    background:#efefef;

}

.ok{

    color:green;
    font-weight:bold;

}

.warn{

    color:orange;
    font-weight:bold;

}

.error{

    color:red;
    font-weight:bold;

}

.footer{

    margin-top:40px;
    color:#777;
    font-size:12px;

}

    .separator{

    height:2px;
    background:#ececec;
    margin:25px 0;

}
/*---------------------------------------------------------
  Dashboard Cards
---------------------------------------------------------*/

.dashboard{

    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
    gap:16px;
    margin:25px 0;

}

.card{

    background:var(--light);
    border:1px solid var(--border);
    border-radius:10px;
    padding:18px;

}

.card-title{

    font-size:12px;
    color:#666;
    text-transform:uppercase;
    letter-spacing:.5px;
    margin-bottom:8px;

}

.card-value{

    font-size:20px;
    font-weight:600;
    color:#222;

}
.card.ok{
    border-left:5px solid var(--success);
}

.card.warn{
    border-left:5px solid var(--warning);
}

.card.error{
    border-left:5px solid var(--danger);
}

.system-status{

    padding:20px;
    margin:20px 0 25px 0;
    border-radius:10px;
    border:1px solid var(--border);
    background:var(--light);

}

.system-status.ok{

    border-left:6px solid var(--success);

}

.system-status.warn{

    border-left:6px solid var(--warning);

}

.system-status.error{

    border-left:6px solid var(--danger);

}

.status-value{

    font-size:28px;
    font-weight:700;
    margin-top:5px;

}

</style>

</head>

<body>

<div class="container">

<h1>OTIMIZADOR POS ENTERPRISE</h1>

<div class="subtitle"> Enterprise Maintenance Report</div>

<p>Report generated on: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")</p>

<div class="separator"></div>

"@

}
#---------------------------------------------------------
# HTML Footer
#---------------------------------------------------------

function Get-HTMLFooter {

    @"

<div class="separator"></div>

<div class="footer">

OTIMIZADOR POS ENTERPRISE v$($Global:App.Version)

</div>

</div>

</body>

</html>

"@

}

Export-ModuleMember -Function *

