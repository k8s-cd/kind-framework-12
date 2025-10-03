#!/usr/bin/env bash
set -euo pipefail
sudo kind delete cluster --name kind-cd || true
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
sudo kubectl --kubeconfig ~/.kube/kind-cd apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

#deploy argocd-core in the cluster
sudo kubectl --kubeconfig ~/.kube/kind-cd create namespace argocd-infra

sudo helm repo add argo https://argoproj.github.io/argo-helm
sudo helm --kubeconfig ~/.kube/kind-cd install argocd-infra  argo/argo-cd --set notifications.enabled=false --set dex.enabled=false --set redis.enabled=true --set server.replicas=1 --set configs.cm.admin.enabled=false --set applicationSet.replicas=0  --namespace argocd-infra --create-namespace


#wait for argocd-core to be ready
echo "Waiting for argocd to be ready..."
sudo kubectl --kubeconfig ~/.kube/kind-cd -n argocd-infra wait --for=condition=available --timeout=600s deployment/argocd-infra-server
sudo kubectl --kubeconfig ~/.kube/kind-cd -n argocd-infra wait --for=condition=available --timeout=600s deployment/argocd-infra-repo-server

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
    repoURL: 'https://github.com/k8s-cd/kind-framework-12.git'#var_git_k8s_cd
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