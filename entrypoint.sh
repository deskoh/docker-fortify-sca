#!/bin/sh
set -e

echo $1

# Check first arg exists or is executable
if [ -f "$1" ] || [ -x "$(command -v $1 2> /dev/null)" ]; then
    exec "$@"
fi

exec /scan.sh "$@"