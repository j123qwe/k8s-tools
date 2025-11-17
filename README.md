# Kubernetes Tools Collection

A comprehensive collection of essential Kubernetes tools for cluster management, development, and operations. This repository provides both automated installation scripts and a Docker containerized environment for easy access to all tools.

## Features

- � **Automated Installation**: One-script installation for all tools
- 🐳 **Docker Support**: Pre-built container with all tools included
- 📦 **Comprehensive Toolset**: 14+ essential Kubernetes tools
- 🔧 **kubectl Enhancement**: Tab completions and 'k' alias
- 🛡️ **Multi-Distribution**: Support for Debian/Ubuntu and RHEL/CentOS/Fedora
- 📊 **Verification**: Built-in tool verification script

## Tools Included

| Tool | Description |
|------|-------------|
| **kubectl** | Official Kubernetes CLI with completions and 'k' alias |
| **kubectx/kubens** | Context and namespace switching utilities |
| **krew** | kubectl plugin manager |
| **helm** | Kubernetes package manager |
| **k9s** | Terminal-based UI for Kubernetes clusters |
| **skaffold** | Continuous development for Kubernetes applications |
| **stern** | Multi-pod log tailing |
| **dive** | Docker image analyzer |
| **popeye** | Kubernetes cluster sanitizer |
| **kubesec** | Security scanner for Kubernetes resources |
| **trivy** | Vulnerability scanner |
| **kubetail** | Kubernetes log tailing utility |
| **kustomize** | Kubernetes configuration customization tool |
| **flux** | GitOps toolkit for Kubernetes |
| **cilium** | Cilium CLI for eBPF-based networking |

## Quick Start

### Option 1: Native Installation

```bash
# Clone the repository
git clone https://github.com/j123qwe/k8s-tools.git
cd k8s-tools

# Make the script executable and run
chmod +x install-k8s-tools.sh
./install-k8s-tools.sh

# Verify installation
./verify-tools.sh
```

### Option 2: Docker Container

```bash
# Clone the repository
git clone https://github.com/j123qwe/k8s-tools.git
cd k8s-tools

# Build and run the container
make build
make run

```

## Installation Options

### Native Installation

The installation script automatically detects your Linux distribution (Debian/Ubuntu or RHEL/CentOS/Fedora) and installs all tools with proper configuration.

```bash
# Basic installation
./install-k8s-tools.sh

# Available options
./install-k8s-tools.sh --help
./install-k8s-tools.sh --verbose      # Detailed output
./install-k8s-tools.sh --dry-run      # See what would be installed
./install-k8s-tools.sh --force        # Reinstall existing tools
```

After installation, restart your shell or source your shell configuration:
```bash
source ~/.bashrc   # or ~/.zshrc
```

### Docker Container

The containerized version includes all tools pre-installed and configured in a lightweight Alpine Linux environment.

```bash
# Using Makefile (recommended)
make build    # Build the container image
make run      # Run interactive container
make shell    # Same as make run
make verify   # Run verification inside container

# Using Docker directly
docker build -t k8s-tools .
docker run -it --rm k8s-tools

# Using docker-compose
docker-compose up -d
docker-compose exec k8s-tools bash
```

## kubectl Enhancement

Both installation methods configure kubectl with:

- **Tab completion**: Auto-complete for commands, resources, and names
- **'k' alias**: Use `k` instead of `kubectl` for faster commands
- **Auto-completion for 'k'**: The alias inherits all kubectl completions

```bash
# These commands work the same way
kubectl get pods
k get pods

# Tab completion works for both
k get po<TAB>    # Expands to 'pods'
k get pods -n <TAB>    # Shows available namespaces
```

## Usage Examples

### Basic Operations
```bash
# Check cluster connection
kubectl cluster-info
k get nodes

# Switch contexts and namespaces
kubectx production
kubens kube-system

# View logs from multiple pods
stern app-name
kubetail deployment/my-app
```

### Security and Analysis
```bash
# Scan cluster for issues
popeye

# Security analysis of manifests
kubesec scan deployment.yaml

# Vulnerability scanning
trivy image nginx:latest
```

### Development Workflow
```bash
# Continuous development
skaffold dev

# Package management
helm search repo nginx
helm install my-release bitnami/nginx

# Image analysis
dive nginx:latest
```

## Directory Structure

```
k8s-tools/
├── README.md                 # This file
├── install-k8s-tools.sh     # Native installation script
├── verify-tools.sh          # Tool verification script
├── Dockerfile               # Container build configuration
├── docker-compose.yml       # Container orchestration
├── Makefile                 # Build and run commands
├── entrypoint.sh            # Container entry point
├── .dockerignore            # Docker build exclusions
├── .gitignore               # Git exclusions
└── LICENSE                  # MIT License
```

## Requirements

### Native Installation
- Linux (Debian/Ubuntu or RHEL/CentOS/Fedora)
- sudo privileges
- curl, wget (installed automatically)
- Internet connection

### Docker Installation
- Docker Engine 20.10+
- docker-compose (optional, for compose usage)

## Verification

After installation, verify all tools are working:

```bash
# Native installation
./verify-tools.sh

# Docker container
make verify
# or
docker run --rm k8s-tools ./verify-tools.sh
```

## Troubleshooting

### Common Issues

1. **Tools not found after installation**
   ```bash
   # Restart shell or source config
   source ~/.bashrc
   ```

2. **Permission denied errors**
   ```bash
   # Ensure user has sudo privileges
   sudo -l
   ```

3. **kubectl completions not working**
   ```bash
   # Check if completion is loaded
   type _kubectl
   
   # Manually source if needed
   source <(kubectl completion bash)
   ```

4. **krew not in PATH**
   ```bash
   # Add to your shell config
   export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
   ```

### Docker Issues

1. **Container build fails**
   ```bash
   # Clean Docker cache and rebuild
   docker system prune -f
   make build
   ```

2. **'k' alias not working in non-interactive mode**
   
   This is expected behavior. The 'k' alias works in interactive shells but may not work in `docker exec` commands. Use `kubectl` directly in scripts.

## Contributing

We welcome contributions! Please feel free to:

- Report bugs or issues
- Suggest new tools to include
- Improve installation scripts
- Update documentation
- Submit pull requests

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- All the amazing tool authors who make Kubernetes development easier
- The Kubernetes community for building such an incredible ecosystem
- Contributors and users who help improve this collection

---

**Happy Kubernetes-ing!** 🚀
