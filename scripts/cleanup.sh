#!/usr/bin/env bash
# cheatsheet: https://devhints.io/bash
set -euo pipefail

sudo journalctl --vacuum-time=7d

cliphist wipe
