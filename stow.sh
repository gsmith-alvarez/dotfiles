#!/usr/bin/env bash
set -euo pipefail

main() {
	# 1. Check if stow is actually installed before doing anything
	if ! command -v stow >/dev/null 2>&1; then
		echo "Error: GNU Stow is not installed." >&2
		exit 1
	fi

	# 3. Skip packages now managed by home-manager and non-stowable dirs
	#    (easy-effects targets the app data dir, not ~/.config)
	shopt -s nullglob
	local SKIP=("easy-effects" "nvim" "git")
	local dirs=()
	for dir in */; do
		# Strip trailing slash for string comparison and stow compatibility
		dir="${dir%/}"

		if [[ ! " ${SKIP[*]} " =~ " ${dir} " ]]; then
			dirs+=("$dir")
		fi
	done

	# 4. Atomic execution: Pass all directories to stow in a single invocation
	if ((${#dirs[@]} > 0)); then
		stow "${dirs[@]}"
	fi
}

main "$@"
