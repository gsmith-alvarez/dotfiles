#!/usr/bin/env bash
# cheatsheet: https://devhints.io/bash
set -euo pipefail

main() {

	# 1. Update and Base Tooling
	echo "=== Upgrading system packages ==="
	sudo dnf -y upgrade

	echo "=== Installing development environment groups ==="
	sudo dnf install -y @development-tools @c-development

	# 2. Git Identity & Dotfiles Configuration
	echo "=== Configuring Git identity ==="

	if [ -t 0 ]; then
		read -r -p "Enter Git User Name: " input_name
		USER_NAME="${input_name}"

		read -r -p "Enter Git User Email: " input_email
		USER_EMAIL="${input_email}"
	fi

	git config --global user.name "$USER_NAME"
	git config --global user.email "$USER_EMAIL"

	echo "Git identity set to: $(git config --global user.name) <$(git config --global user.email)>"

	echo "=== Deploying dotfiles ==="
	if [ ! -d "$HOME/dotfiles" ]; then
		git clone https://github.com/gsmith-alvarez/dotfiles "$HOME/dotfiles"
	fi
	cd "$HOME/dotfiles"

	[[ -x "$HOME/dotfiles/stow.sh" ]] || {
		echo "ERROR: stow.sh missing or not executable"
		exit 1
	}

	mv "$HOME/.gitconfig" "$HOME/.gitconfig.local"
	./stow.sh

	# 3. Third-Party Repositories (Terra, RPM Fusion)
	echo "=== Enabling RPM Fusion Repositories (Codecs & Non-Free) ==="
	sudo dnf install -y \
		https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
		https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	# Enable Cisco OpenH264 for WebRTC
	sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

	echo "=== Swapping to full FFmpeg and restricted multimedia packages ==="
	# Swap out Fedora's crippled ffmpeg-free for the complete unencumbered package.
	# Guard against non-zero exit when ffmpeg is already in the desired state.
	rpm -q ffmpeg &>/dev/null || sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

	sudo dnf install -y \
		gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-plugin-openh264 \
		lame-libs libva-utils rpmfusion-free-appstream-data rpmfusion-nonfree-appstream-data

	echo "=== Configuring Hardware Accelerated Video Decoding ==="
	sudo dnf install -y mesa-va-drivers-freeworld --best --allowerasing

	# Adding Terra repository.
	# --nogpgcheck is intentional here: bootstrapping before terra-gpg-keys are present.
	echo "=== Adding Terra repository ==="
	sudo dnf install -y --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" terra-release terra-gpg-keys

	# 4. Monolithic Package Installation
	echo "=== Installing applications and development libraries ==="
	sudo dnf install -y \
		mise fish ghostty starship wl-clipboard cliphist cargo opentabletdriver \
		gcc gcc-c++ make pkgconf-pkg-config cairo-devel wayland-devel pango-devel \
		wayscriber wayscriber-configurator lazygit hw-probe btop \
		libxkbcommon-devel cairo-gobject-devel

	# 5. Rust Ecosystem & Language Runtime Tooling
	echo "=== Installing Cargo binaries ==="
	# cargo-update provides cargo install-update; use it to skip already-current installs
	cargo install --locked cargo-cache cargo-update
	cargo install-update -i spotify_player fsel kanata topgrade

	echo "=== Initializing mise tools ==="
	# mise may not yet be on PATH if dotfiles haven't been sourced in this shell session
	"$HOME/.local/bin/mise" install -y

	echo "=== Installing Yazi packages ==="
	"$HOME/.local/bin/mise" exec -- ya pkg install --discard

	# 6. Flatpak Setup
	echo "=== Provisioning Flatpak applications ==="
	sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	sudo flatpak install -y --or-update flathub \
		org.blender.Blender \
		com.calibre_ebook.calibre \
		it.mior.GearLever \
		org.keepassxc.KeePassXC \
		org.kde.krita \
		org.kde.kdenlive \
		com.obsproject.Studio \
		org.qbittorrent.qBittorrent \
		com.github.wwmm.easyeffects \
		com.github.tchx84.Flatseal

	# 7. Neovim Build Sourcing
	echo "=== Fetching and preparing Neovim source ==="
	mkdir -p "$HOME/source"
	if [ ! -d "$HOME/source/neovim" ]; then
		git clone https://github.com/neovim/neovim "$HOME/source/neovim"
	else
		cd "$HOME/source/neovim"
		git fetch origin
		git reset --hard origin/HEAD
	fi

	[[ -x "$HOME/dotfiles/neovim_source.sh" ]] || {
		echo "ERROR: neovim_source.sh missing or not executable"
		exit 1
	}
	bash "$HOME/dotfiles/neovim_source.sh"

	# 8. User Desktop Entries & Autostart Configuration
	echo "=== Setting up local desktop entries and autostart hooks ==="
	mkdir -p "$HOME/.local/share/applications" "$HOME/.config/autostart"

	# Cliphist Text Daemon
	cat <<'EOF' >"$HOME/.local/share/applications/cliphist-text.desktop"
[Desktop Entry]
Type=Application
Name=Cliphist Text Daemon
Comment=Watch and store text clipboard history
Exec=wl-paste --type text --watch cliphist store
Terminal=false
X-COSMIC-Autostart-enabled=true
EOF

	# Cliphist Image Daemon
	cat <<'EOF' >"$HOME/.local/share/applications/cliphist-image.desktop"
[Desktop Entry]
Type=Application
Name=Cliphist Image Daemon
Comment=Watch and store image clipboard history
Exec=wl-paste --type image --watch cliphist store
Terminal=false
X-COSMIC-Autostart-enabled=true
EOF

	# Syncthing Engine
	cat <<'EOF' >"$HOME/.local/share/applications/syncthing-start.desktop"
[Desktop Entry]
Name=Start Syncthing
GenericName=File synchronization
Comment=Starts the main syncthing process in the background.
Exec=syncthing serve --no-browser --logfile=default
Icon=syncthing
Terminal=false
Type=Application
Keywords=synchronization;daemon;
Categories=Network;FileTransfer;P2P
EOF

	# Create symlinks for session autostart
	ln -sf "$HOME/.local/share/applications/cliphist-text.desktop" "$HOME/.config/autostart/cliphist-text.desktop"
	ln -sf "$HOME/.local/share/applications/cliphist-image.desktop" "$HOME/.config/autostart/cliphist-image.desktop"
	ln -sf "$HOME/.local/share/applications/syncthing-start.desktop" "$HOME/.config/autostart/syncthing-start.desktop"

	# 9. Services Activation
	echo "=== Enabling user-space daemons ==="
	systemctl --user enable --now wayscriber.service
	systemctl --user enable --now syncthing.service

	sudo firewall-cmd --zone=public --add-service=syncthing --permanent
	sudo firewall-cmd --reload

	echo "=== System provisioning completed successfully ==="

}

main "$@"
