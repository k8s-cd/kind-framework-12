## Context

this repo contains 
- one script 
    - to setup an kind cluster with ingress-nginx controller installed and configured.
    - to setup argocd-core in the cluster
- argocd application manifests that will be applied to the cluster by argocd-core

## Instructions
execute the script `setup-kind-cluster.sh` to setup the kind cluster with ingress-nginx and argocd-core.
```bash
curl -sSL https://raw.githubusercontent.com/k8s-cd/kind-framework-12/refs/heads/main/setup-kind-cluster.sh | bash
```