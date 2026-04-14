# shellcheck shell=bash
# Shows worktree name if in a .worktrees/ dir, otherwise git branch name.

# shellcheck source=lib/tmux_adapter.sh
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"

TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN="${TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN:-24}"
TMUX_POWERLINE_SEG_VCS_BRANCH_TRUNCATE_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_TRUNCATE_SYMBOL:-…}"
TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL:-}"
TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL:-$TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR:-5}"

run_segment() {
	local tmux_path label

	tmux_path=$(tp_get_tmux_cwd)

	# Priority 1: worktree directory name
	if [[ "$tmux_path" =~ /.worktrees/([^/]+) ]]; then
		label="${BASH_REMATCH[1]}"
	else
		# Priority 2: git branch name
		cd "$tmux_path" || return
		local branch
		if branch=$(git symbolic-ref --short HEAD 2>/dev/null); then
			label="$branch"
		elif branch=$(git rev-parse --short HEAD 2>/dev/null); then
			label=":$branch"
		else
			# Priority 3: nothing
			return 0
		fi
	fi

	label=$(__truncate_label "$label")
	echo -n "#[fg=colour${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL} #[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${label}"
	return 0
}

__truncate_label() {
	local label="$1"
	if [ "${#label}" -gt "$TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN" ]; then
		label="${label:0:$((TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN - ${#TMUX_POWERLINE_SEG_VCS_BRANCH_TRUNCATE_SYMBOL}))}"
		label="${label}${TMUX_POWERLINE_SEG_VCS_BRANCH_TRUNCATE_SYMBOL}"
	fi
	echo -n "$label"
}
