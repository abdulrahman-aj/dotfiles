local function rebind(keys, description, dispatcher, options)
  hl.unbind(keys)
  o.bind(keys, description, dispatcher, options)
end

rebind("SUPER + SHIFT + Z", "Zed", { launch = "zeditor" })
rebind("SUPER + SHIFT + T", "T3 Code", { launch = "t3code", focus = "t3code" })

-- Scratchpad — SHIFT for moves.
hl.unbind("SUPER + ALT + S")
rebind("SUPER + SHIFT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Keybindings on SUPER+? (SHIFT+SLASH), vim-style dwindle navigation/swap.
-- Unbind monitor-scaling (SUPER+SLASH / ALT+SLASH) and Passwords (SHIFT+SLASH) to free ?.
hl.unbind("SUPER + SLASH")
hl.unbind("SUPER + ALT + SLASH")
hl.unbind("SUPER + SHIFT + SLASH")
hl.unbind("SUPER + K")
rebind("SUPER + SHIFT + SLASH", "Keybindings", "omarchy-menu-keybindings")

local focus_binds = {
  { keys = "SUPER + H", name = "Focus left window", dir = "l" },
  { keys = "SUPER + J", name = "Focus window below", dir = "d" },
  { keys = "SUPER + K", name = "Focus window above", dir = "u" },
  { keys = "SUPER + L", name = "Focus right window", dir = "r" },
}
local swap_binds = {
  { keys = "SUPER + SHIFT + H", name = "Swap window left", dir = "l" },
  { keys = "SUPER + SHIFT + J", name = "Swap window down", dir = "d" },
  { keys = "SUPER + SHIFT + K", name = "Swap window up", dir = "u" },
  { keys = "SUPER + SHIFT + L", name = "Swap window right", dir = "r" },
}
for _, b in ipairs(focus_binds) do
  rebind(b.keys, b.name, hl.dsp.focus({ direction = b.dir }))
end
for _, b in ipairs(swap_binds) do
  rebind(b.keys, b.name, hl.dsp.window.swap({ direction = b.dir }))
end
