function y --description "Yazi wrapper: Zoxide state sync + Neovim handoff"
    _check_deps yazi nvim; or return 1
    
    # Create isolated temp files for both directory state and file selection
    set -l tmp_cwd (mktemp -t "yazi-cwd.XXXXXX"); or return 1
    set -l tmp_file (mktemp -t "yazi-file.XXXXXX"); or return 1

    # Execute Yazi, capturing both the final directory and the selected file
    yazi $argv --cwd-file="$tmp_cwd" --chooser-file="$tmp_file"

    # 1. State Sync: Update directory and feed the Zoxide database
    if set cwd (command cat -- "$tmp_cwd" 2>/dev/null); and test -n "$cwd"; and test "$cwd" != "$PWD"
        if test -d "$cwd"
            cd "$cwd"
        end
    end

    # 2. Handoff: If you hit <Enter> on a file, open it in Neovim natively
    if set chosen (command cat -- "$tmp_file" 2>/dev/null); and test -n "$chosen"
        if test -f "$chosen"; or test -d "$chosen"
            nvim "$chosen"
        end
    end

    # 3. Memory Management: Ruthless cleanup
    rm -f -- "$tmp_cwd" "$tmp_file"
end
