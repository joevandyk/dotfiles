export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  history
  direnv
)

source $ZSH/oh-my-zsh.sh

# Elixir/Erlang
export ERL_AFLAGS="-kernel shell_history enabled"
