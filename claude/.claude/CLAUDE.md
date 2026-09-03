# Git

NIKDY nepoužívaj git (status, diff, add, commit, push, log, checkout, reset, atď.), pokiaľ na to nie som explicitne vyzvaný v aktuálnej požiadavke. Git je moje source of truth — o jeho použití rozhodujem ja, nie ty automaticky.

Výnimka: príkaz `/commit` môže v rámci svojho postupu čítať `git diff`/`git status` na vygenerovanie commit správy.

# Notifikácie (zvuk + desktop)

V `settings.json` sú nakonfigurované dva odlišné notifikačné hooky, aby som vedel na prvý pohľad/počutie rozlíšiť, či Claude iba dokončil prácu, alebo potrebuje moju pozornosť:

- **Stop** (Claude dokončil úlohu): titulok „Claude Code — dokončené — $dir", urgency `normal`, zvuk `window-attention.oga` na 100 % hlasitosti (`paplay --volume=65536`).
- **Notification** (Claude čaká na vstup — permission prompt, idle čakanie, otázka cez AskUserQuestion a pod.): titulok „Claude Code — čaká na vstup — $dir", urgency `normal`, zvuk `complete.oga` na 60 % hlasitosti (`paplay --volume=39321`).

Rozlíšenie oboch hookov teda nesie titulok, ikona (`dialog-information` vs `dialog-question`) a zvuk — nie urgency.

## Prečo `normal` a nie `critical` (Omarchy 4)

Notifikačný démon Omarchy shellu (Quickshell) má v `durationFor()` natvrdo:

```qml
case NotificationUrgency.Critical:
  return 0    // 0 = nikdy sa samo nezavrie
```

Pri `urgency=critical` sa `-t 20000` ignoruje a notifikácia visí na obrazovke, kým ju ručne nezavriem. Preto je Notification hook na `normal` — vtedy démon `-t` rešpektuje (clampuje do 8–30 s).

Opakované notifikácie sa nestohujú: hook si ukladá ID, ktoré vráti `notify-send -p`, do `$XDG_RUNTIME_DIR/claude-code-waiting-notif-id` a pri ďalšom volaní ho pošle späť cez `-r`, takže nová notifikácia nahradí predošlú. Natvrdo zadané `-r <číslo>` nefunguje — démon si prideľuje vlastné ID, takže treba použiť to vrátené.

**Dôsledok:** pri zapnutom Do Not Disturb (`SUPER CTRL + ,`) sa tieto notifikácie potlačia. Omarchy cez DND prepúšťa len `urgency=critical` + `app_name=notify-send`.

Hlasitosť je lineárna škála `paplay --volume` 0–65536 (65536 = 100 %). Fallback na `canberra-gtk-play`, ak `paplay` zlyhá. Zoznam dostupných zvukov: `/usr/share/sounds/freedesktop/stereo/*.oga` (dá sa vyskúšať cez `paplay --volume=<0-65536> <súbor>`).

Ak chcem zmeniť zvuk/hlasitosť/text, upravujem priamo `command` v `hooks.Stop` / `hooks.Notification` v `claude/.claude/settings.json` v dotfiles repe.
