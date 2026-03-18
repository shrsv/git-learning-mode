#!/usr/bin/env bash

set -euo pipefail

# Ensure we are inside a Git repository (otherwise --local has no meaning)
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not inside a Git repository"
  exit 1
fi

echo "Configuring repo (LOCAL ONLY, learning mode)..."

# Convenience alias so we never accidentally touch global/system config.
CFG="git config --local"

# ----------------------------
# GC / Maintenance suppression
# ----------------------------

# Disables heuristic-based auto GC.
# Normally triggered after ~6700 loose objects.
# GC repacks objects -> destroys 1:1 visibility of blobs/trees/commits.
$CFG gc.auto 0

# Prevents auto-packing based on packfile count thresholds.
# Without this, Git may consolidate packs even if gc.auto is disabled.
$CFG gc.autoPackLimit 0

# Disables the newer "git maintenance" background tasks.
# These run silently in modern Git and can repack, write commit-graphs, etc.
$CFG maintenance.auto false

# Forces maintenance to a no-op strategy (belt-and-suspenders).
# Some Git versions ignore maintenance.auto unless strategy is overridden.
$CFG maintenance.strategy none 2>/dev/null || true


# ----------------------------
# History acceleration features (disable for transparency)
# ----------------------------

# Commit-graph introduces a side index that shortcuts commit traversal.
# It changes how history is *read*, not stored, but obscures raw parent walks.
$CFG core.commitGraph false


# ----------------------------
# Compression / storage behavior
# ----------------------------

# Reduces zlib compression level for loose objects.
# Objects are still zlib-wrapped ("type size\0content"), but easier to inspect
# and faster to inflate manually.
$CFG core.compression 0

# Prevent delta compression in packfiles.
# Delta chains encode objects as differences from others → opaque for learning.
$CFG pack.window 0
$CFG pack.depth 0

# Disables bitmap indexes used for fast reachability.
# These are performance accelerators that hide the actual graph traversal cost.
$CFG pack.useBitmaps false


# ----------------------------
# Retention / pruning behavior
# ----------------------------

# Prevents pruning of unreachable objects.
# Normally Git may delete objects not referenced by any ref after expiry.
# For learning, you want dangling objects to remain inspectable.
$CFG gc.pruneExpire never

# Reflogs track ref movements (HEAD, branches).
# By default they expire → you lose visibility into history mutations.
# Keeping them forever lets you inspect how refs evolved.
$CFG gc.reflogExpire never
$CFG gc.reflogExpireUnreachable never


# ----------------------------
# Misc (reduce hidden machinery)
# ----------------------------

# Disables filesystem monitoring integrations.
# These are performance optimizations that cache working tree state.
# Not directly related to object model, but reduces invisible behavior.
$CFG core.fsmonitor false 2>/dev/null || true


echo "Done. Repo is now in a 'transparent object model' mode."

echo
echo "What this guarantees:"
echo "- Objects remain loose (no automatic packing)"
echo "- No delta compression introduced"
echo "- No background mutation of storage"
echo "- No silent pruning of unreachable objects"
echo "- Minimal auxiliary indexes (commit-graph, bitmaps)"

echo
echo "You can now directly study:"
echo "  find .git/objects -type f"
echo "  git cat-file -t <hash>"
echo "  git cat-file -p <hash>"