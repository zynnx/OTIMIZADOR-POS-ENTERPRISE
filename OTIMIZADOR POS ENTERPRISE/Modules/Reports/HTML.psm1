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

.container{

    background:white;
    border-radius:8px;
    padding:25px;

}

h1{

    color:#005a9e;

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

</style>

</head>

<body>

<div class="container">

<h1>OTIMIZADOR POS ENTERPRISE</h1>

<p>Report generated on: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")</p>

<hr>

"@

}

#---------------------------------------------------------

function Get-HTMLFooter {

@"

<hr>

<div class="footer">

OTIMIZADOR POS ENTERPRISE v$($Global:App.Version)

</div>

</div>

</body>

</html>

"@

}

Export-ModuleMember -Function *

