# Global Claude Instructions

## About Me
- Joe Van Dyk (joevandyk@crowdcow.com)
- Senior developer at Crowd Cow — a DTC meat/seafood e-commerce platform
- Primary stack: Rails 7 + Ruby 3, Vue 2, MySQL, Sidekiq, Elasticsearch
- Also work with: Elixir, Go, Ansible, Docker
- Editor mode: vi (set -o vi in shell)
- Shell: zsh with oh-my-zsh (robbyrussell theme)
- macOS (Apple Silicon) with Homebrew
- Version manager: asdf (ruby, node, python, elixir, erlang)

## Preferences
- Run Claude Code with --dangerously-skip-permissions (bypass mode)
- Default model: opus
- Keep things simple and direct — avoid over-engineering
- Prefer editing existing files over creating new ones
- Don't add unnecessary comments, docstrings, or type annotations
- Use git credential helper via `gh auth` (not SSH keys for GitHub)

## Tmux Window Naming
- Always use `-t $TMUX_PANE` to target the correct window: `tmux rename-window -t $TMUX_PANE '<name>'`
- Use a short label (max 12 chars) describing the work
- Examples: `experiments`, `ship-plan`, `email-fix`, `promo-bug`
- Reset to `ready` when done (e.g. via `/new-work`)

## Infrastructure
- Remote dev server (devbox): OVH bare-metal Debian 13, Ansible-provisioned, Tailscale-only access
- Secrets management: Doppler
- Cloudflare Pages for static hosting (manual deploys with wrangler)
- MCP servers: Asana

## Key Projects
- **crowdcow** (~/projects/crowdcow) — main Rails app, has its own CLAUDE.md
- **devbox** (~/projects/devbox) — Ansible playbooks for remote dev environment
- **dotfiles** (~/projects/dotfiles) — personal dotfiles, symlinked to ~

## PR Labels
- **`ai-working`**: Claude is actively making code changes. Always remove other status labels when setting this.
- **`good-to-go`**: CI is green, all reviews addressed, no open questions — PR is ready for deploy.
- **`waiting-for-human`**: Claude needs the user to answer a question or make a decision before proceeding.
- **Do NOT use `waiting-for-review`** — this label is not needed.
- **When the user asks you to work on a branch/PR**, immediately set `ai-working` (use a subagent if needed to avoid blocking).
- **When you finish working** (ship-it complete, task done, waiting for user), **remove `ai-working`** immediately. Don't leave it on after you're done.
- Only one status label at a time. When setting a new one, remove all others:
  `gh pr edit --add-label <new> --remove-label ai-working --remove-label good-to-go --remove-label waiting-for-human`

## Dotfiles Sync
- Dotfiles repo: joevandyk/dotfiles on GitHub
- Managed files: .zshrc, .zshenv, .gitconfig, .tmux.conf, .tool-versions, .claude/settings.json, .claude/.mcp.json, .claude/CLAUDE.md
- Sync method: symlinks from ~ to ~/projects/dotfiles/
- **Exception**: `~/.claude/skills/` cannot be symlinked (Claude doesn't follow symlinks for skills). Files are copied, not symlinked. After editing skills, sync manually:
  - To dotfiles: `cp -r ~/.claude/skills/ ~/projects/dotfiles/.claude/skills/`
  - From dotfiles: `cp -r ~/projects/dotfiles/.claude/skills/ ~/.claude/skills/`
