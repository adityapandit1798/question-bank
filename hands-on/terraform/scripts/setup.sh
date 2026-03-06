#!/bin/bash
set -euo pipefail

echo "=== EC2 Instance Setup ==="
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello from $(hostname)</h1>" | sudo tee /var/www/html/index.html
echo "=== Setup Complete ==="
