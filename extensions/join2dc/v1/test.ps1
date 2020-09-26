$DomainName  = 'k8swin.com'
$DomainUserName = 'k8swin\sqllinux'
$DomainPassword = 'password@123'
$DCIP = '10.240.0.159'

function ChangeDNS() {
    Write-Host "Changing DNS..."
    Try {
        if ($null -eq $DCIP) {
		    Write-Host "No valid $DCIP"
            return $false
        }
        Write-Host "Changing DNS to $DCIP"
        $Adapter = Get-NetAdapter | Where-Object {$_.Name -like "Ethernet 2"}
        Set-DnsClientServerAddress -InterfaceIndex ($Adapter).ifIndex -ServerAddresses $DCIP
        return $true
    } catch {
        return $false
    }
}

function JoinDomain() {
    Write-Host "Join to domain..."
    $joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
        UserName = $DomainUserName
        Password = (ConvertTo-SecureString -String ($DomainPassword -replace "`n|`r") -AsPlainText -Force)[0]
    })
    Try {
        Add-Computer -Domain $DomainName -Credential $joinCred
		Start-Sleep 10
        return $true
    } catch {
	    Write-Warning Error[0]
		Write-Error $_
        Start-Sleep 10
        return $false
    }

}

function GetSqlVersion() {
    Write-Host "GetSqlVersion.."
    Try {
            $creds = New-Object pscredential -ArgumentList ([pscustomobject]@{
                UserName = "$env:COMPUTERNAME\sqladmin"
                Password = (ConvertTo-SecureString -String ('password@123' -replace "`n|`r") -AsPlainText -Force)[0]
            })
            #Enable-PSRemoting –force
            #Submit the job with creds
            $job = Start-Job {importsystemmodules; Invoke-Sqlcmd -Query 'select @@version'} -Credential $creds | Get-Job | Wait-Job

            #Receive the job
            $jobInfo = Receive-Job -Job $job
            echo $jobInfo
            #Disable-PSRemoting -Force
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
            #Enable-PSRemoting –force
            #Submit the job with creds
            $job = Start-Job {importsystemmodules; Invoke-Sqlcmd -Query "EXEC sp_addsrvrolemember '$DomainUserName', 'sysadmin'" } -Credential $creds | Get-Job | Wait-Job

            #Receive the job
            $jobInfo = Receive-Job -Job $job
            echo $jobInfo
            #Disable-PSRemoting -Force
            return $true
    } catch {
             Write-Warning Error[0]
             Write-Error $_
      return $false
   }
}
ChangeDNS
JoinDomain
GetSqlVersion
AddDomainUserAsSqlSysadmin1

