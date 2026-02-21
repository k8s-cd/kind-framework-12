url=https://raw.githubusercontent.com/k8s-cd/common/main/
export KIND_CLUSTER='automatic-cluster'
cmd="sudo -H --preserve-env=KIND_CLUSTER bash -s --"

#curl -sSL "${url}0_kind-sudo-cluster-with-nginx.sh" | bash -s -- arg1 arg2 arg3
curl -sSL ${url}0_kind-sudo-cluster-with-nginx.sh | $cmd
curl -sSL ${url}1_argocd-core-like.sh | $cmd
curl -sSL ${url}2_argocd-core-app.sh | $cmd

