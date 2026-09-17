# Secrets Architecture & Operational Runbook

This repository integrates [sops-nix](https://github.com/Mic92/sops-nix) for declarative, encrypted secrets management.

> [!IMPORTANT]
> **Integration Status: Tools Only.** `sops-nix` is imported as a NixOS module in [modules/secrets.nix](../modules/secrets.nix), and CLI tools (`sops`, `age`, `ssh-to-age`) are installed in the devShell. **No encryption keys have been generated, no secrets have been enrolled, and no existing service credentials (e.g. Wi-Fi profiles) have been migrated.**

---

## 1. Threat Model & Secret Ownership

### Why Secrets Must Never Enter the Nix Store
By design, all paths in the Nix store (`/nix/store/...`) are **world-readable** (`0755` permissions for directories, `0444` or `0555` for files). Any unprivileged user or process running on the system can inspect every file in `/nix/store`.
- **Anti-Pattern**: Using `builtins.readFile ./my-token` or `pkgs.writeText "token" "secret"` can expose plaintext in the world-readable `/nix/store`; committing the source would also put it in Git history.
- **The sops-nix Solution**: Secrets are committed to Git **only as ciphertext** encrypted with public keys (`age`). At system boot or switch, `sops-nix` runs an activation service as `root` to decrypt the ciphertext in-memory directly into a `ramfs` (RAM filesystem) mounted at `/run/secrets/`. The provisioning path avoids storing plaintext in `/nix/store`. Editors, consuming services, logs, backups, or crash dumps may still persist plaintext; configure those separately.

### Secret Ownership at Runtime
Each secret declared under `sops.secrets.<name>` can specify its target Unix owner, group, and permissions:

```nix
sops.secrets."my-service-token" = {
  owner = "myuser";          # defaults to root
  group = "mygroup";         # defaults to root
  mode = "0400";             # readable only by the owner
  sopsFile = ../secrets/wolfgang.yaml;
};
```

When a service needs the secret, use its documented file-based credential option. This is schematic, not a copy-paste NixOS option:
```nix
services.<actual-service>.<its-secret-file-option> = config.sops.secrets."my-service-token".path;
# Evaluates to: "/run/secrets/my-service-token"
```

---

## 2. Deferred Enrollment Workflow

When you are ready to enroll encrypted secrets into this machine, follow this step-by-step procedure:

### Step 1: Generate an Admin Age Key (Local Workstation)
Create a personal age identity outside this repository (never commit this key). If `keys.txt` already exists, stop and reuse/back up that identity rather than replacing it. Run these commands only when deliberately enrolling keys:
```bash
mkdir -p -m 0700 ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 0600 ~/.config/sops/age/keys.txt
```
Extract your personal public recipient:
```bash
age-keygen -y ~/.config/sops/age/keys.txt
# Output: age1... (public recipient)
```
Securely back up `keys.txt` to offline physical storage or your password manager.

### Step 2: Derive the Host Public Key
On `wolfgang`, derive the host's public age key from its existing SSH host key:
```bash
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
# Output: age1... (host recipient)
```

### Step 3: Create the SOPS Creation Rules (`.sops.yaml`)
Create `.sops.yaml` in the repo root to define encryption recipients:
```yaml
creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - <ADMIN_PUBLIC_AGE_KEY>
          - <WOLFGANG_HOST_PUBLIC_AGE_KEY>
```
> [!NOTE]
> Placing both keys in the same `age` list allows *either* key to decrypt the file. Do not use multiple `key_groups` unless you deliberately intend to require multi-party threshold decryption.

### Step 4: Encrypt Secrets File
Create or edit the encrypted secrets file:
```bash
mkdir -p secrets
sops secrets/wolfgang.yaml
```
`sops` opens your `$EDITOR`. Add your YAML key-value pairs (e.g., `api_key: supersecret`). Upon saving and exiting, `sops` encrypts the values and saves ciphertext. Verify that only ciphertext is staged in Git:
```bash
git add -N secrets/wolfgang.yaml
git diff -- secrets/wolfgang.yaml
```

### Step 5: Configure the Host in NixOS
In [modules/secrets.nix](../modules/secrets.nix):
```nix
{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = [
    pkgs.sops
    pkgs.age
    pkgs.ssh-to-age
  ];

  sops = {
    defaultSopsFile = ../secrets/wolfgang.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets."example-service-token" = {
      owner = "giovanni";
      mode = "0400";
    };
  };
}
```

---

## 3. Verification & Safety Guarantees

- **Build vs. Runtime Separation**:
  Running `nix build .#nixosConfigurations.wolfgang.config.system.build.toplevel --no-link` checks the syntax and schema of your secrets configuration. However, **a successful build does NOT verify that decryption succeeds at runtime**. Decryption requires access to `/etc/ssh/ssh_host_ed25519_key`, which is only available on the physical machine during activation.
- **Never Claim Decryption Verified Without Activation**:
  Only once `nh os switch .` (or `sudo nixos-rebuild switch`) completes on the live machine and `/run/secrets/<name>` exists with valid permissions can runtime decryption be considered verified.
- **Key Rotation**:
  To rotate keys, update `.sops.yaml` with the new recipients and run:
  ```bash
  sops updatekeys secrets/wolfgang.yaml
  ```
  Always test decryption with the new key before discarding the old one.
