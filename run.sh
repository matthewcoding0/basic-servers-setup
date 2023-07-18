#!/bin/bash

read -p "Enter domain name: " domain
read -p "Enter email: " email
read -p "Enter name: " name

# Install Cyberpanel
sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh)
# Options: 1, 1, Y, n, Enter, s, <Password>, n, n, Y
# Note that this requires restarting the server
cyberpanel createWebsite --package Default --owner admin --domainName $domain --email $email --php 7.4 --dkim 1

# Ask again since the server has restarted
read -p "Enter domain name: " domain
read -p "Enter email: " email
read -p "Enter name: " name


# Name servers
echo "Go to domain hosting provider and choose to use custom DNS server settings"
echo "Add two name servers - ns1.<domain> and ns2.<domain>"
read -p "Press enter to continue"

echo "Navigate to the ip address at port 8090"
echo "Sign in with user: admin and same password as used in installation"
echo "Navigate to DNS > Create Nameserver"
echo "Fill in fields with $domain, ns1.$domain, ns2.$domain, and the public IP address"

# Mail server ssl
cyberpanel mailServerSSL --domainName $domain

# Set up reverse DNS (PTR record)
echo "Set up reverse DNS (PTR record)."
echo "On Linode go to Network tab, click 'Edit RDNS' and replace with <domain>"
read -p "Press enter to continue"

read -p "Enter the server's public IPv6 address: " ipv6

# Set up AAAA record
cyberpanel createDNSRecord --domainName $domain --name $domain --recordType AAAA --value $ipv6 --priority 0 --ttl 3600

read -s -p "Enter the new email account password: " password
cyberpanel createEmail --domainName $domain --userName $name --password $password

# Create a database for Wordpress
cyberpanel createDatabase --databaseWebsite $domain --dbName wordpress --dbUsername username --dbPassword password

# Set up Wordpress
cd /home/$domain/public_html/
rm index.html
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
mv wordpress/* ./
rm -rf wordpress latest.tar.gz

echo "All done! Navigate to $domain:8090/snappymail/index.php to sign into your new email"
echo "To set up WordPress, navigate to $domain and log in. Use wordpress, username, password, localhost, and wp_"