if [[ "$PAGER" == "head -n 10000 | cat" || "$COMPOSER_NO_INTERACTION" == "1" ]]; then
  return
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git gitfast brew zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Secrets and ~/.local/bin (via ~/.local/bin/env). Homebrew and system paths
# are set up in ~/.zprofile and /etc/zprofile.
source ~/.profile
source ~/.aliases

# ----------------------------------------------------------------------------
# PATH: each block prepends, so the last one added wins.
# ----------------------------------------------------------------------------

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# nvm, lazy loaded: the default node is on PATH straight away, and nvm.sh is
# only sourced the first time `nvm` itself is run. Node always comes from nvm.
# If the default alias can't be resolved to an installed version (e.g. lts/*),
# fall back to loading nvm eagerly.
export NVM_DIR="$HOME/.nvm"
_nvm_load() {
  unset -f nvm _nvm_load
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() { _nvm_load; nvm "$@"; }
_nvm_bin=""
if [[ -r "$NVM_DIR/alias/default" ]]; then
  _nvm_default="$(<"$NVM_DIR/alias/default")"
  _nvm_default="v${_nvm_default#v}"
  # Exact match (v24.22.0), else the newest installed match for a prefix (24 or v24.22)
  _nvm_bin=( "$NVM_DIR"/versions/node/${_nvm_default}(/N) "$NVM_DIR"/versions/node/${_nvm_default}.*(/NnOn) )
  _nvm_bin="${_nvm_bin[1]:+${_nvm_bin[1]}/bin}"
  unset _nvm_default
fi
if [[ -n "$_nvm_bin" ]]; then
  export PATH="$_nvm_bin:$PATH"
else
  _nvm_load
fi
unset _nvm_bin

# openssl
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ----------------------------------------------------------------------------
# Prompt and extras
# ----------------------------------------------------------------------------

# Powerlevel10k
if [[ -n "$CURSOR_AGENT" ]]; then
  : # skip theme init for Cursor Agent compatibility
else
  [[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh
fi

# Supabase local stacks run on porg, not on this machine's Docker
[[ -f ~/dotfiles/porg/porg.zsh ]] && source ~/dotfiles/porg/porg.zsh

# Machine-specific config (git-ignored)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Drop any duplicate PATH entries, keeping the first occurrence.
typeset -U path PATH
