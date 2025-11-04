# 🎨 Dotfiles Repository

My personal dotfiles for a fast, beautiful Linux setup with Hyprland, Alacritty, and optimized Zsh.

## 🚀 Features

- **⚡ Lightning-fast Zsh** - Startup time ~50-100ms (vs 1000ms+ with standard Oh My Zsh)
- **🎨 Pywal Integration** - Dynamic color schemes from wallpapers
- **🖥️ Hyprland** - Wayland compositor configuration
- **🔧 Complete Config** - Everything from terminal to window manager
- **📦 Stow-managed** - Easy deployment and synchronization

## 📁 What's Included

### Window Manager & Desktop
- **hypr/** - Hyprland compositor configuration
- **waybar/** - Status bar
- **rofi/** - Application launcher
- **wofi/** - Wayland-native launcher
- **eww/** - Custom widgets
- **swaync/** - Notification daemon
- **swaylock/** - Screen locker
- **wlogout/** - Logout menu

### Terminal & Shell
- **alacritty/** - GPU-accelerated terminal emulator
- **ghostty/** - Alternative terminal configuration
- **home/.zshrc** - Optimized Zsh with zinit + lazy loading
- **home/.p10k.zsh** - Powerlevel10k theme configuration

### Development
- **nvim/** - Neovim configuration
- **zed/** - Zed editor configuration
- **home/.gitconfig** - Git configuration

### System Utilities
- **btop/** - System monitor
- **fastfetch/** - System information
- **rog/** - ASUS ROG utilities
- **swayosd/** - On-screen display

### Theming
- **wal/** - Pywal color templates
  - Alacritty colors
  - Hyprland colors
  - Custom theme templates

## 🎯 Quick Start

### Prerequisites

```bash
# Arch/Manjaro/CachyOS
sudo pacman -S stow git zsh alacritty hyprland waybar rofi \
               python-pywal neovim btop fastfetch

# Ubuntu/Debian (some packages may differ)
sudo apt install stow git zsh alacritty neovim btop
pip install pywal
```

### Installation

1. **Backup your existing configs** (important!)
   ```bash
   mkdir -p ~/dotfiles-backup
   cp -r ~/.config ~/dotfiles-backup/
   cp ~/.zshrc ~/.gitconfig ~/.p10k.zsh ~/dotfiles-backup/ 2>/dev/null || true
   ```

2. **Clone this repository**
   ```bash
   # If you already have a ~/.config, rename it first
   mv ~/.config ~/.config.old
   
   # Clone the repo
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git ~/.config
   cd ~/.config
   ```

3. **Deploy home directory dotfiles using Stow**
   ```bash
   # This creates symlinks for .zshrc, .gitconfig, etc.
   stow -v -t ~ home
   ```

4. **Install Zsh dependencies**
   ```bash
   # Install zinit (plugin manager)
   bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
   
   # Install NVM (Node Version Manager)
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
   
   # Install zoxide (better cd)
   curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
   
   # Optional: thefuck (command corrector)
   pip install thefuck
   ```

5. **Set Zsh as default shell**
   ```bash
   chsh -s $(which zsh)
   ```

6. **Generate Pywal colors** (optional but recommended)
   ```bash
   wal -i /path/to/your/favorite/wallpaper.jpg
   ```

7. **Restart your session** or reboot

## 🔄 Daily Usage

### Making Changes

Since we use GNU Stow, your dotfiles are **symlinked**. This means:

```bash
# Edit directly - changes automatically sync to repo
vim ~/.zshrc

# Commit changes
cd ~/.config
git add home/.zshrc
git commit -m "Update zshrc"
git push
```

See [STOW_USAGE.md](STOW_USAGE.md) for detailed Stow instructions.

### Updating Colors with Pywal

```bash
# Generate colors from wallpaper
wal -i /path/to/wallpaper.jpg

# Colors automatically apply to:
# - Alacritty
# - Hyprland
# - Other configured applications
```

### Pulling Updates on Another Machine

```bash
cd ~/.config
git pull
stow -R -v -t ~ home  # Restow to update symlinks if needed
```

## 📚 Documentation

- **[STOW_USAGE.md](STOW_USAGE.md)** - Complete guide to using GNU Stow with this repo
- **Configuration-specific READMEs** - Check individual config directories

## 🎨 Customization

### Changing the Shell Prompt

```bash
# Reconfigure Powerlevel10k
p10k configure
```

### Modifying Alacritty

Edit `~/.config/alacritty/alacritty.toml`:
- Font: Change `font.normal.family` and `font.size`
- Opacity: Change `window.opacity`
- Colors: Managed by Pywal (see `~/.config/wal/templates/alacritty.toml`)

### Hyprland Keybindings

Edit `~/.config/hypr/hyprland.conf` - keybindings section

### Adding New Dotfiles to Track

```bash
# Copy file to repo
cp ~/.mynewconfig ~/.config/home/.mynewconfig

# Remove original and stow
rm ~/.mynewconfig
cd ~/.config
stow -v -t ~ home

# Add to git
git add home/.mynewconfig
git commit -m "Add new config"
git push
```

## 🔧 Troubleshooting

### Stow Conflicts

If stow complains about conflicts:
```bash
# Backup existing files
mv ~/.zshrc ~/.zshrc.backup
mv ~/.gitconfig ~/.gitconfig.backup

# Then stow
cd ~/.config
stow -v -t ~ home
```

### Slow Zsh Startup

Profile your startup:
```bash
time zsh -i -c exit
```

Should be under 100ms. If not, check for:
- Heavy plugins loading synchronously
- Missing lazy-loading configurations

### Pywal Not Applying

```bash
# Regenerate colors
wal -i /path/to/wallpaper.jpg

# Check template exists
ls ~/.config/wal/templates/

# Restart Alacritty/terminal
```

## 📊 Performance

- **Zsh startup**: ~50-100ms (with zinit + lazy loading)
- **Alacritty**: GPU-accelerated, instant
- **Hyprland**: Smooth 144Hz+ support

## 🙏 Credits

- [Zinit](https://github.com/zdharma-continuum/zinit) - Fast Zsh plugin manager
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Lightning-fast prompt
- [Pywal](https://github.com/dylanaraps/pywal) - Color scheme generator
- [Hyprland](https://github.com/hyprwm/Hyprland) - Dynamic tiling Wayland compositor
- [Alacritty](https://github.com/alacritty/alacritty) - GPU-accelerated terminal
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink farm manager

## 📝 License

MIT License - Feel free to use and modify!

## 🔐 Security Note

This repo is **PUBLIC**. Never commit:
- SSH keys
- GPG keys
- API tokens
- Passwords or secrets
- `.env` files with sensitive data

These are already in `.gitignore`, but always double-check!

---

**Enjoy your setup! ⚡**