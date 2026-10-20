# Login-shell setup: Homebrew and the base PATH. Interactive setup is in ~/.zshrc.

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Obsidian CLI
[[ -d /Applications/Obsidian.app/Contents/MacOS ]] && export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# User binaries (Claude Code, Codex, Hermes, uv)
export PATH="$HOME/.local/bin:$PATH"

# Persistent agents and concurrent SQLite readers can legitimately need more
# than macOS's inherited 256-file soft limit.
ulimit -n 65536 2>/dev/null || true

# Machine-specific login config (git-ignored)
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local
