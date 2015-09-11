# Theme and appearance extras

# Default to visible indicators for most VCS elements

# VCS indicator styling for OMZ
ZSH_THEME_GIT_PROMPT_PREFIX=""
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

# themen: load a theme by index
#
# Usage:
#    themen      - advance to the next theme
#    themen <n>  - load theme number <n>
#
# Load a theme selected by index into list of defined themes, instead of by
# name. This is to make it easy to cycle through all the themes for debugging
# purposes.
#
# If called without an argument, it just advances to the next theme in the list
#
# This is redundant with my pending PR 3743, which adds a "theme <n>" calling
# form to the main theme() function
# https://github.com/robbyrussell/oh-my-zsh/pull/3743
function themen() {
  # Numeric index argument: select theme by index 
  local themes n name
  themes=($(lstheme))
  themes=(${themes:|ZSH_BLACKLISTED_THEMES})
  if [[ -z $1 ]]; then
    # Advance to next theme
    # ... darn. Can't do that without knowing the current theme
    #local last_n=${themes[(i)$]}

    # Screw it, we'll use a global variable and our own iteration sequence
    if [[ -n $APJ_LAST_THEME_N ]]; then
      (( n = $APJ_LAST_THEME_N + 1 ))
    else
      n=1
    fi
    else
    n=$1
  fi
  name=${themes[$n]}
  echo "Loading theme #$n: $name"
  APJ_LAST_THEME_N=$n
  theme $name
  }

