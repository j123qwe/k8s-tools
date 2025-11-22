# Kubernetes Tools Collection

A comprehensive collection of Kubernetes tools packaged in a Docker container for easy development and cluster management.

## Overview

This repository provides a containerized environment with all the essential Kubernetes tools pre-installed and configured. Whether you're developing applications for Kubernetes or managing clusters, this toolset has everything you need.

## 🛠️ Included Tools

### Core Kubernetes Tools
- **kubectl** - Official Kubernetes CLI (aliased as `k`)
- **kubectx/kubens** - Context and namespace switching utilities
- **krew** - kubectl plugin manager

### Package Managers
- **helm** - Kubernetes package manager
- **kustomize** - Kubernetes configuration customization tool

### Development Tools
- **skaffold** - Continuous development for Kubernetes applications
- **stern** - Multi-pod log tailing utility
- **dive** - Docker image layer analyzer

### Cluster Management
- **k9s** - Terminal-based Kubernetes dashboard
- **popeye** - Kubernetes cluster resource sanitizer

### Security Tools
- **kubesec** - Security risk analysis for Kubernetes resources
- **trivy** - Vulnerability scanner for containers and other artifacts

### Utility Tools
- **kubetail** - Kubernetes log tailing utility
- **flux** - GitOps toolkit for Kubernetes
- **cilium** - Cilium CLI for eBPF-based networking and security

## 🚀 Quick Start

### Using Docker

Build and run the container:

```bash
make build-run
```

Or use individual commands:

```bash
# Build the image
make build

# Run interactively
make run

# Execute a single command
make exec CMD='kubectl get nodes'
```

### Using docker-compose

```bash
# Start the container
make up

# Get a shell in the running container
make shell

# Stop the container
make down
```

### Local Installation

Install all tools directly on your system:

```bash
./install-k8s-tools.sh
```

Available options:
- `-v, --verbose`: Enable verbose output
- `-d, --dry-run`: Show what would be installed without installing
- `-f, --force`: Install tools even if they already exist
- `-h, --help`: Show help message

## 📋 Verification

Verify that all tools are installed correctly:

```bash
# In container
verify-tools

# On local system
./verify-tools.sh
```

## 🐳 Container Usage

### Mounting Your Kubectl Config

The container automatically mounts your local kubectl configuration:

```bash
# Your ~/.kube/config is mounted to /home/k8suser/.kube/config
docker run -it --rm \
  -v ~/.kube:/home/k8suser/.kube:ro \
  k8s-tools:latest
```

### Working with Local Files

Mount your current directory to work with Kubernetes manifests:

```bash
docker run -it --rm \
  -v ~/.kube:/home/k8suser/.kube:ro \
  -v $(pwd):/workspace \
  k8s-tools:latest
```

## 🔧 Configuration

### kubectl Completions and Aliases

The tools come pre-configured with:
- `k` alias for `kubectl`
- Tab completion for kubectl and the `k` alias
- Proper shell integration

### Krew Plugin Manager

Krew is installed and ready to use:

```bash
# Search for plugins
kubectl krew search

# Install a plugin
kubectl krew install ctx
```

## 📁 Project Structure

```
.
├── Dockerfile              # Container build configuration
├── docker-compose.yml      # Docker Compose configuration
├── Makefile                # Build and run automation
├── install-k8s-tools.sh    # Local installation script
├── verify-tools.sh         # Tool verification script
├── entrypoint.sh           # Container entrypoint
├── README.md               # This file
└── CHANGELOG.md            # Version history
```

## 🛡️ Security

- The container runs as a non-root user (`k8suser`)
- Based on Alpine Linux for minimal attack surface
- Only necessary packages are installed
- Tools are downloaded from official sources with version verification

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add new tools or improvements
4. Test your changes
5. Submit a pull request

When adding new tools:
1. Update the installation scripts
2. Add verification in `verify-tools.sh`
3. Update the Dockerfile
4. Update this README

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Acknowledgments

Thanks to all the amazing projects that make up this toolset:
- [Kubernetes](https://kubernetes.io/)
- [Helm](https://helm.sh/)
- [k9s](https://k9scli.io/)
- [Skaffold](https://skaffold.dev/)
- And many more!

---

**Happy Kuberneting!** 🚢⚓
