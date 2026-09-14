# autoclickers

## What this is
A small collection of macOS mouse-automation shell scripts: a mouse jiggler
(bounces the cursor to keep the machine awake), a grid clicker (clicks through a
list of points on an interval), a live coordinate finder, and a panic "stop all"
button. Hotkeys are wired up with `skhd` from a plain-text config, and an
`install.sh` copies the scripts into a bin dir and installs the hotkey config.
Personal-use utility; currently working and committed to git.

## Tech stack
- Language: Bash (plus one AppleScript variant of the jiggler)
- Mouse control: `cliclick` (Homebrew)
- Global hotkeys: `skhd` (Homebrew), config in `skhdrc`
- Platform: macOS (needs Accessibility permission for cliclick/skhd)

## Key memory files
Read these at session start:
- ~/.claude/projects/-Users-seidel-Documents-git-autoclickers/memory/MEMORY.md
- ~/.claude/projects/-Users-seidel-Documents-git-autoclickers/memory/project_current_state.md
- ScohBrain/Projects/autoclickers/Overview.md — also check its "Open
  questions" section for anything left by another project's agent

## Cross-project patterns
Read /Users/seidel/.claude/GLOBAL-PATTERNS.md — especially the shell/bash and macOS sections.

To write a new Knowledge note to the ScohBrain vault, use the Obsidian MCP server:
- `mcp__obsidian__vault_write` — create or overwrite a vault note (path is vault-relative, e.g. `Knowledge/[tech]/[topic].md`)
- `mcp__obsidian__vault_append` — append to an existing vault note
- `mcp__obsidian__vault_patch` — patch a section of an existing vault note

Do not use the Write tool with an absolute path into the vault, and never use relative paths like `./ScohBrain/...` — that writes into this repo, not the vault. The MCP server requires the Local REST API plugin running on `127.0.0.1:27123` and `OBSIDIAN_API_KEY` set; if MCP is unavailable, ask the user to start Obsidian rather than falling back to direct filesystem writes.

When creating or updating any note, always set frontmatter fields:
- `updated`: today's date (YYYY-MM-DD)
- `updated_by`: your name or "Claude" if an AI wrote/edited it

**Make.md folder notes:** Make.md is installed and uses the folder's own name as its folder
note (e.g. `Fungistics/Fungistics.md`). Do not create a file named after its parent folder
unless you intend it as a Make.md folder note. Use `Overview.md` for project summaries.

## Active work
Consolidated all scripts into the repo, added `install.sh` (with `--no-hotkeys`
and `--uninstall`), `skhdrc` hotkey config, README, and `.gitignore`. Repo
initialized on `main`. Nothing in progress.

## Security rules
(inherits from ~/.claude/CLAUDE.md — do not duplicate)
