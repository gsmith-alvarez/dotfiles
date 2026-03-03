#!/usr/bin/env fish

# EXPORT: Save current COSMIC registry to a trackable file
dconf dump /org/cosmic/ >~/.config/cosmic/cosmic_settings.dconf

# IMPORT: Load settings from the file into the system
# dconf load /org/cosmic/ < ~/dotfiles/cosmic/cosmic_settings.dconf
