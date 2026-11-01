# Arch names Zed's CLI zeditor; preserve any existing zed launcher.
if not type -q zed; and command -q zeditor
    alias zed zeditor
end
