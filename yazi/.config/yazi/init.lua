-- 1. Load Plugins
require("sshfs"):setup()
require("recycle-bin"):setup()
require("full-border"):setup()
require("kdeconnect-send"):setup({})

-- 2. Status Bar Override
-- (Shows the arrow -> target only at the bottom of the screen)
function Status:name()
	local h = cx.active.current.hovered
	if not h then
		return ui.Span("")
	end

	local linked = ""
	if h.link_to then
		linked = " -> " .. tostring(h.link_to)
	end
	
	return ui.Span(" " .. h.name .. linked)
end


