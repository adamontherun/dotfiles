# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

# ~/Documents/projects
Only GitHub clones live directly in ~/Documents/projects. Never create files or folders at that top level.
- Worktrees: inside the repo, at <repo>/.claude/worktrees/<name> (Claude Code's default), not ../<repo>-worktrees.
- Plans, notes, evidence, screenshots: inside the repo they belong to, or in the session scratchpad. Never in the parent folder.
- Throwaway or test apps: in the scratchpad or ~/.t3/scratch, not next to the clones.
- Clone a new repo here only when I ask for it.
- If a session starts with ~/Documents/projects itself as the working directory (cross-repo work), treat it as read-only: edit inside the individual repos and put everything else in the scratchpad.

# CLI installs
Never make `claude`, `codex` or another CLI on PATH run a copy bundled inside a desktop app (Claude.app, ChatGPT.app), whether through a wrapper script or a symlink. T3 Code can't update those copies. If a CLI is missing from PATH, install it the normal way (Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`; Codex: the `codex` cask in ~/dotfiles/Brewfile).
