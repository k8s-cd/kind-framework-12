#!/usr/bin/env bash
set -euo pipefail
#create a kind cluster with ingress-nginx controller installed and configured.
#https://kind.sigs.k8s.io/docs/user/ingress/
sudo mkdir -p ~/.kube
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
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

#deploy argocd-core in the cluster
sudo kubectl --kubeconfig ~/.kube/kind-cd create namespace argocd-infra
sudo kubectl --kubeconfig ~/.kube/kind-cd apply -n argocd-infra -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml

#wait for argocd-core to be ready
echo "Waiting for argocd-core to be ready..."
sudo kubectl --kubeconfig ~/.kube/kind-cd -n argocd-infra wait --for=condition=available --timeout=600s deployment/argocd-server

sudo kubectl apply --kubeconfig ~/.kube/kind-cd -n argocd-infra  -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: infra
  namespace: argocd-infra
spec:
  ignoreDifferences:
    - group: argoproj.io
      kind: Application
      jsonPointers:
        - /operation
  project: default
  source:
    repoURL: 'https://github.com/k8s-cd/kind-framework-12.git'
    targetRevision: HEAD
    path: infra

  destination:
    server: 'https://kubernetes.default.svc'
    namespace: argocd-infra

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF