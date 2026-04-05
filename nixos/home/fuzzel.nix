{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Cartograph CF:size=16";
        prompt = "> ";
        icon-theme = "hicolor";
        icons-enabled = "yes";
        terminal = "foot -e";
        lines = 15;
        width = 40;
        horizontal-pad = 20;
        vertical-pad = 10;
        inner-pad = 5;
        line-height = 24;
        letter-spacing = 0;
      };

      colors = {
        background = "051405f2";
        text = "a3be8cff";
        match = "ecf39eff";
        selection = "b3ff00ff";
        selection-text = "051405ff";
        selection-match = "051405ff";
        border = "132a13ff";
      };

      border = {
        width = 2;
        radius = 0;
      };
    };
  };
}