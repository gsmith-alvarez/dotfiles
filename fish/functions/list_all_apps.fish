# list_all_apps - Generate a markdown master inventory of installed software
#
# USAGE:
#   list_all_apps   : Runs multiple package manager queries and filesystem 
#                     checks to build a comprehensive inventory.
#
# DEPENDENCIES:
#   apt, brew, flatpak, cargo, mise, npm, pipx, am, bin, eza, glow/bat

function list_all_apps --description "Generate a markdown master inventory of installed software"
    set -l output_file ~/Downloads/MasterList.md
    set -l timestamp (date "+%Y-%m-%d %H:%M:%S")
    set -l _hostname (hostname)
    set -l os_name (grep "^PRETTY_NAME=" /etc/os-release | cut -d'"' -f2)
    
    if test -z "$os_name"
        set os_name "Linux"
    end

    # 1. Header and Metadata
    echo "# 🖥️ Master Software Inventory" >$output_file
    echo "Generated on: $timestamp" >>$output_file
    echo "Machine: $_hostname ($os_name)" >>$output_file
    echo "---" >>$output_file
    echo "" >>$output_file

    # 2. Helper: Standard Code Block Section
    function _fmt_section
        set -l title $argv[1]
        set -l cmd $argv[2]
        set -l target_file $argv[3]
        echo "## 📦 $title" >>$target_file
        echo "```text" >>$target_file
        eval $cmd 2>/dev/null >>$target_file
        echo "```" >>$target_file
        echo "" >>$target_file
    end

    # 3. Helper: Markdown Table Section (Default 3 columns)
    function _fmt_table
        set -l title $argv[1]
        set -l cmd $argv[2]
        set -l target_file $argv[3]
        set -l cols 3 # Adjust this number for more or fewer columns

        echo "## 📦 $title" >>$target_file
        
        # Capture items into a list (Fish splits command substitution by newline)
        set -l items (eval $cmd 2>/dev/null)
        set -l total (count $items)
        
        if test $total -eq 0
            echo "_No items found._" >>$target_file
            echo "" >>$target_file
            return
        end

        # Create Table Header and Separator
        set -l header "|"
        set -l separator "|"
        for i in (seq $cols)
            set header "$header Column $i |"
            set separator "$separator --- |"
        end
        echo $header >>$target_file
        echo $separator >>$target_file

        # Chunk the list into rows
        set -l num_rows (math "ceil($total / $cols)")
        for i in (seq $num_rows)
            set -l start (math "($i - 1) * $cols + 1")
            set -l end (math "$i * $cols")
            set -l row_slice $items[$start..$end]
            
            # Ensure the row has exactly $cols items (pad with empty strings if needed)
            while test (count $row_slice) -lt $cols
                set row_slice $row_slice ""
            end
            
            echo "| "(string join " | " $row_slice)" |" >>$target_file
        end
        echo "" >>$target_file
    end

    # 4. Execution - Package Managers
    if type -q apt-mark
        _fmt_table "APT (Manual)" "apt-mark showmanual" $output_file
    end
    if type -q brew
        _fmt_table "Homebrew" "brew list" $output_file
    end
    if type -q flatpak
        _fmt_table "Flatpak" "flatpak list --app --columns=name,application" $output_file
    end
    if type -q cargo
        _fmt_table "Cargo (Global Binaries)" "cargo install --list | grep '^[a-z]'" $output_file
    end
    if type -q mise
        # Format mise output into a clean list of Tool + Version
        _fmt_table "Mise (Core Tools)" "mise ls | awk '{print \$1 \" (\" \$2 \")\"}'" $output_file
    end
    if type -q pipx
        _fmt_section "Pipx (Python Apps)" "pipx list --short" $output_file
    end
    if type -q npm
        _fmt_section "NPM (Global Packages)" "npm list -g --depth=0" $output_file
    end

    # 5. Execution - Binary & AppImage Managers
    if type -q am
        _fmt_section "AM (AppImage Manager)" "am -f" $output_file
    end

    if type -q bin
        _fmt_table "Bin Manager" "bin ls" $output_file
    end

    # 6. Execution - Local Filesystem
    if test -d ~/.local/bin
        set -l ls_cmd "ls -1"
        if type -q eza
            set ls_cmd "eza -1 --icons=never"
        end
        _fmt_table "Manual Binaries (~/.local/bin)" "$ls_cmd ~/.local/bin" $output_file
    end
    if test -d ~/scripts
        set -l ls_cmd "ls -1"
        if type -q eza
            set ls_cmd "eza -1 --icons=never"
        end
        _fmt_table "User Scripts (~/scripts)" "$ls_cmd ~/scripts" $output_file
    end
    
    # 7. Execution - Chronological Intent (APT History)
    if test -f /var/log/apt/history.log
        echo "## ⏳ Recent System Changes (Last 20 APT Commands)" >>$output_file
        echo "```bash" >>$output_file
        begin
            zcat (ls -tr /var/log/apt/history.log*.gz 2>/dev/null) 2>/dev/null
            cat /var/log/apt/history.log 2>/dev/null
        end | grep "Commandline:" | grep -v aptdaemon | tail -n 20 >>$output_file
        echo "```" >>$output_file
        echo "" >>$output_file
    end

    # 8. Execution - Deep Analysis: True Manual Packages
    if type -q dpkg-query; and test -f /var/lib/apt/extended_states
        _fmt_table "APT Metadata Analysis (Manual vs. Auto)" "comm -23 (dpkg-query -W -f='\${Package}\n' | sort | psub) (awk -v RS= '/Auto-Installed: *1/{print \$2}' /var/lib/apt/extended_states | sort | psub)" $output_file
    end

    # 9. Final touch
    echo "✅ Master list generated at: $output_file"
    if type -q glow
        glow $output_file
    else if type -q bat
        bat $output_file
    else
        cat $output_file
    end
end
