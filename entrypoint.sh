#!/bin/sh
set -e

# Alpine's BusyBox date lacks GNU relative-date parsing (-d '7 days ago'),
# so compute the cutoff from the epoch (7 days = 604800s). The @epoch form
# is understood by both BusyBox and GNU date.
CUTOFF="$(date -u -d "@$(( $(date -u +%s) - 7 * 24 * 60 * 60 ))" '+%Y-%m-%dT%H:%M:%SZ')"

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
    shift
    if [ "$#" -eq 0 ]; then
      echo "=== Installing from lockfile (scripts disabled) ==="
      npm ci --ignore-scripts --no-audit --before "$CUTOFF"
    else
      echo "=== Installing $* (scripts disabled) ==="
      npm install "$@" --ignore-scripts --no-audit --save --before "$CUTOFF"
    fi
    echo "=== Done ==="
    ;;

  *)
    echo "Usage: entrypoint {audit|install}"
    exit 1
    ;;
esac
