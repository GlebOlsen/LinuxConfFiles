# Doom Emacs (archived)

Snapshot of the Doom Emacs experiment, run alongside neovim via
[`nix-doom-emacs-unstraightened`](https://github.com/marienz/nix-doom-emacs-unstraightened).
Config baked into the Nix store — no `~/.config/doom`, no `doom sync`, no home-manager.

Removed from the live config. Files here: `init.el`, `config.el`, `packages.el`
(the doomDir), plus the nix wiring below.

## Re-import

1. **flake.nix** — add input:

   ```nix
   nix-doom-emacs-unstraightened = {
     url = "github:marienz/nix-doom-emacs-unstraightened";
     inputs.nixpkgs.follows = "";
   };
   ```

2. **modules/common.nix** — add the overlay (first entry of `nixpkgs.overlays`):

   ```nix
   inputs.nix-doom-emacs-unstraightened.overlays.default
   ```

   and the alias + service:

   ```nix
   environment.shellAliases = {
     dm = "doom-emacs -nw";
   };
   services.emacs = {
     enable = true;
     package = pkgs.doomEmacs {
       doomDir = ./doom;
       doomLocalDir = "~/.local/share/nix-doom";
       emacs = pkgs.emacs30-pgtk;
     };
   };
   ```

3. Put `init.el` / `config.el` / `packages.el` into `modules/doom/`.

4. `nix flake lock` then `nh os switch`.

## Notes

- Launch: `dm` (= `doom-emacs -nw`, cold start) or GUI `doom-emacs`. nvim stays `defaultEditor`.
- `doomLocalDir` (`~/.local/share/nix-doom`) = runtime state, regenerated; safe to delete.
- Theme `doom-badger`, italics off. hl-line/current-linenr bg (`#242A15`) is `#B3FF00` @ ~8%
  pre-blended over the theme bg `#171717` — recompute if the theme changes.
- vterm apps: `SPC o g` lazygit, `SPC o s` scooter (need those on PATH).
