{ pkgs, lib, ... }:

let
  gtkTheme = "Matcha-dark-sea";
  iconTheme = "Obsidian-Mint";
  cursorTheme = "miniature";
  cursorSize = 64;
  gtkFont = "Adwaita Sans 11";
  defaultFont = "Cartograph CF";
  monospaceFont = "${defaultFont} 11";

  miniatureCursors = pkgs.runCommandLocal "miniature-cursors" { } ''
    mkdir -p $out/share/icons/${cursorTheme}
    cp -r ${../assets/cursors/miniature}/. $out/share/icons/${cursorTheme}/
  '';

  cartographFonts = pkgs.runCommandLocal "cartograph-fonts" { } ''
    mkdir -p $out/share/fonts/opentype/Cartograph
    cp -r ${../assets/fonts/Cartograph}/. $out/share/fonts/opentype/Cartograph/
  '';

  gtk4Settings = ''
    [Settings]
    gtk-theme-name=${gtkTheme}
    gtk-icon-theme-name=${iconTheme}
    gtk-font-name=${gtkFont}
    gtk-cursor-theme-name=${cursorTheme}
    gtk-cursor-theme-size=${toString cursorSize}
    gtk-application-prefer-dark-theme=1
  '';

  gtk3Settings = ''
    [Settings]
    gtk-theme-name=${gtkTheme}
    gtk-icon-theme-name=${iconTheme}
    gtk-font-name=${gtkFont}
    gtk-cursor-theme-name=${cursorTheme}
    gtk-cursor-theme-size=${toString cursorSize}
    gtk-toolbar-style=GTK_TOOLBAR_ICONS
    gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
    gtk-button-images=0
    gtk-menu-images=0
    gtk-enable-event-sounds=1
    gtk-enable-input-feedback-sounds=0
    gtk-xft-antialias=1
    gtk-xft-hinting=1
    gtk-xft-hintstyle=hintslight
    gtk-xft-rgba=rgb
    gtk-application-prefer-dark-theme=1
  '';

  gtk2Settings = ''
    gtk-theme-name="${gtkTheme}"
    gtk-icon-theme-name="${iconTheme}"
    gtk-font-name="${gtkFont}"
    gtk-cursor-theme-name="${cursorTheme}"
    gtk-cursor-theme-size=${toString cursorSize}
    gtk-toolbar-style=GTK_TOOLBAR_ICONS
    gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
    gtk-button-images=0
    gtk-menu-images=0
    gtk-enable-event-sounds=1
    gtk-enable-input-feedback-sounds=0
    gtk-xft-antialias=1
    gtk-xft-hinting=1
    gtk-xft-hintstyle="hintslight"
    gtk-xft-rgba="rgb"
  '';

  xsettingsdSettings = ''
    Net/ThemeName "${gtkTheme}"
    Net/IconThemeName "${iconTheme}"
    Gtk/CursorThemeName "${cursorTheme}"
    Net/EnableEventSounds 1
    EnableInputFeedbackSounds 0
    Xft/Antialias 1
    Xft/Hinting 1
    Xft/HintStyle "hintslight"
    Xft/RGBA "rgb"
  '';
in
{
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [{
    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = gtkTheme;
      icon-theme = iconTheme;
      cursor-theme = cursorTheme;
      cursor-size = lib.gvariant.mkInt32 cursorSize;
      font-name = gtkFont;
      monospace-font-name = monospaceFont;
    };
  }];

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment.sessionVariables = {
    XCURSOR_THEME = cursorTheme;
    XCURSOR_SIZE = toString cursorSize;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
    cartographFonts
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ defaultFont ];
    sansSerif = [ defaultFont ];
    serif = [ defaultFont ];
    emoji = [ "Noto Color Emoji" ];
  };

  environment.etc = {
    "xdg/gtk-3.0/settings.ini".text = gtk3Settings;
    "xdg/gtk-4.0/settings.ini".text = gtk4Settings;
    "xdg/gtk-4.0/assets".source = "${pkgs.matcha-gtk-theme}/share/themes/${gtkTheme}/gtk-4.0/assets";
    "xdg/gtk-4.0/gtk.css".source = "${pkgs.matcha-gtk-theme}/share/themes/${gtkTheme}/gtk-4.0/gtk.css";
    "xdg/gtk-4.0/gtk-dark.css".source = "${pkgs.matcha-gtk-theme}/share/themes/${gtkTheme}/gtk-4.0/gtk-dark.css";
    "gtk-2.0/gtkrc".text = gtk2Settings;
    "xdg/xsettingsd/xsettingsd.conf".text = xsettingsdSettings;
  };

  systemd.user.services.xsettingsd = lib.mkIf (pkgs ? xsettingsd) {
    description = "XSettings daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xsettingsd}/bin/xsettingsd -c /etc/xdg/xsettingsd/xsettingsd.conf";
      Restart = "on-failure";
    };
  };

  environment.systemPackages =
    (with pkgs; [
      matcha-gtk-theme
      iconpack-obsidian
      miniatureCursors
    ])
    ++ lib.optional (pkgs ? xsettingsd) pkgs.xsettingsd;
}
