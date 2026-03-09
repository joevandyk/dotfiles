# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export PAGER="less -i"

ZSH_THEME="robbyrussell"

plugins=(git asdf brew dotenv)

source $ZSH/oh-my-zsh.sh

set -o vi

# Load file-based secrets for SSH sessions (no keychain needed)
if [[ -f ~/.secrets ]]; then
  source ~/.secrets
fi

# https://github.com/keybase/keybase-issues/issues/2798
export GPG_TTY=$(tty)

source ~/.zshenv

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Elixir/Erlang
export ERL_AFLAGS="-kernel shell_history enabled"
