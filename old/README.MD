## Context

this repo contains 
- one script 
    - to setup an kind cluster with ingress-nginx controller
    - to setup argocd-core in the cluster
- argocd application manifests that will be applied to the cluster by argocd-core, they are in two separate folders
    - infra
    - applis


## Instructions
execute the script `setup-kind-cluster.sh` to setup the kind cluster with ingress-nginx and argocd-core.
```bash
curl -sSL https://raw.githubusercontent.com/k8s-cd/kind-framework-12/main/setup-kind-cluster.sh | bash
```