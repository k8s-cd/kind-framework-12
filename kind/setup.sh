url=https://raw.githubusercontent.com/k8s-cd/common/main/

#curl -sSL "${url}kind-sudo-cluster-with-nginx.sh" | bash -s -- arg1 arg2 arg3
curl -sSL ${url}kind-sudo-cluster-with-nginx.sh | bash
curl -sSL ${url}argocd-core-like.sh | bash
curl -sSL ${url}argocd-core-app.sh | bash

