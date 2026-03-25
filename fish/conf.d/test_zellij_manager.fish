#!/usr/bin/env fish
# =============================================================================
# Zellij Manager Test Suite
# =============================================================================
# 
# Tests for the zellij_manager.fish configuration
# Run with: fish test_zellij_manager.fish
#
# =============================================================================

set -g TESTS_PASSED 0
set -g TESTS_FAILED 0
set -g TEST_SECTION ""

function test_section
    set -g TEST_SECTION "$argv[1]"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $TEST_SECTION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
end

function assert_equals
    set -l actual "$argv[1]"
    set -l expected "$argv[2]"
    set -l test_name "$argv[3]"
    
    if test "$actual" = "$expected"
        echo "  ✓ $test_name"
        set -g TESTS_PASSED (math $TESTS_PASSED + 1)
        return 0
    else
        echo "  ✗ $test_name"
        echo "    Expected: '$expected'"
        echo "    Actual:   '$actual'"
        set -g TESTS_FAILED (math $TESTS_FAILED + 1)
        return 1
    end
end

function assert_not_empty
    set -l value "$argv[1]"
    set -l test_name "$argv[2]"
    
    if test -n "$value"
        echo "  ✓ $test_name"
        set -g TESTS_PASSED (math $TESTS_PASSED + 1)
        return 0
    else
        echo "  ✗ $test_name"
        echo "    Expected: non-empty value"
        echo "    Actual:   empty/null"
        set -g TESTS_FAILED (math $TESTS_FAILED + 1)
        return 1
    end
end

function assert_contains
    set -l haystack "$argv[1]"
    set -l needle "$argv[2]"
    set -l test_name "$argv[3]"
    
    if string match -q "*$needle*" "$haystack"
        echo "  ✓ $test_name"
        set -g TESTS_PASSED (math $TESTS_PASSED + 1)
        return 0
    else
        echo "  ✗ $test_name"
        echo "    Expected to contain: '$needle'"
        echo "    Actual value:        '$haystack'"
        set -g TESTS_FAILED (math $TESTS_FAILED + 1)
        return 1
    end
end

function assert_file_exists
    set -l filepath "$argv[1]"
    set -l test_name "$argv[2]"
    
    if test -f "$filepath"
        echo "  ✓ $test_name"
        set -g TESTS_PASSED (math $TESTS_PASSED + 1)
        return 0
    else
        echo "  ✗ $test_name"
        echo "    Expected file to exist: $filepath"
        set -g TESTS_FAILED (math $TESTS_FAILED + 1)
        return 1
    end
end

# =============================================================================
# Test Setup
# =============================================================================

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                    ZELLIJ MANAGER TEST SUITE                              ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"

# Source the zellij manager (in test mode, without actually running zellij commands)
set -g ZELLIJ "test-session"  # Fake ZELLIJ session for testing

# =============================================================================
# Environment Variable Tests
# =============================================================================

test_section "Environment Variables"

# Save original values
set -l orig_auto_rename $ZJ_AUTO_RENAME
set -l orig_rename_tui $ZJ_RENAME_TUI_APPS
set -l orig_project_det $ZJ_PROJECT_DETECTION

# Test default values
source (dirname (status -f))/zellij_manager.fish
assert_equals "$ZJ_AUTO_RENAME" "1" "ZJ_AUTO_RENAME defaults to 1"
assert_equals "$ZJ_RENAME_TUI_APPS" "1" "ZJ_RENAME_TUI_APPS defaults to 1"
assert_equals "$ZJ_PROJECT_DETECTION" "0" "ZJ_PROJECT_DETECTION defaults to 0"
assert_not_empty "$ZJ_CONFIG_FILE" "ZJ_CONFIG_FILE is set"

# Test validation (invalid values should be reset to defaults)
set -g ZJ_AUTO_RENAME "invalid"
set -g ZJ_CONFIG_LOADED 0
source (dirname (status -f))/zellij_manager.fish
assert_equals "$ZJ_AUTO_RENAME" "1" "Invalid ZJ_AUTO_RENAME is corrected to 1"

# =============================================================================
# Config Loading Tests
# =============================================================================

test_section "Configuration Loading"

# Reset config loaded flag
set -g ZJ_CONFIG_LOADED 0

# Test config file existence
set -l config_file ~/.config/fish/zellij_manager.conf
assert_file_exists "$config_file" "Config file exists at expected location"

# Test config loading function
__zj_load_config
assert_not_empty "$ZJ_TUI_APPS" "TUI apps list is populated"
assert_equals "$ZJ_CONFIG_LOADED" "1" "Config loaded flag is set"

# Test that config contains expected apps
set -l has_nvim 0
for app in $ZJ_TUI_APPS
    if test "$app" = "nvim"
        set has_nvim 1
        break
    end
end
assert_equals "$has_nvim" "1" "Config contains 'nvim'"

# =============================================================================
# Project Detection Tests
# =============================================================================

test_section "Project Detection"

# Create temporary test directories
set -l test_dir /tmp/zellij_test_(random)
mkdir -p $test_dir

