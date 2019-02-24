Write-Host ' '                                                                                       
Write-Host '                                 ,/////////////////,'
Write-Host '                               .(((((((((((((((((((('
Write-Host '                              *((((((((((((((((((((('
Write-Host '                             /((((((((/****/(((((((('
Write-Host '                           .((((((((/,,,,,,,,/(((((('
Write-Host '           .**************/(((((((((,,,,,,,,,,(((((('
Write-Host '           ##############(((((((((((,,,,,,,,,,(((((('
Write-Host '           #############(((((((((((((*,,,,,,*((((((('
Write-Host '           ###########((((((((((((((((((//(((((((((('
Write-Host '           ##########((((((((((///(((((((((((((((((('
Write-Host '           #########(((((((((/////(((((((((((((((/.'
Write-Host '           .#######(((((((#/////((((((((((((((/.'
Write-Host '             ,####((((((#/////(#((((((((((((.'
Write-Host '               ,##..((#(////(#(((((((((((#'
Write-Host '                     *////(###(((((((##%##'
Write-Host '                    ****(##(((((((##%%%###'
Write-Host '           ***       ..  .(((((#%%%%%#####'
Write-Host '           ***           *%%#%%%%%%%%%%%##'
Write-Host '           ***           ,#%%%%%%%%%%%%%%#'
Write-Host '           ****,,,,,,      ,#%%%%%%%%%%%%#'
Write-Host '           **********        ,#%%%%%%%%%%/'

Set-PowerCLIConfiguration -invalidcertificateaction "ignore" -confirm:$false |out-null
Set-PowerCLIConfiguration -Scope Session -WebOperationTimeoutSeconds -1 -confirm:$false |out-null   
$logfolder = "C:\agent\logs"
$logfile = $logfolder + '\' + (Get-Date -Format o |ForEach-Object {$_ -Replace ':', '-'}) + "-build-log.txt"
write-host "Script result log can be found at $logfile" -ForegroundColor Green

if ( !(Get-Module -ListAvailable -Name VMware.PowerCLI -ErrorAction SilentlyContinue) ) {
    write-host ("VMware PowerCLI PowerShell module not found. Please verify installation and retry.") -BackgroundColor Red
    write-host "Terminating Script" -BackgroundColor Red
    add-content $logfile ("VMware PowerCLI PowerShell module not found. Please verify installation and retry.")
    add-content $logfile "Terminating Script" 
    return
}

try {
    Import-Module VMware.PowerCLI | Add-Content $logfile
}
Catch {
    $_ | Add-Content $logfile
}

#Connect to vCenter server
try {
    Connect-VIserver -Server 192.168.254.20 -User "administrator@vsphere.local" -Password "Nasadmin123#"
}
Catch {
    $_ | Add-Content $logfile
    write-host "Unable to Connect to VMware vCenter Server"
    $_ | Write-Host
    return
}

# Clonee Ubuntu 18.04 LTS template named 'ubuntu-18.04-lts'
$myDatastore = Get-Datastore -Name "VNX5300-SAS"
$myCluster = Get-Cluster -Name "New Cluster"
$myTemplate = Get-Template -Name ubuntu-18.04-lts
$mySpec = Get-OSCustomizationSpec -Name "unifi"
$buildNumber = $Env:Build.BuildNumber
Write-Host "DevOps Build number: $buildNumber"
$vmname = "unifi-devops-build-$buildNumber" 
try{
    New-VM -Name $vmname -Template $myTemplate -OSCustomizationSpec $mySpec -Datastore $myDatastore -resourcepool $myCluster -HardwareVersion 4
}
Catch {
    $_ | Add-Content $logfile
    write-host "Unable to Clone Template"
    $_ | Write-Host
}


add-content $logfile ("Disconnecting vCenter session. Script Complete")