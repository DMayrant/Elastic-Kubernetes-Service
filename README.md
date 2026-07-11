# Workload Threat Detection and Observability Platform 🐳

Amazon EKS is a fully managed Kubernetes service where AWS manages the Kubernetes control plane, while customers are responsible for managing the worker nodes (data plane), networking, workloads, and cluster security.

EKS is a fully managed service by AWS responsible for managing the Kubernetes Control plane within your Kubernetes cluster. The customer is responsible for the data plane. 

I used Jenkins to automate my Terraform workflow—plan, apply, and validation—and I embedded tfsec and Checkov directly into the pipeline so security checks run before anything gets deployed. That helped catch misconfigurations early and reduce risk in production.

This platform deploys Datadog and Falco using Helm charts to provide centralized observability and Kubernetes runtime threat detection.

# Datadog
provides infrastructure monitoring, log management, distributed tracing (APM), dashboards, and alerting to improve operational visibility and accelerate troubleshooting.

In the Jenkins pipeline, I integrated multiple security tools like Trivy, Snyk, Checkov, tfsec, and OWASP ZAP. These run at different stages to scan container images, dependencies, and Terraform code for vulnerabilities and misconfigurations.

- AWS is responsible for 📊
Kubernetes API server
Schedular
Control Manager
Cloud-Controller Manager 
Control plane availability and scaling

# Falco
provides runtime threat detection by monitoring Kubernetes and Linux system events for suspicious activity, helping identify potential security threats in real time.

Together, these tools improve platform observability, reduce mean time to resolution (MTTR), and strengthen the security posture of Kubernetes workloads.

# Update kubeconfig ☁️

```bash
aws eks update-kubeconfig \
  --region <your-region> \
  --name <your-cluster-name>
```
# Terraform 🏗️

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

![image alt](https://github.com/DMayrant/Datadog-Falco-Workloads/blob/main/3-tier-private%20EKS.jpeg?raw=true)

