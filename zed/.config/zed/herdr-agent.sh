#!/bin/sh
# Bridge Zed's Terminal Threads into Herdr.
#
# Wired to Zed's `agent.terminal_init_command`: each Terminal Thread shell gets a
# fresh Herdr workspace running Claude Code, and Zed's terminal attaches to it.
# The workspace outlives the Zed terminal, so the session stays resumable from
# the Herdr TUI.
#
# Overrides: HERDR_BIN, ZED_HERDR_AGENT_KIND (any `herdr agent start --kind`).

set -u

HERDR=${HERDR_BIN:-herdr}
AGENT_KIND=${ZED_HERDR_AGENT_KIND:-claude}

# Anything unexpected (no Herdr, no server, agent refuses to start) degrades to
# running the agent directly in Zed's terminal.
fallback() {
    exec "$AGENT_KIND"
}

command -v "$HERDR" >/dev/null 2>&1 || fallback
command -v jq >/dev/null 2>&1 || fallback

label=$(basename "$PWD")
# Agent names must match [a-z][a-z0-9_-]{0,31}; the pid goes first so truncation
# can never collide with a concurrent terminal thread.
slug=$(printf '%s' "$label" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-')
name=$(printf 'zed-%s-%s' "$$" "$slug" | cut -c1-32)

workspace=$("$HERDR" workspace create --cwd "$PWD" --label "$label" --no-focus 2>/dev/null) || fallback
pane=$(printf '%s' "$workspace" | jq -r '.result.root_pane.pane_id // empty')
workspace_id=$(printf '%s' "$workspace" | jq -r '.result.workspace.workspace_id // empty')
[ -n "$pane" ] || fallback

if ! "$HERDR" agent start "$name" --kind "$AGENT_KIND" --pane "$pane" >/dev/null 2>&1; then
    # `agent start` also reports failure when the agent came up but is waiting on
    # a prompt; only tear the workspace down if nothing is actually running.
    if ! "$HERDR" agent get "$name" >/dev/null 2>&1; then
        [ -n "$workspace_id" ] && "$HERDR" workspace close "$workspace_id" >/dev/null 2>&1
        fallback
    fi
fi

exec "$HERDR" agent attach "$name"
