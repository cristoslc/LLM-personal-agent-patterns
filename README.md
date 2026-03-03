# This branch has been renamed

`l3-standalone` has been renamed to **`l3-agents-core`**.

## Migration

Update your `agents-upstream` remote to fetch the new branch:

```bash
git fetch --depth=1 agents-upstream l3-agents-core
git merge agents-upstream/l3-agents-core --allow-unrelated-histories --squash
```

If using `npx skills`:

```bash
npx skills add https://github.com/cristoslc/LLM-personal-agent-patterns@l3-agents-core --yes
```

This branch will no longer receive updates.
