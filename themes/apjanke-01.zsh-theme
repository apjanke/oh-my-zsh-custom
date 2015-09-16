# apjanke-01 Andrew Janke's main zsh theme
#
# Author: Andrew Janke <andrew@apjanke.net>

# This theme is intended for use and tested with the Solarized theme for iTerm2,
# and especially the solarized-dark theme. It may be ugly otherwise.
#
# Inspirations: 
# * "My Extravagant Zsh Prompt"
# * The "agnoster" oh-my-zsh theme (https://gist.github.com/agnoster/3712874)
#
# TODO: Replace "$(...)" capturing subshell calls with regular function calls
# that use shared variables, to improve performance, especially on Windows.

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
# - was there an error (bright ✘)
# - am I root (red #, like bash's root-indicating prompt)
local first_bit='%(?::%F{yellow}✘%f )%(#:%F{red}#%f :)'
# User info, abbreviating default case
if [[ "$USER" == $ZSH_DEFAULT_USER ]]; then
  if [[ -n "$SSH_CLIENT" ]]; then
    # Default user on remote host: just "@host"
    first_bit+="%F{blue}@%m%f "
  fi
  # Default user on local host: show nothing
else
  # Otherwise, "user@host"
  first_bit+="%F{blue}%n@%m%f "
fi
first_bit+='%F{cyan}%~%f'
local line2=''

if [[ $OSTYPE == cygwin ]]; then
  # Skip git info on Windows because it is too slow
  PROMPT="[$first_bit]
$line2\$ "
else
  PROMPT="[$first_bit\$(git_prompt_info)]
$line2\$ "
fi

# VCS indicator styling for OMZ
ZSH_THEME_GIT_PROMPT_PREFIX=" on ⇄ "
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{green}±%f"
ZSH_THEME_GIT_PROMPT_TIMEDOUT=" %F{yellow}?%f"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %F{green}?%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""

}

