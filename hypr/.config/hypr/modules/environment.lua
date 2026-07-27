hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")
-- XWayland apps render at physical pixels; GTK needs an integer UI scale.
hl.env("GDK_SCALE", "2")
