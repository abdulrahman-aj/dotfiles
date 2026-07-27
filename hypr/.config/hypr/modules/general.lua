hl.config({
    general = {
        resize_on_border = false,
        allow_tearing = false,
        no_focus_fallback = true,
        layout = "dwindle",
    },
    -- Keep XWayland clients crisp on fractional display scales.
    xwayland = {
        force_zero_scaling = true,
    },
    dwindle = {
        force_split = 2,
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        fullscreen_on_one_column = true,
    },
    misc = {
        focus_on_activate = true,
    },
})
