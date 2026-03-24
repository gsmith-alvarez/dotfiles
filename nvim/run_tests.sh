#!/usr/bin/env bash

# [[ NEOTEST CLI RUNNER ]]
# Runs the full configuration integration suite headlessly.

# We use the current directory as the project root.
NVIM_CONFIG_DIR=$(pwd)

echo "🚀 Starting Neovim Integration Tests..."

# Execute Neovim headlessly, load the test runner, and exit.
# We ensure the project root is in the Lua path.
nvim --headless \
     -u tests/run_tests.lua \
     -c "lua MiniTest.run()" \
     -c "qa!"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Tests Passed."
else
    echo "❌ Tests Failed with exit code $EXIT_CODE."
fi

exit $EXIT_CODE
