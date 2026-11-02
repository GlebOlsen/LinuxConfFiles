# linuxconffiles

My linux "stuff" and configs: a NixOS flake plus dotfiles for two machines.

## Layout

| Path | Contents |
|------|----------|
| `arch/` | Arch (i3/X11) dotfiles, laid out like `$HOME`: `arch/.config/i3/config` belongs at `~/.config/i3/config` |
| `nixos/` | Flake, hosts, and modules (the system config) |
| `archive/` | Old setups and retired configs (Hyprland, Sway, niri, i3bar/i3status, qutebrowser, vscode, zed, Helium, old Helix config, Neovim, yazi) |

In `arch/`, `.local/bin/` holds the Lenovo helper scripts (fan, battery, screen).

## NixOS

Flake (`nixos/flake.nix`) defines two hosts off a shared `modules/common.nix`:

- `nix-desktop`: AMD GPU (ROCm), systemd-boot, DDC/CI brightness.
- `nix-laptop`: Intel GPU, GRUB, TLP/thermald power, bluetooth, miracle-wm test.

Modules: `common.nix` (base system), `styling.nix` (GTK/cursor/font theming), `clipboard.nix` (cliphist + fuzzel image picker).

### Build

```sh
nh os switch nixos -H nix-desktop   # or nix-laptop
```

Or plain Nix:

```sh
sudo nixos-rebuild switch --flake ./nixos#nix-desktop
```

## Stack

- Window managers: i3/X11 and Hyprland/Wayland (Lua config). Sway archived.
- Wallpaper: nitrogen on i3; awww on Hyprland.
- Kernel: XanMod latest, low-latency tweaks, BBR + CAKE.
- Shell: fish. Audio: PipeWire. Editor: Neovim/Helix.
- Bleeding-edge nixpkgs `master` exposed as `pkgs.master`.

## Credits

- Cursor theme: [Bibata_Cursor_Rainbow](https://github.com/ful1e5/Bibata_Cursor_Rainbow)
- Font: [Cartograph CF](https://github.com/g5becks/Cartograph)
