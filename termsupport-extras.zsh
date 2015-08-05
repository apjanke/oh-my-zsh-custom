# termsupport-extras.zsh
#
# Andrew Janke's (apjanke) extensions to the termsupport.zsh stuff.

# One-shot auto setting of window title using precmd logic
# Ignores DISABLE_AUTO_TITLE
# (Probably only useful for testing, since once you cd then you have a stale title)
function autotitle {
  DISABLE_AUTO_TITLE=false omz_termsupport_precmd
}

# Enable autotitle support
function autotitle_enable {
  DISABLE_AUTO_TITLE=false
}

# Quote a terminal escape string, terminfo-style
# This makes control sequences from $terminfo readable
#
# Example:
#  tiquote $terminfo[kcuu1]
function tiquote {
  emulate -L zsh
  local str out i ch
  local ESC=$'\033'
  str="$1"
  out=""
  for ((i = 1; i <= ${#str}; ++i)); do
    ch="$str[i]"
    #printf "%s: ch is %s\n" $i "$ch"
    if [[ $ch == "$ESC" ]]; then
      out+="\\E"
    else
      out+="$ch"
    fi
  done
  printf '%s\n' "$out"
}

# Avoid duplication of directory in window title
if [[ $TERM_PROGRAM == Apple_Terminal ]]; then
  ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<" #15 char left truncated PWD
  ZSH_THEME_TERM_TITLE_IDLE="%n@%m"
fi

