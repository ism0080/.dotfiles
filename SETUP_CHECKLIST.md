# Setup Checklist for WSL/Windows Dotfiles

Use this checklist to set up your new dotfiles environment.

## Prerequisites

### WSL Setup
- [ ] Windows 10/11 with WSL2 installed
- [ ] Ubuntu (or preferred distro) installed in WSL
- [ ] Windows Terminal installed (optional but recommended)

### Windows Setup
- [ ] Git for Windows installed
- [ ] PowerShell 5.1+ or PowerShell Core

## Initial Setup (Run in WSL)

### 1. Clone Repository
```bash
cd ~
git clone https://github.com/YOUR_USERNAME/dotfiles.git .dotfiles
cd .dotfiles
```

- [ ] Repository cloned to `~/.dotfiles`
- [ ] Changed into dotfiles directory

### 2. Personalize Git Configuration
```bash
vim home/.config/git/config
```

Edit these fields:
- [ ] Replace `YOUR_NAME` with your name
- [ ] Replace `YOUR_EMAIL` with your email
- [ ] (Optional) Uncomment GPG signing if you use it

If you need work configuration:
```bash
vim home/.config/git/work_config
```

- [ ] Replace `YOUR_WORK_NAME` with your work name
- [ ] Replace `YOUR_WORK_EMAIL` with your work email
- [ ] Update the `includeIf` path in main config if your work dir isn't `~/work/`

### 3. Review Packages
```bash
cat packages/bundle
```

- [ ] Review Homebrew packages
- [ ] Add/remove packages as needed
- [ ] Review work packages in `packages/bundle.work`

### 4. Run Initial Setup
```bash
chmod +x dot
./dot init
```

This will:
- [ ] Install Homebrew
- [ ] Install packages from Brewfile
- [ ] Create symlinks to config files
- [ ] Set up Zsh shell (if selected)

### 5. Restart Shell
```bash
# Close and reopen terminal, or:
exec $SHELL
```

- [ ] Shell restarted with new configuration

### 6. Verify Installation
```bash
./dot doctor
```

Check that:
- [ ] Homebrew is installed
- [ ] Git config is linked
- [ ] Neovim config is linked
- [ ] All essential tools are available

### 7. Set Up SSH Keys (if needed)
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

- [ ] SSH key generated
- [ ] Public key copied
- [ ] Added to GitHub/GitLab (Settings → SSH Keys)

## Windows Side Setup

### 1. Install Scoop
Open PowerShell (non-admin):
```powershell
irm get.scoop.sh | iex
```

- [ ] Scoop installed successfully
- [ ] Test with: `scoop --version`

### 2. Run Automated Windows Setup
Navigate to dotfiles directory and run:
```powershell
cd C:\dev\projects\dotfiles  # or wherever you cloned it
.\scripts\setup-windows.ps1
```

This will:
- Install all Scoop packages from `scoopfile.json`
- Install PowerShell modules (PSReadLine, PSFzf, posh-git, Terminal-Icons)
- Create symlinks (requires running as Administrator for this step)

If not running as admin, you'll be prompted to run the symlink script separately.

- [ ] Scoop packages installed (lsd, fzf, gh, lazygit, etc.)
- [ ] PowerShell modules installed
- [ ] Proceed to next step for symlinks if needed

### 3. Create Symlinks (if not done in step 2)
Open PowerShell **as Administrator** and run:
```powershell
cd C:\dev\projects\dotfiles
.\scripts\setup-windows-links.ps1
```

- [ ] Git config symlink created
- [ ] Neovim config symlink created
- [ ] PowerShell profile symlink created
- [ ] Verified symlinks work from Windows

### 4. Test Windows Tools
```powershell
git --version
nvim --version
git config user.name  # Should show your name from WSL config
```

- [ ] Git works and shows correct config
- [ ] Neovim opens with WSL config

### 5. Reload PowerShell Profile
Close and reopen PowerShell, or reload the profile:
```powershell
. $PROFILE
```

- [ ] PowerShell profile loaded without errors
- [ ] Starship prompt visible in PowerShell
- [ ] Test alias: `ll` (should list files)
- [ ] Test alias: `g` (should run git status)

## Optional Enhancements

