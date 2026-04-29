#!/bin/sh
set -e

case "$1" in
  audit|a)
    echo "=== Dry run: packages that would be installed ==="
    npm install --dry-run 2>/dev/null || true

    echo ""
    echo "=== Security audit ==="
    npm audit --audit-level=none || true

    echo ""
    echo "=== Packages with install scripts (postinstall hooks) ==="
    node -e "
      const fs = require('fs');
      if (!fs.existsSync('./package-lock.json')) {
        console.log('No lockfile found, generating one first...');
        require('child_process').execSync('npm install --package-lock-only --ignore-scripts', {stdio: 'inherit'});
      }
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
    npm ci --ignore-scripts --no-audit
    echo "=== Done ==="
    ;;

  *)
    echo "Usage: entrypoint {audit|install}"
    exit 1
    ;;
esac
