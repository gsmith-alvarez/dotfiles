# bats - Run bats test runner
#
# USAGE:
#   bats            : Runs all *.bats files in current directory (if they exist).
#   bats <args>     : Passes specific files or arguments to bats.
#
# DEPENDENCIES:
#   bats

function bats --description "Run bats test runner"
    # If arguments were passed, use them.
    if count $argv >/dev/null
        env BATS_RUN_SKIPPED=true command bats $argv
    else
        # Safely handle the wildcard by checking if files exist first
        set -l files *.bats
        if count $files >/dev/null
            env BATS_RUN_SKIPPED=true command bats $files
        else
            echo "No .bats files found in current directory."
        end
    end
end
