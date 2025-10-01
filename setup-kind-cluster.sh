#!/usr/bin/env bash
set -euo pipefail
#create a kind cluster with ingress-nginx controller installed and configured.
#https://kind.sigs.k8s.io/docs/user/ingress/
mkdir -p ~/.kube
cat <<EOF | sudo kind create cluster --name kind-cd --kubeconfig ~/.kube/kind-cd --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
    listenAddress: "127.0.0.1"
  - containerPort: 443
    hostPort: 443
    protocol: TCP
    listenAddress: "127.0.0.1"
EOF
sudo kubectl --kubeconfig ~/.kube/kind-cd apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

#deploy argocd-core in the cluster
sudo kubectl --kubeconfig ~/.kube/kind-cd apply -n argocd-core --create-namespace -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml