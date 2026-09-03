-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- Layout, left to right (logical sizes after scaling):
--
--   eDP-1 (laptop)          1600x1000   x =    0
--   HDMI-A-1 (Samsung C34)  2752x1152   x = 1600
--   DP-2 (AOC Q27G2WG4)     2048x1152   x = 4352   (1600 + 2752)
--
-- Positions are explicit on purpose. The display panel applies scale changes
-- with position = "auto", which re-derives the order from monitor IDs and
-- puts DP-2 in the middle. After using that panel, run: hyprctl reload

-- Laptop panel, leftmost
hl.monitor({ output = "eDP-1", mode = "2560x1600@165.019", position = "0x83", scale = 1.25 })

-- Samsung ultrawide, centre
hl.monitor({ output = "HDMI-A-1", mode = "3440x1440@99.982", position = "2048x0", scale = 1 })

-- AOC 1440p, rightmost
hl.monitor({ output = "DP-2", mode = "2560x1440@143.912", position = "5488x0", scale = 1 })

-- Alternatives kept from the old config:
-- Mirror DP-2 onto the ultrawide:
-- hl.monitor({ output = "DP-2", mode = "2560x1440@143.91", position = "4352x0", scale = 1.25, mirror = "HDMI-A-1" })
-- DP-2 rotated 90 degrees (transform: 1 = 90 deg, 3 = 270 deg):
-- hl.monitor({ output = "DP-2", mode = "2560x1440@143.91", position = "4352x-320", scale = 1.25, transform = 3 })
