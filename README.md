# Elastic Kubernetes Service EKS 🐳

EKS is a fully managed service by AWS responsible for managing the Kubernetes Control plane within your Kubernetes cluster. The customer is responsible for the data plane

In kubernetes a pod is a smallest single deployable resource. A pod consist of one or containers, a local host, pod directories and persistent volumes. In Kubernetes every deployment, service, or configmap is based on a YAML❗️ configuration file. Its best practice to install health probes in your containers to help monitor container status. 

# AWS is responsible for

- Kubernetes API server
- Schedular
- Control Manager
- Control plane availability and scaling 

# Kubernetes Control Plane (scheduling)

- Kubernetes API
- Key/Value store
- Kube Schedular 
- authorization and authentication permission policies 

# Kubernetes Data Plane (execution) 

- Worker nodes
- kube proxy 
- networking paths
- pods and containers
- kubelet 

#! /bin/bash

# Secure Kubernetes endpoints in prod environment, keep your Kubernetes API server and control plane away from the internet
✅ Best practice

```bash 
endpoint_private_access = true
endpoint_public_access  = false
```
# For a dev environment: local host is outside of VPC

```bash 
endpoint_private_access = true
endpoint_public_access  = true 

public_access_cidrs = ["182.232.135.20/32"] 
```
Allow access for 1 Public IP address not ["0.0.0.0/0"] your attack surface will be wide open


# The following commands provision the VPC and EKS cluster in terraform 🛠️ 

```bash
cd terraform
terraform init 
terraform fmt -recursive
terraform validate
terraform apply
terraform destroy 
```
# Kubernetes CLI commands using kubectl for workload deployment and rollbacks 

```bash
cd kubernetes
kubectl get pods -A
kubectl get pods 
kubectl get pod <pod-name> -o yaml
kubectl get deploy
kubectl config view
kubectl describe deploy
kubectl rollout history undo deploy <deployment-name>
```

# EKS Worker Nodes need to be recreated in order to be registered with AWS Systems Manager when SSM permissions were created and modified 🔧

```bash 
aws eks update-nodegroup-version \
  --cluster-name eks-dev \
  --nodegroup-name eks-ng-default \
  --force
  ```

# Check Kubectl context to make sure its set

```bash
kubectl config current-context
```

# kubectl context isn't set use this command

```bash
aws eks update-kubeconfig \   
  --region us-east-1 \
  --name eks-dev
```

# Create a Service YAML❗️ so pods can communicate via DNS Name rather that IP address
To verify service endpoints

```bash 
kubectl get svc
kubectl exec -it <pod-name> -- sh
curl http://<svc-name>
```




