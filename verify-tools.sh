#!/bin/bash

# Kubernetes Tools Verification Script
# Checks if all installed tools are working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Kubernetes Tools Verification${NC}"
echo "=============================="
echo

# Function to check command and get version
check_tool() {
    local tool="$1"
    local version_cmd="$2"
    
    if command -v "$tool" >/dev/null 2>&1; then
        echo -n -e "${GREEN}✓${NC} $tool: "
        if [[ -n "$version_cmd" ]]; then
            eval "$version_cmd" 2>/dev/null || echo "installed (version check failed)"
        else
            echo "installed"
        fi
    else
        echo -e "${RED}✗${NC} $tool: not found"
    fi
}

# Check core tools
echo -e "${YELLOW}Core Kubernetes Tools:${NC}"
check_tool "kubectl" "kubectl version --client --short 2>/dev/null | head -1"
check_tool "kubectx" "kubectx --version"
check_tool "kubens" "kubens --version"
echo

# Check plugin manager
echo -e "${YELLOW}Plugin Manager:${NC}"
# Set PATH for krew if it's installed but not in current PATH
if [[ -d "${KREW_ROOT:-$HOME/.krew}/bin" ]]; then
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi
if [[ -x "${KREW_ROOT:-$HOME/.krew}/bin/kubectl-krew" ]] || command -v kubectl-krew >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} krew: $(kubectl krew version 2>/dev/null | head -1 || echo 'installed')"
else
    echo -e "${RED}✗${NC} krew: not found (try: source ~/.bashrc)"
fi
echo

# Check package managers
echo -e "${YELLOW}Package Managers:${NC}"
check_tool "helm" "helm version --short"
check_tool "kustomize" "kustomize version --short"
echo

# Check cluster management tools
echo -e "${YELLOW}Cluster Management:${NC}"
check_tool "k9s" "k9s version | head -1"
check_tool "popeye" "popeye version"
echo

# Check development tools
echo -e "${YELLOW}Development Tools:${NC}"
check_tool "skaffold" "skaffold version"
check_tool "stern" "stern --version"
check_tool "dive" "dive --version"
check_tool "kubetail" "echo 'latest from GitHub'"
echo

# Check security tools
echo -e "${YELLOW}Security Tools:${NC}"
check_tool "kubesec" "kubesec version"
check_tool "trivy" "trivy --version | head -1"
echo

echo -e "${BLUE}Verification Complete!${NC}"
echo
echo "To get started with Kubernetes:"
echo "1. Connect to your existing cluster: kubectl config use-context <context>"
echo "2. Verify connection: kubectl cluster-info"
echo "3. Explore with k9s or kubectl get nodes"
echo "4. Install kubectl plugins: kubectl krew search"
echo
echo "For help with any tool, use: <tool-name> --help"