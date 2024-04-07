#!/bin/bash

# Installing Docker
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER
newgrp docker

# Installing Minikube
sudo apt install -y curl wget apt-transport-https
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo cp minikube-linux-amd64 /usr/local/bin/minikube
sudo chmod +x /usr/local/bin/minikube
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
minikube start --driver=docker
kubectl version
minikube dashboard –url

# Creating Docker images
git clone https://github.com/arthurescriou/redis-node
git clone https://github.com/arthurescriou/redis-react

# Building Docker image for redis-node
cd redis-node
nano Dockerfile
docker build -t redis-node .

# Building Docker image for redis-react
cd ../redis-react
nano Dockerfile
docker build -t redis-react .

# Listing Docker images
docker images


# Pushing Docker images to Docker Hub
docker tag redis-node:latest Katline/redis-node:latest
docker push Katline/redis-node:latest
docker tag redis-react:latest Katline/redis-react:latest
docker push Katline/redis-react:latest

# Applying Kubernetes deployments
kubectl apply -f redis-deployment.yaml
kubectl apply -f nodejs-deployment.yaml
kubectl apply -f reactjs-deployment.yaml
kubectl get deployment

# Configuring autoscaling
kubectl autoscale deployment redis-app --cpu-percent=50 --min=1 --max=10
kubectl autoscale deployment react-app --cpu-percent=50 --min=1 --max=10
kubectl autoscale deployment nodejs-app --cpu-percent=50 --min=1 --max=10

# Deploying Prometheus
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f prometheus-service.yaml
kubectl apply -f config-map.yaml
kubectl apply -f clusterRole.yaml
kubectl get deploy -n monitoring
kubectl get pod -n monitoring


# Deploying Grafana
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deploy -n monitoring
kubectl get pod -n monitoring
