#!/usr/bin/env bash
set -euo pipefail
#use to listen on ports 80,443 and allow privileged containers
sudo -i
cluster_name='kind-cd' #var_cluster_name
key_file="$HOME/.ssh/id_$cluster_name"
if compgen -G "$key_file*" > /dev/null; then
  echo "existing ssh keys"
else
  ssh-keygen -t rsa -b 4096 -f "$key_file" -N "" 
fi
kind delete cluster --name $cluster_name || true
#create a kind cluster with ingress-nginx controller installed and configured.
#https://kind.sigs.k8s.io/docs/user/ingress/
mkdir -p ~/.kube
cat <<EOF | kind create cluster --name $cluster_name --kubeconfig ~/.kube/kind-cd --config=-
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
kubectl --kubeconfig ~/.kube/kind-cd apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

#deploy argocd-core in the cluster
kubectl --kubeconfig ~/.kube/kind-cd create namespace argocd-infra

helm repo add argo https://argoproj.github.io/argo-helm
helm --kubeconfig ~/.kube/kind-cd install argocd-infra  argo/argo-cd --set notifications.enabled=false --set dex.enabled=false --set redis.enabled=true --set server.replicas=1 --set configs.cm.admin.enabled=false --set applicationSet.replicas=0  --namespace argocd-infra --create-namespace


#wait for argocd-core to be ready
echo "Waiting for argocd to be ready..."
kubectl --kubeconfig ~/.kube/kind-cd -n argocd-infra wait --for=condition=available --timeout=600s deployment/argocd-infra-server
kubectl --kubeconfig ~/.kube/kind-cd -n argocd-infra wait --for=condition=available --timeout=600s deployment/argocd-infra-repo-server

kubectl apply --kubeconfig ~/.kube/kind-cd -n argocd-infra  -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 0-infra
  namespace: argocd-infra
spec:
  ignoreDifferences:
    - group: argoproj.io
      kind: Application
      jsonPointers:
        - /operation
  project: default
  source:
    repoURL: 'https://github.com/k8s-cd/kind-framework-12.git' #var_git_k8s_cd
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