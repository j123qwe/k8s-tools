#!/bin/bash

# Kubernetes Tools Installation Script
# Supports Debian/Ubuntu and RHEL/CentOS/Fedora based systems
# Author: Auto-generated
# Date: $(date +%Y-%m-%d)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
VERBOSE=false
DRY_RUN=false
SKIP_EXISTING=true

# Helper functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

debug() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

show_help() {
    cat << EOF
Kubernetes Tools Installation Script

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -v, --verbose       Enable verbose output
    -d, --dry-run      Show what would be installed without actually installing
    -f, --force        Install tools even if they already exist
    -h, --help         Show this help message

DESCRIPTION:
    This script automatically installs essential Kubernetes tools on
    Debian/Ubuntu or RHEL/CentOS/Fedora based Linux systems.

TOOLS INSTALLED:
    • kubectl         - Official Kubernetes CLI
    • kubectx/kubens  - Context and namespace switching
    • krew            - kubectl plugin manager
    • helm            - Kubernetes package manager
    • k9s             - Terminal UI for Kubernetes
    • skaffold        - Continuous development for Kubernetes
    • stern           - Multi-pod log tailing
    • dive            - Docker image analyzer
    • popeye          - Kubernetes cluster sanitizer
    • kubesec         - Security scanner for K8s resources
    • trivy           - Vulnerability scanner
    • kubetail        - Kubernetes log tailing utility
    • kustomize       - Kubernetes configuration customization

EOF
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID_LIKE" == *"debian"* ]] || [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
            echo "debian"
        elif [[ "$ID_LIKE" == *"rhel"* ]] || [[ "$ID" == "fedora" ]] || [[ "$ID" == "centos" ]] || [[ "$ID" == "rhel" ]]; then
            echo "rhel"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if tool is already installed
is_installed() {
    local tool="$1"
    if command_exists "$tool"; then
        if [[ "$SKIP_EXISTING" == true ]]; then
            warn "$tool is already installed. Skipping..."
            return 0
        else
            warn "$tool is already installed but will be reinstalled."
            return 1
        fi
    fi
    return 1
}

# Update package manager
update_packages() {
    local distro="$1"
    log "Updating package manager..."
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would update packages for $distro"
        return
    fi
    
    case "$distro" in
        "debian")
            sudo apt update
            ;;
        "rhel")
            if command_exists dnf; then
                sudo dnf check-update || true
            else
                sudo yum check-update || true
            fi
            ;;
    esac
}

# Install prerequisites
install_prerequisites() {
    local distro="$1"
    log "Installing prerequisites..."
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install prerequisites for $distro"
        return
    fi
    
    case "$distro" in
        "debian")
            sudo apt install -y curl wget apt-transport-https gnupg lsb-release ca-certificates git
            ;;
        "rhel")
            if command_exists dnf; then
                sudo dnf install -y curl wget ca-certificates gnupg git
            else
                sudo yum install -y curl wget ca-certificates gnupg git
            fi
            ;;
    esac
}

# Install krew
install_krew() {
    log "Installing krew (kubectl plugin manager)..."
    
    if is_installed "kubectl-krew" || [[ -x "${KREW_ROOT:-$HOME/.krew}/bin/kubectl-krew" ]]; then
        if [[ "$SKIP_EXISTING" == true ]]; then
            warn "krew is already installed. Skipping..."
            return 0
        else
            warn "krew is already installed but will be reinstalled."
        fi
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install krew"
        return
    fi
    
    # Create temporary directory for krew installation
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    local os arch krew_binary
    os="$(uname | tr '[:upper:]' '[:lower:]')"
    arch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    krew_binary="krew-${os}_${arch}"
    
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${krew_binary}.tar.gz"
    # Extract tar with options to ignore macOS metadata and suppress warnings
    tar zxf "${krew_binary}.tar.gz" 2>/dev/null || tar zxf "${krew_binary}.tar.gz"
    ./"${krew_binary}" install krew 2>/dev/null || {
        warn "Git is required for krew but not found. Installing git first..."
        case "$(detect_distro)" in
            "debian")
                sudo apt update && sudo apt install -y git
                ;;
            "rhel")
                if command_exists dnf; then
                    sudo dnf install -y git
                else
                    sudo yum install -y git
                fi
                ;;
        esac
        ./"${krew_binary}" install krew
    }
    
    # Clean up
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    # Add krew to PATH in user's shell config
    local shell_config=""
    local current_shell
    current_shell=$(basename "$SHELL" 2>/dev/null || echo "bash")
    
    case "$current_shell" in
        "bash")
            if [[ -f "$HOME/.bashrc" ]]; then
                shell_config="$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                shell_config="$HOME/.bash_profile"
            fi
            ;;
        "zsh")
            if [[ -f "$HOME/.zshrc" ]]; then
                shell_config="$HOME/.zshrc"
            fi
            ;;
        *)
            if [[ -f "$HOME/.profile" ]]; then
                shell_config="$HOME/.profile"
            fi
            ;;
    esac
    
    if [[ -n "$shell_config" ]]; then
        if ! grep -q 'KREW_ROOT' "$shell_config"; then
            echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> "$shell_config"
            log "Added krew to PATH in $shell_config"
        fi
    else
        warn "Could not detect shell config file. Please manually add to your shell:"
        warn 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"'
    fi
    
    log "krew installed successfully"
    log "Note: You may need to restart your shell or run: export PATH=\"\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH\""
}

