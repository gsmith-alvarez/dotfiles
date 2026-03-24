# _check_deps - Internal helper to validate command dependencies
#
# USAGE:
#   _check_deps cmd1 cmd2 cmd3
#
# Returns 0 if all commands exist, 1 if any are missing

function _check_deps --description "Validate required commands exist"
    for cmd in $argv
        if not type -q $cmd
            echo "Error: Required command '$cmd' not found. Please install it first." >&2
            return 1
        end
    end
    return 0
end
