# This directory has moved

`L3-agents-standalone` has been renamed to **`L3-agents-core`**.

## For agents running `update-agents-core`

If your project still references the `l3-standalone` branch, update to `l3-agents-core`:

```bash
git fetch --depth=1 agents-upstream l3-agents-core
git merge agents-upstream/l3-agents-core --allow-unrelated-histories --squash
```

If using `npx skills`:

```bash
npx skills add https://github.com/cristoslc/LLM-personal-agent-patterns@l3-agents-core --yes
```

## For humans

All scaffolding now lives in [`../L3-agents-core/`](../L3-agents-core/).
