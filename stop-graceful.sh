#!/usr/bin/env bash

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

exec "$DIR/stop.sh" --graceful-only "$@"
