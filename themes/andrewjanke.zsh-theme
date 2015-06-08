# Andrew Janke's ZSH theme

# This theme is intended for use and tested with the Solarized theme for iTerm2,
# and especially the solarized-dark theme. It may be ugly otherwise.
#
# Logic is based on "My Extravagant Zsh Prompt" and the "agnoster" oh-my-zsh 
# theme (https://gist.github.com/agnoster/3712874)

# Calm ls colors without bold directories or red executables
#export LSCOLORS="gxfxdxdxdxexexdxdxgxgx"
export LSCOLORS="exfxdxdxdxexexdxdxgxgx"
# GNU version of same scheme
#export LS_COLORS="di=36:ln=35:so=33:pi=33:ex=33:bd=34:cd=34:su=33:sg=33:tw=36:ow=36:"
export LS_COLORS="di=34:ln=35:so=33:pi=33:ex=33:bd=34:cd=34:su=33:sg=33:tw=36:ow=36:"

# Sets prompt character based on what kind of repo you're in
# (Not currently used)
# Useful characters: ⇄ • ☿ ✘ ↕
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
    echo -n '%(?::%F{cyan}✘%f )%(#:%F{yellow}ROOT %f:)'
}

# Display user info, abbreviating default case
function prompt_user {
    if [[ "$USER" != $ZSH_DEFAULT_USER || -n "$SSH_CLIENT" ]]; then
        echo -n "%F{cyan}%n@%m%f "
    else
        echo -n "%F{cyan}@%f "
    fi
}

# Top-level function for dynamic part of prompt
function build_prompt_front {
    local RETVAL=$?
    prompt_status
    prompt_user
}

# The prompt

if [[ $OSTYPE == cygwin ]]; then
    # Skip git info on Windows because it is too slow
    PROMPT='[$(build_prompt_front)in %F{yellow}%~%f]
$ '
else
    PROMPT='[$(build_prompt_front)in %F{yellow}%~%f$(git_prompt_info)]
$ '
fi

# VCS indicator styling
ZSH_THEME_GIT_PROMPT_PREFIX=" on ⇄ "
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{green}±%f"
ZSH_THEME_GIT_PROMPT_TIMEDOUT=" %F{yellow}?%f"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %F{green}?%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""

ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE='(ahr)'
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE='(bhr)'
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE='(dvr)'
ZSH_THEME_GIT_PROMPT_AHEAD='(ah)'
ZSH_THEME_GIT_PROMPT_BEHIND='(bh)'
ZSH_THEME_GIT_PROMPT_DIVERGED='V'
ZSH_THEME_GIT_PROMPT_SHA_BEFORE='['
ZSH_THEME_GIT_PROMPT_SHA_AFTER=']'
ZSH_THEME_GIT_PROMPT_ADDED='A'
ZSH_THEME_GIT_PROMPT_MODIFIED='M'
ZSH_THEME_GIT_PROMPT_RENAMED='R'
ZSH_THEME_GIT_PROMPT_DELETED='D'
ZSH_THEME_GIT_PROMPT_STASHED='(stash)'
ZSH_THEME_GIT_PROMPT_UNMERGED='U'
ZSH_THEME_GIT_PROMPT_UNTRACKED='+'

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

# Completion LS_COLORS need to be set *after* LS_COLORS is set up
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
