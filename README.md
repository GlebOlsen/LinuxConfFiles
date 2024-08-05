# My GNU/Linux config files

* HOME config files
* i3 config files in i3config and i3status
* picom compositor

Cursor theme:
https://github.com/ful1e5/Bibata_Cursor_Rainbow

...

## My neovim config
* Space is the "Leader key"


### For LSP support:
* For C: clangd
* For Python: npm install -g pyright

### Instalation
1. Clone repo
2. Put init.lua ->  .config/nvim/init.lua
3. Install packer: ```git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim```
4. Install a nerd (Has to be a nerdfont) font:  CaskaydiaMono or FiraCode. If on WSL you'll have to install it on the windows only.
5. Open nvim and run: ```:PackerInstall``` ```:PackerUpdate``` ```:PackerSync``` ```:PackerCompile```
6. Enjoy

## My vscode config
Need to install: 
Code spell checker, Current Path, Dragan theme, Error Lens, GitLens, Glassit, indent-rainbow, material icon theme.
