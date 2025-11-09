#!/bin/bash

# Set up basic alias (always available)
alias k=kubectl

# Source bashrc to get our configuration if available
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc 2>/dev/null || true
fi

echo "🚀 Kubernetes Tools Container"
echo "=============================="
echo

# Show available tools
echo "📦 Available Tools:"
echo "  kubectl (k), kubectx, kubens, krew"
echo "  helm, k9s, skaffold, stern"
echo "  dive, popeye, kubesec, trivy"
echo "  kubetail, kustomize, flux"
echo

# Check if kubectl config is mounted
if [[ -f /home/k8suser/.kube/config ]]; then
    echo "✅ Kubernetes config detected"
    echo "   Current context: $(kubectl config current-context 2>/dev/null || echo 'none')"
else
    echo "⚠️  No kubectl config found"
    echo "   Mount your ~/.kube/config to /home/k8suser/.kube/config"
fi
echo

# If no command specified, start interactive bash
if [[ $# -eq 0 ]]; then
    echo "Starting interactive shell..."
    echo "Run 'verify-tools' to check all installations"
    echo
    exec /bin/bash
else
    exec "$@"
fi