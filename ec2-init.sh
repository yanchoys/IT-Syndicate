#!/bin/bash
sudo su
sudo yum update
sudo yum search docker
sudo yum install docker -y
sudo usermod -a -G docker ec2-user
id ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker.service
git clone https://github.com/benc-uk/nodejs-demoapp.git
docker run --rm -it -p 3000:3000 ghcr.io/benc-uk/nodejs-demoapp:latest