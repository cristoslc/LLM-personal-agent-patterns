#!/usr/bin/env bash
# One-time import of agents-standalone scaffolding into a project repo.
#
# Usage (run from your project root):
#   curl -fsSL https://raw.githubusercontent.com/cristoslc/LLM-personal-agent-patterns/main/L3-agents-standalone/import-agents-standalone.sh | bash
#
# Can also be downloaded and run as a file — the script will clean up after itself.
set -euo pipefail

UPSTREAM_URL="https://github.com/cristoslc/LLM-personal-agent-patterns.git"
UPSTREAM_BRANCH="l3-standalone"
REMOTE_NAME="agents-upstream"

# --- preflight checks ---

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "ERROR: Not inside a git repository. Run this from your project root." >&2
  exit 1
fi

if [ "$(git rev-parse --show-toplevel)" != "$(pwd)" ]; then
  echo "ERROR: Run this from the repository root ($(git rev-parse --show-toplevel))." >&2
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: Working tree has uncommitted changes. Commit or stash first." >&2
  exit 1
fi

if git remote get-url "$REMOTE_NAME" &>/dev/null; then
  echo "ERROR: Remote '$REMOTE_NAME' already exists. Already imported?" >&2
  exit 1
fi

# --- clean up script file before merge (if run as a file, not piped) ---

# Detect if we were invoked as a file (not piped via curl | bash).
# If so, remove the script now — before the merge — so it can't conflict
# with incoming files. This is safe because the { ... } block below
# ensures bash has already read the entire script into memory.
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  rm -f "$SCRIPT_FILE"
fi

# --- import ---

echo "Adding remote '$REMOTE_NAME'..."
git remote add "$REMOTE_NAME" "$UPSTREAM_URL"

echo "Fetching $UPSTREAM_BRANCH..."
git fetch "$REMOTE_NAME" "$UPSTREAM_BRANCH"

echo "Merging into project root (squash)..."
git merge "$REMOTE_NAME/$UPSTREAM_BRANCH" --allow-unrelated-histories --squash

echo ""
echo "Files staged. Review with: git diff --cached --stat"
echo "Then commit with: git commit -m 'Import agents-standalone scaffolding'"
echo ""
echo "To pull future updates:"
echo "  git fetch $REMOTE_NAME $UPSTREAM_BRANCH"
echo "  git merge $REMOTE_NAME/$UPSTREAM_BRANCH --squash"
echo ""
echo "Done."
