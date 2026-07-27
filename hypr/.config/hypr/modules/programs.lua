local terminal = "alacritty"
local fileManager = "nautilus"
local shell = "nixos-shell"
local shellIpc = "nixos-shell-ipc call "
local showVolumeOsd = shellIpc .. "osd volume"

return {
    fileManager = fileManager,
    mainMod = "SUPER",
    shell = shell,
    shellIpc = shellIpc,
    showVolumeOsd = showVolumeOsd,
    terminal = terminal,
}