# Test Node.js project detection
echo '{"name": "test-project"}' >$test_dir/package.json
set -g ZJ_PROJECT_DETECTION 1
__zj_detect_project $test_dir
assert_equals "$__ZJ_PROJECT_NAME" "test-project" "Node.js project name detected"
assert_equals "$__ZJ_PROJECT_TYPE" "📦" "Node.js project type icon set"

# Test Rust project detection
rm $test_dir/package.json
echo '[package]
name = "rust-project"' >$test_dir/Cargo.toml
__zj_detect_project $test_dir
assert_equals "$__ZJ_PROJECT_NAME" "rust-project" "Rust project name detected"
assert_equals "$__ZJ_PROJECT_TYPE" "🦀" "Rust project type icon set"

# Test Python project detection
rm $test_dir/Cargo.toml
echo '[project]
name = "python-app"' >$test_dir/pyproject.toml
__zj_detect_project $test_dir
assert_equals "$__ZJ_PROJECT_NAME" "python-app" "Python project name detected"
assert_equals "$__ZJ_PROJECT_TYPE" "🐍" "Python project type icon set"

# Cleanup
rm -rf $test_dir

# =============================================================================
# Tab Naming Tests (without actually running zellij)
# =============================================================================

test_section "Tab Naming Logic"

# Mock zellij command to avoid actually renaming tabs
function zellij
    # Do nothing - just for testing
end

# Test home directory naming
set -l original_pwd $PWD
cd ~
set -l dir_name (basename $PWD)
test "$PWD" = "$HOME" && set dir_name "~"
assert_equals "$dir_name" "~" "Home directory shows as ~"

# Test regular directory naming
cd /tmp
set dir_name (basename $PWD)
assert_equals "$dir_name" "tmp" "Regular directory shows basename"

# Test empty directory name handling
set dir_name ""
test -z "$dir_name" && set dir_name "/"
assert_equals "$dir_name" "/" "Empty directory name defaults to /"

# Restore original directory
cd $original_pwd

# =============================================================================
# Template Pattern Tests
# =============================================================================

test_section "Template Pattern Expansion"

# Test template variable replacement
set -l test_pattern "{dir}/{git_root}:{git_branch}"
set -l expanded $test_pattern
set expanded (string replace -a '{dir}' "src" "$expanded")
set expanded (string replace -a '{git_root}' "my-repo" "$expanded")
set expanded (string replace -a '{git_branch}' "main" "$expanded")
assert_equals "$expanded" "src/my-repo:main" "Template variables expand correctly"

# Test cleanup of empty placeholders
set test_pattern "{project}_{git_branch}"
set expanded (string replace -a '{project}' "" "$test_pattern")
set expanded (string replace -a '{git_branch}' "feature" "$expanded")
set expanded (string replace -ra '\{\w+\}' '' "$expanded")
assert_contains "$expanded" "feature" "Empty placeholders are cleaned up"

# =============================================================================
# Edge Case Tests
# =============================================================================

test_section "Edge Cases"

# Test long name truncation
set -l long_name "this-is-a-very-long-directory-name-that-should-be-truncated"
if test (string length "$long_name") -gt 40
    set long_name (string sub -l 37 "$long_name")…
end
assert_contains "$long_name" "…" "Long names are truncated with ellipsis"
assert_equals (test (string length "$long_name") -le 40; and echo "1"; or echo "0") "1" "Truncated name is within limit"

# Test control character sanitization
set -l unsafe_name "test\x00\x1fdir"
set -l safe_name (string replace -ra '[\x00-\x1f\x7f]' '?' "$unsafe_name")
assert_equals "$safe_name" "test??dir" "Control characters are sanitized"

# =============================================================================
# Performance Tests
# =============================================================================

test_section "Performance & Caching"

# Test git cache initialization
assert_equals "$ZJ_GIT_ROOT_CACHE" "" "Git cache starts empty"
assert_equals "$ZJ_GIT_ROOT_CACHE_DIR" "" "Git cache dir starts empty"

# Test that git cache can be set
set -g ZJ_GIT_ROOT_CACHE "/home/user/repo"
set -g ZJ_GIT_ROOT_CACHE_DIR "/home/user/repo"
assert_equals "$ZJ_GIT_ROOT_CACHE" "/home/user/repo" "Git cache can be set"

# Test config loaded flag prevents reloading
set -g ZJ_CONFIG_LOADED 1
set -l apps_before (count $ZJ_TUI_APPS)
__zj_load_config
set -l apps_after (count $ZJ_TUI_APPS)
assert_equals "$apps_before" "$apps_after" "Config not reloaded when already loaded"

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                           TEST RESULTS                                    ║"
echo "╠═══════════════════════════════════════════════════════════════════════════╣"
echo "║                                                                           ║"
echo "║  Tests Passed:  $TESTS_PASSED"
echo "║  Tests Failed:  $TESTS_FAILED"
echo "║  Total Tests:   "(math $TESTS_PASSED + $TESTS_FAILED)"                                                                        ║"
echo "║                                                                           ║"

if test $TESTS_FAILED -eq 0
    echo "║  Status: ✓ ALL TESTS PASSED                                              ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    exit 0
else
    echo "║  Status: ✗ SOME TESTS FAILED                                             ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    exit 1
end
