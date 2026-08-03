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

	CURRENT_GIT_NAME="$(git config --global user.name 2>/dev/null || true)"
	CURRENT_GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"

	if [ -n "$CURRENT_GIT_NAME" ] && [ -n "$CURRENT_GIT_EMAIL" ]; then
		log "Git identity already configured: $CURRENT_GIT_NAME <$CURRENT_GIT_EMAIL>"
		USER_NAME="$CURRENT_GIT_NAME"
		USER_EMAIL="$CURRENT_GIT_EMAIL"
	else
		if [ -t 0 ]; then
			read -r -p "Enter Git User Name: " input_name
			USER_NAME="${input_name}"

			read -r -p "Enter Git User Email: " input_email
			USER_EMAIL="${input_email}"
		fi
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
	elif [ "$USER_NAME" != "$CURRENT_GIT_NAME" ] || [ "$USER_EMAIL" != "$CURRENT_GIT_EMAIL" ]; then
		git config --global user.name "$USER_NAME"
		git config --global user.email "$USER_EMAIL"
		log "Git identity set to: $USER_NAME <$USER_EMAIL>"
	else
		log "Git identity retained: $USER_NAME <$USER_EMAIL>"
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

		# Adding Terra repository safely (skip if already installed)
		log "=== Adding Terra repository ==="
		if ! rpm -q terra-release &>/dev/null; then
			sudo dnf install -y --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" terra-release terra-gpg-keys || true
		else
			log "Terra repository is already installed."
		fi
	fi

	# 4. Monolithic Package Installation
	if [ "$SKIP_PACKAGES" = false ]; then
		log "=== Installing applications and development libraries ===="
		sudo dnf install -y \
			mise fish ghostty starship wl-clipboard cliphist syncthing cargo opentabletdriver \
			gcc gcc-c++ make pkgconf-pkg-config cairo-devel wayland-devel pango-devel \
			wayscriber wayscriber-configurator lazygit hw-probe btop sqlite-devel \
			libxkbcommon-devel cairo-gobject-devel pandoc fuzzel

		# Niri compositor and DMS desktop shell (Copr)
		log "=== Enabling danklinux Copr for DMS (Material Shell) ==="
		if ! dnf repolist | grep -q -i "avengemedia.*danklinux\|danklinux"; then
			sudo dnf copr enable -y avengemedia/danklinux
		else
			log "danklinux Copr repository is already enabled."
		fi
		# Ensure conflicting Noctalia packages are removed before installing DMS & quickshell
		if rpm -q noctalia-qs &>/dev/null || rpm -q noctulia-qs &>/dev/null || rpm -q noctalia &>/dev/null; then
			log "=== Removing conflicting noctalia package(s) ==="
			sudo dnf remove -y noctalia-qs noctulia-qs noctalia 2>/dev/null || true
		fi

		# Explicitly install quickshell alongside dms and exclude noctalia/noctulia-qs
		sudo dnf install -y --allowerasing --exclude=noctalia-qs,noctulia-qs,noctalia \
			niri dms quickshell xdg-desktop-portal-wlr dankcalendar-git
		# Add niri to wlr portal UseIn list
		sudo sed -i 's/UseIn=wlroots;sway;Wayfire;river;phosh;Hyprland;/UseIn=wlroots;sway;Wayfire;river;phosh;Hyprland;niri;/' /usr/share/xdg-desktop-portal/portals/wlr.portal 2>/dev/null || true

		# I2C group for DDC/CI monitor brightness control
		log "=== Setting up i2c group for monitor brightness ===="
		if ! getent group i2c >/dev/null 2>&1; then
			sudo groupadd i2c
		fi
		sudo usermod -aG i2c "$USER"
		cat <<'EOF' | sudo tee /etc/udev/rules.d/99-i2c-permissions.rules > /dev/null
# Give i2c group access to /dev/i2c-* devices for DDC/CI monitor control
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
EOF
		sudo udevadm control --reload-rules 2>/dev/null || true
		log "=== i2c group created. Re-login required for brightness to work. ===="
	fi

	# 5. Rust Ecosystem & Language Runtime Tooling
	if [ "$SKIP_RUST" = false ]; then
		log "=== Installing Cargo binaries ==="
		# cargo-update provides cargo install-update; use it to skip already-current installs
		cargo install --locked cargo-cache cargo-update cargo-binstall
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
		flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

		FLATPAK_APPS=(
			org.blender.Blender
			com.calibre_ebook.calibre
			it.mijorus.gearlever
			org.keepassxc.KeePassXC
			org.kde.krita
			org.kde.kdenlive
			com.obsproject.Studio
			org.qbittorrent.qBittorrent
			com.github.wwmm.easyeffects
			com.github.tchx84.Flatseal
			org.freecad.FreeCAD
		)

		for app in "${FLATPAK_APPS[@]}"; do
			if flatpak info "$app" &>/dev/null; then
				log "Flatpak $app is already installed; updating..."
				flatpak update -y --system "$app" || log "Warning: Failed to update $app, continuing..."
			else
				log "Installing Flatpak $app..."
				flatpak install -y --or-update --system "$app" || log "Warning: Failed to install $app, continuing..."
			fi
		done
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

	# 9. Desktop Setup (Niri + DMS)
	if [ "$SKIP_DESKTOP" = false ]; then
		log "=== Setting up desktop entries, niri DM entry ===="
		# Ensure default.target prefers niri for the display-manager
		mkdir -p "$HOME/.config/systemd/user/niri.service.wants"

		# Create the niri session file if not present
		if [ ! -f "/usr/share/wayland-sessions/niri.desktop" ]; then
			sudo mkdir -p /usr/share/wayland-sessions
			cat <<'EOF' | sudo tee /usr/share/wayland-sessions/niri.desktop >/dev/null
[Desktop Entry]
Name=Niri
Comment=A scrollable-tiling Wayland compositor
Exec=niri-session
Type=Application
DesktopNames=niri
EOF
		fi

		# DMS first-launch will initialize the config; trigger it by removing marker
		rm -f "$HOME/.config/DankMaterialShell/.firstlaunch" 2>/dev/null || true

		log "=== DMS greeter will show on first Niri login ===="
	fi

	# 10. Services Activation
	if [ "$SKIP_SERVICES" = false ]; then
		log "=== Enabling user-space daemons ===="
		systemctl --user enable --now wayscriber.service 2>/dev/null || true
		systemctl --user enable --now syncthing.service
		systemctl --user enable --now dsearch

		# Stop swaync if running (DMS handles notifications)
		systemctl --user stop swaync.service 2>/dev/null || true
		systemctl --user disable swaync.service 2>/dev/null || true

		sudo firewall-cmd --zone=public --add-service=syncthing --permanent
		sudo firewall-cmd --reload
	fi

	log "=== System provisioning completed successfully ==="
	cd "$ORIGINAL_PWD"
}

main "$@"
