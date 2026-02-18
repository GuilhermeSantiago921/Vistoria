#!/bin/bash
rm -f /etc/apt/sources.list.d/mssql-release.list
rm -f /usr/share/keyrings/microsoft-prod.gpg
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/mssql-release.list
apt-get update
