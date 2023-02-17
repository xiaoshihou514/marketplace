local M = {}
M.cache = {
	-- put curl output here cause it takes a long time
	raw_str = nil,
	-- also the formatted table goes here
	formatted_line = nil,
}
local remote = require("marketplace.remote")
local parser = require("marketplace.parser")
local ui = require("marketplace.ui")
local default_settings = {
	symbols = {
		pkg = "",
		star = "",
		issue = "",
		time = "",
		separator = "─",
	},
	sizes = {
		side = {
			width = 40,
		},
		popup = {
			height = 35,
			width = 120,
		},
	},
	highlight = {
		pkg = "#56b6c2",
		star = "#e5b84e",
		issue = "#be95ff",
		time = "#229a58",
	},
	curl = "curl -s ",
}

function M.setup(opts)
	-- configuration goes here
end

function M.open()
	if M.cache.raw_str == nil or M.cache.raw_str == "" then
		vim.notify("Pulling plugin list...", vim.log.levels.INFO)
		M.cache.raw_str = remote.request(remote.url_list.plugins)
	end
	if M.cache.formatted_line == nil then
		local str = parser.parse_plugin_list(M.cache.raw_str)
		M.cache.formatted_line = parser.to_table(str)
	end
	ui.create_hl_groups()
	ui.spawn_side(M.cache.formatted_line)
	ui.highlight_glyphs()
	ui.insert_mappings(ui.mappings)
end

vim.api.nvim_create_user_command("Marketplace", function()
	M.open()
end, {})

return M
