#!/usr/bin/env bash
# Report filenames that contain likely secret patterns; never print matching lines.
# This is a lightweight pre-commit aid, not a replacement for Gitleaks/history scanning.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
patterns='-----BEGIN (OPENSSH|RSA|EC|DSA) PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|playit.{0,20}(token|secret|key)|rcon[-_ ]?password'
echo "Scanning tracked working-tree files for likely secret patterns (filenames only)..."
if git grep -Il -E -i "$patterns" -- . ':!*.md' ':!.env.example' ':!docs/**' ; then
  echo "REVIEW REQUIRED: inspect listed files locally; matching content was not printed."
  exit 1
else
  rc=$?
  if [[ "$rc" -eq 1 ]]; then
    echo "No matches in this limited pattern scan."
  else
    echo "Scanner encountered a git grep error (exit $rc)." >&2
    exit "$rc"
  fi
fi
echo "NOTE: This does not scan ignored/untracked files, all history, encoded secrets, or every provider token format."
