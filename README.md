# 🏠 Marek's Dotfiles

> *"After managing to delete my configs a few times, I decided to solve it like a proper programmer." — Marek*

## 🌟 What is this?

Welcome to my dotfiles repository! I'm a programmer, I love **Linux**, and I run **Arch Linux** — specifically the [Omarchy](https://omarchy.com/) distribution. 🐧

This repository holds all my configuration files (dotfiles), which let me set up my working environment quickly and easily on any Linux system. Thanks to [GNU Stow](https://www.gnu.org/software/stow/), managing dotfiles is remarkably simple and safe.

## 🎯 Why does this repository exist?

Because I'm clumsy and have **managed to delete my dotfiles several times** (not a pleasant experience 😱), I decided to use Git and GNU Stow to manage them. Now I have:

- ✅ **A backup** of every config in the cloud
- ✅ **Version history** — I can go back to older versions
- ✅ **Easy installation** on new systems
- ✅ **Safe management** — no more accidental deletions!

## 📦 What's included?

This repository contains configurations for:

- 🖥️ **alacritty** - terminal emulator config
- 🐚 **bashrc** - Bash shell config
- 🤖 **claude** - Claude Code (`~/.claude/settings.json` - hooks, model, permissions; `~/.claude/CLAUDE.md` - global instructions)
- 🐑 **herdr** - the [herdr](https://herdr.dev) multiplexer for AI agents (shortcuts mirror tmux)
- 🪟 **hypr** - [Hyprland](https://hyprland.org/) compositor (Wayland)
- 💡 **ideavim** - Vim bindings for JetBrains IDEs
- 🔧 **jetbrains** - JetBrains IDE configuration
- ✏️ **nvim** - [Neovim](https://neovim.io/) configuration
- 🖥️ **tmux** - terminal multiplexer
- 🎨 **omarchy** - Omarchy shell: `shell.json` (bar layout), `shell.toml` (font size)
  and my own plugin clones in `plugins/`
- 🦶 **foot** - the foot terminal (default since Omarchy 4), including `Ctrl+Backspace` = delete word
- 🧰 **bin** - my own scripts in `~/.local/bin`
- ⌨️ **xkb** - keyboard layout
- 🖱️ mx-master - my Logitech MX Master 4 mouse (`sudo stow -t / mx-master`) - `logid.cfg`,
  a udev rule that restarts logid on Bluetooth connect, and a systemd override for `logid.service`
- 🖱️ **mx-scroll** - toggle for hi-res ("smooth") scrolling on the MX Master 4, keybind `MEH + P`.
  XWayland turns every hi-res scroll event into its own button 4/5 click, so in CS2 a single
  wheel detent counts as several scrolls. Installed by copying, **not by stow** - see below

## 🚀 Omarchy 4 "Quattro" — what changed

The upgrade from Omarchy 3.8.4 to 4.0.2 replaced the whole shell with Quickshell. **Waybar, Walker,
Mako, SwayOSD, hyprlock, hypridle, swaybg and polkit-gnome are gone**, and Hyprland is configured in
Lua. The migration left the old `.conf` files on disk but generated empty `.lua` templates — so
everything below had to be ported by hand.

### Hyprland: `.conf` → `.lua`

| File | What it holds |
|---|---|
| `hypr/.config/hypr/monitors.lua` | 3 monitors with explicit positions (eDP-1 \| HDMI-A-1 \| DP-2) |
| `hypr/.config/hypr/bindings.lua` | vim navigation (h/j/k/l + arrow keys), launchers, swap `SUPER+SPACE` ↔ `SUPER+ALT+SPACE` |
| `hypr/.config/hypr/input.lua` | `accel_profile = flat`, `repeat_delay = 600` |
| `hypr/.config/hypr/hyprland.lua` | cursor size (`XCURSOR_SIZE` + `HYPRCURSOR_SIZE`) |

> ⚠️ **The monitor positions are explicit on purpose.** The Display panel (`SUPER+CTRL+D`) sends
> `position = "auto"` when the scale changes, which makes Hyprland reshuffle the monitor order. That
> is why the `bin` package ships the `omarchy-monitor-scale-keep-layout` script, which changes the
> scale, preserves the order, and writes the result into `monitors.lua`. The `marek.monitor` plugin
> clone calls it instead of the system's `omarchy-hyprland-monitor-scaling`. If the layout falls
> apart anyway: `hyprctl reload`.

### Cursor size — mind which sizes exist

Adwaita only ships bitmaps for **24, 30, 36, 48, 72, 96**. Any other value is rounded to the nearest
one (28 → 24, 32 → 36), so it looks as if nothing changed. Currently set to **36** in three places —
two in `hyprland.lua` and one in gsettings, which is **not a file** and so is not covered by stow:

```bash
gsettings set org.gnome.desktop.interface cursor-size 36
```

To apply it without logging out (apps started through uwsm read the systemd user environment, not Hyprland):

```bash
hyprctl setcursor default 36
systemctl --user set-environment XCURSOR_SIZE=36 HYPRCURSOR_SIZE=36
```

### Shell plugin clones

Custom shell changes never belong in `/usr/share/omarchy/` — an update overwrites them. Use
`omarchy plugin clone <id>` instead, which creates a copy in `~/.config/omarchy/plugins/`:

- **`marek.monitor`** (clone of `omarchy.monitor`) — changing the scale no longer reshuffles the
  monitor order; enabling/disabling a display uses `hyprctl eval` instead of `hyprctl keyword`,
  which Hyprland rejects under the Lua parser (upstream is a no-op there).
- **`marek.agents`** (clone of `omarchy.agents`) — shows the Claude logo in the bar instead of the
  robot icon, and both percentages side by side: `4% / 48%` = session (5h) / weekly limit. Upstream
  goes through `bindingWindow()` and shows only the fuller window, so a low session percentage hid
  behind the higher weekly one. A missing window keeps its slot as `–%` — Claude stops reporting the
  session limit whenever the saved sign-in expires (`claude auth login` fixes it). Details and reset
  times are in the tooltip.

> After editing a `.qml` file in a clone you need `omarchy restart shell` — hot-reload on its own
> leaves the old instance of the component in the bar.

### What is not in the stow packages

- **gsettings** (`cursor-size`) — dconf, not a file; see the command above.
- **`/etc` files from `mx-master`** — these need `sudo stow -t / mx-master`. If real files are
  already there, stow reports a conflict; delete them first (`sudo rm`), then stow.
- **`logid`** — the binary is a manual build in `/usr/local/bin/logid`, not a pacman package.
- **`mx-scroll`** — installed by copying (`sudo bash mx-scroll/install.sh`), not by stow.
  `sudo` ignores anything in `/etc/sudoers.d` that is not a regular root-owned file, so a symlink
  would silently kill the NOPASSWD rule; and `mx-scroll-mode` runs as root through that rule, so a
  symlink into this (user-writable) repo would turn it into a path to root.
- **`~/.config/omarchy/bar/scripts/`, `extensions/omarchy-menu.jsonc`, `hooks/`** — left untracked;
  they are older custom changes unrelated to this upgrade.

## 🖥️ Tmux shortcuts (ZSA Voyager)

Since the ZSA Voyager has no reliably reachable physical Alt key, window and pane management in tmux runs through no-prefix (`bind -n`) shortcuts mapped onto the Voyager's key layers instead of the classic tmux prefix (`Alt+s`):

| Layer + key | Sends | tmux action |
|---|---|---|
| Layer 3 (Hold Spc) + **H** | `Ctrl+Shift+Tab` | Previous window |
| Layer 3 (Hold Spc) + **L** | `Ctrl+Tab` | Next window |
| Layer 3 (Hold Spc) + **T** | `Ctrl+Alt+T` | New window |
| Layer 3 (Hold Spc) + **S** | `Ctrl+Alt+S` | Split side by side `│` |
| Layer 3 (Hold Spc) + **V** | `Ctrl+Alt+V` | Split stacked `─` |
| Layer 3 (Hold Spc) + **C** | `Ctrl+Alt+C` | Close pane |
| Layer 3 (Hold Spc) + **X** | `Ctrl+Alt+X` | Close window |
| Layer 3 (Hold Spc) + **R** | `Ctrl+Alt+R` | Rename the current window (empty prompt, no need to clear the old name) |
| Layer 2 (Control) + **/** | `Ctrl+Shift+F12` | Zoom pane (fullscreen toggle, same shortcut as in JetBrains) |

The matching bindings live in `tmux/.tmux.conf`.

### Saving and restoring the session layout (tmux-resurrect + tmux-continuum)

- **Save manually:** `Prefix + Ctrl+s`
- **Restore manually:** `Prefix + Ctrl+r`
- **Automatically:** `@continuum-restore` is enabled, so the last saved layout is restored by itself every time the tmux server starts (after a reboot, for example). Continuum also saves state in the background as you go, so there is nothing to remember.

On a new machine (after `stow tmux`) press `Prefix + I` (capital i) once inside tmux so that TPM downloads these plugins.

## 🐑 herdr (multiplexer for AI agents)

[herdr](https://herdr.dev) is an alternative to tmux that shows each AI agent's state in a side panel (`working` / `blocked` / `done` / `idle`). Installed on a trial basis alongside tmux - tmux stays untouched and I can switch back at any time.

**Installing the binary** (not part of the stow package):

```bash
curl -fsSL https://herdr.dev/install.sh | sh   # -> ~/.local/bin/herdr
# or from the AUR: yay -S herdr-bin
```

**Stow - CAREFUL, you need `--no-folding`:**

```bash
stow --no-folding herdr
```

Without `--no-folding`, stow links the whole `~/.config/herdr` directory into the repo and herdr then writes its logs there (`herdr.log`, `herdr-server.log`, `plugins.json`). With `--no-folding` only `config.toml` is symlinked and the runtime files stay out of git. The same applies to a bulk `stow */`.

**The Voyager shortcuts are the same as in tmux** - `config.toml` mirrors the live tmux bindings:

| Layer + key | Sends | herdr action |
|---|---|---|
| Layer 3 (Hold Spc) + **H** | `Ctrl+Shift+Tab` | Previous tab |
| Layer 3 (Hold Spc) + **L** | `Ctrl+Tab` | Next tab |
| Layer 3 (Hold Spc) + **T** | `Ctrl+Alt+T` | New tab |
| Layer 3 (Hold Spc) + **S** | `Ctrl+Alt+S` | Split side by side `│` (`split_vertical`) |
| Layer 3 (Hold Spc) + **V** | `Ctrl+Alt+V` | Split stacked `─` (`split_horizontal`) |
| Layer 3 (Hold Spc) + **C** | `Ctrl+Alt+C` | Close pane |
| Layer 3 (Hold Spc) + **X** | `Ctrl+Alt+X` | Close tab |
| Layer 3 (Hold Spc) + **R** | `Ctrl+Alt+R` | Rename tab |
| Layer 2 (Control) + **/** | `Ctrl+Shift+F12` | Zoom pane |

The prefix is `Ctrl+Space` (same as in tmux; herdr has no secondary prefix, so `Ctrl+b` is out).

**Useful commands:**

```bash
herdr config check          # validate config.toml (also reports unknown keys)
herdr server reload-config  # reload without a restart (or Prefix+q)
herdr config reset-keys     # back up the config and drop custom shortcuts
```

On an error in `config.toml` herdr **silently falls back to the default shortcuts** - so run `herdr config check` after every edit.

## 🚀 Installation

### Prerequisites

First install GNU Stow:

```bash
# Arch Linux
sudo pacman -S stow

# Ubuntu/Debian
sudo apt install stow

# Fedora
sudo dnf install stow
```

### Cloning the repository

```bash
cd ~
git clone https://github.com/Maclogger/marekove-dotfiles.git
cd marekove-dotfiles
```

### Using Stow

GNU Stow creates symlinks from this repository into your home directory. It's safe and simple!

**Install every config:**

```bash
stow */
```

**Install one specific config:**

```bash
# For example, just nvim
stow nvim

# Or just bashrc and tmux
stow bashrc tmux
```

**Uninstall a config:**

```bash
# Removes the symlinks
stow -D nvim
```

## 🎓 How does Stow work?

GNU Stow is dead simple! When you run `stow nvim`, it creates symlinks:

```
~/marekove-dotfiles/nvim/.config/nvim  →  ~/.config/nvim
```

Which means:
- 📝 You can edit the files directly in the repository
- 🔄 Changes take effect immediately
- 💾 You can commit them to Git easily
- 🎯 No manual file copying

## 🛡️ Safety tips

1. **Always make a backup before the first run:**
   ```bash
   mkdir ~/dotfiles-backup
   cp -r ~/.config ~/dotfiles-backup/
   cp ~/.bashrc ~/dotfiles-backup/
   ```

2. **Check for conflicts** - if you already have dotfiles, Stow warns you and does not create the links

3. **Test on a single config first:**
   ```bash
   stow bashrc  # Start with something simple
   ```

## 🔄 Updating the configs

```bash
cd ~/marekove-dotfiles
git pull  # Fetch the latest changes
```

Thanks to the symlinks, changes are live immediately! ⚡

## 📝 Adding your own configs

```bash
cd ~/marekove-dotfiles

# Create a new directory for the config
mkdir my-app

# Move the config file there
mv ~/.config/my-app ./my-app/.config/

# Use Stow
stow my-app

# Add it to Git
git add my-app
git commit -m "feat: add my-app config"
git push
```

## 🤝 Why share dotfiles?

Even though these are my personal configs, you're welcome to take inspiration from them! The dotfiles community is wonderful and we all learn from each other. Feel free to look through the configs and use whatever you like. 🎨

## 📚 Useful links

- [GNU Stow documentation](https://www.gnu.org/software/stow/manual/)
- [Arch Linux Wiki - Dotfiles](https://wiki.archlinux.org/title/Dotfiles)
- [r/unixporn](https://www.reddit.com/r/unixporn/) - config inspiration
- [Omarchy Linux](https://omarchy.com/)

## 📄 License

This is my personal repository, but feel free to use anything you find useful! 🎉

## 💡 Notes

> **"The best backup is the one you actually use."** - Unknown programmer

This repository has saved my day more than once. I can only recommend that every programmer builds a similar system. You never know when your disk will die or you'll delete something important by mistake! 🚨

---

Made with ❤️ and too many cups of ☕ by Marek

*P.S.: If you're only here because you accidentally deleted your dotfiles, know that you're not alone. It has happened to the best of us. 😅*
