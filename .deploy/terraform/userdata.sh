#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io

sudo usermod -a -G docker ubuntu

sudo systemctl start docker
sudo systemctl enable docker
sudo docker pull fclebinho/jib-example:2024.5.27.19.45.9
sudo docker run -d -p 80:8080 fclebinho/jib-example:2024.5.27.19.45.9