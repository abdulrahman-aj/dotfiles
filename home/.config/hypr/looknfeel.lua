hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 1,
    no_focus_fallback = true,
  },

  decoration = {
    rounding = 8,
    dim_inactive = true,
    dim_strength = 0.20,
  },
})

o.window(".*", { opacity = "1 1" })
