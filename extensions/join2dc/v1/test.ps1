$DomainUserName = 'k8swin\sqllinux'

function GetSqlVersion() {
    Write-Host "GetSqlVersion.."
    Try {
            $creds = New-Object pscredential -ArgumentList ([pscustomobject]@{
                UserName = "$env:COMPUTERNAME\sqladmin"
                Password = (ConvertTo-SecureString -String ('password@123' -replace "`n|`r") -AsPlainText -Force)[0]
            })
            Enable-PSRemoting –force
            #Submit the job with creds
            $job = Start-Job {importsystemmodules; Invoke-Sqlcmd -Query 'select @@version'} -Credential $creds | Get-Job | Wait-Job

            #Receive the job
            $jobInfo = Receive-Job -Job $job
            echo $jobInfo
            Disable-PSRemoting -Force
            return $true
    } catch {
             Write-Warning Error[0]
             Write-Error $_
      return $false
   }
}

function AddDomainUserAsSqlSysadmin1() {
    Write-Host "Add AddDomainUserAsSqlSysadmin .."
    Try {
            $creds = New-Object pscredential -ArgumentList ([pscustomobject]@{
                UserName = "$env:COMPUTERNAME\sqladmin"
                Password = (ConvertTo-SecureString -String ('password@123' -replace "`n|`r") -AsPlainText -Force)[0]
            })
            Enable-PSRemoting –force
            #Submit the job with creds
            $job = Start-Job {importsystemmodules; Invoke-Sqlcmd -Query "EXEC sp_addsrvrolemember '$DomainUserName', 'sysadmin'" } -Credential $creds | Get-Job | Wait-Job

            #Receive the job
            $jobInfo = Receive-Job -Job $job
            echo $jobInfo
            Disable-PSRemoting -Force
            return $true
    } catch {
             Write-Warning Error[0]
             Write-Error $_
      return $false
   }
}

GetSqlVersion
AddDomainUserAsSqlSysadmin1

