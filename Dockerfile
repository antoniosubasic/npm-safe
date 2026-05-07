FROM node:25-alpine

ARG OSV_VERSION=v2.3.6
RUN apk add --no-cache dumb-init \
 && apk add --no-cache --virtual .download curl \
 && case "$(uname -m)" in \
      x86_64) ARCH=amd64 ;; \
      aarch64) ARCH=arm64 ;; \
      *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;; \
    esac \
 && curl -fsSL "https://github.com/google/osv-scanner/releases/download/${OSV_VERSION}/osv-scanner_linux_${ARCH}" \
      -o /usr/local/bin/osv-scanner \
 && chmod +x /usr/local/bin/osv-scanner \
 && apk del .download

WORKDIR /work

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

ENTRYPOINT ["dumb-init", "--", "entrypoint"]
