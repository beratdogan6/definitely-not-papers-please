#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

mkdir -p bin
odin build src -out:bin/definitely-not-papers-please "$@"
