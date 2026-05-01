#!/usr/bin/env bash
#
# apply-legacy-rename.sh
#
# Applies the "Legacy" rename to a clean upstream apollo-ios checkout so the
# package can coexist with the modern Apollo iOS package in the same app.
#
# Idempotent: re-running on an already-renamed tree is a no-op.
#
# Usage:  Scripts/apply-legacy-rename.sh
#
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT="$( cd -- "$SCRIPT_DIR/.." && pwd )"
cd "$ROOT"

say() { printf '\033[1;34m[legacy-rename]\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# Step 1 — Folder renames (use `git mv` so history follows)
# ---------------------------------------------------------------------------
move_dir() {
  local from="$1" to="$2"
  if [ -d "$from" ] && [ ! -d "$to" ]; then
    say "moving $from -> $to"
    git mv "$from" "$to"
  elif [ -d "$to" ] && [ ! -d "$from" ]; then
    : # already renamed
  elif [ -d "$from" ] && [ -d "$to" ]; then
    echo "ERROR: both $from and $to exist; refusing to merge." >&2
    exit 1
  fi
}

say "Step 1: renaming source folders"
move_dir "Sources/Apollo"             "Sources/Apollo_Legacy"
move_dir "Sources/ApolloAPI"          "Sources/ApolloAPI_Legacy"
move_dir "Sources/ApolloSQLite"       "Sources/ApolloSQLite_Legacy"
move_dir "Sources/ApolloWebSocket"    "Sources/ApolloWebSocket_Legacy"
move_dir "Sources/ApolloTestSupport"  "Sources/ApolloTestSupport_Legacy"
move_dir "Plugins/InstallCLI"         "Plugins/InstallCLI_Legacy"

# ---------------------------------------------------------------------------
# Step 2 — Rewrite Package.swift
# ---------------------------------------------------------------------------
# Only quoted identifiers are renamed — descriptive prose like
# "Installs the Apollo iOS Command line interface." stays untouched.
# All literals are idempotent because, after rename, the closing quote sits
# after `_Legacy` (or `Legacy`) and the original literal no longer matches.
say "Step 2: rewriting Package.swift"
perl -i -pe '
  s{"ApolloTestSupport"}{"ApolloTestSupport_Legacy"}g;
  s{"ApolloWebSocket"}{"ApolloWebSocket_Legacy"}g;
  s{"ApolloSQLite"}{"ApolloSQLite_Legacy"}g;
  s{"ApolloAPI"}{"ApolloAPI_Legacy"}g;
  s{"Apollo-Dynamic"}{"Apollo-Dynamic_Legacy"}g;
  s{"Apollo"}{"Apollo_Legacy"}g;
  s{"Plugins/InstallCLI"}{"Plugins/InstallCLI_Legacy"}g;
  s{"InstallCLI"}{"InstallCLI_Legacy"}g;
  s{"Install CLI"}{"Install CLI Legacy"}g;
' Package.swift

# ---------------------------------------------------------------------------
# Step 3 — Rewrite Swift imports across all renamed source folders
# ---------------------------------------------------------------------------
# Matches:
#   import Apollo
#   import ApolloAPI
#   @_exported import ApolloAPI
#   @_spi(<X>) import Apollo
# and rewrites the module name to its _Legacy form. The negative lookahead
# (?![_A-Za-z0-9]) prevents matching `Apollo` inside `Apollo_Legacy` or
# `ApolloAPI` (so order ApolloAPI before Apollo is safe regardless).
say "Step 3: rewriting Swift import statements"
find Sources -type f -name '*.swift' -print0 | xargs -0 perl -i -pe '
  s/^(\s*(?:\@_exported\s+|\@_spi\([^)]+\)\s+)?import\s+)ApolloAPI(?![_A-Za-z0-9])/${1}ApolloAPI_Legacy/g;
  s/^(\s*(?:\@_exported\s+|\@_spi\([^)]+\)\s+)?import\s+)Apollo(?![_A-Za-z0-9])/${1}Apollo_Legacy/g;
'

# ---------------------------------------------------------------------------
# Step 4 — CHANGELOG.md doc-string edit
# ---------------------------------------------------------------------------
say "Step 4: updating CHANGELOG.md doc-string"
perl -i -pe 's/`import ApolloAPI`(?!_Legacy)/`import ApolloAPI_Legacy`/g' CHANGELOG.md

# ---------------------------------------------------------------------------
# Step 5 — Add SwiftPM xcworkspace stub (matches historical rename commit)
# ---------------------------------------------------------------------------
WORKSPACE_FILE=".swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata"
if [ ! -f "$WORKSPACE_FILE" ]; then
  say "Step 5: adding $WORKSPACE_FILE"
  mkdir -p "$(dirname "$WORKSPACE_FILE")"
  cat > "$WORKSPACE_FILE" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
EOF
fi

# ---------------------------------------------------------------------------
# Step 6 — Sanity scan: catch new upstream files that escaped the rename
# ---------------------------------------------------------------------------
say "Step 6: sanity scan"

scan_failed=0

# Any non-renamed source folders left?
for stale in Sources/Apollo Sources/ApolloAPI Sources/ApolloSQLite \
             Sources/ApolloWebSocket Sources/ApolloTestSupport \
             Plugins/InstallCLI; do
  if [ -e "$stale" ]; then
    echo "WARN: original path still exists: $stale" >&2
    scan_failed=1
  fi
done

# Any swift import lines that still reference the un-suffixed modules?
remaining_imports=$(grep -rEl '^[[:space:]]*(@_exported[[:space:]]+|@_spi\([^)]+\)[[:space:]]+)?import[[:space:]]+(Apollo|ApolloAPI)[[:space:]]*$' Sources 2>/dev/null || true)
if [ -n "$remaining_imports" ]; then
  echo "WARN: files still importing un-renamed modules:" >&2
  echo "$remaining_imports" >&2
  scan_failed=1
fi

# Any Package.swift entries that still name un-suffixed targets?
if grep -E '"(Apollo|ApolloAPI|ApolloSQLite|ApolloWebSocket|ApolloTestSupport|Apollo-Dynamic|InstallCLI|Install CLI)"' Package.swift > /dev/null; then
  echo "WARN: Package.swift still references un-renamed identifiers:" >&2
  grep -nE '"(Apollo|ApolloAPI|ApolloSQLite|ApolloWebSocket|ApolloTestSupport|Apollo-Dynamic|InstallCLI|Install CLI)"' Package.swift >&2
  scan_failed=1
fi

if [ "$scan_failed" -eq 0 ]; then
  say "OK — all targets, folders, and imports are in *_Legacy form."
else
  echo "" >&2
  echo "Sanity scan found issues — review the warnings above." >&2
  echo "If new upstream files were added, extend the script to handle them." >&2
  exit 1
fi
