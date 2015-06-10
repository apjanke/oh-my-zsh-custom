# Full replacement for OMZ's completion setup

# I don't quite like OMZ's completion configuration behavior, and its
# completion setup code is too complicated for me to follow,
# so I'm rebuilding my own set of simpler completion options as I learn them.

setopt always_to_end
setopt no_menu_complete
setopt no_auto_menu
setopt no_complete_in_word

zmodload -i zsh/complist

zstyle ':completion:*' completer _complete _ignored

# Settings "list-colors {(s.:.)LS_COLORS}" here doesn't work because LS_COLORS is 
# not set up at lib load time; it's set up in the theme, which is done after the lib
# is loaded.
# Must do this in ~/.zshrc after OMZ is loaded, or as part of the theme itself
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Leave a default set in place instead
zstyle ':completion:*' list-colors ''

# Lowercase matches uppercase but not vice-versa
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}'
