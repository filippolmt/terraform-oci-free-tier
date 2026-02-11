FROM alpine:3.23 AS downloader

ARG TARGETARCH
ARG OPENTOFU_VERSION=1.11.4
ARG TERRAFORM_DOCS_VERSION=0.21.0
ARG TFLINT_VERSION=0.61.0
ARG TRIVY_VERSION=0.69.1

RUN apk add --no-cache curl unzip

# Install OpenTofu (multi-arch)
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") && \
    curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_${ARCH}.zip" -o /tmp/tofu.zip && \
    unzip /tmp/tofu.zip tofu -d /usr/local/bin && \
    rm /tmp/tofu.zip

# Install terraform-docs (multi-arch)
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") && \
    curl -fsSL "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${ARCH}.tar.gz" | \
    tar -xz -C /usr/local/bin terraform-docs

# Install tflint (multi-arch)
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") && \
    curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${ARCH}.zip" -o /tmp/tflint.zip && \
    unzip /tmp/tflint.zip -d /usr/local/bin && \
    rm /tmp/tflint.zip

# Install Trivy (multi-arch)
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "ARM64" || echo "64bit") && \
    curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${ARCH}.tar.gz" | \
    tar -xz -C /usr/local/bin trivy

# --- Final stage: only runtime dependencies + tool binaries ---
FROM alpine:3.23

RUN apk add --no-cache \
    bash \
    git \
    make \
    jq \
    shellcheck

COPY --from=downloader /usr/local/bin/tofu /usr/local/bin/
COPY --from=downloader /usr/local/bin/terraform-docs /usr/local/bin/
COPY --from=downloader /usr/local/bin/tflint /usr/local/bin/
COPY --from=downloader /usr/local/bin/trivy /usr/local/bin/

WORKDIR /workspace

CMD ["make", "test"]
