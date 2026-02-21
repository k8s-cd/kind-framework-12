url=https://raw.githubusercontent.com/k8s-cd/common/main/
export KIND_CLUSTER='automatic-cluster'
cmd="sudo -H --preserve-env=KIND_CLUSTER bash -s --"

#curl -sSL "${url}kind-sudo-cluster-with-nginx.sh" | bash -s -- arg1 arg2 arg3
curl -sSL ${url}kind-sudo-cluster-with-nginx.sh | $cmd
curl -sSL ${url}argocd-core-like.sh | $cmd
curl -sSL ${url}argocd-core-app.sh | $cmd

