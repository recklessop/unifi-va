$vm_ip = $ENV:vm_ip

ssh -i .ssh\id_rsa.pub unifi@$vm_ip "sudo apt update; sudo apt upgrade -y; git clone https://github.com/recklessop/unifi-va.git; cd unifi-va;"

Write-Output $vm_ip