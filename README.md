# My GNU/Linux config files

* Linux confix files
	- i3wm
	- others
* Editor configs
	- VSCODE
	- NVIM
* Scripts
	- **fan.sh** Thinkpad fan control

NixOS is in progress...

Cursor theme:
https://github.com/ful1e5/Bibata_Cursor_Rainbow
or
https://github.com/nxll/miniature

Favorite font:
https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip

## Vscode Setup
* Extentions 
	- 8-Bit *(theme)*
	- Code spell checker
	- Current Path
	- Error Lens
	- material icon theme
	- Power Mode *(Optional)*.
* **Copy Settings.json file**
* **Copy keybinding.json file**

## Neovim Setup

*Haven't maintained in some time and don't know if I will ever go back...*

1. Clone repo
2. Put init.lua ->  .config/nvim/init.lua
3. Install packer: ```git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim```
4. Install a nerd (Has to be a nerdfont) font:  CaskaydiaMono or FiraCode. If on WSL you'll have to install it on the windows only.
5. Open nvim and run: ```:PackerInstall``` ```:PackerUpdate``` ```:PackerSync``` ```:PackerCompile```
6. Enjoy

### My neovim config
* Space is the "Leader key"

### For LSP support:
* For C: clangd
* For Python: npm install -g pyright
