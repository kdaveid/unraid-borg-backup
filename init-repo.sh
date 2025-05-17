#!/bin/sh

set -eu

if [ -z "$BORG_PASSPHRASE" ]; then
    echo "Error: The environment variable BORG_PASSPHRASE is not set!"
    exit 1
fi

borg init --encryption=repokey "$REPO_PATH"
