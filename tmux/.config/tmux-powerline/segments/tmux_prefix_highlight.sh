# shellcheck shell=bash
# Shows copy mode and sync status (prefix mode is too transient for polling)

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

TMUX_POWERLINE_SEG_COPY_PROMPT_DEFAULT="COPY"
TMUX_POWERLINE_SEG_SYNC_PROMPT_DEFAULT="SYNC"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Custom prompts for each mode
export TMUX_POWERLINE_SEG_COPY_PROMPT="${TMUX_POWERLINE_SEG_COPY_PROMPT_DEFAULT}"
export TMUX_POWERLINE_SEG_SYNC_PROMPT="${TMUX_POWERLINE_SEG_SYNC_PROMPT_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings

	# Get custom prompts from tmux-prefix-highlight plugin if set
	local copy_prompt=$(tmux show-option -gqv @prefix_highlight_copy_prompt 2>/dev/null)
	local sync_prompt=$(tmux show-option -gqv @prefix_highlight_sync_prompt 2>/dev/null)
	local show_copy_mode=$(tmux show-option -gqv @prefix_highlight_show_copy_mode 2>/dev/null)
	local show_sync_mode=$(tmux show-option -gqv @prefix_highlight_show_sync_mode 2>/dev/null)

	# Use defaults if not set
	[ -z "$copy_prompt" ] && copy_prompt="$TMUX_POWERLINE_SEG_COPY_PROMPT"
	[ -z "$sync_prompt" ] && sync_prompt="$TMUX_POWERLINE_SEG_SYNC_PROMPT"

	# Check states
	local pane_in_mode=$(tmux display-message -p '#{pane_in_mode}' 2>/dev/null)
	local sync_panes=$(tmux display-message -p '#{pane_synchronized}' 2>/dev/null)

	# Show status based on priority: copy mode > sync
	if [ "$show_copy_mode" = "on" ] && [ "$pane_in_mode" = "1" ]; then
		echo "$copy_prompt"
		return 0
	fi

	if [ "$show_sync_mode" = "on" ] && [ "$sync_panes" = "1" ]; then
		echo "$sync_prompt"
		return 0
	fi

	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_COPY_PROMPT" ]; then
		export TMUX_POWERLINE_SEG_COPY_PROMPT="${TMUX_POWERLINE_SEG_COPY_PROMPT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_SYNC_PROMPT" ]; then
		export TMUX_POWERLINE_SEG_SYNC_PROMPT="${TMUX_POWERLINE_SEG_SYNC_PROMPT_DEFAULT}"
	fi
}
