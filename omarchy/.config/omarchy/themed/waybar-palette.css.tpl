/*
 * Waybar farebná paleta odvodená z aktuálnej Omarchy témy.
 *
 * Toto je TEMPLATE. Omarchy ho pri každom `omarchy theme set` prerenderuje
 * (omarchy-theme-set-templates) a výsledok zapíše do
 *   ~/.config/omarchy/current/theme/waybar-palette.css
 * kde si ho ťahá ~/.config/waybar/style.css cez @import.
 *
 * Placeholdery {{ key }} sa plnia z colors.toml danej témy. Zámerne sa menuje
 * inak ako waybar.css, ktorý si niektoré témy (catppuccin, lumon, retro-82)
 * dodávajú vlastný a ten by tento template prebil.
 *
 * Zdroj: marekove-dotfiles/omarchy/.config/omarchy/themed/
 */

/* Základ */
@define-color foreground {{ foreground }};
@define-color background {{ background }};
@define-color accent {{ accent }};
@define-color cursor {{ cursor }};
@define-color selection_foreground {{ selection_foreground }};
@define-color selection_background {{ selection_background }};

/* ANSI 0-7 (normal) */
@define-color color0 {{ color0 }};
@define-color color1 {{ color1 }};
@define-color color2 {{ color2 }};
@define-color color3 {{ color3 }};
@define-color color4 {{ color4 }};
@define-color color5 {{ color5 }};
@define-color color6 {{ color6 }};
@define-color color7 {{ color7 }};

/* ANSI 8-15 (bright) */
@define-color color8 {{ color8 }};
@define-color color9 {{ color9 }};
@define-color color10 {{ color10 }};
@define-color color11 {{ color11 }};
@define-color color12 {{ color12 }};
@define-color color13 {{ color13 }};
@define-color color14 {{ color14 }};
@define-color color15 {{ color15 }};
