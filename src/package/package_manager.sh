package_manager() {
  local command="$1"
  local output

  local manager
  local authorizer="sudo" # TODO: make configurable
  local args__install
  local args__uninstall
  local args__get_manually_installed

  set_opts +
  local args__user_args="$2"
  set_opts -

  if [ $OS = "FreeBSD" ]; then
    manager="pkg"
    args__get_manually_installed='query -e "%a = 0" "%n"'
    args__install='install'
    args__uninstall='delete'
  fi

  # shellcheck disable=SC2086
  if [ "$command" = 'get_manually_installed' ]; then
    eval $manager "$args__get_manually_installed"
  elif [ "$command" = 'install' ]; then
    $authorizer $manager $args__install $args__user_args
  elif [ "$command" = 'uninstall' ]; then
    $authorizer $manager $args__uninstall $args__user_args
  else
    log debug "[package_manager] Unexpected command: $command"
  fi
}
