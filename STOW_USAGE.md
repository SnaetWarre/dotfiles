# 🔗 GNU Stow Usage Guide

This repository uses **GNU Stow** to manage dotfiles that live outside the `.config` directory (like `.zshrc`, `.gitconfig`, etc.).

## 📁 Repository Structure

```
~/.config/  (this repo)
├── home/                    # Dotfiles that belong in ~/
│   ├── .zshrc              # → ~/.zshrc
│   ├── .zshenv             # → ~/.zshenv
│   ├── .zprofile           # → ~/.zprofile
│   ├── .p10k.zsh           # → ~/.p10k.zsh
│   ├── .gitconfig          # → ~/.gitconfig
│   └── .fonts.conf         # → ~/.fonts.conf
├── alacritty/              # → ~/.config/alacritty/
├── hypr/                   # → ~/.config/hypr/
├── nvim/                   # → ~/.config/nvim/
├── wal/                    # → ~/.config/wal/
└── ... (other config dirs)
```

## 🚀 Quick Start

### First Time Setup (New System)

1. **Install GNU Stow**
   ```bash
   # Arch/Manjaro/CachyOS
   sudo pacman -S stow
   
   # Ubuntu/Debian
   sudo apt install stow
   
   # Fedora
   sudo dnf install stow
   
   # macOS
   brew install stow
   ```

2. **Clone this repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git ~/.config
   cd ~/.config
   ```

3. **Deploy home directory dotfiles**
   ```bash
   stow -v -t ~ home
   ```
   
   This creates symlinks:
   - `~/.zshrc` → `~/.config/home/.zshrc`
   - `~/.p10k.zsh` → `~/.config/home/.p10k.zsh`
   - etc.

4. **Done!** 
   Your config files are now in sync. Any changes you make to `~/.zshrc` will automatically be reflected in the repo (because they're symlinked).

## 🔄 Common Operations

### Deploy/Update Dotfiles
```bash
cd ~/.config
stow -v -t ~ home
```

### Remove Symlinks (Unstow)
```bash
cd ~/.config
stow -D -t ~ home
```

### Re-stow (Useful after updates)
```bash
cd ~/.config
stow -R -t ~ home
```

### Check What Would Happen (Dry Run)
```bash
cd ~/.config
stow -n -v -t ~ home
```

## 📝 Making Changes

### Option 1: Edit Directly in Home Directory (Recommended)
```bash
# Just edit the file normally - it's symlinked!
vim ~/.zshrc
# Changes are automatically in the repo
cd ~/.config
git add home/.zshrc
git commit -m "Update zshrc"
git push
```

### Option 2: Edit in the Repo
```bash
vim ~/.config/home/.zshrc
# Changes are immediately live in ~/
cd ~/.config
git add home/.zshrc
git commit -m "Update zshrc"
git push
```

Both work the same because of symlinks! 🎉

## ➕ Adding New Dotfiles

To track a new dotfile from your home directory:

1. **Copy the file to the repo**
   ```bash
   cp ~/.mynewconfig ~/.config/home/.mynewconfig
   ```

2. **Remove the original and stow**
   ```bash
   rm ~/.mynewconfig
   cd ~/.config
   stow -v -t ~ home
   ```

3. **Commit to git**
   ```bash
   git add home/.mynewconfig
   git commit -m "Add mynewconfig"
   git push
   ```

## 🆘 Troubleshooting

### "WARNING! stowing home would cause conflicts"

This means files already exist. You have options:

**Option A: Backup and stow**
```bash
# Backup existing files
mkdir -p ~/dotfiles-backup
mv ~/.zshrc ~/dotfiles-backup/
mv ~/.gitconfig ~/dotfiles-backup/
# ... backup any conflicting files

# Then stow
cd ~/.config
stow -v -t ~ home
```

**Option B: Adopt existing files** (use with caution!)
```bash
cd ~/.config
stow --adopt -v -t ~ home
# This moves your existing files INTO the repo
# Then check what changed:
git diff home/
```

### "stow: Cannot read link"

Make sure you're running stow from the correct directory:
```bash
cd ~/.config  # Must be here!
stow -v -t ~ home
```

### Symlinks Look Broken in File Manager

They're not! Some file managers show symlinks as broken if the target uses `~` or relative paths. They still work fine.

### Want to Stop Using Stow?

```bash
# 1. Unstow (removes symlinks)
cd ~/.config
stow -D -t ~ home

# 2. Copy files back to home
cp ~/.config/home/.zshrc ~/
cp ~/.config/home/.gitconfig ~/
# ... etc

# 3. Remove the home/ directory from repo
rm -rf ~/.config/home/
```

## 🎯 Why Use Stow?

### Benefits
- ✅ **Symlinks**: Edit files in place, changes auto-sync to repo
- ✅ **Clean**: No manual copying needed
- ✅ **Version Control**: All configs in git
- ✅ **Portable**: Clone repo on new machine → `stow` → done!
- ✅ **Safe**: Can unstow anytime without losing files

### What Stow Does
```bash
# Before stow:
~/.config/home/.zshrc     (in repo)
~/.zshrc                   (separate file)

# After stow:
~/.config/home/.zshrc     (actual file in repo)
~/.zshrc                   (symlink → ~/.config/home/.zshrc)
```

Now editing either file edits the same actual file!

## 📚 Advanced Usage

### Stow Multiple Packages
```bash
# If you had more packages organized:
cd ~/.config
stow -v -t ~ home         # Home dotfiles
stow -v -t ~ scripts      # Scripts to ~/.local/bin
stow -v -t ~ fonts        # Fonts to ~/.local/share/fonts
```

### Restow Everything
```bash
cd ~/.config
stow -R -v -t ~ home
```

### Ignore Certain Files When Stowing
Create `.stow-local-ignore` in the package directory:
```bash
echo "*.backup" >> ~/.config/home/.stow-local-ignore
echo "*.log" >> ~/.config/home/.stow-local-ignore
```

## 🔐 Security Notes

- **NEVER** add sensitive files like:
  - SSH keys (`~/.ssh/`)
  - GPG keys (`~/.gnupg/`)
  - API tokens or passwords
  - `.env` files with secrets

- These are already in `.gitignore` but be careful!

## 📖 Additional Resources

- [GNU Stow Official Docs](https://www.gnu.org/software/stow/manual/stow.html)
- [Stow Tutorial](https://www.jakewiesler.com/blog/managing-dotfiles)

---

**Happy Stowing! 🎉**