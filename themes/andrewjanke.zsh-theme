# Andrew Janke's ZSH theme

# This theme is intended for use and tested with the Solarized theme for iTerm2,
# and especially the solarized-dark theme. It may be ugly otherwise.
#
# Logic is based on "My Extravagant Zsh Prompt" and the "agnoster" oh-my-zsh 
# theme (https://gist.github.com/agnoster/3712874)

# Calm ls colors without bold directories or red executables
export LSCOLORS="gxfxcxdxdxegedabagacad"


# Useful characters: ⇄ • ☿ ✘ ↕
# Prompt
function prompt_char_from_vcs {
    git branch >/dev/null 2>/dev/null && echo '⇄ ' && return
    # Disabling the hg check for speed reasons
    # hg root >/dev/null 2>/dev/null && echo '☿' && return
    echo '$'
}

# Builds flags indicating status:
# - was there an error
# - am I root
function prompt_status {
    local symbols
    symbols=()
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}ROOT"

    [[ -n "$symbols" ]] && echo -n "$symbols %{$reset_color%}"
}

# Display user info, abbreviating default case
function prompt_user {
    if [[ "$USER" != $ZSH_DEFAULT_USER || -n "$SSH_CLIENT" ]]; then
        echo -n "%{$fg[cyan]%}%n@%m%{$reset_color%} "
    else
        echo -n "%{$fg[cyan]%}@%{$reset_color%} "
    fi
}

# Top-level function for dynamic part of prompt
function build_prompt_front {
    RETVAL=$?
    prompt_status
    prompt_user
}

# Remove user@host for simplification
PROMPT='[$(build_prompt_front)in %{$fg[yellow]%}%~%{$reset_color%}$(git_prompt_info)]
$ '


ZSH_THEME_GIT_PROMPT_PREFIX=" on ⇄ "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[green]%}±"
ZSH_THEME_GIT_PROMPT_TIMEDOUT=" %{$fg[yellow]%}?"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"


# Dynamic dir updates for iTerm2 or other xterm lookalikes
# (Temporarily disabled while I try out manual tab name management 12/2014 )
if false && [[ "$TERM_PROGRAM" == "iTerm.app" ]] && [[ -z "$INSIDE_EMACS" ]]; then
    update_terminal_title_cwd() {
        echo -ne "\033]0;${HOST%%.*}: ${PWD/#$HOME/~}\007"
    }

    # Run function at each prompt
    precmd_functions+=(update_terminal_title_cwd)

    # Tell the terminal about the initial directory.
    update_terminal_title_cwd
fi


