#!/usr/bin/env bash
# Recreate the standard cmux workspace layout on any of my Macs.
#
#   ~/.config/cmux/bootstrap-workspaces.sh
#
# Idempotent: a workspace whose name already exists is left alone, so it is
# safe to re-run. Remote sessions attach to the SAME tmux sessions on the
# Mac Mini (`tmux new -As`), so deathstar and millenium share one set of
# long-running agents. Quitting cmux never kills those; tmux on the mini owns them.

set -euo pipefail

MINI_HOST="${MINI_HOST:-mplacona@mac-mini}"   # Tailscale MagicDNS name

CMUX="$(command -v cmux 2>/dev/null || true)"
if [ -z "$CMUX" ] || [ ! -x "$CMUX" ]; then
  CMUX="/Applications/cmux.app/Contents/Resources/bin/cmux"
fi
[ -x "$CMUX" ] || { echo "cmux CLI not found. Is cmux installed?" >&2; exit 1; }
export CMUX_QUIET=1

"$CMUX" ping >/dev/null 2>&1 || { echo "cmux is not running. Start it first." >&2; exit 1; }

# Print the workspace ref (workspace:N) for a given name, or nothing.
ref_for() {
  "$CMUX" workspace list 2>/dev/null \
    | sed -E 's/^[* ]+//' \
    | awk -v want="$1" '{ ref=$1; $1=""; sub(/^ +/,""); sub(/ +\[selected\]$/,""); if ($0==want) { print ref; exit } }'
}

# ensure_workspace <name> <color> <description> <cwd> [layout-json]
# Echoes "<ref> exists" or "<ref> created" on stdout; progress goes to stderr.
ensure_workspace() {
  local name="$1" color="$2" desc="$3" cwd="$4" layout="${5:-}"
  local ref

  ref="$(ref_for "$name")"
  if [ -n "$ref" ]; then
    echo "  = $name ($ref, exists, untouched)" >&2
    printf '%s exists' "$ref"
    return 0
  fi

  local args=(new-workspace --name "$name" --cwd "$cwd" --focus false)
  # A description is only set where it encodes a rule worth the sidebar line.
  # The name and the directory row already say what the workspace is.
  [ -n "$desc" ]   && args+=(--description "$desc")
  [ -n "$layout" ] && args+=(--layout "$layout")

  # new-workspace prints "OK workspace:N"
  ref="$("$CMUX" "${args[@]}" 2>/dev/null | grep -oE 'workspace:[0-9]+' | head -1)"
  if [ -z "$ref" ]; then
    echo "  ! $name (creation failed)" >&2
    return 1
  fi

  "$CMUX" workspace-action --action set-color --color "$color" --workspace "$ref" >/dev/null 2>&1 || true
  "$CMUX" workspace-action --action pin --workspace "$ref" >/dev/null 2>&1 || true
  echo "  + $name ($ref)" >&2
  printf '%s created' "$ref"
}

# Helpers for the "<ref> <status>" pairs returned above.
ref_of()    { printf '%s' "${1%% *}"; }
status_of() { printf '%s' "${1##* }"; }

MINI_LAYOUT=$(cat <<JSON
{"direction":"horizontal","split":0.5,"children":[
 {"pane":{"surfaces":[{"type":"terminal","command":"$HOME/dotfiles/bin/remote-tmux ${MINI_HOST} hermes"}]}},
 {"pane":{"surfaces":[{"type":"terminal","command":"$HOME/dotfiles/bin/remote-tmux ${MINI_HOST} clientwork"}]}}
]}
JSON
)

echo "cmux workspaces:" >&2

# Remote: the only thing that lives here is the mini's long-running agents.
MINI_RESULT="$(ensure_workspace "Mac Mini" Blue \
  "Nothing local belongs here." \
  "$HOME" "$MINI_LAYOUT")"
MINI_REF="$(ref_of "$MINI_RESULT")"

# Local work, one workspace per unit of work.
CLIENT_REF="$(ref_of "$(ensure_workspace "Client Work"   Purple ""                               "$HOME/Projects/Work/DevRelWork")")"
LI_REF="$(ref_of     "$(ensure_workspace "LinkIntel"     Indigo ""                               "$HOME/Projects/JavaScript/LinkIntel")")"
DB_REF="$(ref_of     "$(ensure_workspace "DevRel Bridge" Teal   ""                               "$HOME/Projects/JavaScript/DevRelBridge")")"
IOS_REF="$(ref_of    "$(ensure_workspace "iOS"           Orange "One Swift project per surface." "$HOME/Projects/Swift")")"

# Name the two Mac Mini tabs: left pane = Hermes, right pane = ClientWork.
# `list-pane-surfaces` without --pane only reports the FOCUSED pane, so walk
# the panes explicitly. Deliberately avoids `mapfile` (absent in bash 3.2).
# Only on first creation, so hand-edited tab names are never clobbered on re-run.
if [ -n "$MINI_REF" ] && [ "$(status_of "$MINI_RESULT")" = "created" ]; then
  mini_i=0
  for p in $("$CMUX" list-panes --workspace "$MINI_REF" 2>/dev/null | grep -oE 'pane:[0-9]+' || true); do
    s="$("$CMUX" list-pane-surfaces --workspace "$MINI_REF" --pane "$p" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)"
    [ -n "$s" ] || { mini_i=$((mini_i + 1)); continue; }
    case $mini_i in
      0) "$CMUX" rename-tab --workspace "$MINI_REF" --surface "$s" "⚫ Hermes"     >/dev/null 2>&1 || true ;;
      1) "$CMUX" rename-tab --workspace "$MINI_REF" --surface "$s" "🟢 ClientWork" >/dev/null 2>&1 || true ;;
    esac
    mini_i=$((mini_i + 1))
  done
fi

ORDER="$(printf '%s\n' "$MINI_REF" "$CLIENT_REF" "$LI_REF" "$DB_REF" "$IOS_REF" \
         | grep -v '^$' | paste -sd, -)"
[ -n "$ORDER" ] && "$CMUX" reorder-workspaces --order "$ORDER" >/dev/null 2>&1 || true

echo >&2
echo "Done. Workspace order: Mac Mini, Client Work, LinkIntel, DevRel Bridge, iOS" >&2
