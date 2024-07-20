package_manager() {
  local command="$1"

  local manager
  local authorizer="sudo"
  local args__install
  local args__uninstall
  local args__get_manually_installed
  local args__get_available

  set_opts off
  local args__user_args="$2"
  set_opts on

  if [ "$OS" = "FreeBSD" ]; then
    manager="pkg"
    args__get_manually_installed='query -e "%a = 0" "%n"'
    args__install='install'
    args__uninstall='delete'
    args__update='update'
    args__get_available="rquery -a '%n'"
  fi

  # shellcheck disable=SC2086
  if [ "$command" = 'get_manually_installed' ]; then
    eval $manager "$args__get_manually_installed"
  elif [ "$command" = 'install' ]; then
    $authorizer $manager $args__install $args__user_args
  elif [ "$command" = 'uninstall' ]; then
    $authorizer $manager $args__uninstall $args__user_args
  elif [ "$command" = 'update' ]; then
    $authorizer $manager $args__update
  elif [ "$command" = 'get_available' ]; then
    eval $manager "$args__get_available"
  else
    log debug "[package_manager] Unexpected command: $command"
  fi
}
