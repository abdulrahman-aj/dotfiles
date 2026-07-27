local shellPath = "/run/current-system/sw/share/hypr/nixos-shell.lua"
local shellFile = io.open(shellPath, "r")

if not shellFile then
    return
end

shellFile:close()
package.path = "/run/current-system/sw/share/hypr/?.lua;" .. package.path
return require("nixos-shell").apply(hl)
