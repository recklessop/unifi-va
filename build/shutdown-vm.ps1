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
$vmname = $Env:buildnumber

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
# connect to vi server using username and password from azure pipelines
Connect-VIserver -Server 192.168.254.20 -User $Env:viuser -Password $ENv:vipass

$vmname = $Env:buildnumber
Write-Host "clone name: $vmname"

Shutdown-VMGuest -VM $vmname -confirm:$false

do {
    start-sleep -Seconds 5
    $state = (Get-VM -Name $vmname).PowerState
} while ($state -ne "PoweredOff")