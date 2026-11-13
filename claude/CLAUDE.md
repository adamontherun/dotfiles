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
