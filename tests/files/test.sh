#! /usr/bin/env sh

set -eu

test_name=files
config_dir="$HOME/.config/tori"
tori_path=

log() {
    echo " [tori test: $test_name] $1"
}

log "Starting"

cd "$(dirname "$0")" || exit 1
tori_path=$(realpath "../../tori")

log "tori_path=$tori_path"
log "$(file "$tori_path")"

log "Bootstrapping tori"
if [ -d "$config_dir" ]; then
    log "Found tori config directory at $config_dir"
else
    mkdir -p "$config_dir"
fi
echo "tori_root = $(dirname "$tori_path")" > "$config_dir"/tori.conf

if $tori_path version > /dev/null 2>&1; then
    log "tori $($tori_path version) is ready"
else
    log "Failed to bootstrap tori"
    exit 1
fi

if $tori_path os > /dev/null 2>&1; then
    OS="$($tori_path os)"
else
    log "Failed to get OS from tori"
    exit 1
fi

log "Setting up configuration"

case $OS in
    Void|FreeBSD)
        log "OS=$OS"
        rm -vrf "$config_dir"
        ! [ -d "$config_dir" ] && mkdir -p "$(dirname "$config_dir")"
        cp -rv config "$config_dir"
        echo "tori_root = $(dirname "$tori_path")" > "$config_dir/tori.conf"
        mv -v "$config_dir/base/home/test_user" "$config_dir/base/home/$USER"
        tree "$HOME/.config/tori"
        ;;
    *)
        log "OS is unsupported for this test or tori could not determine it"
        exit 1
        ;;
esac

log "Running tori check --prefer-config with DEBUG=5"

DEBUG=5 $tori_path check --prefer-config

log "Comparing checksums"
sha256sum -c checksums/canonical

cat checksums/canonical |
    sed "s:config:$config_dir:" |
    sed "s/test_user/$USER/g" > checksums/config_checksums.local

cat checksums/canonical |
    sed "s:config/base::" |
    sed "s/test_user/$USER/g" > checksums/system_checksums.local

sha256sum -c checksums/config_checksums.local
sha256sum -c checksums/system_checksums.local

log "Done"
