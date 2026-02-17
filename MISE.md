# Mise - Runtime Version Manager

This guide explains how mise is configured and used in the dotfiles setup.

## What is Mise?

[Mise](https://mise.jdx.dev/) (pronounced "meez") is a modern, fast runtime version manager that replaces:
- nvm/fnm (Node.js)
- rbenv/rvm (Ruby)
- pyenv (Python)
- goenv (Go)
- And many others...

**Benefits:**
- ✅ **Single tool** - Manages all language runtimes
- ✅ **Fast** - Written in Rust, much faster than alternatives
- ✅ **Compatible** - Reads `.nvmrc`, `.node-version`, `.ruby-version`, etc.
- ✅ **Cross-platform** - Works on WSL, macOS, and Windows
- ✅ **Plugin ecosystem** - Supports hundreds of tools via plugins

## Installation

### WSL (Linux)
Mise is installed via Homebrew (already in `packages/bundle`):
```bash
brew install mise
```

### Windows
Mise is installed via Scoop (already in `packages/scoopfile.json`):
```powershell
scoop install mise
```

## Configuration Files

### Global Configuration
**Location:** `~/.mise.toml` (symlinked from `dotfiles/home/.mise.toml`)

```toml
[tools]
node = "lts"  # Use Node.js LTS version globally

[settings]
experimental = true
legacy_version_file = true  # Read .nvmrc, .node-version, etc.
```

### Per-Directory Configuration
**Location:** `.mise.toml` in project root

```toml
[tools]
node = "20.11.0"
python = "3.12.0"
ruby = "3.3.0"
```

Or use `mise use` command:
```bash
cd my-project
mise use node@20
mise use python@3.12
```

### Alternative: Legacy Files
Mise automatically reads these files:
- `.node-version` → Node.js version
- `.nvmrc` → Node.js version
- `.ruby-version` → Ruby version
- `.python-version` → Python version
- `.go-version` → Go version

## Common Commands

### Install Runtimes

```bash
# Install specific version
mise install node@20.11.0

# Install latest version
mise install node@latest

# Install LTS version
mise install node@lts

# Install all tools from .mise.toml
mise install
```

### Set Versions

```bash
# Set version for current directory
mise use node@20

# Set global version
mise use -g node@lts

# Set specific version
mise use python@3.12.0
```

### List Versions

```bash
# List installed versions
mise list

# List available versions for a tool
mise list-all node

# Show current active versions
mise current
```

### Update and Upgrade

```bash
# Update mise itself
brew upgrade mise  # WSL
scoop update mise  # Windows

# Upgrade installed runtimes to latest
mise upgrade

# Upgrade specific tool
mise upgrade node
```

### Remove Versions

```bash
# Uninstall specific version
mise uninstall node@18.0.0

# Remove all unused versions
mise prune
```

## Shell Integration

### Zsh (WSL)
Already configured in `.zshrc`:
```zsh
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi
```

### PowerShell (Windows)
Already configured in PowerShell profile:
```powershell
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (mise activate powershell | Out-String) })
}
```

## Usage Examples

### Node.js Project

```bash
cd my-node-project

# Use Node 20 for this project
mise use node@20

# This creates .mise.toml with:
# [tools]
# node = "20"

# Install Node 20
mise install

# Verify
node --version  # v20.x.x
```

### Multi-Language Project

```bash
cd my-fullstack-project

# Set multiple runtimes
mise use node@20 python@3.12 ruby@3.3

# Install all
mise install

# Check what's active
mise current
```

### Global Default Versions

```bash
# Set global defaults
mise use -g node@lts
mise use -g python@3.12

# These are written to ~/.mise.toml
```

### Using with Legacy Files

If your project has `.nvmrc`:
```bash
echo "20.11.0" > .nvmrc
mise install  # Automatically reads .nvmrc
```

## Available Runtimes

Mise supports hundreds of tools. Common ones:

### Languages
- **Node.js**: `mise install node@20`
- **Python**: `mise install python@3.12`
- **Ruby**: `mise install ruby@3.3`
- **Go**: `mise install go@1.22`
- **Rust**: `mise install rust@latest`
- **Java**: `mise install java@21`
- **PHP**: `mise install php@8.3`
- **Deno**: `mise install deno@latest`
- **Bun**: `mise install bun@latest`
- **Elixir**: `mise install elixir@latest`
- **Erlang**: `mise install erlang@latest`

### Tools
- **Terraform**: `mise install terraform@latest`
- **kubectl**: `mise install kubectl@latest`
- **helm**: `mise install helm@latest`
- And many more...

See full list: https://mise.jdx.dev/registry.html

## Migration from Other Version Managers

### From NVM

```bash
# Old (nvm)
nvm install 20
nvm use 20

# New (mise)
mise install node@20
mise use node@20

# Or just rely on .nvmrc
# mise automatically reads it
```

### From rbenv

```bash
# Old (rbenv)
rbenv install 3.3.0
rbenv local 3.3.0

# New (mise)
mise install ruby@3.3.0
mise use ruby@3.3.0
```

### From pyenv

```bash
# Old (pyenv)
pyenv install 3.12.0
pyenv local 3.12.0

# New (mise)
mise install python@3.12.0
mise use python@3.12.0
```

## Troubleshooting

### Mise command not found

**WSL:**
```bash
# Make sure Homebrew is in PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Reload shell
exec $SHELL

# Or install manually
curl https://mise.run | sh
```

**Windows:**
```powershell
# Make sure Scoop is installed
scoop install mise

# Reload PowerShell
. $PROFILE
```

### Runtime not activating

```bash
# Make sure mise is activated in your shell
# Check .zshrc or PowerShell profile

# Manually activate
eval "$(mise activate zsh)"  # Zsh
# Or
mise activate powershell | Out-String | Invoke-Expression  # PowerShell

# Verify
mise current
```

### Wrong version being used

```bash
# Check which version is active
mise current

# Check where version is set
mise where node

# Debug which config files are being read
mise doctor
```

### Clear cache

```bash
# Clear mise cache
rm -rf ~/.local/share/mise
rm -rf ~/.cache/mise

# Reinstall tools
mise install
```

## Tips and Tricks

### Auto-install on directory change

Add to `.mise.toml`:
```toml
[settings]
experimental = true
yes = true  # Auto-install without prompting
```

### Use with direnv

Mise works great with direnv:
```bash
# .envrc
use mise
```

### Check what will be installed

```bash
# Dry run
mise install --dry-run
```

### Install from lockfile

```bash
# Use mise.lock for reproducible builds
mise install --frozen
```

### Set environment variables per project

In `.mise.toml`:
```toml
[env]
NODE_ENV = "development"
DATABASE_URL = "postgres://localhost/mydb"
```

## Configuration in Dotfiles

The dotfiles include:

1. **Global config**: `home/.mise.toml`
   - Sets Node.js LTS as default
   - Enables legacy version file support

2. **Shell integration**: 
   - Zsh: `home/.config/zsh/.zshrc`
   - PowerShell: `home/.config/powershell/profile.ps1`

3. **Package installation**:
   - WSL: `packages/bundle` (Homebrew)
   - Windows: `packages/scoopfile.json` (Scoop)

## Resources

- **Official Site**: https://mise.jdx.dev/
- **GitHub**: https://github.com/jdx/mise
- **Documentation**: https://mise.jdx.dev/getting-started.html
- **Registry**: https://mise.jdx.dev/registry.html
- **CLI Reference**: https://mise.jdx.dev/cli/

## Comparison with Alternatives

| Feature | mise | nvm | asdf | fnm |
|---------|------|-----|------|-----|
| Speed | ⚡⚡⚡ Very Fast | 🐌 Slow | 🐌 Slow | ⚡⚡ Fast |
| Languages | All | Node only | All | Node only |
| Legacy files | ✅ | ✅ | ✅ | ✅ |
| Cross-platform | ✅ | ✅ | ⚠️ Limited | ✅ |
| Written in | Rust | Bash | Bash | Rust |
| Active development | ✅ | ✅ | ✅ | ✅ |

**Why mise?**
- Single tool for all runtimes (no need for nvm + rbenv + pyenv + ...)
- Much faster than bash-based alternatives
- Better Windows support than asdf
- More features than fnm
- Active development and growing community
