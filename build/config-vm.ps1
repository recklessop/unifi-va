$vm_ip = $ENV:vm_ip
Write-Output $vm_ip

ssh -i .ssh\id_rsa.pub unifi@$vm_ip "sudo apt update; sudo apt upgrade -y"
ssh -i .ssh\id_rsa.pub unifi@$vm_ip  "git clone https://github.com/recklessop/unifi-va.git; cd unifi-va; sudo bash /home/unifi/unifi-va/install.sh"
ssh -i .ssh\id_rsa.pub unifi@$vm_ip  "echo 'Zeroing out virtual disk'; dd if=/dev/zero of=temp.img bs=1M; rm temp.img"