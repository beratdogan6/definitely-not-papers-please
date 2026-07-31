#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

odin run src -out:bin/definitely-not-papers-please "$@"
