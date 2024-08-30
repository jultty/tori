# utility functions

log() {
  local level="$1"
  local message="$2"

  print_user_message() {
    printf "%b\n" "[tori] $(date "+%H:%M:%S"): $1" 1>&2
  }

  print_debug_message() {
    printf "%b\n" "$(date "+%H:%M:%N") $1" 1>&2
  }

  if [ -z "$DEBUG" ]; then
    DEBUG=3
  elif ! echo "$DEBUG" | grep -q '^[[:number:]]$'; then
    echo "[log] Warning: DEBUG should always be set to a number. Assuming DEBUG=3 (warn)"
    DEBUG=3
  fi

  if [ -z "$DEBUG_DISABLED_WARNING" ] && [ "$DEBUG" -eq 0 ]; then
    echo "[log] Warning: Setting DEBUG=0 disables all logging except for user messages"
    echo "      Use a value beween 1 (fatal) and 5 (debug). The default level is 3 (warn)"
    DEBUG_DISABLED_WARNING=1
  elif [ "$DEBUG" -gt 5 ]; then
    echo "[log] Warning: Assuming DEBUG maximum level of 5 (debug) over provided level $DEBUG"
    DEBUG=5
  fi

  if [ "$level" = user ]; then
    print_user_message "$message"
  elif [ "$DEBUG" -ge 1 ] && [ "$level" = fatal ]; then
    print_user_message "$message"
  elif [ "$DEBUG" -ge 2 ] && [ "$level" = error ]; then
    print_user_message "$message"
  elif [  "$DEBUG" -ge 3 ] && [ "$level" = warn ]; then
    print_user_message "$message"
  elif [ "$DEBUG" -ge 4 ] && [ "$level" = info ]; then
    print_debug_message "$message"
  elif [ "$DEBUG" -ge 5 ] && [ "$level" = debug ]; then
    print_debug_message "$message"
  fi
}

confirm() {
  local question="$1"
  local answer=
  read -rp "$question [y/N] " answer

  if [ "$answer" == y ] || [ "$answer" == Y ]; then
    return 0;
  else
    return 1;
  fi
}

ask() {
  local question="$1"
  local options="$2"
  local answer=
  local options_count=0
  local dialog_options=

  local IFS=,
  for option in $options; do
    _=$((options_count+=1))
    dialog_options="$dialog_options\n [$options_count] $option"
  done;
  IFS=

  printf "%s" "$question" >&2
  printf "%b" "$dialog_options" >&2
  printf "\n%s" "Choose an option [1-$options_count] " >&2
  read -r read_answer
  answer="$(echo "$read_answer" | xargs)"

  if [ "$answer" -gt 0 ] 2> /dev/null && [ "$answer" -le $options_count ]; then
    echo "$answer"
  else
    log debug "[ask] Invalid choice"
    return 1
  fi
}

tildify() {
  echo "$1" | sed "s*$HOME*~*"
}

set_opts() {
  local target="$1"
  local sign=

  if [ "$target" = on ]; then
    sign='-'
  elif [ "$target" = off ]; then
    sign='+'
  else
    log fatal "Invalid set_opts target: $target. Expected on or off"
    return 1
  fi

  set_opt() {
    local opt="$1"

    if set -o | grep -q "^$opt[[:space:]]"; then
      set "${sign}o" "$opt"
      log debug "[set_opts] Set: $(set -o | grep "^$opt[[:space:]]")"
    else
      log fatal "Unsupported shell: no $opt option support"
      return 1
    fi
  }

  set_opt errexit
  set_opt nounset
  set_opt pipefail
}

prepare_directories() {
  if ! [ -d "$TMP_DIR" ]; then
    mkdir "$TMP_DIR"
  fi

  if ! [ -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR"
  fi

  if ! [ -d "$CONFIG_ROOT" ]; then
    log fatal "Configuration root not found at $CONFIG_ROOT"
    exit 1
  fi
}

print_help() {
  printf "\n  tori: configuration managent and system replication tool\n"
  printf "\n    Options:\n\n"
  printf "\tcheck\t\tcompare configuration to system state\n"
  printf "\tcache\t\trefresh the local package cache\n"
  printf "\n"
  printf "\tversion\t\tprint current version with release date\n"
  printf "\thelp\t\tshow this help text\n"
  printf "\n  See 'man tori' or https://tori.jutty.dev/docs for more help\n\n"
}
