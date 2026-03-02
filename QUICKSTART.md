# Quickstart guide with tools and tweaks

This document defines the idempotent execution sequence for a Fedora-based Embedded Engineering workstation. It is architected to transition a pristine installation into a hardened, high-performance development environment.

---

## Phase 1: Core Toolchain & Repository Provisioning

Establish the foundation by updating the base system, adding external repositories, and authenticating core services.

### 1. Repository Injection
```bash
# Terra Repo (Ghostty/Edge Packages)
sudo dnf config-manager addrepo --from-repofile="https://repos.fyralabs.com/terra$(rpm -E %fedora)/terra.repo"

# Microsoft VSCode Repo
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Mise Toolchain Repo
sudo dnf config-manager addrepo --from-repofile="https://mise.jdx.dev/rpm/mise.repo"
```

### 2. Base System Synchronization
Force a metadata refresh and upgrade the system before dependency resolution.
```bash
sudo dnf upgrade --refresh -y
```

### 3. Package Deployment
Deploy the primary toolset including compilers, debuggers, and virtualization layers.
```bash
sudo dnf install -y llvm-devel clang lldb lld ccache git gh ghostty \
direnv lnav tree-sitter-cli valgrind gdb \
flatpak podman toolbox virt-manager \
code thunderbird keepassxc syncthing texlive-scheme-medium libusb1-devel \
distrobox openssl-devel alsa-lib-devel dbus-devel mold readline-devel asd \
sysstat perf picocom avrdude tuned-utils iotop nload clang-tools-extra \
mise gcc-gfortran

sudo dnf group install -y admin-tools c-development development-tools \
security-lab electronic-lab python-science libreoffice \
multimedia sound-and-video
```

