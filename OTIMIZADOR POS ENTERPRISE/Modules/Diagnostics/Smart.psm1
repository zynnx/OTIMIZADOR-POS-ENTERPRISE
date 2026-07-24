#=========================================================
# Smart.psm1
# SMART Disk Diagnostic
#=========================================================

function Get-SmartDiagnostic {

    return [PSCustomObject]@{

        Name = "SMART"

        DiagnosticFunction = "Invoke-SmartDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-SmartDiagnostic {

    try {

        $Status = Get-CimInstance `
            -Namespace root\wmi `
            -ClassName MSStorageDriver_FailurePredictStatus `
            -ErrorAction Stop

        if($Status){

            $PredictFailure = $Status | Where-Object {$_.PredictFailure -eq $true}

            if($PredictFailure){

                return [PSCustomObject]@{

                    Name = "SMART"

                    Status = "CRITICAL"

                    Score = 20

                    Details = "Disk indicates possible failure."

                    Recommendation = "Replace the disk as soon as possible."

                }

            }
            else{

                return [PSCustomObject]@{

                    Name = "SMART"

                    Status = "OK"

                    Score = 100

                    Details = "No SMART failure predicted."

                    Recommendation = ""

                }

            }

        }

        return [PSCustomObject]@{

            Name = "SMART"

            Status = "UNKNOWN"

            Score = 80

            Details = "Unable to obtain SMART information."

            Recommendation = ""

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "SMART"

            Status = "NOT SUPPORTED"

            Score = 80

            Details = "Hardware or controller does not provide SMART."

            Recommendation = ""

        }

    }

}

Export-ModuleMember -Function *