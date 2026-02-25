# memory packs

Pre-built knowledge and skills for [memory engine](https://memory.build) — import a YAML file, get instant value.

## What are memory packs?

A memory pack is a YAML file containing engrams (memories) that you import with `me engram import`. No code, no plugins, no running processes.

There are two kinds:

- **Knowledge packs** — static reference content that's useful immediately after import
- **Skill packs** — procedural instructions that teach AI agents how to populate memory from external sources (git, Slack, filesystems, etc.)

Skill packs are the interesting part: import one file, and an agent — using only the MCP tools it already has — can create hundreds of engrams. The system bootstraps itself.

## Quick start

```bash
# Import a pack
me engram import packs/git-history.yaml

# Preview what will be imported
me engram import --dry-run packs/git-history.yaml

# Import all packs in a directory
me engram import --recursive packs/
```

## Available packs

| Pack | Type | Description |
|------|------|-------------|
| *coming soon* | | |

## Pack format

Each pack is a standard engram YAML file with conventions for `tree`, `meta`, and `id`:

```yaml
# Pack: example
# Version: 0.1.0
# ID prefix: 019b0000

- id: "019b0000-0001-7000-8000-000000000001"
  tree: "packs.example.skill"
  meta:
    type: "skill"
    pack: "example"
    pack_version: "0.1.0"
    source: "pack"
  content: |
    # Example Skill — What This Does

    Instructions for an agent...
```

### Conventions

- **Tree**: `packs.<pack_name>.*` — lowercase, dot-separated, underscores for multi-word names
- **Meta**: must include `type`, `pack`, `pack_version`, and `source: "pack"`
- **IDs**: deterministic UUIDv7 with a fixed prefix per pack (makes re-imports idempotent)
- **Content**: non-empty, self-contained, follows [engram best practices](https://memory.build)

## Writing a pack

### Knowledge packs

Write engrams the same way you'd write any memory — specific, self-contained, concise. Use `type: "reference"` in meta.

### Skill packs

Skill pack content is a prompt addressed to an agent. Structure it like this:

```
# Title — What This Skill Does

<1-2 sentence overview>

## What to Extract
<What's worth creating memories for>
<What to skip>

## How to Extract
<Numbered steps referencing specific MCP tool names>

## Example Output
<Complete me_engram_create call with all fields>

## Scope Control
<Limits to prevent runaway extraction>
```

Guidelines:
- Use MCP tool names directly (`me_engram_create`, `me_engram_search`)
- Include complete examples with all fields filled in
- Prescribe tree and meta conventions — don't leave organization to the agent
- Always include a duplicate-check step before creation
- Set explicit scope limits ("last 50 commits", not "all commits")

### ID allocation

Each pack claims a unique UUIDv7 prefix. Document it in a comment at the top of your file.

| Prefix | Pack |
|--------|------|
| `019b0000` | git-history |
| `019b0100` | project-bootstrap |
| `019b0200` | pack-authoring |

When adding a new pack, choose the next available prefix.

## Contributing

1. Fork this repository
2. Create your pack as a YAML file in `packs/`
3. Validate with `me engram import --dry-run packs/your-pack.yaml`
4. Submit a pull request

All packs must:
- Follow the format conventions above
- Use a unique ID prefix (check the table above)
- Include a header comment with pack name, version, description, and ID prefix
- Have non-empty, well-written content

## License

[MIT](LICENSE)
