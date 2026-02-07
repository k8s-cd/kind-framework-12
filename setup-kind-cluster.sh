#!/usr/bin/env bash
set -euo pipefail
#use to listen on ports 80,443 and allow privileged containers
use_sudo=true #var_use_sudo
if $use_sudo ; then
  sudo -i
  port_https=443
  port_http=80
  else
  port_https=4443
  port_http=8080
fi
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
    hostPort: $port_http
    protocol: TCP
    listenAddress: "127.0.0.1"
  - containerPort: 443
    hostPort: $port_https
    protocol: TCP
    listenAddress: "127.0.0.1"
EOF
kubectl --kubeconfig ~/.kube/kind-cd apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