### Tmux Plugin Manager
```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Then in tmux: `Ctrl-a I` to install plugins

- [ ] TPM installed
- [ ] Tmux plugins installed

### Neovim Plugins
Open Neovim:
```bash
nvim
```

Lazy.nvim will automatically bootstrap and install plugins.

- [ ] Lazy.nvim bootstrapped
- [ ] Plugins installed
- [ ] No errors on startup

### Starship Prompt
Already configured! Just verify it's working:
```bash
which starship
# Should see the custom prompt
```

- [ ] Starship prompt visible

## Verification Tests

### Test Git Configuration
```bash
# Test personal config
cd ~
git config user.email  # Should show personal email

# Test work config (if configured)
mkdir -p ~/work/test-repo
cd ~/work/test-repo
git init
git config user.email  # Should show work email
cd ~ && rm -rf ~/work/test-repo
```

- [ ] Personal git config works
- [ ] Work git config applies in work directory

### Test Neovim
```bash
nvim
# Try: <leader>w (should save, leader is space)
# Try: <C-h> <C-j> <C-k> <C-l> (window navigation)
```

- [ ] Neovim opens without errors
- [ ] Keybindings work
- [ ] Clipboard works (copy/paste with `y`/`p`)

### Test Tmux
```bash
tmux
# Try: Ctrl-a | (horizontal split)
# Try: Ctrl-a - (vertical split)
# Try: Ctrl-a h/j/k/l (navigate panes)
```

- [ ] Tmux starts without errors
- [ ] Custom keybindings work
- [ ] Mouse support works

### Test Windows → WSL Config Access
From PowerShell:
```powershell
git config user.name
nvim test.txt  # Save with :w and quit with :q
```

- [ ] Windows git uses WSL config
- [ ] Windows Neovim uses WSL config

### Test PowerShell Integration
From PowerShell:
```powershell
# Test aliases
ll  # Should list files with details
g   # Should show git status
which nvim  # Should find neovim

# Test integrations (if starship/zoxide installed)
# Starship prompt should be visible
# Try: z <directory> (if zoxide is installed)
```

- [ ] PowerShell aliases work correctly
- [ ] Starship prompt displays in PowerShell
- [ ] Git integration works in PowerShell
- [ ] Neovim accessible from PowerShell

## Post-Setup

### Create Work Directory (if needed)
```bash
mkdir -p ~/work
```

- [ ] Work directory created

### Add Dotfiles to PATH
The `dot` command should be available. If not:
```zsh
# In Zsh
export PATH= ~/.dotfiles
```

- [ ] `dot` command accessible from anywhere

### Set Up Git Commit Signing (optional)
```bash
# Uncomment GPG settings in git config
vim ~/.dotfiles/home/.config/git/config
```

- [ ] GPG signing enabled (if desired)

### Customize Further
- [ ] Add personal Neovim plugins in `home/.config/nvim/lua/plugins/`
- [ ] Customize Zsh abbreviations in `home/.config/zsh/.zshrc`
- [ ] Add more packages to Brewfile
- [ ] Customize tmux keybindings

## Troubleshooting

If something doesn't work, refer to:
- `./dot doctor` - System diagnostics
- `README.md` - Full documentation
- `QUICKREF.md` - Quick command reference

## Maintenance

### Regular Updates
```bash
cd ~/.dotfiles
./dot update  # Updates repo and packages
```

- [ ] Set reminder to update weekly/monthly

### Backup Strategy
Since configs are in git:
```bash
cd ~/.dotfiles
git add .
git commit -m "Update configs"
git push
```

- [ ] Initial commit pushed to GitHub
- [ ] Set up regular backup routine

---

## ✅ Setup Complete!

You now have a fully configured WSL/Windows dotfiles setup with:
- ✅ Shared Git and Neovim configs
- ✅ Work/personal Git configuration separation
- ✅ Homebrew (WSL) + Scoop (Windows) package management
- ✅ Zsh shell with Starship prompt
- ✅ PowerShell profile with matching aliases and integrations
- ✅ Tmux with custom keybindings
- ✅ Cross-platform clipboard support

Next steps:
1. Explore the configurations and customize to your liking
2. Read `QUICKREF.md` for daily commands
3. Check out the reference dotfiles at https://github.com/dmmulroy/.dotfiles for more ideas

Happy coding! 🚀
