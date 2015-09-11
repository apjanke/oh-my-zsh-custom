# Andrew Janke's ZSH theme

# This theme is intended for use and tested with the Solarized theme for iTerm2,
# and especially the solarized-dark theme. It may be ugly otherwise.
#
# Logic is based on "My Extravagant Zsh Prompt" and the "agnoster" oh-my-zsh 
# theme (https://gist.github.com/agnoster/3712874)
#
# TODO: Replace "$(...)" capturing subshell calls with regular function calls
# that use shared variables, to improve performance, especially on Windows.

# Calm ls colors without bold directories or red executables
# This is designed for a light-on-dark theme
export LSCOLORS="gxfxdxdxdxexexdxdxgxgx"
export LS_COLORS=$(omz_lscolors_bsd_to_gnu $LSCOLORS)
# Make completion LS_COLORS consistent with main LS_COLORS
zstyle -e ':completion:*' list-colors 'reply=${(s.:.)LS_COLORS}'

# The prompt

# Top-level function for dynamic part of prompt
function build_prompt_front {
  # Flags indicating status:
  # - was there an error (cyan ✘)
  # - am I root (red #, like bash's root-indicating prompt)
  print -n '%(?::%F{yellow}✘%f )%(#:%F{red}#%f :)'
  # Display user info, abbreviating default case
  if [[ "$USER" == $ZSH_DEFAULT_USER && -z "$SSH_CLIENT" ]]; then
    if [[ -n "$SSH_CLIENT" ]]; then
      # Default user on remote host: just "@host"
      print -n "%F{yellow}@%m%f "
    fi
  else
    # Otherwise, show "user@host"
    print -n "%F{yellow}%n@%m%f "
  fi
}

if [[ $OSTYPE == cygwin ]]; then
  # Skip git info on Windows because it is too slow
  PROMPT="[$(build_prompt_front)%F{blue}%~%f]
$ "
else
  PROMPT="[$(build_prompt_front)%F{blue}%~%f\$(git_prompt_info)]
$ "
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


