#!/bin/bash

#variabless
read -p 'Enter username: ' userName

SSHSetup() {
    mkdir ~/.ssh
    read -p 'Enter SSH public key: ' sshKey
    echo $sshKey > ~/.ssh/authorized_keys
    chmod 775 ~/.ssh
    chmod 644 ~/.ssh/authorized_keys
    chown $userName:$userName ~/.ssh -R
}

netplanSetup() {
    file=/etc/netplan/50-cloud-init.yaml
    if [ -f "$file" ]; then
        rm -r /etc/netplan/50-cloud-init.yaml
    fi
    {
        echo -e "network:"
        echo -e "  version: 2"
        echo -e "  renderer: networkd"
        echo -e "  ethernets:"
        echo -e "    enp0s3:"
        echo -e "      addresses: [192.168.1.250/24]"
        echo -e "      dhcp4: true"
        echo -e "      nameservers:"
        echo -e "        addresses: [1.1.1.1, 1.0.0.1]"
    } >/etc/netplan/netplan.yaml
    sudo netplan apply
}

nginxSetup() {
    sudo apt update
    sudo apt install nginx
    read -p 'Enter name for site: ' siteBlockName
    sudo mkdir -p /var/www/$siteBlockName/html
    sudo chown -R $userName:$userName /var/www/$siteBlockName/html
    sudo chmod -R 755 /var/www/$siteBlockName
    read -p 'Enter title for demo site: ' demoTitle
    {
        echo -e "<html>"
        echo -e "\t<body>"
        echo -e "\t\t<h4>"
        echo -e "\t\t\t$demoTitle"
        echo -e "\t\t</h4>"
        echo -e "\t</body>"
        echo -e "</html>"
    } >/var/www/$siteBlockName/html/index.html
    {
        echo -e "server {"
        echo -e "\tlisten 80;"
        echo -e "\tlisten [::]:80;"

        echo -e "\troot /var/www/$siteBlockName/html;"
        echo -e "\tindex index.html index.htm index.nginx-debian.html;"

        echo -e "\tserver_name $siteBlockName www.$siteBlockName;"

        echo -e "\tlocation / {"
        echo -e "\t\ttry_files \$uri \$uri/ =404;"
        echo -e "\t}"
        echo -e "}"
    } >/etc/nginx/sites-available/$siteBlockName
    sudo ln -s /etc/nginx/sites-available/$siteBlockName /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx
}

firewallSetup() {
    sudo ufw allow 'Nginx FULL'
    sudo ufw allow 'OpenSSH'
    sudo ufw enable
    service ssh restart
}

SSHSetup
netplanSetup
nginxSetup
firewallSetup

exit 0
