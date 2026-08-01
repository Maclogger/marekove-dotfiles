# Git

NIKDY nepoužívaj git (status, diff, add, commit, push, log, checkout, reset, atď.), pokiaľ na to nie som explicitne vyzvaný v aktuálnej požiadavke. Git je moje source of truth — o jeho použití rozhodujem ja, nie ty automaticky.

Výnimka: príkaz `/commit` môže v rámci svojho postupu čítať `git diff`/`git status` na vygenerovanie commit správy.

# Notifikácie (zvuk + desktop)

V `settings.json` sú nakonfigurované dva odlišné notifikačné hooky, aby som vedel na prvý pohľad/počutie rozlíšiť, či Claude iba dokončil prácu, alebo potrebuje moju pozornosť:

- **Stop** (Claude dokončil úlohu): titulok „Claude Code — dokončené — $dir", urgency `normal`, zvuk `window-attention.oga` na 100 % hlasitosti (`paplay --volume=65536`).
- **Notification** (Claude čaká na vstup — permission prompt, idle čakanie, otázka cez AskUserQuestion a pod.): titulok „Claude Code — čaká na vstup — $dir", urgency `critical`, zvuk `complete.oga` na 60 % hlasitosti (`paplay --volume=39321`).

Hlasitosť je lineárna škála `paplay --volume` 0–65536 (65536 = 100 %). Fallback na `canberra-gtk-play`, ak `paplay` zlyhá. Zoznam dostupných zvukov: `/usr/share/sounds/freedesktop/stereo/*.oga` (dá sa vyskúšať cez `paplay --volume=<0-65536> <súbor>`).

Ak chcem zmeniť zvuk/hlasitosť/text, upravujem priamo `command` v `hooks.Stop` / `hooks.Notification` v `claude/.claude/settings.json` v dotfiles repe.
