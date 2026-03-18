## git-learning-mode

`git-learning-mode.sh` configures the **current repository only** for studying Git's object model with minimal hidden automation.

The script disables background/automatic maintenance features that can mutate `.git/objects` behind the scenes (such as auto-GC, auto-packing, pruning, and maintenance tasks). It also disables pack delta behavior and some acceleration indexes so object storage and history traversal stay easier to inspect.

## Why this exists

Git normally optimizes storage and performance automatically. That is great for day-to-day work, but it can make internals harder to observe while learning.

This script puts a repository into a "learning mode" where:

- Objects are less likely to be silently repacked.
- Unreachable objects are retained instead of pruned.
- Reflog history is preserved indefinitely.
- Auxiliary acceleration features are reduced.

## Scope and safety

- Changes are written with `git config --local`.
- No global or system Git config is touched.
- You must run it from inside a Git repository.

## Usage

From inside a repository:

```bash
path/to/git-learning-mode.sh
```

If successful, it prints a short summary and suggested inspection commands.

## What gets configured

The script sets local config values including:

- `gc.auto=0`
- `gc.autoPackLimit=0`
- `maintenance.auto=false`
- `maintenance.strategy=none` (best-effort)
- `core.commitGraph=false`
- `core.compression=0`
- `pack.window=0`
- `pack.depth=0`
- `pack.useBitmaps=false`
- `gc.pruneExpire=never`
- `gc.reflogExpire=never`
- `gc.reflogExpireUnreachable=never`
- `core.fsmonitor=false` (best-effort)

## Helpful follow-up commands

After running the script, inspect object internals directly:

```bash
find .git/objects -type f
git cat-file -t <hash>
git cat-file -p <hash>
```

## Notes

- This mode favors transparency over performance.
- It is intended for local learning repos, not production workflows.
