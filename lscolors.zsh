# Converts BSD-style LSCOLORS values to their GNU-style LS_COLORS equivalent
#
# BSD color codes are in the ls man page on BSD (including OS X).
#
# GNU color codes found at http://linux-sxs.org/housekeeping/lscolors.html
# and http://leocharre.com/articles/setting-ls_colors-colors-of-directory-listings-in-bash-terminal/
#
# Note that in the Solarized colorscheme, the colors defined for "bright" ANSI colors
# are not brighter or lighter versions of the regular color, but are used for various
# extra shades of grey. That is an intentional behavior of Solarized, and not a bug with
# this conversion code.
#
# Usage:
#
#    omz_lscolors_bsd_to_gnu <bsd_color_string>
#
# Where <bsd_color_string> is a color specifier string in BSD $LSCOLORS format.
# It will look like "gxfxdxdxdxexexdxdxgxgx"
function omz_lscolors_bsd_to_gnu() {
  emulate -L zsh
  local bsd=$1
  local -a bsd_positions
  bsd_positions=( di ln so pi ex bd cd su sg tw ow)
  local -A fg_map
  local -A bg_map bg_map_bright
  # The BSD ls manual talks about "bold" standard ANSI colors, which the terminal may map to bright
  # colors, or draw in bold text.
  # The GNU LS definition has both a bold flag ("1") and bright variants of all the colors.
  # Experimentally, it looks like they really are using bold text, and the bold variants of
  # background colors have no effect. (Tested on OS X 10.9)
  # TODO: should maybe add a flag that allows mapping bold colors to bright colors instead
  # of bold text, in both fg and bg.
  fg_map=(
    x 0       # default
    a 8       # black
    b 31      # red
    c 32      # green
    d 33      # orange, AKA brown
    e 34      # blue
    f 35      # magenta, AKA purple
    g 36      # cyan
    h 37      # light grey
    A "8;1"   # bold black
    B "31;1"  # bold red
    C "32;1"  # bold green
    D "33;1"  # bold orange
    E "34;1"  # bold blue
    F "35;1"  # bold magenta
    G "36;1"  # bold cyan
    H "37;1"  # bold light grey
  )
  fg_map_bright=(
    x 0     # default
    a 8     # black
    b 31    # red
    c 32    # green
    d 33    # orange, AKA brown
    e 34    # blue
    f 35    # magenta, AKA purple
    g 36    # cyan
    h 37    # light grey
    A 90    # bright black
    B 91    # bright red
    C 92    # bright green
    D 93    # bright orange
    E 94    # bright blue
    F 95    # bright magenta
    G 96    # bright cyan
    H 97    # bright light grey
  )
  bg_map=(
    x ""    # default
    a 40    # black background
    b 41    # red background
    c 42    # green background
    d 43    # orange background
    e 44    # blue background
    f 45    # magenta background
    g 46    # cyan background
    h 47    # light grey background
    A 40    # black background
    B 41    # red background
    C 42    # green background
    D 43    # orange background
    E 44    # blue background
    F 45    # magenta background
    G 46    # cyan background
    H 47    # light grey background
  )
  bg_map_bright=(
    x ""    # default
    a 40    # black background
    b 41    # red background
    c 42    # green background
    d 43    # orange background
    e 44    # blue background
    f 45    # magenta background
    g 46    # cyan background
    h 47    # light grey background
    A 100   # bright black background
    B 101   # bright red background
    C 102   # bright green background
    D 103   # bright orange background
    E 104   # bright blue background
    F 105   # bright magenta background
    G 106   # bright cyan background
    H 107   # bright light brey background
  )

  local i fg bg gnu gnu_name gnu_fg gnu_bg gnu_code gnu_item
  gnu=()
  for (( i = 1; i <= $#bsd_positions; i++ )) do
    gnu_type_name=$bsd_positions[i]
    fg=$bsd[1+2*(i-1)]
    bg=$bsd[2+2*(i-1)]
    gnu_fg=$fg_map[$fg]
    gnu_bg=$bg_map[$bg]
    if [[ -z $gnu_fg ]]; then
      print "omz_lscolors_bsd_to_gnu: unrecognized BSD color code \"$fg\" for item \"$gnu_type_name\" fg. Using default." >&2
      gnu_fg="0"
    fi
    # Hack: we can omit explicit "default" colors since we don't use other flags
    if [[ $gnu_fg == "0" ]]; then
      gnu_fg=""
    fi
    if [[ $bg != x && -z $gnu_bg ]]; then
      print "omz_lscolors_bsd_to_gnu: unrecognized BSD color code \"$bg\" for item \"$gnu_type_name\" bg. Using default." >&2
    fi
    gnu_code=()
    if [[ -n $gnu_fg ]]; then
      gnu_code+=$gnu_fg
    fi
    if [[ -n $gnu_bg ]]; then
      gnu_code+=$gnu_bg
    fi
    gnu_code=${(pj<;>)gnu_code}
    if [[ -n $gnu_code ]]; then
      gnu_item="${gnu_type_name}=$gnu_code"
      gnu+=$gnu_item
    fi
  done

  gnu=${(pj<:>)gnu}
  print $gnu
}

# Tests the color map using BSD and GNU ls
# Assumes that on this system, `ls` is BSD ls and `gls` is GNU ls.
# If your system is different, set $BSD_LS and/or $GNU_LS to the appropriate 
# commands.
function omz_lscolors_bsd_to_gnu_test() {
  local BSD_LS=${BSD_LS:=ls}
  local GNU_LS=${GNU_LS:=gls}

  if [[ -n $1 ]]; then
    local LSCOLORS=$1
    export LSCOLORS
    shift 1
  fi
  local LS_COLORS=$(omz_lscolors_bsd_to_gnu $LSCOLORS)
  export LS_COLORS
  print "BSD ls: $LSCOLORS"
  print
  $BSD_LS $@
  print
  print "GNU ls: $LS_COLORS"
  print
  $GNU_LS --color $@
  print
}

