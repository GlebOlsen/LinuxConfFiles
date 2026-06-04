{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;

    plugins = {
      relative-motions = pkgs.yaziPlugins.relative-motions.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace main.lua --replace-fail "ya.mgr_emit(" "ya.emit("
        '';
      });
      gvfs = pkgs.yaziPlugins.gvfs;
      mount = pkgs.yaziPlugins.mount;
    };

    initLua = pkgs.writeText "yazi-init.lua" ''
      require("relative-motions"):setup({ show_numbers = "relative", show_motion = true })
      require("gvfs"):setup({
        save_path = os.getenv("HOME") .. "/.config/yazi/gvfs.private",
        password_vault = "keyring",
      })

      function Linemode:perms_owner_time()
        local cha = self._file.cha
        local perm = cha:perm() or ""

        local user = ya.user_name(cha.uid) or tostring(cha.uid or "")
        local group = ya.group_name(cha.gid) or tostring(cha.gid or "")

        local size = self._file:size()
        local size_s = size and ya.readable_size(size) or "-"

        local time = math.max(math.floor(cha.mtime or 0), math.floor(cha.btime or 0))
        local date = ""
        if time > 0 then
          if os.date("%Y", time) == os.date("%Y") then
            date = os.date("%b %d %H:%M", time)
          else
            date = os.date("%b %d  %Y", time)
          end
        end

        return string.format("%s  %s  %s:%s  %s", size_s, perm, user, group, date)
      end

      Status:children_add(function()
        local h = cx.active.current.hovered
        if not h or ya.target_family() ~= "unix" then
          return ""
        end
        local cha = h.cha

        local user = ya.user_name(cha.uid) or tostring(cha.uid or "")
        local group = ya.group_name(cha.gid) or tostring(cha.gid or "")

        local size = h:size()
        local size_s = size and ya.readable_size(size) or "-"

        local t = math.max(math.floor(cha.mtime or 0), math.floor(cha.btime or 0))
        local date = t > 0 and os.date("%b %d %H:%M", t) or ""

        return ui.Line {
          ui.Span(size_s .. "  "):fg("cyan"),
          ui.Span(user .. ":" .. group .. "  "):fg("magenta"),
          ui.Span(date .. "  "):fg("blue"),
        }
      end, 500, Status.RIGHT)

      Status:children_add(function()
        local files = cx.active.current.files
        local count, total = 0, 0
        for i = 1, #files do
          local f = files[i]
          if f:is_selected() then
            count = count + 1
            total = total + (f:size() or 0)
          end
        end
        if count == 0 then
          return ""
        end
        return ui.Line {
          ui.Span(string.format(" %d sel %s ", count, ya.readable_size(total))):fg("yellow"),
        }
      end, 600, Status.RIGHT)
    '';

    settings.yazi = {
      mgr.show_hidden = true;
      mgr.linemode = "perms_owner_time";
      preview = {
        max_width = 1920;
        max_height = 1920;
      };
    };

    settings.theme.indicator.padding = { open = "█"; close = "█"; };
    settings.theme.status.sep_left = { open = ""; close = ""; };
    settings.theme.status.sep_right = { open = ""; close = ""; };
    settings.theme.tabs.sep_inner = { open = ""; close = ""; };
    settings.theme.tabs.sep_outer = { open = ""; close = ""; };

    settings.keymap.mgr.prepend_keymap =
      (map (n: {
        on = [ (toString n) ];
        run = "plugin relative-motions ${toString n}";
        desc = "Move in relative steps";
      }) [ 1 2 3 4 5 6 7 8 9 ])
      ++ (map (n: {
        on = [ "<A-${toString n}>" ];
        run = "tab_switch ${toString (n - 1)}";
        desc = "Switch to tab ${toString n}";
      }) [ 1 2 3 4 5 6 7 8 9 ])
      ++ [
        { on = [ "M" "m" ]; run = "plugin gvfs -- select-then-mount --jump"; desc = "Mount device/share + jump"; }
        { on = [ "M" "u" ]; run = "plugin gvfs -- select-then-unmount --eject"; desc = "Unmount / eject"; }
        { on = [ "M" "a" ]; run = "plugin gvfs -- add-mount"; desc = "Add mount: smb:// sftp:// nfs://"; }
        { on = [ "M" "r" ]; run = "plugin gvfs -- remove-mount"; desc = "Remove saved mount"; }
        { on = [ "g" "m" ]; run = "plugin gvfs -- jump-to-device"; desc = "Jump to device"; }
      ]
      ++ [
        { on = [ "<C-y>" ]; run = ''shell -- magick %h png:- | wl-copy --type image/png''; desc = "Copy image to clipboard (paste into Discord/Chromium)"; }
        { on = [ "<A-y>" ]; run = ''shell -- wl-copy --type text/uri-list "file://$(realpath %h)"''; desc = "Copy file reference (Thunar-style)"; }
        { on = [ "<Tab>" ]; run = "spot"; desc = "Spot: image dimensions + metadata"; }
      ];
  };

  programs.bash.interactiveShellInit = ''
    function y() {
      local tmp cwd
      tmp="$(mktemp -t yazi-cwd.XXXXXX)"
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';

  # gvfs.yazi backend: network shares (SMB/SFTP/NFS/WebDAV) + device mounting,
  # and udisks2 for block-device enumeration (mount/unmount/eject).
  services.gvfs.enable = true;

  # `ils` -> sixel thumbnail grid of the current dir (foot speaks sixel, not kitty).
  environment.shellAliases.ils =
    "mcat ls --hyprlink --sixel --ls-opts 'height=10%,items_per_row=6'";

  environment.systemPackages = with pkgs; [
    imagemagick # `magick` -> transcode any image to PNG for clipboard paste (<C-y>)
    glib # `gio` CLI -> gvfs.yazi mount/unmount client
    libsecret # `secret-tool` -> gvfs.yazi keyring password vault
    mcat # `ils` image grid viewer
  ];
}
