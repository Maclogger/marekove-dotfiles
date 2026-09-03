-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print
--
-- Ported from the pre-Quattro bindings.conf. Where a binding matches an
-- Omarchy 4 default exactly it is left out rather than restated:
--   SUPER + RETURN        Terminal   -- now an Omarchy default
--   SUPER + ALT + RETURN  Tmux       -- now an Omarchy default
--   SUPER + LEFT/RIGHT    Focus left/right -- Omarchy's default is the same
--                                            dispatcher this config used

--------------------------------------------------------------------------
-- Navigation
--
-- Vim-style movement, with the arrow keys mirroring it. Note that j/k and
-- up/down switch *workspaces* here rather than moving focus between windows,
-- which is why several Omarchy defaults have to go.
--------------------------------------------------------------------------

-- Omarchy defaults replaced below.
hl.unbind("SUPER + J")           -- was: Toggle window split (see CTRL+ALT+O)
hl.unbind("SUPER + K")           -- was: Keybindings cheatsheet
hl.unbind("SUPER + L")           -- was: Toggle workspace layout
hl.unbind("SUPER + UP")          -- was: Focus on above window
hl.unbind("SUPER + DOWN")        -- was: Focus on below window
hl.unbind("SUPER + CTRL + LEFT")  -- was: Move grouped window focus left
hl.unbind("SUPER + CTRL + RIGHT") -- was: Move grouped window focus right

-- Move focus left / right
o.bind("SUPER + H", "Focus left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus right window", hl.dsp.focus({ direction = "r" }))

-- Switch to the next / previous workspace
o.bind("SUPER + J", "Next workspace", hl.dsp.focus({ workspace = "r+1" }))
o.bind("SUPER + K", "Previous workspace", hl.dsp.focus({ workspace = "r-1" }))
o.bind("SUPER + DOWN", "Next workspace", hl.dsp.focus({ workspace = "r+1" }))
o.bind("SUPER + UP", "Previous workspace", hl.dsp.focus({ workspace = "r-1" }))

-- Take the window with you to the next / previous workspace
o.bind("SUPER + SHIFT + J", "Move window to next workspace", hl.dsp.window.move({ workspace = "r+1" }))
o.bind("SUPER + SHIFT + K", "Move window to previous workspace", hl.dsp.window.move({ workspace = "r-1" }))
o.bind("SUPER + CTRL + DOWN", "Move window to next workspace", hl.dsp.window.move({ workspace = "r+1" }))
o.bind("SUPER + CTRL + UP", "Move window to previous workspace", hl.dsp.window.move({ workspace = "r-1" }))

-- Move the window left / right, crossing to the next monitor at the edge
o.bind("SUPER + SHIFT + H", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.move({ direction = "r" }))
o.bind("SUPER + CTRL + LEFT", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + CTRL + RIGHT", "Move window right", hl.dsp.window.move({ direction = "r" }))

--------------------------------------------------------------------------
-- Applications
--------------------------------------------------------------------------

-- launch wraps the command with uwsm-app, matching the old `uwsm app --`.
-- google-chrome-stable is on PATH, so the old hardcoded /opt path is dropped.
o.bind("SUPER + E", "Chrome", { launch = "google-chrome-stable" })
o.bind("SUPER + M", "Spotify", { launch = "spotify" })

--------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------

-- ncaron is 'ň' on the Slovak layout. Omarchy's own SUPER+CTRL+L still works.
o.bind("CTRL + ALT + ncaron", "Lock session", "loginctl lock-session")

-- Replaces the SUPER+J default given up above.
o.bind("CTRL + ALT + O", "Toggle window split", hl.dsp.layout("togglesplit"))

--------------------------------------------------------------------------
-- Menus
--
-- Swapped from the Omarchy defaults: SUPER+SPACE opens the app launcher,
-- SUPER+ALT+SPACE opens the Omarchy (setup) menu.
--------------------------------------------------------------------------

hl.unbind("SUPER + SPACE")        -- was: Omarchy menu
hl.unbind("SUPER + ALT + SPACE")  -- was: Apps menu

o.bind("SUPER + SPACE", "Apps menu", "omarchy-menu toggle apps")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")

--------------------------------------------------------------------------
-- Appearance (MEH = CTRL + ALT + SHIFT)
--
-- The ZSA layout is built around MEH, and no application uses these
-- combos, so they never collide. Omarchy's own SPACE-based defaults
-- (SUPER+SHIFT+SPACE, SUPER+CTRL+SPACE, SUPER+SHIFT+CTRL+SPACE) are left
-- in place alongside these.
--------------------------------------------------------------------------

o.bind_toggle("CTRL + ALT + SHIFT + F", "Toggle top bar", "bar")
o.bind("CTRL + ALT + SHIFT + Y", "Theme menu", "omarchy-menu toggle theme")
o.bind("CTRL + ALT + SHIFT + U", "Background switcher", "omarchy-menu toggle background")
