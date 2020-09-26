$DomainUserName = 'k8swin\sqllinux'

function GetSqlVersion() {
    Write-Host "Add domain user as as sql sysadmin.."
    Try {
            $creds = New-Object pscredential -ArgumentList ([pscustomobject]@{
                UserName = 'sqladmin'
                Password = (ConvertTo-SecureString -String ('password@123' -replace "`n|`r") -AsPlainText -Force)[0]
            })
            #Submit the job with creds
            $job = Start-Job {importsystemmodules; Invoke-Sqlcmd -Query 'select @@version'} -Credential $creds | Get-Job | Wait-Job

            #Receive the job
            $jobInfo = Receive-Job -Job $job
            echo $jobInfo
            return $true
    } catch {
             $user = whoami
             Write-Host 'user: ' $user 
             Write-Warning Error[0]
             Write-Error "$_  user: $user  ##"
      return $false
   }
}

function AddDomainUserAsSqlSysadmin1() {
    Write-Host "Add domain user as as sql sysadmin."
    Try {
            $creds = New-Object pscredential -ArgumentList ([pscustomobject]@{
                UserName = 'sqladmin'
                Password = (ConvertTo-SecureString -String ('password@123' -replace "`n|`r") -AsPlainText -Force)[0]
            })
            #Submit the job with creds
            $job = Start-Job {importsystemmodules; Invoke-Sqlcmd -Query "EXEC sp_addsrvrolemember '$DomainUserName', 'sysadmin'" } -Credential $creds | Get-Job | Wait-Job

            #Receive the job
            $jobInfo = Receive-Job -Job $job
            echo $jobInfo
            return $true
    } catch {
             $user = whoami
             Write-Host 'user: ' $user 
             Write-Warning Error[0]
             Write-Error "$_  user: $user  ##"
      return $false
   }
}

GetSqlVersion
AddDomainUserAsSqlSysadmin1

