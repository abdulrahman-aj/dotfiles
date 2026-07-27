---@class NixosShellBindingHandle
---@field remove fun()
---@field restore fun()

---@class NixosShellDefaults
---@field launcher NixosShellBindingHandle
---@field system_menu NixosShellBindingHandle
---@field model_usage NixosShellBindingHandle
---@field lock NixosShellBindingHandle?
---@field media_next NixosShellBindingHandle
---@field media_pause NixosShellBindingHandle
---@field media_play NixosShellBindingHandle
---@field media_previous NixosShellBindingHandle
---@field volume_up NixosShellBindingHandle?
---@field volume_down NixosShellBindingHandle?
---@field mute NixosShellBindingHandle?
---@field mic_mute NixosShellBindingHandle?
---@field brightness_up NixosShellBindingHandle
---@field brightness_down NixosShellBindingHandle

local M = {}

---@param hl table
---@return NixosShellDefaults
function M.apply(hl) end

return M
