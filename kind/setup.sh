url=https://raw.githubusercontent.com/k8s-cd/common/main/
export KIND_CLUSTER='automatic-cluster'

#curl -sSL "${url}kind-sudo-cluster-with-nginx.sh" | bash -s -- arg1 arg2 arg3
curl -sSL ${url}kind-sudo-cluster-with-nginx.sh | bash
curl -sSL ${url}argocd-core-like.sh | bash
curl -sSL ${url}argocd-core-app.sh | bash -s -- 'kind/core' 'https://github.com/k8s-cd/kind-framework-12.git'

