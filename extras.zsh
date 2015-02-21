# Miscellaneous oh-my-zsh extras


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
function themen() {
    # Numeric index argument: select theme by index 
    local themes n name
    themes=($(lstheme))
    if [[ -z $1 ]]; then
    	# Advance to next theme
    	# ... darn. Can't do that without knowing the current theme
    	#local last_n=${themes[(i)$]}

    	# Screw it, we'll use a global variable
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