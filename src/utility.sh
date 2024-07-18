# utility functions

log() {
  local level="$1"
  local message="$2"

  if [ "$level" = fatal ]; then
    echo "[tori] $(date "+%H:%M:%S"): $message" 1>&2
  elif [ "$level" = user ]; then
    echo "[tori] $(date "+%H:%M:%S"): $message" 1>&2
  elif [ -n "$DEBUG" ] && [ "$level" = debug ]; then
    echo "$(date "+%H:%M:%N") $message" 1>&2
  fi
}

set_opts() {
  sign="$1"

  set_opt() {
    local opt="$1"

    if set -o | grep -q "^$opt[[:space:]]"; then
      set "${sign}o" "$opt"
      log debug "[set_opts] Set: $(set -o | grep -q "^$opt[[:space:]]")"
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
