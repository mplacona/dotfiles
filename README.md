# Marcos Placona's dotfiles

Shell, prompt, tmux, git, ssh, Ghostty/cmux and Homebrew setup, kept the same on every Mac.

## New Mac

```sh
xcode-select --install          # git, if it isn't there yet
git clone https://github.com/mplacona/dotfiles ~/dotfiles
~/dotfiles/install.sh           # add --profile server on the Mac mini
```

Then open a new terminal.

## Keeping Macs in sync

```sh
cd ~/dotfiles && git pull && ./install.sh
```

`install.sh` is safe to run any time. It only fixes what's missing, and a second run changes nothing.
Run `./install.sh --check` to see what's out of place without changing anything.

| Option | What it does |
| --- | --- |
| `--profile laptop` (default) | Command-line tools plus desktop apps (`Brewfile.apps`) and nvm |
| `--profile server` | Command-line tools only. Used on the Mac mini. Remembered for later runs |
| `--no-brew` | Skip Homebrew |
| `--macos` | Also apply Finder settings from `macos.sh` |

## What goes where

- **Linked into `~`:** `.zshrc`, `.zprofile`, `.aliases`, `.p10k.zsh`, `.vimrc`, `.vim`, `.tmux.conf`, `.gitconfig`, `~/.config/ghostty/config`, `~/.config/cmux/bootstrap-workspaces.sh`. Anything already there is moved to `~/.dotfiles-backup/<date>/` first.
- **`~/.ssh/config`** stays a normal file for machine-specific hosts. It starts with `Include ~/dotfiles/ssh/config`.
- **Homebrew:** `Brewfile` holds the command-line tools for every Mac. `Brewfile.apps` holds desktop apps for laptops. Nothing is ever upgraded or removed by the installer.
- **Folders:** `~/Projects` and its standard subfolders are created on every Mac.
- **Machine-specific and secret settings** go in git-ignored files: `~/.zshrc.local`, `~/.zprofile.local` and `~/.gitconfig.local`. See `.zshrc.local.example`.

## Other bits

- `bin/remote-tmux user@host session` attaches to a tmux session on another Mac over ssh and reconnects when the lid is closed or the network changes. `hermes` and `clientwork` use it. It uses ssh rather than mosh because mosh drops clickable links.
- `porg/` runs local Supabase stacks on porg. See `porg/README.md`.
- After a fresh install, run `vim +PluginInstall +qall` once to fetch the vim plugins.
