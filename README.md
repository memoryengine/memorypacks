# memory packs

Pre-built knowledge and skills for [memory engine](https://memory.build) — import a YAML file, get instant value.

## What are memory packs?

A memory pack is a YAML file containing engrams (memories) that you import with `me pack import`. No code, no plugins, no running processes.

Packs may contain a mix of:

- **Reference knowledge** — static content that's useful immediately after import
- **Skill instructions** — procedural content that teaches AI agents how to perform tasks
- **Temporal context** — time-bounded information with start/end dates

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
| [pack-authoring](packs/pack-authoring.yaml) | How to write effective memory packs — skill engram structure, reference engram craft, organization, ID/versioning, and quality checklist |
| [skill-to-pack](packs/skill-to-pack.yaml) | Convert Agent Skills (agentskills.io) into memory engine packs — format reference, conversion procedure, field mapping, and edge cases |

## Pack format

Each pack is a standard engram YAML file. The only required convention is `meta.pack: {name, version}` and deterministic IDs:

```yaml
# Pack: example
# Version: 0.1.0
# ID prefix: 019b0000

- id: "019b0000-0001-7000-8000-000000000001"
  tree: "tools.example.skill"
  meta:
    pack:
      name: "example"
      version: "0.1.0"
  content: |
    # Example Skill — What This Does

    Instructions for an agent...
```

### Conventions

- **Meta**: must include `meta.pack` as an object with `name` and `version` — this is the only required convention
- **IDs**: deterministic UUIDv7 with a fixed prefix per pack (makes re-imports idempotent)
- **Tree**: pack authors choose tree paths for discoverability — no fixed prefix required
- **Content**: non-empty, self-contained, follows [engram best practices](https://memory.build)

Additional meta keys (like `type`, `topic`, etc.) are optional — add whatever makes your content discoverable and filterable.

### ID allocation

Each pack claims a unique UUIDv7 prefix. Document it in a comment at the top of your file.

| Prefix | Pack |
|--------|------|
| `019b0001` | pack-authoring |
| `019b0002` | skill-to-pack |

When adding a new pack, choose the next available prefix.

## Upgrading packs

`me pack import` handles version-aware upgrades automatically:

```bash
# First import: installs v0.1.0
me pack import packs/git-history.yaml
# Imported 1 engram, deleted 0 (pack: git-history@0.1.0)

# After updating the file to v0.2.0:
me pack import packs/git-history.yaml
# Imported 2 engrams, deleted 1 (pack: git-history@0.2.0)
```

Old-version engrams are automatically cleaned up. Engrams that exist in both versions are updated in place (deterministic IDs).

## Contributing

1. Fork this repository
2. Create your pack as a YAML file in `packs/`
3. Validate with `me pack validate packs/your-pack.yaml`
4. Submit a pull request

All packs must:
- Follow the format conventions above
- Use a unique ID prefix (check the table above)
- Include a header comment with pack name, version, description, and ID prefix
- Have non-empty, well-written content
- Have consistent `meta.pack.name` and `meta.pack.version` across all engrams

## Validation & CI

Every pack is validated on push and pull request via GitHub Actions. The workflow checks:

1. **Per-pack validation** — schema, IDs, meta.pack consistency
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
