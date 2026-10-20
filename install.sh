#!/bin/bash
# Set up (or repair) this Mac from ~/dotfiles. Safe to run any number of times:
# anything already in place is left alone, and a second run changes nothing.
#
#   ./install.sh                    set up a laptop (links, shell, Homebrew, apps)
#   ./install.sh --profile server   no desktop apps or nvm (the Mac mini)
#   ./install.sh --check            only report what is missing; change nothing
#   ./install.sh --no-brew          skip Homebrew packages
#   ./install.sh --macos            also apply macos.sh (Finder settings)
#
# The profile is remembered in ~/.config/dotfiles/profile.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_FILE="$HOME/.config/dotfiles/profile"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

check=0 brew=1 macos=0 profile=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)   check=1 ;;
    --no-brew) brew=0 ;;
    --macos)   macos=1 ;;
    --profile) profile="${2:-}"; shift ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1 (see --help)" >&2; exit 2 ;;
  esac
  shift
done

if [ -z "$profile" ]; then
  profile="$(cat "$PROFILE_FILE" 2>/dev/null || echo laptop)"
fi
case "$profile" in laptop|server) ;; *) echo "--profile must be laptop or server" >&2; exit 2 ;; esac

changes=0 problems=0
say()     { printf '%s\n' "$*"; }
changed() { changes=$((changes + 1)); if [ "$check" = 1 ]; then say "  ✗ $*"; else say "  + $*"; fi; }
problem() { problems=$((problems + 1)); say "  ! $*"; }

# Move something out of the way into this run's backup folder.
backup() {
  local rel="${1#"$HOME"/}"
  mkdir -p "$BACKUP/$(dirname "$rel")"
  mv "$1" "$BACKUP/$rel"
  say "    (old copy kept in ${BACKUP/#$HOME/~}/$rel)"
}

# link <path in repo> <path under $HOME>
link() {
  local src="$DOTFILES/$1" dest="$HOME/$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    return
  fi
  changed "link ~/$2 → ${src/#$HOME/~}"
  [ "$check" = 1 ] && return
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    # A machine's own login settings carry on in the .local file instead of a backup.
    if [ "$2" = .zprofile ] && [ ! -L "$dest" ] && [ ! -e "$HOME/.zprofile.local" ]; then
      mv "$dest" "$HOME/.zprofile.local"
      say "    (previous ~/.zprofile kept as ~/.zprofile.local)"
    else
      backup "$dest"
    fi
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
}

# clone_once <url> <dir> [tag-or-branch]
clone_once() {
  [ -d "$2" ] && return
  changed "install ${2/#$HOME/~}"
  [ "$check" = 1 ] && return
  git -c advice.detachedHead=false clone --quiet --depth 1 ${3:+--branch "$3"} "$1" "$2"
}

# ---------------------------------------------------------------------------
say "dotfiles: ${DOTFILES/#$HOME/~} (profile: $profile$([ "$check" = 1 ] && echo ', check only'))"
if [ "$DOTFILES" != "$HOME/dotfiles" ]; then
  problem "this repo should live at ~/dotfiles; .zshrc and .aliases expect it there"
fi

if [ "$check" = 0 ]; then
  mkdir -p "$(dirname "$PROFILE_FILE")"
  [ "$(cat "$PROFILE_FILE" 2>/dev/null)" = "$profile" ] || echo "$profile" > "$PROFILE_FILE"
fi

say "Folders"
for dir in Projects Projects/Archive Projects/Content Projects/Hardware Projects/JavaScript \
           Projects/PHP Projects/Python Projects/Ruby Projects/Setup Projects/Swift Projects/Work \
           .local/bin; do
  if [ ! -d "$HOME/$dir" ]; then
    changed "create ~/$dir"
    [ "$check" = 1 ] || mkdir -p "$HOME/$dir"
  fi
done

say "Links"
link .zshrc .zshrc
link .zprofile .zprofile
link .aliases .aliases
link .p10k.zsh .p10k.zsh
link .vimrc .vimrc
link .vim .vim
link .tmux.conf .tmux.conf
link .gitconfig .gitconfig
link config/ghostty/config .config/ghostty/config
link config/cmux/bootstrap-workspaces.sh .config/cmux/bootstrap-workspaces.sh

# ~/.ssh/config stays a normal file for machine-specific hosts; it just includes ours.
include="Include $DOTFILES/ssh/config"
if ! grep -qxF "$include" "$HOME/.ssh/config" 2>/dev/null; then
  changed "add '$include' to ~/.ssh/config"
  if [ "$check" = 0 ]; then
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    # Include must come before any Host block to apply to every host.
    { echo "$include"; echo; cat "$HOME/.ssh/config" 2>/dev/null || true; } > "$HOME/.ssh/config.new"
    chmod 600 "$HOME/.ssh/config.new"
    mv "$HOME/.ssh/config.new" "$HOME/.ssh/config"
  fi
fi

say "Shell"
clone_once https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
clone_once https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
clone_once https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
clone_once https://github.com/VundleVim/Vundle.vim.git "$DOTFILES/.vim/bundle/Vundle.vim"
if [ "$profile" = laptop ]; then
  clone_once https://github.com/nvm-sh/nvm.git "$HOME/.nvm" v0.40.3
fi

if [ "$brew" = 1 ]; then
  say "Homebrew"
  if [ ! -x /opt/homebrew/bin/brew ]; then
    changed "install Homebrew"
    if [ "$check" = 0 ]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  fi
  if [ -x /opt/homebrew/bin/brew ]; then
    brewfiles="Brewfile"
    [ "$profile" = laptop ] && brewfiles="Brewfile Brewfile.apps"
    for bf in $brewfiles; do
      if ! /opt/homebrew/bin/brew bundle check --no-upgrade --file="$DOTFILES/$bf" >/dev/null 2>&1; then
        changed "install what's missing from $bf"
        if [ "$check" = 0 ]; then
          /opt/homebrew/bin/brew bundle install --no-upgrade --file="$DOTFILES/$bf" \
            || problem "some of $bf failed to install (see above); re-run to retry"
        fi
      fi
    done
  fi
fi

if [ "$macos" = 1 ] && [ "$check" = 0 ]; then
  say "macOS settings"
  "$DOTFILES/macos.sh"
fi

say ""
if [ "$changes" = 0 ]; then
  say "✓ Everything already in place."
elif [ "$check" = 1 ]; then
  say "$changes thing(s) to set up. Run ./install.sh to fix."
else
  say "✓ Made $changes change(s). Open a new terminal to pick them up."
fi
[ "$problems" = 0 ] || say "$problems problem(s) above need a look."

if [ "$check" = 1 ] && [ "$changes" -gt 0 ]; then exit 1; fi
[ "$problems" = 0 ]
