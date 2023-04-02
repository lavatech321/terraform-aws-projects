#!/bin/bash
sudo yum install httpd -y
sudo touch /var/www/html/index.html
sudo echo "Welcome to terraform (auto-scaling)" >> /var/www/html/index.html 
sudo systemctl restart httpd
sudo systemctl enable httpd

