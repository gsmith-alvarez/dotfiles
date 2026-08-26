# Keybinding Register — Modifier Layers

**Single source of truth for keyboard shortcut ownership.** Each input layer
owns exactly one modifier so muscle memory transfers between them and no chord
is silently stolen by a higher layer. Run `./scripts/check-layers.sh` after any
keybinding change to verify conformance.

"That is the leader-key model: a leader key defines each region."

| Modifier        | Layer                  | Owner                        | Sanctioned forms |
|-----------------|------------------------|------------------------------|------------------|
| **Super / Mod** | Compositor             | Niri (+ DMS)                 | `Mod`, `Mod+Alt`, `Mod+Ctrl`, `Mod+Shift` combos |
| **Alt**         | Terminal               | Ghostty (+ Meta, Nvim helpers) | `Alt+Tab` family is the **only** bare-Alt exception |
| **Space**       | Editor (leader)        | Neovim                       | `<leader>` = ` ` (`00-options.lua`) |
| **Ctrl**        | Neovim shell & tabs    | nvim `:term`, Ghostty tabs   | bare `Ctrl` in nvim; `Ctrl+Shift` / `Ctrl+Alt` in Ghostty |

## Hard rule

> **The compositor (Niri) must NEVER bind bare `Ctrl+X` or bare `Alt+X`** —
> except the single sanctioned `Alt+Tab` / `Alt+Shift+Tab` / `Alt+grave` /
> `Alt+Shift+grave` window-switching family.
>
> Once Niri lets go of bare Ctrl/Alt, those modifiers pass through to the
> terminal and editor, and every layer's chords work without interception.

## Where each layer is configured

| Layer     | File(s)                                        |
|-----------|------------------------------------------------|
| Compositor | `niri/.config/niri/config.kdl` (authoritative, post-include) + `niri/.config/niri/dms/binds.kdl` (DMS-managed) |
| Terminal  | `ghostty/.config/ghostty/config`               |
| Editor    | `nvim/.config/nvim/plugin/03-keymaps.lua`, `04-plugin-keymaps.lua` |
| Shell     | `fish/.config/fish/config.fish` (vi-bindings; Ctrl = line-editing) |

## Mappings that must hold (by pointer/decision)

| Binding | Layer | Action | Status |
|---------|-------|--------|--------|
| `Mod+H/J/K/L`, `Mod+arrows` | Compositor | focus column / workspace | ✅ |
| `Mod+Alt+H/J/K/L`, `Mod+Alt+arrows` | Compositor | **move** column / window | ✅ (moved from bare Ctrl) |
| `Mod+Shift+H/J/K/L`, `Mod+Shift+arrows` | Compositor | focus monitor | ✅ |
| `Mod+Shift+Ctrl+{H,J,K,L,arrows}` | Compositor | move column to monitor | ✅ |
| `Alt+Tab` / `Alt+grave` family | Compositor | **sanctioned exception** — window switching | ✅ |
| `Ctrl+H/J/K/L` | **Neovim** | window focus (editor/shell layer) | ✅ (Niri freed it) |
| `Ctrl+Shift+H/L` | Ghostty | previous/next tab | ✅ |
| `Ctrl+Alt+J/K/H/L` | Ghostty | split navigation | ✅ |
| `<leader>` = ` ` | Neovim | leader prefix | ✅ |
| `Mod+grave` | Compositor | focus previous workspace | ✅ |

## Sanctioned exceptions (deliberate, documented)

1. **`Alt+Tab` family** (Compositor window switching) — the one bare-Alt
   exception. Keep for universal muscle memory; Niri does not bind any other
   bare Alt.
2. **`Ctrl+Alt+Delete`** (Compositor quit / task manager) — reserved system
   chord; all layers agree it is "menu or quit".

## Why Nvim may use Alt and Ctrl freely

- Nvim's `Alt` helpers (`<A-t>`, `<A-e>`, `<A-j/k>`, …) fire **only while Nvim
  is focused**, so they never collide with Ghostty's Meta consumption or with a
  Niri Alt+Tab-only policy.
- Nvim's bare `Ctrl` window nav / core editing is safe once Niri binds no bare
  Ctrl.

## Maintenance notes

- **DMS regenerates `binds.kdl`.** Keep the authoritative keymap in
  `config.kdl` (defined *after* the `include` of `dms/binds.kdl`, so it wins).
  Comment conflicting entries in `binds.kdl`. Re-run `check-layers.sh` after
  any DMS settings change.
- **Ghostty files are tracked in the repo but NOT stowed** (regular copies in
  `~/.config/ghostty/`). Keep both in sync, or `stow ghostty` to symlink.

## Enforcement

```bash
./scripts/check-layers.sh        # fails on any violation
niri validate                    # compositor parses (run after config.kdl edits)
ghostty +validate-config         # terminal parses
```
