# 🏠 Marekove Dotfiles

> *"Keď sa mi párkrát podarilo zmazať svoje konfigurácie, rozhodol som sa to vyriešiť ako správny programátor." - Marek*

## 🌟 O čom to je?

Vitaj v mojom repozitári s dotfiles! Som programátor, milujem **Linux** a používam **Arch Linux** (konkrétne distribúciu [Omarchy](https://omarchy.com/)). 🐧

Tento repozitár obsahuje všetky moje konfiguračné súbory (dotfiles), ktoré mi umožňujú rýchlo a jednoducho nastaviť moje pracovné prostredie na akom koľvek Linuxovom systéme. Vďaka utility [GNU Stow](https://www.gnu.org/software/stow/) je správa dotfiles neuveriteľne jednoduchá a bezpečná.

## 🎯 Prečo tento repozitár existuje?

Keďže som nešikovný a už sa mi **párkrát podarilo zmazať svoje dotfiles** (čo nebolo vôbec príjemné 😱), rozhodol som sa použiť Git a GNU Stow na ich správu. Teraz mám:

- ✅ **Zálohu** všetkých konfigurácií v cloude
- ✅ **Verzionovanie** - môžem sa vrátiť k starším verziám
- ✅ **Jednoduchú inštaláciu** na nových systémoch
- ✅ **Bezpečnú správu** - už žiadne náhodné zmazania!

## 📦 Čo je tu obsiahnuté?

Tento repozitár obsahuje konfigurácie pre:

- 🖥️ **alacritty** - konfigurácia terminálového emulátora
- 🐚 **bashrc** - konfigurácia Bash shellu
- 🪟 **hypr** - [Hyprland](https://hyprland.org/) compositor (Wayland)
- 💡 **ideavim** - Vim bindings pre JetBrains IDE
- 🔧 **jetbrains** - konfigurácie pre JetBrains IDE
- ✏️ **nvim** - [Neovim](https://neovim.io/) konfigurácia
- 🖥️ **tmux** - terminálový multiplexer
- 📊 **waybar** - status bar pre Wayland
- ⌨️ **xkb** - rozloženie klávesnice
- 🖱️ mx-master - moja myška Logitech MxMaster 3s (sudo stow -t / mx-master)

## 🖥️ Tmux skratky (ZSA Voyager)

Keďže ZSA Voyager nemá spoľahlivo dostupný fyzický Alt, správa okien a panelov v tmuxe beží cez no-prefix (`bind -n`) skratky namapované na klávesových vrstvách Voyageru namiesto klasického tmux prefixu (`Alt+s`):

| Vrstva + klávesa | Posiela | tmux akcia |
|---|---|---|
| Vrstva 3 (Hold Spc) + **H** | `Ctrl+Shift+Tab` | Predchádzajúce okno |
| Vrstva 3 (Hold Spc) + **L** | `Ctrl+Tab` | Ďalšie okno |
| Vrstva 3 (Hold Spc) + **T** | `Ctrl+Alt+T` | Nové okno |
| Vrstva 3 (Hold Spc) + **S** | `Ctrl+Alt+S` | Split vedľa seba `│` |
| Vrstva 3 (Hold Spc) + **V** | `Ctrl+Alt+V` | Split pod seba `─` |
| Vrstva 3 (Hold Spc) + **C** | `Ctrl+Alt+C` | Zavrieť panel |
| Vrstva 3 (Hold Spc) + **X** | `Ctrl+Alt+X` | Zavrieť okno |
| Vrstva 2 (Control) + **/** | `Ctrl+Shift+F12` | Zoom panelu (fullscreen toggle, rovnaká skratka ako v JetBrains) |

Zodpovedajúce väzby sú v `tmux/.tmux.conf`.

## 🚀 Inštalácia

### Predpoklady

Najprv si nainštaluj GNU Stow:

```bash
# Arch Linux
sudo pacman -S stow

# Ubuntu/Debian
sudo apt install stow

# Fedora
sudo dnf install stow
```

### Klonovanie repozitára

```bash
cd ~
git clone https://github.com/Maclogger/marekove-dotfiles.git
cd marekove-dotfiles
```

### Použitie Stow

GNU Stow vytvorí symbolické linky z tohto repozitára do tvojho domovského adresára. Je to bezpečné a jednoduché!

**Nainštalovať všetky konfigurácie:**

```bash
stow */
```

**Nainštalovať konkrétnu konfiguráciu:**

```bash
# Napríklad len nvim
stow nvim

# Alebo len bashrc a tmux
stow bashrc tmux
```

**Odinštalovať konfiguráciu:**

```bash
# Odstráni symbolické linky
stow -D nvim
```

## 🎓 Ako Stow funguje?

GNU Stow je super jednoduchý! Keď spustíš `stow nvim`, vytvorí symbolické linky:

```
~/marekove-dotfiles/nvim/.config/nvim  →  ~/.config/nvim
```

Vďaka tomu:
- 📝 Editovať môžeš súbory priamo v repozitári
- 🔄 Zmeny sú hneď aktívne
- 💾 Môžeš ich jednoducho commitnúť do Gitu
- 🎯 Žiadne manuálne kopírovanie súborov

## 🛡️ Bezpečnostné tipy

1. **Vždy si urob backup pred prvým použitím:**
   ```bash
   mkdir ~/dotfiles-backup
   cp -r ~/.config ~/dotfiles-backup/
   cp ~/.bashrc ~/dotfiles-backup/
   ```

2. **Skontroluj konflikty** - ak už máš existujúce dotfiles, Stow ťa upozorní a nevytvorí linky

3. **Testuj najprv na jednej konfigurácii:**
   ```bash
   stow bashrc  # Začni niečím jednoduchým
   ```

## 🔄 Aktualizácia konfigurácií

```bash
cd ~/marekove-dotfiles
git pull  # Stiahni najnovšie zmeny
```

Vďaka symbolickým linkom sú zmeny aktívne okamžite! ⚡

## 📝 Pridávanie vlastných konfigurácií

```bash
cd ~/marekove-dotfiles

# Vytvor nový adresár pre konfiguráciu
mkdir moja-app

# Presuň konfiguračný súbor tam
mv ~/.config/moja-app ./moja-app/.config/

# Použi Stow
stow moja-app

# Pridaj do Gitu
git add moja-app
git commit -m "feat: add moja-app config"
git push
```

## 🤝 Prečo zdieľať dotfiles?

Aj keď sú to moje osobné konfigurácie, môžeš sa z nich inšpirovať! Dotfiles komunita je úžasná a všetci sa učíme jeden od druhého. Neváhaj si pozrieť konfigurácie a použiť čo sa ti páči. 🎨

## 📚 Užitočné odkazy

- [GNU Stow dokumentácia](https://www.gnu.org/software/stow/manual/)
- [Arch Linux Wiki - Dotfiles](https://wiki.archlinux.org/title/Dotfiles)
- [r/unixporn](https://www.reddit.com/r/unixporn/) - inšpirácia pre konfigurácie
- [Omarchy Linux](https://omarchy.com/)

## 📄 Licencia

Toto je môj osobný repozitár, ale feel free to use anything you find useful! 🎉

## 💡 Poznámky

> **"The best backup is the one you actually use."** - Neznámy programátor

Tento repozitár mi už viackrát zachránil deň. Môžem len odporučiť každému programátorovi, aby si spravil podobný systém. Nikdy nevieš, kedy ti zhavaruje disk alebo omylom zmažeš niečo dôležité! 🚨

---

Made with ❤️ and too many cups of ☕ by Marek

*P.S.: Ak si tu len pretože si omylom zmazal svoje dotfiles, vedz že nie si sám. Stalo sa to aj najlepším z nás. 😅*
