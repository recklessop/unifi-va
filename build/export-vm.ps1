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

try {
    Import-Module VMware.PowerCLI | Out-Null
}
Catch {
    $_ | Out-Null
}

#Connect to vCenter server
# connect to vi server using username and password from azure pipelines
Connect-VIserver -Server 192.168.254.20 -User $Env:viuser -Password $ENv:vipass

$vmname = $Env:buildnumber
$ExportDir = $ENV:ExportDir
Write-Host "clone name: $vmname"

Get-VM -Name $vmname | Export-Vapp -Destination $ExportDir -Format Ova