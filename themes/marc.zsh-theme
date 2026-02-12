# Marc's custom theme
# Git status with simple theme style (✗ for dirty, ✔ for clean)

# Function to conditionally show user@host
function prompt_user_host() {
    local user="${(%):-%n}"
    local host="${(%):-%m}"

    if [[ "$user" != "marc" || "$host" != "marcfedora" ]]; then
        echo "%F{magenta}${user}%f@%F{green}${host}%f:"
    fi
}

# Git prompt style from simple theme
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[blue]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[blue]%})"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔"

setopt PROMPT_SUBST
PROMPT='%F{red}%D{%H:%M}$(git_prompt_info) $(prompt_user_host)%F{yellow}%~%f$ '
