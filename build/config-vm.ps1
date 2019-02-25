$vm_ip = $ENV:vm_ip
Write-Output $vm_ip

ssh -i .ssh\id_rsa.pub unifi@$vm_ip "sudo apt update; sudo apt upgrade -y"
ssh -i .ssh\id_rsa.pub unifi@$vm_ip  "git clone https://github.com/recklessop/unifi-va.git; cd unifi-va; sudo bash /home/unifi/unifi-va/install.sh"
