#!/usr/bin/env sh
sha256sum $(find config -type f | xargs) > checksums/canonical
