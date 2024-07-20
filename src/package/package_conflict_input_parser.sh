package_conflict_input_parser() {
  local packages="$1"
  local conflict_type="$2"
  local input="$TMP_DIR/package_conflict_input"
  local input_choices="$TMP_DIR/package_conflict_input_choices"
  local choices=
  local packages_to_install=
  local packages_to_uninstall=
  local packages_to_track=
  local packages_to_untrack=

    help_text_generator "$conflict_type" > "$input"

  echo "$packages" | sed 's/ /\n/g' | while read -r package; do
    echo "skip $package" >> "$input"
  done

  $EDITOR "$input"

  choices="$(cat "$input" | grep -v '^#' | grep '.')" > "$input_choices"

  # validation
  while read -r action package; do

    validate_input_packages "$package"

    if [ "$action" = install ] || [ "$action" = i ]; then
      packages_to_install="$packages_to_install $package"
    elif [ "$action" = uninstall ] || [ "$action" = u ]; then
      packages_to_uninstall="$packages_to_uninstall $package"
    elif [ "$action" = add ] || [ "$action" = a ]; then
      packages_to_track="$packages_to_track $package"
    elif [ "$action" = remove ] || [ "$action" = r ]; then
      packages_to_untrack="$packages_to_untrack $package"
    elif [ "$action" = skip ] || [ "$action" = s ]; then
      log debug "[package_conflict_input_parser] Skipped: $package"
    else
      log user "Invalid action provided: $action"
    fi
  done < "$input_choices"

  # actual system or configuration change
  echo "$choices" | while read -r action package; do
    if [ "$action" = install ] || [ "$action" = i ]; then
      package_manager install "$packages_to_install"
    elif [ "$action" = uninstall ] || [ "$action" = u ]; then
      debug info "Calling package manager to uninstall $packages_to_uninstall"
      package_manager uninstall "$packages_to_uninstall"
    elif [ "$action" = add ] || [ "$action" = a ]; then
      track_packages "$package"
    elif [ "$action" = remove ] || [ "$action" = r ]; then
      untrack_packages "$package"
    fi
  done
}


help_text_generator() {
  local conflict_type="$1"

  echo "# Options:"

  if [ "$conflict_type" == not_installed ]; then
    echo "#   [i]nstall     Install package to system"
    echo "#   [r]emove      Remove from configuration"
  elif [ "$conflict_type" == not_on_configuration ]; then
    echo "#   [u]ninstall   Uninstall package from system"
    echo "#   [a]dd         Add to configuration"
  else
    debug fatal "Invalid conflict type provided: $conflict_type"
    return 1
  fi

  echo "#   [s]kip        Do not take any action"
  echo -e "\n# Providing just the value between brackets is sufficient"
  echo -e "# Replace 'skip' below with the desired option\n"
}
