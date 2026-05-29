{ pkgs, ... }:

let
  cliphist-fuzzel-img = pkgs.writeShellApplication {
    name = "cliphist-fuzzel-img";
    runtimeInputs = with pkgs; [ cliphist fuzzel gawk wl-clipboard coreutils ];
    text = ''
      thumbs="''${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbs"
      mkdir -p "$thumbs"

      # shellcheck disable=SC2016
      sel=$(cliphist list | gawk -v d="$thumbs" '
        match($0, /^([0-9]+)\t\[\[ binary data .*(png|jpg|jpeg|bmp|gif|webp|tiff).* \]\]$/, m) {
          f = d "/" m[1] ".png"
          system("[ -f \"" f "\" ] || (echo " m[1] " | cliphist decode > \"" f "\")")
          print $0 "\0icon\x1f" f; next
        }
        { print }
      ' | fuzzel --dmenu --placeholder "Clipboard..." --counter --no-sort --with-nth 2) || true

      [ -n "$sel" ] && printf '%s' "$sel" | cliphist decode | wl-copy
    '';
  };
in
{
  environment.systemPackages = [ pkgs.wl-clipboard pkgs.cliphist cliphist-fuzzel-img ];
}
