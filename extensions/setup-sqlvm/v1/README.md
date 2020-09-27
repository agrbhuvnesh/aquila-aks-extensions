# Setup SQL Server VM
- Steps involved in script
 1. Install Azure VM
 2. Install SQL Server on VM
 3. Add VM to given Domain
 4. Update gMSA Account
 5. Add domain user as local admin
 6. Add domain user as sysadmin in sqlserver instance
 
powershell.exe setup-sqlvm.ps1 resource-group vm-name vm-type existing-vnet-name existing-vnet-subnet adminuser adminpwd  domain-fqdn 
                domain-ip domain-user domain-user-pwd gmsa-account
 
 
