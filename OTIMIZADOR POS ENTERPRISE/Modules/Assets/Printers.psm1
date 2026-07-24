#=========================================================
# Printers.psm1
#=========================================================

function Get-PrinterInventory {

    $Printers = Get-Printer -ErrorAction SilentlyContinue

    foreach ($Printer in $Printers) {

        [PSCustomObject]@{
            Name = "Printers"

            Data = [PSCustomObject]@{

                Name    = $Printer.Name

                Driver  = $Printer.DriverName

                Port    = $Printer.PortName

                Default = $Printer.Default
            }
        }

    }

}

Export-ModuleMember -Function *