local M = {}
local cache = {
	-- put curl output here cause it takes a long time
	raw_str = nil,
	-- also the formatted table goes here
	formatted_line = nil,
}

function M.setup(opts)
	-- configuration goes here
end

function M.toggle_view()
	-- toggle the side search bar
	-- maybe put some popular plugins on it on startup
end

return M
