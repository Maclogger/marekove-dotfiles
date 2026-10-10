-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- JetBrains Toolbox moves itself off-screen every time it is shown; this
-- re-centers it (a window rule can't, Toolbox moves after mapping).
o.launch_on_start("hypr-toolbox-recenter")
