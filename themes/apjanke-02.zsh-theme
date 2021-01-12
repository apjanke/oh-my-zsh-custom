# apjanke-02.zsh-theme
#
# A single-line variant of apjanke-01
#
# Author: Andrew Janke <andrew@apjanke.net>

# Calm ls colors without bold directories or red executables
# This is designed for a light-on-dark theme
export LSCOLORS="gxxxdxdxdxexexdxdxgxgx"
export LS_COLORS=$(omz_lscolors_bsd_to_gnu $LSCOLORS)
# GNU-specific extras
LS_COLORS="${LS_COLORS}:ln=00;04"
# Make completion LS_COLORS consistent with main LS_COLORS
zstyle -e ':completion:*' list-colors 'reply=${(s.:.)LS_COLORS}'

# The prompt

() {

# Flags indicating status:
# - am I root (red #, like bash's root-indicating prompt)
local first_bit='%(#:%F{red}#%f :)'
# User info, abbreviating default case
if [[ " ${ZSH_DEFAULT_USERS[@]} " =~ " $USER " ]]; then
  if [[ -n "$SSH_CLIENT" ]]; then
    # Default user on remote host: just "@host"
    first_bit+="%F{blue}@%m%f "
  fi
  # Default user on local host: show nothing
else
  # Otherwise, "user@host"
  first_bit+="%F{blue}%n@%m%f "
fi
first_bit+='%F{cyan}%1~%f'
# - was there an error (bright ✘)
local flags='%(?::%F{yellow}✘$?%f )'

PROMPT="[$flags$first_bit] \$ "

if [[ $OSTYPE == cygwin ]]; then
  # Skip git info on Windows because it is too slow
else
  RPROMPT="\$(git_prompt_info)"
fi

# VCS indicator styling for OMZ
ZSH_THEME_GIT_PROMPT_PREFIX="[on ⇄ "
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{green}±%f"
ZSH_THEME_GIT_PROMPT_TIMEDOUT=" %F{yellow}?%f"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %F{green}?%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_SUFFIX="]"

}

