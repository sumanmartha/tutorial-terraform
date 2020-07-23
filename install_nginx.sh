#! /bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h1>Deployed via Terraform</h1>" | tee /var/www/html/index.html