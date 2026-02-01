# Agent Skills for AiMo Network

## Project structure

```
skills/
  <skill-name>/
    SKILL.md             # Skill definition (YAML frontmatter + markdown body)
    examples/            # Working code examples
    references/          # Additional documentation
```

## Conventions

- Each skill is a directory under `skills/` containing a `SKILL.md` file.
- The directory name must match the `name` field in the SKILL.md frontmatter.
- SKILL.md files follow the [Agent Skills specification](https://agentskills.io/specification).
- Examples should be self-contained and runnable with minimal setup.
- Keep SKILL.md under 500 lines; move detailed docs to `references/`.

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with required `name` and `description` frontmatter.
2. Add examples in `skills/<skill-name>/examples/`.
3. Ensure the directory name matches the frontmatter `name` field.
