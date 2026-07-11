 ##########
 FALCO  
 ##########

# Falco for Cloud Native Runtime Security 🦅

```bash 
curl -L https://falcosecurity.github.io/charts 

helm repo add falcosecurity https://falcosecurity.github.io/charts

helm repo update
```
Installing Falco

create a ns first then install Falco

```bash
kubectl create ns falco --dry-run=client -o yaml > falco-ns.yaml 

helm install my-falco falcosecurity/falco --version 8.0.5 -n falco -f falco-values.yaml

helm repo add falcosecurity https://falcosecurity.github.io/charts -n falco
  ```

 #################
 Datadog 
 ################# 

# Datadog helm chart installation ☸️

Datadog is a Security Information Event Management (SIEM) for analyzing logs, metrics and traces and used for Observability

```bash
helm repo add datadog https://helm.datadoghq.com

helm repo update 

kubectl create ns datadog --dry-run -o yaml > datadog-ns.yaml 

kubectl create secret generic datadog-secret --from-literal=api-key="<API-TOKEN>" -n datadog

helm install my-datadog datadog/datadog --version 3.208.2 -n datadog -f datadog-values.yaml 
```