# Install kubectl
install_kubectl() {
    local distro="$1"
    log "Installing kubectl..."
    
    if is_installed "kubectl"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install kubectl"
        return
    fi
    
    local kubectl_version
    kubectl_version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -LO "https://dl.k8s.io/release/$kubectl_version/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    
    log "kubectl installed successfully"
}

# Install kubectx and kubens
install_kubectx() {
    local distro="$1"
    log "Installing kubectx and kubens..."
    
    if is_installed "kubectx"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install kubectx/kubens"
        return
    fi
    
    case "$distro" in
        "debian")
            sudo apt install -y kubectx
            ;;
        "rhel")
            if command_exists dnf; then
                sudo dnf install -y kubectx
            else
                # Install from GitHub releases for older systems
                local version
                version=$(curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest | grep tag_name | cut -d '"' -f 4)
                curl -L "https://github.com/ahmetb/kubectx/releases/download/$version/kubectx_${version#v}_linux_x86_64.tar.gz" | tar xz
                curl -L "https://github.com/ahmetb/kubectx/releases/download/$version/kubens_${version#v}_linux_x86_64.tar.gz" | tar xz
                sudo mv kubectx kubens /usr/local/bin/
            fi
            ;;
    esac
    
    log "kubectx and kubens installed successfully"
}

# Install Helm
install_helm() {
    log "Installing Helm..."
    
    if is_installed "helm"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install Helm"
        return
    fi
    
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    log "Helm installed successfully"
}

# Install k9s
install_k9s() {
    log "Installing k9s..."
    
    if is_installed "k9s"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install k9s"
        return
    fi
    
    local k9s_version
    k9s_version=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -L "https://github.com/derailed/k9s/releases/download/$k9s_version/k9s_Linux_amd64.tar.gz" | tar xz
    sudo mv k9s /usr/local/bin/
    
    log "k9s installed successfully"
}

# Install skaffold
install_skaffold() {
    log "Installing skaffold..."
    
    if is_installed "skaffold"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install skaffold"
        return
    fi
    
    curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
    sudo install skaffold /usr/local/bin/
    rm skaffold
    
    log "skaffold installed successfully"
}

