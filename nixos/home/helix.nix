{
  xdg.configFile."helix/config.toml".text = ''
    theme = "ao"

    [editor]
    end-of-line-diagnostics = "hint"
    line-number = "relative"
    true-color = true
    cursorline = true
    scrolloff = 8
    color-modes = true

    [editor.inline-diagnostics]
    cursor-line = "warning"

    [editor.whitespace]
    render = { space = "none", tab = "all", newline = "none" }

    [editor.soft-wrap]
    enable = true

    [editor.indent-guides]
    render = true
    skip-levels = 1
  '';
}