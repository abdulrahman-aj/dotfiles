hl.config({
  input = {
    kb_layout = "us",
    kb_options = "compose:caps",
    touchpad = {
      natural_scroll = true,
    },
  },
})
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
