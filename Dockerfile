FROM alpine:3.23

ARG TARGETARCH
ARG OPENTOFU_VERSION=1.11.1
ARG TERRAFORM_DOCS_VERSION=0.21.0
ARG TFLINT_VERSION=0.60.0
ARG TRIVY_VERSION=0.58.0

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    make \
    jq \
    unzip

# Install OpenTofu (multi-arch)
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") && \
    curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_${ARCH}.zip" -o /tmp/tofu.zip && \
    unzip /tmp/tofu.zip -d /usr/local/bin && \
    rm /tmp/tofu.zip && \
    chmod +x /usr/local/bin/tofu

# Install terraform-docs (multi-arch)
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") && \
    curl -fsSL "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${ARCH}.tar.gz" | \
    tar -xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/terraform-docs

# Install tflint (multi-arch)
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") && \
    curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${ARCH}.zip" -o /tmp/tflint.zip && \
    unzip /tmp/tflint.zip -d /usr/local/bin && \
    rm /tmp/tflint.zip && \
    chmod +x /usr/local/bin/tflint

# Install Trivy (multi-arch)
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "ARM64" || echo "64bit") && \
    curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${ARCH}.tar.gz" | \
    tar -xz -C /usr/local/bin trivy && \
    chmod +x /usr/local/bin/trivy

# Create working directory
WORKDIR /workspace

# Healthcheck (nominal - this is an ephemeral build container, not a service)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=1 \
    CMD exit 0

# Default command
CMD ["make", "test"]
