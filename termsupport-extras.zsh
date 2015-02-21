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