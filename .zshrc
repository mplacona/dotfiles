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

# Core PATH - use $HOME everywhere so this works on any machine
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:$HOME/google-cloud-sdk/bin
export PATH=$PATH:$HOME/.rvm/gems/ruby-2.1.3/bin
export PATH=$PATH:$HOME/.rvm/gems/ruby-2.1.3@global/bin
export PATH=$PATH:$HOME/.rvm/rubies/ruby-2.1.3/bin
export PATH=$PATH:/usr/local/heroku/bin
export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export PATH=$PATH:/usr/local/git/bin
export PATH=$PATH:$HOME/Installs/depot_tools
export PATH=$PATH:/usr/local/mysql/bin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
export PATH=$PATH:/Applications/gradle-2.2/bin
export PATH=$PATH:$HOME/.rvm/bin
export PATH=$PATH:$HOME/.local/bin

source ~/.profile
source ~/.aliases

export PATH="$PATH:$HOME/.rvm/bin"
eval $(/usr/libexec/path_helper -s)
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.2

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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

# Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# zoxide
eval "$(zoxide init zsh)"

# Google Cloud SDK
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then
  source "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"
fi

# sdkman - must be at the end
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Powerlevel10k
if [[ -n "$CURSOR_AGENT" ]]; then
  : # skip theme init for Cursor Agent compatibility
else
  [[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh
fi

# Machine-specific config (git-ignored)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
