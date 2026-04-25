#!/usr/bin/env bash
# cheatsheet: https://devhints.io/bash
set -euo pipefail

main() {
	for i in *; do
		if [[ -d "$i" ]]; then
			stow "$i"
		fi
	done
}

main "$@"
