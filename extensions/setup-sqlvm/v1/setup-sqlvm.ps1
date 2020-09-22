
[CmdletBinding()]
param(
    #[Parameter(Mandatory=$true)]
    #[string]$subscriptionId,

    #[Parameter(Mandatory=$true)]
    #[string]$location,
	
	[Parameter(Mandatory=$true)]
    [string]$resourceGroup,

    [Parameter(Mandatory=$true)]
    [string]$virtualMachineName,
	
	[Parameter(Mandatory=$true)]
    [string]$virtualMachineSize,
	
	[Parameter(Mandatory=$true)]
    [string]$existingVirtualNetworkName,

    [Parameter(Mandatory=$true)]
    [string]$existingSubnetName,
	
	[Parameter(Mandatory=$true)]
    [string]$adminUsername,
	
	[Parameter(Mandatory=$true)]
    [string]$adminPassword,
	
	# AD settings 
	[Parameter(Mandatory=$true)]
    [string]$domainFQDN,
	
	[Parameter(Mandatory=$true)]
    [string]$domainIP,
	
	[Parameter(Mandatory=$true)]
    [string]$domainJoinUserName,
	
	[Parameter(Mandatory=$true)]
    [string]$domainJoinUserPassword,
	
	# gMSA Account
	[Parameter(Mandatory = $true)]
	[String]$AccountName

	#[Parameter(Mandatory = $false)]
	#[object[]]$AdditionalAccounts
)


# Write-Host "ApplicationId " $myApp
Write-Host "Creating SQL Server VM under resource-group " $resourceGroup
#Name of aks-engine api model template file. Include the .json extension in the filename
$parametersFileTempName = "default-parameters.json"

#Name of aks-engine api model file used for deployment
$parametersFileName = "parameters.json"

# Load template
$inJson = Get-Content $parametersFileTempName | ConvertFrom-Json


$inJson.parameters.virtualMachineName.value = $virtualMachineName
$inJson.parameters.virtualMachineSize.value = $virtualMachineSize

$inJson.parameters.existingVirtualNetworkName.value = $existingVirtualNetworkName
$inJson.parameters.existingSubnetName.value = $existingSubnetName


$inJson.parameters.adminUsername.value = $adminUsername
$inJson.parameters.adminPassword.value = $adminPassword


$inJson.parameters.domainFQDN.value = $domainFQDN
$inJson.parameters.domainIP.value = $domainIP

$inJson.parameters.domainJoinUserName.value = $domainJoinUserName
$inJson.parameters.domainJoinUserPassword.value = $domainJoinUserPassword

$inJson.parameters.AccountName.value = $AccountName
#$inJson.parameters.AdditionalAccounts.value = $AdditionalAccounts


# Save file
$inJson | ConvertTo-Json -Depth 5 | Out-File -Encoding ascii -FilePath $parametersFileName
# create AKS clster with AKS engine
az  deployment group  create --resource-group $resourceGroup --template-file .\template.json --parameters .\parameters.json