# Install stern
install_stern() {
    log "Installing stern..."
    
    if is_installed "stern"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install stern"
        return
    fi
    
    local stern_version
    stern_version=$(curl -s https://api.github.com/repos/stern/stern/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -L "https://github.com/stern/stern/releases/download/$stern_version/stern_${stern_version#v}_linux_amd64.tar.gz" | tar xz
    sudo mv stern /usr/local/bin/
    
    log "stern installed successfully"
}

# Install dive
install_dive() {
    log "Installing dive..."
    
    if is_installed "dive"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install dive"
        return
    fi
    
    local dive_version
    dive_version=$(curl -s https://api.github.com/repos/wagoodman/dive/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -L "https://github.com/wagoodman/dive/releases/download/$dive_version/dive_${dive_version#v}_linux_amd64.tar.gz" | tar xz
    sudo mv dive /usr/local/bin/
    
    log "dive installed successfully"
}

# Install popeye
install_popeye() {
    log "Installing popeye..."
    
    if is_installed "popeye"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install popeye"
        return
    fi
    
    local popeye_version
    popeye_version=$(curl -s https://api.github.com/repos/derailed/popeye/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -L "https://github.com/derailed/popeye/releases/download/$popeye_version/popeye_linux_amd64.tar.gz" | tar xz
    sudo mv popeye /usr/local/bin/
    
    log "popeye installed successfully"
}

# Install kubesec
install_kubesec() {
    log "Installing kubesec..."
    
    if is_installed "kubesec"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install kubesec"
        return
    fi
    
    local kubesec_version
    kubesec_version=$(curl -s https://api.github.com/repos/controlplaneio/kubesec/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -L "https://github.com/controlplaneio/kubesec/releases/download/$kubesec_version/kubesec_linux_amd64.tar.gz" | tar xz
    chmod +x kubesec
    sudo mv kubesec /usr/local/bin/
    
    log "kubesec installed successfully"
}

# Install trivy
install_trivy() {
    local distro="$1"
    log "Installing trivy..."
    
    if is_installed "trivy"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install trivy"
        return
    fi
    
    case "$distro" in
        "debian")
            wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
            echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
            sudo apt update
            sudo apt install -y trivy
            ;;
        "rhel")
            if command_exists dnf; then
                sudo dnf install -y dnf-plugins-core
                sudo dnf config-manager --add-repo https://aquasecurity.github.io/trivy-repo/rpm/releases.repo
                sudo dnf install -y trivy
            else
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://aquasecurity.github.io/trivy-repo/rpm/releases.repo
                sudo yum install -y trivy
            fi
            ;;
    esac
    
    log "trivy installed successfully"
}

# Install minikube
install_minikube() {
    log "Installing minikube..."
    
    if is_installed "minikube"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install minikube"
        return
    fi
    
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube
    sudo mv minikube /usr/local/bin/
    
    log "minikube installed successfully"
}

# Install kind
install_kind() {
    log "Installing kind..."
    
    if is_installed "kind"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install kind"
        return
    fi
    
    local kind_version
    kind_version=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -Lo kind "https://github.com/kubernetes-sigs/kind/releases/download/$kind_version/kind-linux-amd64"
    chmod +x kind
    sudo mv kind /usr/local/bin/
    
    log "kind installed successfully"
}

# Install k3d
install_k3d() {
    log "Installing k3d..."
    
    if is_installed "k3d"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install k3d"
        return
    fi
    
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    
    log "k3d installed successfully"
}

# Install minikube
install_minikube() {
    log "Installing minikube..."
    
    if is_installed "minikube"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install minikube"
        return
    fi
    
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube
    sudo mv minikube /usr/local/bin/
    
    log "minikube installed successfully"
}

# Install kind
install_kind() {
    log "Installing kind..."
    
    if is_installed "kind"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install kind"
        return
    fi
    
    local kind_version
    kind_version=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -Lo kind "https://github.com/kubernetes-sigs/kind/releases/download/$kind_version/kind-linux-amd64"
    chmod +x kind
    sudo mv kind /usr/local/bin/
    
    log "kind installed successfully"
}

# Install k3d
install_k3d() {
    log "Installing k3d..."
    
    if is_installed "k3d"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install k3d"
        return
    fi
    
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    
    log "k3d installed successfully"
}

# Install kubetail
install_kubetail() {
    log "Installing kubetail..."
    
    if is_installed "kubetail"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install kubetail"
        return
    fi
    
    curl -Lo kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
    chmod +x kubetail
    sudo mv kubetail /usr/local/bin/
    
    log "kubetail installed successfully"
}

# Install kustomize
install_kustomize() {
    log "Installing kustomize..."
    
    if is_installed "kustomize"; then return; fi
    
    if [[ "$DRY_RUN" == true ]]; then
        debug "DRY RUN: Would install kustomize"
        return
    fi
    
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/
    
    log "kustomize installed successfully"
}

# Verify installation
verify_installations() {
    log "Verifying installations..."
    local tools=("kubectl" "kubectx" "kubens" "helm" "k9s" "skaffold" "stern" "dive" "popeye" "kubesec" "trivy" "kubetail" "kustomize")
    local failed=0
    
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            echo -e "${GREEN}✓${NC} $tool"
        else
            echo -e "${RED}✗${NC} $tool"
            ((failed++))
        fi
    done
    
    # Special check for krew
    if [[ -x "${KREW_ROOT:-$HOME/.krew}/bin/kubectl-krew" ]] || command_exists "kubectl-krew"; then
        echo -e "${GREEN}✓${NC} krew"
    else
        echo -e "${RED}✗${NC} krew"
        ((failed++))
    fi
    
    if [[ $failed -eq 0 ]]; then
        log "All tools installed successfully!"
    else
        error "$failed tools failed to install."
        return 1
    fi
}

# Main installation function
main() {
    log "Starting Kubernetes tools installation..."
    
    # Detect distribution
    local distro
    distro=$(detect_distro)
    
    if [[ "$distro" == "unknown" ]]; then
        error "Unsupported Linux distribution. This script supports Debian/Ubuntu and RHEL/CentOS/Fedora based systems."
        exit 1
    fi
    
    log "Detected distribution: $distro"
    
    # Check for sudo
    if ! sudo -n true 2>/dev/null; then
        error "This script requires sudo privileges. Please run with sudo or ensure your user has passwordless sudo."
        exit 1
    fi
    
    # Update packages and install prerequisites
    update_packages "$distro"
    install_prerequisites "$distro"
    
    # Install all tools
    install_kubectl "$distro"
    install_kubectx "$distro"
    install_krew
    install_helm
    install_k9s
    install_skaffold
    install_stern
    install_dive
    install_popeye
    install_kubesec
    install_trivy "$distro"
    install_kubetail
    install_kustomize
    
    # Verify installations
    if [[ "$DRY_RUN" != true ]]; then
        verify_installations
        log "Installation complete!"
        echo
        log "🎉 All Kubernetes tools have been successfully installed!"
        echo
        log "📝 Next steps:"
        log "   1. Restart your shell or run: source ~/.bashrc"
        log "   2. Verify tools: ./verify-tools.sh"
        log "   3. Connect to your cluster: kubectl config use-context <context>"
        log "   4. Test with: kubectl get nodes"
        echo
        log "🔧 krew (kubectl plugin manager) is installed!"
        log "   Try: kubectl krew search"
    else
        log "Dry run complete. Run without -d/--dry-run to perform actual installation."
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            SKIP_EXISTING=false
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main