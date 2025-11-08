# Kubernetes Tools Repository

A comprehensive collection of essential Kubernetes tools with automated installation scripts for Debian and RHEL-based Linux distributions.

## 🚀 Quick Start

### Native Installation
Run the automated installation script:

```bash
./install-k8s-tools.sh
```

### Docker Container
Use the pre-built container with all tools included:

```bash
# Build the container
make build

# Run interactively
make run

# Or use Docker directly
docker run -it --rm -v ~/.kube:/home/k8suser/.kube:ro k8s-tools:latest
```

Or install tools individually using the commands below.

## 📦 Included Tools

### Core Kubernetes Tools

#### kubectl
The official Kubernetes command-line tool for interacting with clusters.

**Manual Installation:**
```bash
# Debian/Ubuntu
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# RHEL/CentOS/Fedora
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### kubectx & kubens
Fast way to switch between clusters and namespaces.

**Manual Installation:**
```bash
# Debian/Ubuntu
sudo apt update
sudo apt install kubectx

# RHEL/CentOS/Fedora
sudo dnf install kubectx
```

#### kustomize
Template-free way to customize application configuration.

**Manual Installation:**
```bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/
```

### Cluster Management Tools

#### Helm
The package manager for Kubernetes.

**Manual Installation:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### k9s
Terminal UI to interact with your Kubernetes clusters.

**Manual Installation:**
```bash
# Download and install latest release
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz | tar xz
sudo mv k9s /usr/local/bin/
```

#### krew
Plugin manager for kubectl command line tool.

**Manual Installation:**
```bash
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```

### Development & Debugging Tools

#### skaffold
Build and deploy to Kubernetes continuously.

**Manual Installation:**
```bash
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
sudo install skaffold /usr/local/bin/
```

#### stern
Multi-pod and container log tailing.

**Manual Installation:**
```bash
STERN_VERSION=$(curl -s https://api.github.com/repos/stern/stern/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L https://github.com/stern/stern/releases/download/${STERN_VERSION}/stern_${STERN_VERSION#v}_linux_amd64.tar.gz | tar xz
sudo mv stern /usr/local/bin/
```

#### dive
Tool for exploring Docker images and layer contents.

**Manual Installation:**
```bash
DIVE_VERSION=$(curl -s https://api.github.com/repos/wagoodman/dive/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L https://github.com/wagoodman/dive/releases/download/${DIVE_VERSION}/dive_${DIVE_VERSION#v}_linux_amd64.tar.gz | tar xz
sudo mv dive /usr/local/bin/
```

### Monitoring & Observability

#### kubetail
Tail Kubernetes logs from multiple pods simultaneously.

**Manual Installation:**
```bash
curl -Lo kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
chmod +x kubetail
sudo mv kubetail /usr/local/bin/
```

#### popeye
Kubernetes cluster resource sanitizer.

**Manual Installation:**
```bash
POPEYE_VERSION=$(curl -s https://api.github.com/repos/derailed/popeye/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L https://github.com/derailed/popeye/releases/download/${POPEYE_VERSION}/popeye_linux_amd64.tar.gz | tar xz
sudo mv popeye /usr/local/bin/
```

### Security Tools

#### kubesec
Security scanner for Kubernetes resources.

**Manual Installation:**
```bash
KUBESEC_VERSION=$(curl -s https://api.github.com/repos/controlplaneio/kubesec/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L https://github.com/controlplaneio/kubesec/releases/download/${KUBESEC_VERSION}/kubesec_linux_amd64.tar.gz | tar xz
chmod +x kubesec
sudo mv kubesec /usr/local/bin/
```

#### trivy
Vulnerability scanner for containers and other artifacts.

**Manual Installation:**
```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# RHEL/CentOS/Fedora
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://aquasecurity.github.io/trivy-repo/rpm/releases.repo
sudo dnf install trivy
```

## 🐳 Docker Usage

The repository includes a Dockerfile and Docker Compose setup for containerized usage.

### Building the Image

```bash
# Using Makefile
make build

# Or directly with Docker
docker build -t k8s-tools:latest .
```

### Running the Container

#### Interactive Mode
```bash
# Using Makefile (recommended)
make run

# Or with Docker directly
docker run -it --rm \
  --name k8s-tools \
  -v ~/.kube:/home/k8suser/.kube:ro \
  -v $(pwd):/workspace \
  --network host \
  k8s-tools:latest
```

#### Execute Single Commands
```bash
# Using Makefile
make exec CMD='kubectl get nodes'
make exec CMD='k9s'

# Or with Docker directly
docker run --rm \
  -v ~/.kube:/home/k8suser/.kube:ro \
  k8s-tools:latest kubectl get pods
```

#### Using Docker Compose
```bash
# Start the container
docker-compose up -d k8s-tools

# Get a shell
docker-compose exec k8s-tools bash

# Stop the container
docker-compose down
```

### Container Features

- **Base Image**: Alpine Linux 3.19 (lightweight and secure)
- **Non-root User**: Runs as `k8suser` (UID 1000) for security
- **Volume Mounts**:
  - `~/.kube` → `/home/k8suser/.kube` (kubectl config)
  - Current directory → `/workspace` (for manifests)
- **Network**: Host networking for easy cluster access
- **Tools Verification**: Run `verify-tools` inside container

### Security Considerations

- Container runs as non-root user (`k8suser`)
- kubectl config mounted read-only
- Based on minimal Alpine Linux
- No unnecessary packages or services

## 🛠️ Installation Script

The repository includes an automated installation script (`install-k8s-tools.sh`) that:

- ✅ Detects your Linux distribution (Debian/Ubuntu or RHEL/CentOS/Fedora)
- ✅ Installs all tools automatically
- ✅ Provides verbose output and error handling
- ✅ Skips already installed tools
- ✅ Verifies installations

### Usage

```bash
# Make the script executable
chmod +x install-k8s-tools.sh

# Run the installation
./install-k8s-tools.sh

# Run with verbose output
./install-k8s-tools.sh -v
```

## 📋 Verification

After installation, verify your tools:

```bash
# Core tools
kubectl version --client
helm version
k9s version

# Development tools
skaffold version
stern --version
dive --version

# Security tools
trivy --version
kubesec version

# Utilities
kubectx
kubens
popeye version
krew version

# Check available kubectl plugins
kubectl krew list
```

## 🔧 Tool Descriptions

| Tool | Purpose | Key Features |
|------|---------|--------------|
| **kubectl** | Official K8s CLI | Resource management, debugging |
| **kubectx/kubens** | Context switching | Quick cluster/namespace switching |
| **krew** | kubectl plugin manager | Extend kubectl functionality |
| **Helm** | Package manager | Chart management, templating |
| **k9s** | Terminal UI | Interactive cluster management |
| **skaffold** | Development workflow | Continuous build/deploy |
| **stern** | Log aggregation | Multi-pod log tailing |
| **dive** | Image analysis | Layer inspection, efficiency |
| **popeye** | Cluster health | Resource sanitization |
| **kubesec** | Security scanning | YAML security analysis |
| **trivy** | Vulnerability scanning | Container/image security |

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Helm Documentation](https://helm.sh/docs/)
- [k9s Documentation](https://k9scli.io/)

## 🤝 Contributing

Feel free to contribute by:
- Adding new tools
- Improving installation methods
- Updating Docker configuration
- Improving documentation
- Reporting issues

### Repository Structure

```
k8s-tools/
├── README.md              # This documentation
├── install-k8s-tools.sh   # Native installation script
├── verify-tools.sh        # Tools verification script
├── Dockerfile             # Container definition
├── docker-compose.yml     # Container orchestration
├── Makefile              # Container management commands
├── entrypoint.sh         # Container entry point
├── .dockerignore         # Docker build exclusions
├── .gitignore            # Git exclusions
└── LICENSE               # MIT license
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

- [Docker container image](https://hub.docker.com/r/kubesec/kubesec/tags) at `docker.io/kubesec/kubesec:v2`
- Linux/MacOS/Win binary (get the [latest release](https://github.com/controlplaneio/kubesec/releases))
- [Kubernetes Admission Controller](https://github.com/controlplaneio/kubesec-webhook)
- [Kubectl plugin](https://github.com/controlplaneio/kubectl-kubesec)

Or install the latest commit from GitHub with:

#### Go 1.16+

```bash
$ go install github.com/controlplaneio/kubesec/v2@latest
```

#### Go version < 1.16

```bash
$ GO111MODULE="on" go get github.com/controlplaneio/kubesec/v2
```

#### Command line usage:

```bash
$ kubesec scan k8s-deployment.yaml
```

#### Usage example:

```bash
$ cat <<EOF > kubesec-test.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kubesec-demo
spec:
  containers:
  - name: kubesec-demo
    image: gcr.io/google-samples/node-hello:1.0
    securityContext:
      readOnlyRootFilesystem: true
EOF
$ kubesec scan kubesec-test.yaml
```

#### Docker usage:

Run the same command in Docker:

```bash
$ docker run -i kubesec/kubesec:v2 scan /dev/stdin < kubesec-test.yaml
```

#### Specify custom schema

Kubesec leverages kubeconform (thanks @yannh) to validate the manifests to scan.
This implies that specifying different schema locations follows the rules as
described in [the kubeconform README](https://github.com/yannh/kubeconform#overriding-schemas-location).

Here is a quick overview on how this work for scanning a pod manifest:

- I want to use the latest available schema from upstream.

```bash
kubesec [scan|http]
```

Schema will be fetched from: https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/pod-v1.json

- I want to use a specific schema version from upstream. (Formatted x.y.z with no v prefix)

```bash
kubesec [scan|http] --kubernetes-version <version>
```

Schema will be fetched from: https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.25.3-standalone-strict/pod-v1.json

- I want to use a specific schema version in an airgap environment over HTTP.

```bash
kubesec [scan|http] --kubernetes-version <version> --schema-location https://host.server
```

Schema will be fetched from: `https://host.server/v<version>-standalone-strict/pod-v1.json`

- I want to use a specific schema version in an airgap environment with local files:

```bash
kubesec [scan|http] --kubernetes-version <version> --schema-location /opt/schemas
```

Schema will be read from: `/opt/schemas/v<version>-standalone-strict/pod-v1.json`

**Note:** in order to limit external network calls and allow usage in airgap
environments, the `kubesec` image embeds schemas. If you are looking to change
the schema location, you'll need to change the `K8S_SCHEMA_VER` and `SCHEMA_LOCATION`
environment variables at runtime.

#### Print the scanning rules with their associated scores

All the scanning rules can be printed in in different formats (json (default),
yaml and table). This is useful to easily get the point associated with
each rule:

```bash
kubesec print-rules
```

which produces the following output:

```json
[
  {
    "id": "AllowPrivilegeEscalation",
    "selector": "containers[] .securityContext .allowPrivilegeEscalation == true",
    "reason": "Ensure a non-root process can not gain more privileges",
    "kinds": [
      "Pod",
      "Deployment",
      "StatefulSet",
      "DaemonSet"
    ],
    "points": -7,
    "advise": 0
  },
...
]
```

## Kubesec HTTP Server

Kubesec includes a bundled HTTP server

The listen address for the HTTP server can be configured by setting
`KUBESEC_ADDR` environment variable. The value can be a single port
such as `8080` or an address in the form of `ip:port` or `[ipv6]:port`.

#### CLI usage example:

Start the HTTP server in the background

<!-- markdownlint-disable line-length -->

```bash
$ kubesec http 8080 &
[1] 12345
{"severity":"info","timestamp":"2019-05-12T11:58:34.662+0100","caller":"server/server.go:69","message":"Starting HTTP server on port 8080"}
```

<!-- markdownlint-enable line-length -->

Use curl to POST a file to the server

```bash
$ curl -sSX POST --data-binary @test/asset/score-0-cap-sys-admin.yml http://localhost:8080/scan
[
  {
    "object": "Pod/security-context-demo.default",
    "valid": true,
    "message": "Failed with a score of -30 points",
    "score": -30,
    "scoring": {
      "critical": [
        {
          "selector": "containers[] .securityContext .capabilities .add == SYS_ADMIN",
          "reason": "CAP_SYS_ADMIN is the most privileged capability and should always be avoided",
          "points": -30
        },
        {
          "selector": "containers[] .securityContext .runAsNonRoot == true",
          "reason": "Force the running image to run as a non-root user to ensure least privilege",
          "points": 1
        },
  // ...
```

Finally, stop the Kubesec server by killing the background process

```bash
$ kill %
```

#### Docker usage example:

Start the HTTP server using Docker

```bash
$ docker run -d -p 8080:8080 kubesec/kubesec:v2 http 8080
```

Use curl to POST a file to the server

```bash
$ curl -sSX POST --data-binary @test/asset/score-0-cap-sys-admin.yml http://localhost:8080/scan
...
```

Don't forget to stop the server.

## Kubesec-as-a-Service

Kubesec is also available via HTTPS at [v2.kubesec.io/scan](https://v2.kubesec.io/scan)

Please do not submit sensitive YAML to this service.

The service is ran on a good faith best effort basis.

#### Command line usage:

```bash
$ curl -sSX POST --data-binary @"k8s-deployment.yaml" https://v2.kubesec.io/scan
```

#### Usage example:

Define a BASH function

```bash
$ kubesec ()
{
    local FILE="${1:-}";
    [[ ! -e "${FILE}" ]] && {
        echo "kubesec: ${FILE}: No such file" >&2;
        return 1
    };
    curl --silent \
      --compressed \
      --connect-timeout 5 \
      -sSX POST \
      --data-binary=@"${FILE}" \
      https://v2.kubesec.io/scan
}
```

POST a Kubernetes resource to v2.kubesec.io/scan

```bash
$ kubesec ./deployment.yml
```

Return non-zero status code is the score is not greater than 10

```bash
$ kubesec ./score-9-deployment.yml | jq --exit-status '.score > 10' >/dev/null
# status code 1
```

## Example output

Kubesec returns a returns a JSON array, and can scan multiple YAML documents in a single input file.

```json
[
  {
    "object": "Pod/security-context-demo.default",
    "valid": true,
    "message": "Failed with a score of -30 points",
    "score": -30,
    "scoring": {
      "critical": [
        {
          "selector": "containers[] .securityContext .capabilities .add == SYS_ADMIN",
          "reason": "CAP_SYS_ADMIN is the most privileged capability and should always be avoided",
          "points": -30
        }
      ],
      "advise": [
        {
          "selector": "containers[] .securityContext .runAsNonRoot == true",
          "reason": "Force the running image to run as a non-root user to ensure least privilege",
          "points": 1
        },
        {
          // ...
        }
      ]
    }
  }
]
```

---

## Contributors

Thanks to our awesome contributors!

- [Andrew Martin](@sublimino)
- [Stefan Prodan](@stefanprodan)
- [Jack Kelly](@06kellyjac)

## Getting Help

If you have any questions about Kubesec and Kubernetes security:

- Read the Kubesec docs
- Reach out on Twitter to [@sublimino](https://twitter.com/sublimino) or [@controlplaneio](https://twitter.com/controlplaneio)
- File an issue

Your feedback is always welcome!

[testing_workflow]: https://github.com/controlplaneio/kubesec/actions?query=workflow%3ATesting
[testing_workflow_badge]: https://github.com/controlplaneio/kubesec/workflows/Testing/badge.svg
[security_workflow]: https://github.com/controlplaneio/kubesec/actions?query=workflow%3A%22Security+Analysis%22
[security_workflow_badge]: https://github.com/controlplaneio/kubesec/workflows/Security%20Analysis/badge.svg
[release_workflow]: https://github.com/controlplaneio/kubesec/actions?query=workflow%3ARelease
[release_workflow_badge]: https://github.com/controlplaneio/kubesec/workflows/Release/badge.svg
[goreportcard]: https://goreportcard.com/report/github.com/controlplaneio/kubesec
[goreportcard_badge]: https://goreportcard.com/badge/github.com/controlplaneio/kubesec
[go_dev]: https://pkg.go.dev/github.com/controlplaneio/kubesec/v2
[go_dev_badge]: https://pkg.go.dev/badge/github.com/controlplaneio/kubesec/v2
