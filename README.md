# linuxconffiles

My linux "stuff" config: a NixOS flake plus dotfiles for two machines.

## Layout

| Path | Contents |
|------|----------|
| `nixos/` | Flake, hosts, and modules (the system config) |
| `sway/` | Sway WM, waybar, foot, fuzzel, swaylock |
| `hyprland/` | Hyprland WM, waybar, foot, fuzzel, hyprpaper |
| `terminalEditors/` | Helix, Neovim, micro configs |
| `heliumbrowser/` | Helium browser (ublock, vimium) |
| `home/` | `.bashrc`, `.tmux.conf` |
| `cava/`, `ncspot/` | Audio visualizer, Spotify TUI |
| `scripts/` | Helper lenovo scripts (fan, backlight, screen) |
| `archive/` | Old setups (i3, niri, qutebrowser, old Hyprland, vscode, zed.) |

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

- Compositor: Sway (patched fullscreen), Hyprland available.
- Kernel: XanMod latest, low-latency tweaks, BBR + CAKE.
- Shell: fish. Audio: PipeWire. Editor: Neovim/Helix.
- Bleeding-edge nixpkgs `master` exposed as `pkgs.master`.

## Credits

- Cursor theme: [Bibata_Cursor_Rainbow](https://github.com/ful1e5/Bibata_Cursor_Rainbow)
- Font: [Cartograph CF](https://github.com/g5becks/Cartograph)
