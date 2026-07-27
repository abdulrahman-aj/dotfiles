local programs = require("modules.programs")

hl.on("hyprland.start", function()
    hl.exec_cmd(programs.shell)
    hl.exec_cmd("wl-clip-persist --clipboard both")
end)
