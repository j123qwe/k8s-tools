# Kubernetes Tools Docker Image
# Based on Alpine Linux for minimal size and security
FROM alpine:3.19

# Metadata
LABEL maintainer="K8s Tools Repository"
LABEL description="Comprehensive Kubernetes tools collection in a lightweight container"
LABEL version="1.0"

# Set environment variables
ENV PATH="${PATH}:/usr/local/bin"
ENV KREW_ROOT="/opt/krew"
ENV PATH="${KREW_ROOT}/bin:${PATH}"

# Install base packages and dependencies
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    tar \
    gzip \
    ca-certificates \
    git \
    jq \
    openssl \
    && rm -rf /var/cache/apk/*

# Create non-root user for security
RUN addgroup -g 1000 k8suser && \
    adduser -D -s /bin/bash -G k8suser -u 1000 k8suser

# Create directories
RUN mkdir -p /opt/krew /home/k8suser/.krew /home/k8suser/.kube && \
    touch /home/k8suser/.kube/kuberc && \
    chown -R k8suser:k8suser /opt/krew /home/k8suser/.krew /home/k8suser/.kube

# Install kubectl
RUN KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt) && \
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install kubectx and kubens
RUN KUBECTX_VERSION=$(curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz" | tar xz && \
    curl -L "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_linux_x86_64.tar.gz" | tar xz && \
    chmod +x kubectx kubens && \
    mv kubectx kubens /usr/local/bin/

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install k9s
RUN K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" | tar xz && \
    chmod +x k9s && \
    mv k9s /usr/local/bin/

# Install skaffold
RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
    chmod +x skaffold && \
    mv skaffold /usr/local/bin/

# Install stern
RUN STERN_VERSION=$(curl -s https://api.github.com/repos/stern/stern/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L "https://github.com/stern/stern/releases/download/${STERN_VERSION}/stern_${STERN_VERSION#v}_linux_amd64.tar.gz" | tar xz && \
    chmod +x stern && \
    mv stern /usr/local/bin/

# Install dive
RUN DIVE_VERSION=$(curl -s https://api.github.com/repos/wagoodman/dive/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L "https://github.com/wagoodman/dive/releases/download/${DIVE_VERSION}/dive_${DIVE_VERSION#v}_linux_amd64.tar.gz" | tar xz && \
    chmod +x dive && \
    mv dive /usr/local/bin/

# Install popeye
RUN POPEYE_VERSION=$(curl -s https://api.github.com/repos/derailed/popeye/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L "https://github.com/derailed/popeye/releases/download/$POPEYE_VERSION/popeye_linux_amd64.tar.gz" | tar xz && \
    chmod +x popeye && \
    mv popeye /usr/local/bin/

# Install kubesec
RUN KUBESEC_VERSION=$(curl -s https://api.github.com/repos/controlplaneio/kubesec/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L "https://github.com/controlplaneio/kubesec/releases/download/$KUBESEC_VERSION/kubesec_linux_amd64.tar.gz" | tar xz && \
    chmod +x kubesec && \
    mv kubesec /usr/local/bin/

# Install trivy
RUN TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L "https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-64bit.tar.gz" | tar xz && \
    chmod +x trivy && \
    mv trivy /usr/local/bin/

# Install kubetail
RUN curl -Lo kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail && \
    chmod +x kubetail && \
    mv kubetail /usr/local/bin/

# Install kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    chmod +x kustomize && \
    mv kustomize /usr/local/bin/

# Install krew as the k8suser
USER k8suser
WORKDIR /tmp
RUN OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew && \
    rm -rf /tmp/*

# Switch back to root for final setup
USER root

# Copy scripts
COPY verify-tools.sh /usr/local/bin/verify-tools
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/verify-tools /usr/local/bin/entrypoint.sh

# Set up kubectl completions and alias for k8suser
RUN echo '# Enable alias expansion in non-interactive shells' >> /home/k8suser/.bashrc && \
    echo 'shopt -s expand_aliases' >> /home/k8suser/.bashrc && \
    echo '# kubectl completion and alias' >> /home/k8suser/.bashrc && \
    echo 'alias k=kubectl' >> /home/k8suser/.bashrc && \
    echo '# Only enable kubectl completion if we have a valid kube config' >> /home/k8suser/.bashrc && \
    echo 'if [[ -f ~/.kube/config ]] && kubectl version --client >/dev/null 2>&1; then' >> /home/k8suser/.bashrc && \
    echo '    source <(kubectl completion bash) 2>/dev/null || true' >> /home/k8suser/.bashrc && \
    echo '    complete -o default -F __start_kubectl k 2>/dev/null || true' >> /home/k8suser/.bashrc && \
    echo 'fi' >> /home/k8suser/.bashrc && \
    chown k8suser:k8suser /home/k8suser/.bashrc

# Set up working directory and user
WORKDIR /home/k8suser
USER k8suser

# Expose the container as a CLI environment
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []