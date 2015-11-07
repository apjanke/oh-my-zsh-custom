
# omz_bindkey_dump()
#
# Dumps the current bindkey state, including mappings to terminal keys using 
# terminfo.
#
# Output is displayed as a human-readable table which includes:
#  - The character sequence that is bound
#  - The terminal capability names matching that sequence for the current $TERM
#  - The command this character sequence is bound to
#
# As a hack, you may set $TERM before running this to see what the capability map
# looks like in other terminals. This is not guaranteed to work in all situations.
#
#    TERM=rxvt-unicode omz_bindkey_dump
function omz_bindkey_dump() {

  # Display the active keymap
  bindkey -l -L main

  local header_format="%-8s   %-20s   %-20s";
  local table_format="%8s   %-20s   %-20s";

  printf "$header_format\n" "Key"       "Capability"      ""
  printf "$header_format\n" "Sequence"  "($TERM)"         "Command"

  # This is an ugly hack because zsh doesn't have real array references
  local code="$(bindkey | sed -e 's/\(.*\)/_omz_bindkey_dump_step \1/')"
  eval $code
}

function _omz_bindkey_dump_step() {
  local is_range=0
  if [[ $1 == "-R" ]]; then
    is_range=1
    shift
  fi

  local keys="$1"
  local name="$2"
  # Replace bindkey escapes with echo-able escapes
  local keys2=${keys:s/^[/\\e/}
  local literal_keys="$(echo -ne $keys2)"
  #printf "Literal keys: %s - %s\n" "$(tiquote $literal_keys)" "$literal_keys"

  # Terminal capabilities bound to this thing
  # This is not a full list, unfortunately, because custom capabilities defined
  # in $terminfo are not exposed in their list of keys.
  local -a caps
  local cap

  if [[ $is_range == 0 ]]; then
    for cap ( ${(k)terminfo} ); do
      if [[ "$terminfo[$cap]" == "$literal_keys" ]]; then
        caps+=$cap
      fi
    done
  fi
  caps_str=${(j:,:)caps}

  printf "$table_format\n" "$keys" "$caps_str" "$name"
}