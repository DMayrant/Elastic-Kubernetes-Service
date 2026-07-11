# Workload Threat Detection and Observability Platform 🐳

Amazon EKS is a fully managed Kubernetes service where AWS manages the Kubernetes control plane, while customers are responsible for managing the worker nodes (data plane), networking, workloads, and cluster security.

This platform deploys Datadog and Falco using Helm charts to provide centralized observability and Kubernetes runtime threat detection.

# Datadog
provides infrastructure monitoring, log management, distributed tracing (APM), dashboards, and alerting to improve operational visibility and accelerate troubleshooting.

# Falco
provides runtime threat detection by monitoring Kubernetes and Linux system events for suspicious activity, helping identify potential security threats in real time.

Together, these tools improve platform observability, reduce mean time to resolution (MTTR), and strengthen the security posture of Kubernetes workloads.

---

# Update kubeconfig ☁️

```bash
aws eks update-kubeconfig \
  --region <your-region> \
  --name <your-cluster-name>
```

---

# Terraform 🏗️

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```