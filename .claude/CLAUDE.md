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

## Infrastructure
- Remote dev server (devbox): OVH bare-metal Debian 13, Ansible-provisioned, Tailscale-only access
- Secrets management: Doppler
- Cloudflare Pages for static hosting (manual deploys with wrangler)
- MCP servers: Asana

## Key Projects
- **crowdcow** (~/projects/crowdcow) — main Rails app, has its own CLAUDE.md
- **devbox** (~/projects/devbox) — Ansible playbooks for remote dev environment
- **dotfiles** (~/projects/dotfiles) — personal dotfiles, symlinked to ~

## Dotfiles Sync
- Dotfiles repo: joevandyk/dotfiles on GitHub
- Managed files: .zshrc, .zshenv, .gitconfig, .tmux.conf, .tool-versions, .claude/settings.json, .claude/.mcp.json, .claude/CLAUDE.md
- Sync method: symlinks from ~ to ~/projects/dotfiles/
