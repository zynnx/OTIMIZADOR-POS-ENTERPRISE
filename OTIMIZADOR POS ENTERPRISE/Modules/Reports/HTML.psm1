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

/*=========================================================
Enterprise Dashboard
=========================================================*/

.dashboard-grid{


display:grid;
grid-template-columns:repeat(4,1fr);
gap:18px;
margin:20px 0 30px 0;


}

.dashboard-card{


border:1px solid var(--border);
border-radius:12px;
padding:20px;
background:white;
box-shadow:0 3px 10px rgba(0,0,0,.05);


}

.dashboard-card-title{


color:#666;
font-size:13px;
font-weight:600;
text-transform:uppercase;
margin-bottom:8px;


}

.dashboard-card-value{


font-size:26px;
font-weight:700;


}

.dashboard-card.ok{


border-top:5px solid var(--success);


}

.dashboard-card.warn{


border-top:5px solid var(--warning);


}

.dashboard-card.error{


border-top:5px solid var(--danger);


}

.dashboard-card.info{


border-top:5px solid var(--primary);


}

@media(max-width:1200px){

    .container{

        margin:20px;

    }

    .dashboard-grid{

        grid-template-columns:repeat(2,1fr);

    }

}

@media(max-width:700px){

    body{

        margin:10px;

    }

    .container{

        margin:0;
        padding:18px;
        border-radius:8px;

    }

    h1{

        font-size:26px;

    }

    .dashboard-grid{

        grid-template-columns:1fr;

    }

    table{

        font-size:13px;

    }

    td,th{

        padding:6px;

    }

}
}

/*=========================================================
Diagnostic Score Bar
=========================================================*/
.score-bar{

    width:100%;
    height:14px;
    background:#e5e7eb;
    border-radius:10px;
    overflow:hidden;
    margin-top:12px;

}

.score-bar-fill{

    height:100%;
    border-radius:10px;
    transition:width .3s ease;

}

.score-ok{

    background:var(--success);

}

.score-good{

    background:#66bb6a;

}

.score-warning{

    background:var(--warning);

}

.score-critical{

    background:var(--danger);

}

.score-label{

    margin-top:6px;
    font-size:12px;
    color:#666;

}

.table-wrapper{

    width:100%;
    overflow-x:auto;

}

.dashboard-system-info{

    display:grid;
    grid-template-columns:repeat(4,1fr);
    gap:12px;
    margin:0 0 25px 0;

}

.dashboard-system-info > div{

    background:var(--light);
    border:1px solid var(--border);
    border-radius:8px;
    padding:12px 15px;

}

.dashboard-system-info strong{

    display:block;
    font-size:11px;
    color:#666;
    text-transform:uppercase;
    margin-bottom:4px;

}

.dashboard-system-info span{

    display:block;
    font-size:14px;
    font-weight:600;
    word-break:break-word;

}

@media(max-width:1000px){

    .dashboard-system-info{

        grid-template-columns:repeat(2,1fr);

    }

}

@media(max-width:600px){

    .dashboard-system-info{

        grid-template-columns:1fr;

    }

}
    .report-meta{

    display:flex;
    gap:12px;
    margin:15px 0 20px 0;

}

.report-meta > div{

    background:var(--light);
    border:1px solid var(--border);
    border-radius:8px;
    padding:10px 15px;

}

.report-meta strong{

    display:block;
    font-size:11px;
    color:#666;
    text-transform:uppercase;
    margin-bottom:3px;

}

.report-meta span{

    font-size:13px;
    font-weight:600;

}

@media(max-width:600px){

    .report-meta{

        flex-direction:column;

    }

}

</style>

</head>

<body>

<div class="container">

<h1>OTIMIZADOR POS ENTERPRISE</h1>

<div class="subtitle">Enterprise Maintenance Report</div>

<div class="report-meta">

    <div>
        <strong>Generated</strong>
        <span>$(Get-Date -Format "dd/MM/yyyy HH:mm:ss")</span>
    </div>

    <div>
        <strong>Optimizer Version</strong>
        <span>v$($Global:App.Version)</span>
    </div>

</div>


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

