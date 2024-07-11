# utility functions

log() {
  local level="$1"
  local message="$2"

  if [ $level = fatal ]; then
    printf "[tori] $(date "+%H:%M:%S"): $message\n" 1>&2
  elif [ $level = user ]; then
    printf "[tori] $(date "+%H:%M:%S"): $message\n" 1>&2
  elif [ -n "$DEBUG" ] && [ $level = debug ]; then
    printf "$(date "+%H:%M:%N") $message\n" 1>&2
  fi
}

set_opts() {
  sign="$1"

  set "${sign}o" errexit
  set "${sign}o" nounset
  set "${sign}o" pipefail
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
  printf "\n  See 'man tori' or https://brew.bsd.cafe/jutty/tori for more\n\n"
}
