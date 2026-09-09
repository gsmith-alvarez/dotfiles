function ndiff --description 'Diff current NixOS generation against a previous one (default: last)'
    set -l cur (/nix/var/nix/profiles/system/bin/switch-to-configuration 2>/dev/null; readlink /nix/var/nix/profiles/system)
    set cur /nix/var/nix/profiles/system

    set -l old_gen (math $argv[1] 2>/dev/null)
    set -l prev
    if set -q old_gen[1]
        set prev /nix/var/nix/profiles/system-$argv[1]-link
    else
        # find the newest generation link that isn't the current one
        for l in (ls -d /nix/var/nix/profiles/system-*-link 2>/dev/null | string match -v (readlink -f $cur))
            set prev $l
        end
    end

    if not test -d $prev
        echo "ndiff: no previous generation found" >&2
        return 1
    end

    nvd diff $prev $cur
end
