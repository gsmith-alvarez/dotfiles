#!/usr/bin/env bash
set -euo pipefail

main() {
	# 1. Check if stow is actually installed before doing anything
	if ! command -v stow >/dev/null 2>&1; then
		echo "Error: GNU Stow is not installed." >&2
		exit 1
	fi

	# 2. Match only directories natively using the trailing slash
	# 3. Handle cases where no directories match cleanly without errors
	shopt -s nullglob

	local dirs=()
	for dir in */; do
		# Strip trailing slash for string comparison and stow compatibility
		dir="${dir%/}"

		if [[ "$dir" != "easy-effects" ]]; then
			dirs+=("$dir")
		fi
	done

	# 4. Atomic execution: Pass all directories to stow in a single invocation
	if ((${#dirs[@]} > 0)); then
		stow "${dirs[@]}"
	fi
}

main "$@"
