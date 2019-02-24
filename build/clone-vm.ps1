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
    # connect to vi server using username and password from azure pipelines
    Connect-VIserver -Server 192.168.254.20 -User $Env:viuser -Password $ENv:vipass
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
$vmname = $Env:buildnumber
Write-Host "clone name: $vmname"

try{
    New-VM -Name $vmname -Template $myTemplate -OSCustomizationSpec $mySpec -Datastore $myDatastore -resourcepool $myCluster
}
Catch {
    $_ | Add-Content $logfile
    write-host "Unable to Clone Template"
    $_ | Write-Host
}

Start-VM -VM $vmname -confirm:$false

$VMInfo = Get-VM | Select-Object Name, @{N="IP Address";E={@($_.guest.IPAddress[0])}}

$VMinfo.GetType()

add-content $logfile ("Disconnecting vCenter session. Script Complete")
