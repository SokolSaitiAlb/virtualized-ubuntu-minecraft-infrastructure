#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash -n "$ROOT/scripts/collect-host-evidence.sh"
bash -n "$ROOT/scripts/review-secrets.sh"
echo "PASS: evidence and secrets-review scripts pass Bash syntax checks."
echo "NOTE: no measurements or secret scan were performed by this syntax test."
