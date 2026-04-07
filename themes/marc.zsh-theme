# Marc's custom theme
# Git status with simple theme style (✗ for dirty, ✔ for clean)
# Worktree-aware: suppresses branch name when it matches the worktree dir,
# and colors the path segments (repo in muted green, worktree in cyan).

# Detect if cwd is inside a git worktree (not the main working tree)
function _is_git_worktree() {
    local toplevel=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
    local commondir=$(git -C "$toplevel" rev-parse --git-common-dir 2>/dev/null) || return 1
    [[ -n "$toplevel" && "$commondir" != ".git" && "$commondir" != "$toplevel/.git" ]]
}

# Detect if cwd is directly inside a bare repo (e.g. ~/git/synctera/achilles.git)
function _is_bare_repo_dir() {
    [[ -f "$PWD/HEAD" && -d "$PWD/refs" && -d "$PWD/objects" ]]
}

# Function to conditionally show user@host
function prompt_user_host() {
    local user="${(%):-%n}"
    local host="${(%):-%m}"

    if [[ "$user" != "marc" || "$host" != "marcfedora" ]]; then
        echo "%F{magenta}${user}%f@%F{green}${host}%f:"
    fi
}

# Custom git status: ahead/behind counts, staged/dirty indicator, branch name
# In worktrees where branch == directory name, suppresses the branch text
function git_custom_status() {
    # Skip entirely in bare repos — branch/status are meaningless there
    if _is_bare_repo_dir; then
        return
    fi
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch="$(git_current_branch)"
        local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
        local state=""
        if [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ]]; then
            state="|REBASE"
        elif [[ -f "$git_dir/MERGE_HEAD" ]]; then
            state="|MERGE"
        elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
            state="|CHERRY-PICK"
        fi
        local status_output="$(git status --porcelain 2>/dev/null)"
        local staged=$(echo "$status_output" | grep -c '^[MADRC]')
        local dirty=$(echo "$status_output" | grep -c '^.[MD]')

        # Ahead/behind counts
        local ahead=0 behind=0
        local ab=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
        if [[ -n "$ab" ]]; then
            ahead=${ab%%$'\t'*}
            behind=${ab##*$'\t'}
        fi

        # Decide whether to show branch name
        local show_branch=true
        if _is_git_worktree && [[ "$branch" == "${PWD:t}" ]]; then
            show_branch=false
        fi

        # Symlink indicator: muted grey L→ if PWD is via symlink
        local symlink_hint=""
        if [[ "$PWD" != "$(realpath "$PWD" 2>/dev/null)" ]]; then
            symlink_hint="%F{245}L→ %f"
        fi

        if $show_branch; then
            echo -n " %{$fg[cyan]%}(${symlink_hint}$branch%{$fg[red]%}${state}%{$fg[cyan]%} "
        else
            echo -n " %{$fg[cyan]%}(${symlink_hint}%{$fg[red]%}${state}%{$fg[cyan]%}"
        fi

        # Show ahead/behind before the status icon, no space between ↑ and ↓
        local has_ab=false
        if [[ $ahead -gt 0 || $behind -gt 0 ]]; then
            has_ab=true
        fi
        if [[ $ahead -gt 0 ]]; then
            echo -n "%{$fg[green]%}↑${ahead}"
        fi
        if [[ $behind -gt 0 ]]; then
            echo -n "%{$fg[red]%}↓${behind}"
        fi
        if $has_ab; then
            echo -n " "
        fi

        if [[ $dirty -gt 0 ]]; then
            echo -n "%{$fg[red]%}✗"
        elif [[ $staged -gt 0 ]]; then
            echo -n "%{$fg[yellow]%}+"
        else
            echo -n "%{$fg[green]%}✔"
        fi

        echo -n "%{$fg[cyan]%})"
    fi
}

# Build a colored repo path: prefix in yellow, repo in sage green,
# optional highlight segment in cyan, subdirs in yellow.
# Falls back to plain yellow %~ if PWD doesn't match the expected toplevel
# (e.g. when accessed via symlink).
function _color_repo_path() {
    local repo_name="$1"
    local repo_prefix="$2"
    local toplevel="$3"       # working tree root (for subdir computation); empty to skip
    local highlight_name="$4" # optional segment after repo in cyan (e.g. worktree name)

    # Symlink guard: PWD must start with toplevel, otherwise fall back
    if [[ -n "$toplevel" && "$PWD" != "$toplevel"* ]]; then
        return 1
    fi

    if [[ "$repo_prefix" == "$HOME"* ]]; then
        repo_prefix="~${repo_prefix#$HOME}"
    fi

    local result="%F{yellow}${repo_prefix}/%F{65}${repo_name}%f"

    if [[ -n "$highlight_name" ]]; then
        result+="%F{245}/[wt]%F{yellow}/%F{cyan}${highlight_name}%f"
    fi

    if [[ -n "$toplevel" ]]; then
        local subdir="${PWD#$toplevel}"
        if [[ -n "$subdir" ]]; then
            result+="%F{yellow}${subdir}"
        fi
    fi

    echo -n "${result}%f"
}

# Path with colored segments:
#   - prefix path: yellow (preserves command-boundary visibility)
#   - repo dir: darker sage green (%F{65})
#   - worktree dir: cyan (matches branch color)
#   - subdirs: yellow
# Falls back to plain yellow %~ outside git repos or when accessed via symlink.
function prompt_path() {
    # Worktree: color repo + worktree segments
    if _is_git_worktree 2>/dev/null; then
        local toplevel=$(git rev-parse --show-toplevel 2>/dev/null)
        local commondir=$(git -C "$toplevel" rev-parse --git-common-dir 2>/dev/null)
        local repo_root="${commondir%/.git}"
        if [[ "$repo_root" != /* ]]; then
            repo_root=$(cd "$toplevel/$repo_root/.." 2>/dev/null && pwd)
        fi
        _color_repo_path "${repo_root:t}" "${repo_root:h}" "$toplevel" "${toplevel:t}" && return
    fi

    # Bare repo dir: just the repo name in sage green
    if _is_bare_repo_dir; then
        _color_repo_path "${PWD:t}" "${PWD:h}" "" "" && return
    fi

    # Regular git repo: repo folder in sage green
    local toplevel=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$toplevel" ]]; then
        _color_repo_path "${toplevel:t}" "${toplevel:h}" "$toplevel" "" && return
    fi

    echo -n "%F{yellow}%~%f"
}

setopt PROMPT_SUBST
PROMPT='%F{red}%D{%H:%M}$(git_custom_status) $(prompt_user_host)$(prompt_path)%f$ '
