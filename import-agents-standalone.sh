#!/usr/bin/env bash
# One-time import of agents-standalone scaffolding into a project repo.
# Run from the root of the target project repo. Self-deletes after use.
set -euo pipefail

UPSTREAM_URL="https://github.com/cristoslc/LLM-personal-agent-patterns.git"
UPSTREAM_BRANCH="l3-standalone"
REMOTE_NAME="agents-upstream"
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

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

# --- self-destruct ---

rm -f "$SCRIPT_PATH"
echo "Script self-deleted. Done."
