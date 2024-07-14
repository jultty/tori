track_packages() {
  local packages="$1"

  validate_input_packages "$packages"

  echo "$packages" | xargs | sed 's/ /\n/g' | while read -r package; do
    echo "$package" >> "$CONFIG_ROOT/packages"
  done
}

untrack_packages() {
  local packages="$1"

  echo "$packages" | xargs | sed 's/ /\n/g' | while read -r package; do
    sed -i '' "/^$package$/d" "$CONFIG_ROOT/packages"
  done
}
