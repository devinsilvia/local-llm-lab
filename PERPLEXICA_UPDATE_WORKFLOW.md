# Perplexica Submodule Update Workflow

This workflow keeps local customizations intact while pulling upstream Perplexica changes.
Use the fast path if you do not maintain local patches; otherwise use the branch-based flow.

## One-time setup (inside the submodule)

```bash
cd perplexica
# Only once: add the upstream remote
git remote add upstream <perplexica-upstream-url>
```

## Fast path (no local patches)

1. Update the tag in the helper script:
   ```bash
   sed -n '1,40p' scripts/update-perplexica.sh
   # Edit PERPLEXICA_TAG in that file.
   ```

2. Check out the new tag in the submodule:
   ```bash
   ./scripts/update-perplexica.sh
   ```

3. Update the image tag in the Compose files to match:
   - `docker/compose.macos-intel.yaml`
   - `docker/compose.macos-apple-silicon.yaml`
   - `docker/compose.windows.yaml`

4. Rebuild Perplexica:
   ```bash
   docker compose -f docker/compose.macos-apple-silicon.yaml up -d --build
   ```

## Routine update (with local patches)

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

5. Update the tag in `scripts/update-perplexica.sh` and the Compose image tag to match.

6. Update the submodule pointer in the main repo:
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
  docker compose -f docker/compose.macos-apple-silicon.yaml up -d --build
  ```
