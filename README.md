# Sandboxed NPM Package Installer

A simple container for auditing and installing NPM packages in a sandboxed environment.

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

# Install packages
podman run --rm \
  --network=host \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v ./package.json:/work/package.json:ro,Z \
  -v ./package-lock.json:/work/package-lock.json:ro,Z \
  -v ./node_modules:/work/node_modules:Z \
  ghcr.io/antoniosubasic/npm-safe:latest install
```
