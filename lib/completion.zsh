# Full replacement for OMZ's completion setup

# I'm not a fan of the completion behavior - too complicated and I can't follow it -
# so I'm rebuilding my own set of simpler completion options.

# In particular, I don't like the zsh/complist behavior.

setopt always_to_end
setopt no_menu_complete
setopt no_auto_menu
setopt no_complete_in_word

zmodload -i zsh/complist

zstyle ':completion:*' completer _complete _ignored

# This doesn't work because LS_COLORS is not set up at lib load time
# Must do this again after theme is loaded, or as part of theme
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Leave a default set in place instead
zstyle ':completion:*' list-colors ''

# Lowercase matches uppercase but not vice-versa
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}'
