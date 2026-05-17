# Sandboxed NPM Package Installer

A simple container for auditing and installing NPM packages in a sandboxed environment, using Google's [OSV-Scanner](https://github.com/google/osv-scanner) for CVE checks against the [OSV.dev](https://osv.dev) database (no API key required).

Run the container in your project:

```bash
# Audit packages
podman run --rm \
  --network=host \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v ./package.json:/work/package.json:ro,Z \
  -v ./package-lock.json:/work/package-lock.json:ro,Z \
  ghcr.io/antoniosubasic/npm-safe:latest audit

# Install packages from existing lockfile
podman run --rm \
  --network=host \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v ./package.json:/work/package.json:ro,Z \
  -v ./package-lock.json:/work/package-lock.json:ro,Z \
  -v ./node_modules:/work/node_modules:Z \
  ghcr.io/antoniosubasic/npm-safe:latest install

# Install a specific package (replaces `npm install <pkg>`)
# Note: package.json and package-lock.json must be writable so npm can update them.
podman run --rm \
  --network=host \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v ./package.json:/work/package.json:Z \
  -v ./package-lock.json:/work/package-lock.json:Z \
  -v ./node_modules:/work/node_modules:Z \
  ghcr.io/antoniosubasic/npm-safe:latest install lodash
```

Packages must have been published at least 7 days ago — newer releases are rejected as a supply-chain safeguard.
