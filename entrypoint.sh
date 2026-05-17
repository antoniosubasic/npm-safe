#!/bin/sh
set -e

CUTOFF="$(date -u -d '7 days ago' '+%Y-%m-%dT%H:%M:%SZ')"

case "$1" in
  audit|a)
    echo "=== Dry run: packages that would be installed ==="
    npm install --dry-run --before "$CUTOFF" 2>/dev/null || true

    echo ""
    if [ ! -f ./package-lock.json ]; then
      echo "No lockfile found, generating one first..."
      npm install --package-lock-only --ignore-scripts --before "$CUTOFF"
    fi

    echo ""
    echo "=== OSV vulnerability scan ==="
    osv-scanner scan source -L package-lock.json || true

    echo ""
    echo "=== Packages with install scripts (postinstall hooks) ==="
    node -e "
      const lock = require('./package-lock.json');
      const pkgs = lock.packages || {};
      const risky = Object.entries(pkgs)
        .filter(([k, v]) => k && v.hasInstallScript)
        .map(([k]) => k.replace('node_modules/', ''));
      if (risky.length) {
        console.warn('⚠️  These packages run code at install time:');
        risky.forEach(p => console.warn('  - ' + p));
        console.warn('They will be blocked during install (--ignore-scripts).');
      } else {
        console.log('✓ No install scripts found.');
      }
    "
    ;;

  install|i)
    echo "=== Installing (scripts disabled) ==="
    npm ci --ignore-scripts --no-audit --before "$CUTOFF"
    echo "=== Done ==="
    ;;

  *)
    echo "Usage: entrypoint {audit|install}"
    exit 1
    ;;
esac
