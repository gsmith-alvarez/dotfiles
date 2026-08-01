#!/usr/bin/env bash
# cheatsheet: https://devhints.io/bash
set -euo pipefail

trap 'echo "ERROR: init.sh failed at line $LINENO" >&2' ERR

main() {
	ORIGINAL_PWD="$PWD"

	# Parse --skip-* flags
	SKIP_REPOS=false
	SKIP_PACKAGES=false
	SKIP_RUST=false
	SKIP_MISE=false
	SKIP_FLATPAK=false
	SKIP_NEOVIM=false
	SKIP_DESKTOP=false
	SKIP_SERVICES=false

	for arg in "$@"; do
		case "$arg" in
		--skip-repos) SKIP_REPOS=true ;;
		--skip-packages) SKIP_PACKAGES=true ;;
		--skip-rust) SKIP_RUST=true ;;
		--skip-mise) SKIP_MISE=true ;;
		--skip-flatpak) SKIP_FLATPAK=true ;;
		--skip-neovim) SKIP_NEOVIM=true ;;
		--skip-desktop) SKIP_DESKTOP=true ;;
		--skip-services) SKIP_SERVICES=true ;;
		*)
			echo "Unknown option: $arg" >&2
			exit 1
			;;
		esac
	done

	log() {
		echo "[$(date +%H:%M:%S)] $*"
	}

	# 1. Update and Base Tooling
	log "=== Upgrading system packages ==="
	sudo dnf -y upgrade

	log "=== Installing development environment groups ==="
	sudo dnf install -y @development-tools @c-development

	# 2. Git Identity & Dotfiles Configuration
	log "=== Configuring Git identity ==="

	if [ -t 0 ]; then
		read -r -p "Enter Git User Name: " input_name
		USER_NAME="${input_name}"

		read -r -p "Enter Git User Email: " input_email
		USER_EMAIL="${input_email}"
	fi

	# Fallback: if no TTY or user skipped, use a safe default marker
	USER_NAME="${USER_NAME:-}"
	USER_EMAIL="${USER_EMAIL:-}"

	log "=== Deploying dotfiles ==="
	if [ ! -d "$HOME/dotfiles" ]; then
		git clone https://github.com/gsmith-alvarez/dotfiles "$HOME/dotfiles"
	fi
	cd "$HOME/dotfiles"

	[[ -x "$HOME/dotfiles/stow.sh" ]] || {
		echo "ERROR: stow.sh missing or not executable"
		exit 1
	}

	./stow.sh

	# Set git identity after stow (into the stowed .gitconfig)
	if [ -z "$USER_NAME" ] || [ -z "$USER_EMAIL" ]; then
		echo "WARNING: Git identity not set. Set later with: git config --global user.name ..." >&2
	else
		git config --global user.name "$USER_NAME"
		git config --global user.email "$USER_EMAIL"
		log "Git identity set to: $USER_NAME <$USER_EMAIL>"
	fi

	# 3. Third-Party Repositories (Terra, RPM Fusion)
	if [ "$SKIP_REPOS" = false ]; then
		log "=== Enabling RPM Fusion Repositories (Codecs & Non-Free) ==="
		sudo dnf install -y \
			"https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
			"https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

		# Enable Cisco OpenH264 for WebRTC
		sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

		log "=== Swapping to full FFmpeg and restricted multimedia packages ==="
		# Swap out Fedora's crippled ffmpeg-free for the complete unencumbered package.
		# Guard against non-zero exit when already swapped.
		if rpm -q ffmpeg-free &>/dev/null; then
			sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
		fi

		sudo dnf install -y \
			gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-plugin-openh264 \
			lame-libs libva-utils rpmfusion-free-appstream-data rpmfusion-nonfree-appstream-data

		log "=== Configuring Hardware Accelerated Video Decoding ==="
		sudo dnf install -y mesa-va-drivers-freeworld --best --allowerasing

		# Adding Terra repository.
		# --nogpgcheck is intentional here: bootstrapping before terra-gpg-keys are present.
		log "=== Adding Terra repository ==="
		sudo dnf install -y --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" terra-release terra-gpg-keys
	fi

	# 4. Monolithic Package Installation
	if [ "$SKIP_PACKAGES" = false ]; then
		log "=== Installing applications and development libraries ==="
		sudo dnf install -y \
			mise fish ghostty starship wl-clipboard cliphist syncthing cargo opentabletdriver \
			gcc gcc-c++ make pkgconf-pkg-config cairo-devel wayland-devel pango-devel \
			wayscriber wayscriber-configurator lazygit hw-probe btop sqlite-devel \
			libxkbcommon-devel cairo-gobject-devel pandoc
	fi

	# 5. Rust Ecosystem & Language Runtime Tooling
	if [ "$SKIP_RUST" = false ]; then
		log "=== Installing Cargo binaries ==="
		# cargo-update provides cargo install-update; use it to skip already-current installs
		cargo install --locked cargo-cache cargo-update binstall
		cargo install-update -i spotify_player fsel kanata topgrade
	fi

	if [ "$SKIP_MISE" = false ]; then
		log "=== Initializing mise tools ==="
		mise install -y

		log "=== Installing Yazi packages ==="
		mise exec -- ya pkg install --discard
	fi

	# 6. Flatpak Setup
	if [ "$SKIP_FLATPAK" = false ]; then
		log "=== Provisioning Flatpak applications ==="
		flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
		flatpak install -y --or-update --system flathub \
			org.blender.Blender \
			com.calibre_ebook.calibre \
			it.mior.GearLever \
			org.keepassxc.KeePassXC \
			org.kde.krita \
			org.kde.kdenlive \
			com.obsproject.Studio \
			org.qbittorrent.qBittorrent \
			com.github.wwmm.easyeffects \
			com.github.tchx84.Flatseal \
			org.freecad.FreeCAD
	fi

	# 7. Neovim Build Sourcing
	if [ "$SKIP_NEOVIM" = false ]; then
		log "=== Fetching and preparing Neovim source ==="
		mkdir -p "$HOME/source"
		if [ ! -d "$HOME/source/neovim" ]; then
			git clone https://github.com/neovim/neovim "$HOME/source/neovim"
		else
			# cd into neovim dir for git operations, then back
			cd "$HOME/source/neovim"
			git fetch origin
			git reset --hard origin/master
			cd "$HOME/dotfiles"
		fi

		[[ -x "$HOME/dotfiles/neovim_source.sh" ]] || {
			echo "ERROR: neovim_source.sh missing or not executable"
			exit 1
		}
		bash "$HOME/dotfiles/neovim_source.sh"
	fi

	# 8. User Desktop Entries & Autostart Configuration
	if [ "$SKIP_DESKTOP" = false ]; then
		log "=== Setting up local desktop entries and autostart hooks ==="
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

		# Create symlinks for session autostart
		ln -sf "$HOME/.local/share/applications/cliphist-text.desktop" "$HOME/.config/autostart/cliphist-text.desktop"
		ln -sf "$HOME/.local/share/applications/cliphist-image.desktop" "$HOME/.config/autostart/cliphist-image.desktop"
	fi

	# 9. Services Activation
	if [ "$SKIP_SERVICES" = false ]; then
		log "=== Enabling user-space daemons ==="
		systemctl --user enable --now wayscriber.service
		systemctl --user enable --now syncthing.service

		sudo firewall-cmd --zone=public --add-service=syncthing --permanent
		sudo firewall-cmd --reload
	fi

	log "=== System provisioning completed successfully ==="
	cd "$ORIGINAL_PWD"
}

main "$@"