### 4. Digilent Toolchain & Run-times
Install [Digilent Waveforms](https://digilent.com/reference/software/waveforms/waveforms-3/getting-started-guide) from local `.rpm` files.
```bash
sudo dnf install -y ./digilent.adept.runtime_*.rpm ./digilent.waveforms_*.rpm
```

---

## Phase 2: Environment Bootstrapping

Authorize Git and map configuration state to the local filesystem.

### 1. Authentication & Cloning
```bash
# Required for private submodules or repo access
gh auth login

# Clone and deploy dotfiles
gh repo clone gsmith-alvarez/.dotfiles ~/dotfiles
cd ~/dotfiles
stow .config -t ~
```

### 2. Runtime Toolchain
Initialize `mise` to manage language runtimes and other tools
```bash
mise install -y
```

---

## Phase 3: Hardware & Embedded Subsystem

Configure hardware access for serial bridges, MCU bootloaders, and logic analyzers.

### 1. Legacy Permission Fallback
Ensure older toolchains and packet capture utilities have sufficient permissions.
```bash
sudo usermod -aG dialout,wireshark $USER
```

### 2. Udev Rule Injection
Create persistent rules for user-level hardware access.

**Serial Probes (`/etc/udev/rules.d/60-serial-probes.rules`):**
```text
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", TAG+="uaccess"
```

**MCU Bootloaders (`/etc/udev/rules.d/61-mcu-bootloaders.rules`):**
```text
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", TAG+="uaccess"
```

**EE Tools (`/etc/udev/rules.d/62-ee-tools.rules`):**
```text
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0925", ATTRS{idProduct}=="3881", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1001", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1003", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1004", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1005", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="21a9", ATTRS{idProduct}=="1006", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1443", TAG+="uaccess"
```

### 3. Immediate Hardware Trigger
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger
```

---

## Phase 4: Userland & Sandboxing

Deploy GUI applications via Flatpak and manage hardware passthrough.

> **SECURITY WARNING:**
> The `--device=all` override intentionally shatters the Flatpak sandbox for specific applications. This is a calculated risk required to grant IDEs (Arduino, KiCad, BambuStudio) raw passthrough to MCU bootloaders and serial probes. Without this, the sandboxed apps cannot communicate with hardware via USB/Serial.

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub \
cc.arduino.IDE2 com.bambulab.BambuStudio com.calibre_ebook.calibre \
com.discordapp.Discord com.github.flxzt.rnote com.github.reds.LogisimEvolution \
com.github.tchx84.Flatseal com.github.wwmm.easyeffects com.jgraph.drawio.desktop \
com.obsproject.Studio com.usebottles.bottles \
eu.jumplink.Learn6502 io.github.alainm23.planify io.github.ra3xdh.qucs_s \
md.obsidian.Obsidian net.ankiweb.Anki org.freecad.FreeCAD \
org.gnome.NetworkDisplays org.kde.kdenlive org.kicad.KiCad org.qbittorrent.qBittorrent \
org.freedesktop.LinuxAudio.Plugins.Calf org.freedesktop.LinuxAudio.Plugins.LSP \
org.freedesktop.LinuxAudio.Plugins.MDA org.freedesktop.LinuxAudio.Plugins.TAP \
org.freedesktop.LinuxAudio.Plugins.ZamPlugins org.freedesktop.LinuxAudio.Plugins.swh

# Apply IPC/Device Overrides for Hardware Access
flatpak override --user --device=all cc.arduino.IDE2
flatpak override --user --device=all org.kicad.KiCad
flatpak override --user --device=all com.bambulab.BambuStudio
```

*Note: You can utilize [AppManager](https://github.com/kem-a/AppManager) for external AppImage-based tools like [LM Studio](https://lmstudio.ai/) and [Saleae Logic](https://saleae.com/).*

---

## Phase 5: Power & Memory Management

Optimize the system for diskless swap and modern power states.

### 1. zram & OOM-Killer
Eliminate disk-swap latency by compressing data in RAM.
```bash
sudo dnf install -y systemd-zram-generator
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd" | sudo tee /etc/systemd/zram-generator.conf
sudo systemctl daemon-reload && sudo systemctl start /dev/zram0
sudo systemctl enable --now systemd-oomd
```

### 2. Power States & Lid Behavior
Manage Thunderbolt DMA security and force uniform suspend behavior.
```bash
sudo dnf install -y bolt powertop tuned tuned-ppd
sudo systemctl enable --now tuned boltd

# Force suspend on lid close
echo -e "HandleLidSwitch=suspend\nHandleLidSwitchExternalPower=suspend\nHandleLidSwitchDocked=suspend" | sudo tee /etc/systemd/logind.conf.d/lid-behavior.conf
```

---

## Phase 6: Kernel & Scheduling

Replace default kernel parameters with high-performance backends.

### 1. iwd (Wi-Fi Backend)
Switch from `wpa_supplicant` to `iwd` for superior scanning speed and reduced overhead.
```bash
sudo dnf install -y iwd
echo -e "[device]\nwifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/iwd.conf
sudo systemctl mask wpa_supplicant
sudo systemctl enable --now iwd
sudo systemctl restart NetworkManager
```

### 2. scx (CPU Scheduler)
Bypass the standard EEVDF scheduler for `scx_rustland`, a BPF-based scheduler optimized for interactive latency.
```bash
sudo dnf copr enable -y bieszczaders/kernel-cachyos-addons
sudo dnf install -y scx-scheds scx-manager scx-tools
sudo systemctl enable --now scx_loader.service
sudo mkdir -p /etc/scx_loader
echo -e 'default_sched = "scx_rustland"\ndefault_mode = "Auto"' | sudo tee /etc/scx_loader/config.toml
```

---

## Phase 7: Network Hardening & Zero-Trust

Enforce strict boundary controls by separating discovery services from public interfaces.

### 1. Zone Hardening
Strip discovery and synchronization services from the `public` zone and relocate them to `home`.
```bash
# Target Services: KDE Connect, Syncthing, mDNS
for svc in kdeconnect syncthing mdns; do
    sudo firewall-cmd --permanent --zone=public --remove-service=$svc
    sudo firewall-cmd --permanent --zone=home --add-service=$svc
done
sudo firewall-cmd --reload
```

### 2. Connection Zoning
Assign your known home network to the trusted zone.
```bash
# Identify and re-zone home SSID
nmcli connection show
# Replace "MyHomeWiFi" with the actual SSID from the command above
sudo nmcli connection modify "MyHomeWiFi" connection.zone home
```

### 3. Verification
Confirm that the runtime firewall is no longer exposing sensitive ports to public interfaces.
```bash
firewall-cmd --zone=public --list-services
ss -tulpn | grep -E '1714-1764|22000|5353'
```
