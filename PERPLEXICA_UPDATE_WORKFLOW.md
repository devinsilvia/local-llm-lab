# Perplexica Submodule Update Workflow

This workflow keeps local customizations intact while pulling upstream Perplexica changes.
It assumes you track local changes on a branch inside the submodule and rebase onto upstream releases.

## One-time setup (inside the submodule)

```bash
cd perplexica
# Only once: add the upstream remote
git remote add upstream <perplexica-upstream-url>
```

## Routine update (recommended)

1. Ensure your local changes are committed on a dedicated branch:
   ```bash
   cd perplexica
   git checkout local-customizations
   git status
   ```

2. Fetch upstream tags/branches:
   ```bash
   git fetch upstream --tags
   ```

3. Rebase your local branch onto the desired upstream tag or branch:
   ```bash
   git rebase upstream/<tag-or-branch>
   ```

4. Resolve conflicts (if any), then rebuild/test Perplexica.

5. Update the submodule pointer in the main repo:
   ```bash
   cd ..
   git add perplexica
   git commit -m "Update Perplexica submodule to <tag> + local patches"
   ```

## Alternative: merge (if you want merge commits)

Use merge instead of rebase if you want to preserve a non-linear history or multiple collaborators are working on the same submodule branch.

```bash
cd perplexica
git checkout local-customizations
git fetch upstream --tags
git merge upstream/<tag-or-branch>
```

## Notes

- Keep `PERPLEXICA_CHANGES.md` updated with your local modifications.
- If you need to “refresh” local changes without rewriting history, use merge instead of rebase.
- Always rebuild after updating the submodule:
  ```bash
  docker compose -f docker/compose.m1pro.yaml up -d --build
  ```
