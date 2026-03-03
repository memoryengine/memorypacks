# memory packs

Pre-built knowledge and skills for [memory engine](https://memory.build) — import a YAML file, get instant value.

## What are memory packs?

A memory pack is a YAML file containing memories that you import with `me pack import`. No code, no plugins, no running processes.

Packs may contain a mix of:

- **Reference knowledge** — static content that's useful immediately after import
- **Skill instructions** — procedural content that teaches AI agents how to perform tasks

Memory Packs are Neo's "I know kung fu" for your agents.

## Quick start

```bash
# Validate a pack (no server needed)
me pack validate packs/git-history.yaml

# Import a pack
me pack import packs/git-history.yaml

# Preview what would happen
me pack import --dry-run packs/git-history.yaml
```

## Available packs

| Pack | Description |
|------|-------------|
| [pack-authoring](packs/pack-authoring.yaml) | How to write effective memory packs — skill memory structure, reference memory craft, organization, ID/versioning, and quality checklist |
| [skill-to-pack](packs/skill-to-pack.yaml) | Convert Agent Skills (agentskills.io) into memory engine packs — format reference, conversion procedure, field mapping, and edge cases |
| [codebase-index](packs/codebase-index.yaml) | Teaches agents to build a structural code index using Tree-sitter and filesystem watching — zero LLM cost, always current |

## Pack format

Each pack is a YAML file with a top-level envelope declaring pack identity, followed by a `memories` array:

```yaml
name: example_pack
version: "0.1.0"
description: "One-line summary of what this pack provides"
id-prefix: "019b0000"
format: 1
memories:
  - id: "019b0000-0001-7000-8000-000000000001"
    tree: "subtopic"
    meta:
      type: "skill"
    content: |
      # Example Skill — What This Does

      Instructions for an agent...
```

### Envelope fields

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | ltree-safe identifier (`[a-z0-9_]+`) — used to construct tree paths at import |
| `version` | Yes | Semantic version string (e.g., `"0.1.0"`) |
| `description` | No | Human-readable summary |
| `id-prefix` | Yes | 8 lowercase hex characters — all memory IDs must start with this |
| `format` | Yes | Must be `1` |
| `memories` | Yes | Array of memory objects |

### Conventions

- **Envelope**: declares pack identity (`name`, `version`) — individual memories do not include `meta.pack`
- **IDs**: deterministic UUIDv7 with a fixed prefix per pack (makes re-imports idempotent)
- **Tree**: relative paths — auto-prefixed with `pack.<name>.` at import time
- **Content**: non-empty, self-contained, follows [memory best practices](https://memory.build)

Additional meta keys (like `type`, `topic`, etc.) are optional — add whatever makes your content discoverable and filterable.

### ID allocation

Each pack claims a unique UUIDv7 prefix. Declare it in the envelope's `id-prefix` field.

| Prefix | Pack |
|--------|------|
| `019b0001` | pack-authoring |
| `019b0002` | skill-to-pack |

When adding a new pack, choose the next available prefix.

To generate IDs for a new pack:

```bash
bun scripts/pack-uuids.ts 019b0003        # 10 IDs (default)
bun scripts/pack-uuids.ts 019b0003 25     # 25 IDs
bun scripts/pack-uuids.ts 019b0003 5 3    # 5 IDs starting at sequence 3
```

## Upgrading packs

`me pack import` handles version-aware upgrades automatically:

```bash
# First import: installs v0.1.0
me pack import packs/git-history.yaml
# Imported 1 memory, deleted 0 (pack: git_history@0.1.0)

# After updating the file to v0.2.0:
me pack import packs/git-history.yaml
# Imported 2 memories, deleted 1 (pack: git_history@0.2.0)
```

Old-version memories are automatically cleaned up. Memories that exist in both versions are updated in place (deterministic IDs).

## Contributing

1. Fork this repository
2. Create your pack as a YAML file in `packs/`
3. Validate with `me pack validate packs/your-pack.yaml`
4. Submit a pull request

All packs must:
- Use the v2 envelope format (`name`, `version`, `id-prefix`, `format: 1`, `memories`)
- Use an ltree-safe pack name (`[a-z0-9_]+` — no hyphens)
- Use a unique ID prefix (check the table above)
- Have non-empty, well-written content

## Validation & CI

Every pack is validated on push and pull request via GitHub Actions. The workflow checks:

1. **Per-pack validation** — envelope fields, schema, IDs match `id-prefix`
2. **Cross-pack duplicate names** — no two packs may share a name
3. **Cross-pack ID prefix collisions** — no two packs may share an ID prefix

### Local validation

```bash
# Single pack
me pack validate packs/git-history.yaml

# All packs (same checks as CI)
./scripts/validate.sh
```

The script requires `me` and [`yq`](https://github.com/mikefarah/yq) on PATH.

## License

[MIT](LICENSE)
