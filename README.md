# skills

My agent skills, picked from several skill stacks and trimmed to plain folders. Claude Code and OpenCode both read them. `/index` shows them grouped by development stage, each with a short code to run it.

## Layout

- `skills/`: one folder per skill, each with a `SKILL.md`.
- `references/`: shared checklists from addyosmani/agent-skills. His skills link them as `../../references/`.
- `index.txt`: the table `/index` shows.
- `claude-mod/skills-index/`: a Claude Code mod that adds `/index` and prints `index.txt` without a model call.
- `opencode/commands/index.md`: the OpenCode `/index` command.

## Sources

| Author      | Repo                                     |
| ----------- | ---------------------------------------- |
| superpowers | obra/superpowers                         |
| matt        | mattpocock/skills                        |
| addy        | addyosmani/agent-skills                  |
| cursor      | cursor/plugins (pstack, cursor-team-kit) |

Where each skill came from. `local` means the skill is rewritten here and has no upstream copy.

| Skill                       | Repo                                                       | Upstream path                                       |
| --------------------------- | ---------------------------------------------------------- | --------------------------------------------------- |
| code-review-and-quality     | addyosmani/agent-skills                                    | skills/code-review-and-quality                      |
| code-simplification         | addyosmani/agent-skills                                    | skills/code-simplification                          |
| comment-sicko               | local (pstack agents/comment-sicko.md from cursor/plugins) | none                                                |
| documentation-and-adrs      | addyosmani/agent-skills                                    | skills/documentation-and-adrs                       |
| deslop                      | cursor/plugins                                             | cursor-team-kit/skills/deslop                       |
| grill-me                    | local (grilling from mattpocock/skills)                    | none                                                |
| handoff                     | mattpocock/skills                                          | skills/productivity/handoff                         |
| idea-refine                 | addyosmani/agent-skills                                    | skills/idea-refine                                  |
| incremental-implementation  | addyosmani/agent-skills                                    | skills/incremental-implementation                   |
| interview-me                | addyosmani/agent-skills                                    | skills/interview-me                                 |
| planning-and-task-breakdown | addyosmani/agent-skills                                    | skills/planning-and-task-breakdown                  |
| pr                          | mattpocock/skills                                          | skills/engineering/pr                               |
| pr-bullets                  | local                                                      | none                                                |
| auto                        | local                                                      | none                                                |
| receiving-code-review       | obra/superpowers                                           | skills/receiving-code-review                        |
| security-and-hardening      | addyosmani/agent-skills                                    | skills/security-and-hardening                       |
| technical-writing           | cursor/plugins                                             | harness/pstack/claude-code/skills/technical-writing |
| unslop                      | cursor/plugins                                             | harness/pstack/claude-code/skills/unslop            |
| wait-what                   | mattpocock/skills                                          | skills/productivity/wait-what                       |

## Install

The agents read skills from these paths:

- OpenCode: `~/.agents/skills/`
- Claude Code: `~/.claude/skills/`, which can't point at a folder of skills as a whole, so each skill gets its own link.

```sh
ln -sfn ~/workspace/skills/skills ~/.agents/skills
ln -sfn ~/workspace/skills/references ~/.agents/references
ln -sfn ~/workspace/skills/index.txt ~/.agents/skills-index.txt
for s in ~/workspace/skills/skills/*/; do ln -sfn "$s" ~/.claude/skills/"$(basename "$s")"; done
```

Run the loop again after adding a skill. After removing one, clear the dead links:

```sh
find -L ~/.claude/skills -maxdepth 1 -type l -delete
```

OpenCode also scans `~/.claude/skills/`. To keep it from listing every skill twice, add this to `~/.zshrc`:

```sh
export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1
```

### `/index`

Claude Code: add the mod folder to the `env` block of `~/.claude/settings.json`.

```json
"CLAUDE_CODE_PLUGIN_DIRS": "~/workspace/skills/claude-mod/skills-index"
```

OpenCode:

```sh
mkdir -p ~/.config/opencode/commands
ln -sfn ~/workspace/skills/opencode/commands/index.md ~/.config/opencode/commands/index.md
```

## Use

Inside a claude or Opencode session, write command `/index`.
