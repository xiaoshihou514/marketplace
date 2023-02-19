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
-- local default_settings = {
-- 	symbols = {
-- 		pkg = "",
-- 		star = "",
-- 		issue = "",
-- 		time = "",
-- 		separator = "─",
-- 	},
-- 	sizes = {
-- 		side = {
-- 			width = 40,
-- 		},
-- 		popup = {
-- 			height = 35,
-- 			width = 120,
-- 		},
-- 	},
-- 	colors = {
-- 		pkg = "#56b6c2",
-- 		star = "#e5b84e",
-- 		issue = "#be95ff",
-- 		time = "#229a58",
-- 	},
-- 	curl = "curl -s ",
-- 	readme_action = nil,
-- }

function M.setup(opts)
	-- configuration goes here
	if opts == nil then
		return
	end
	if opts.symbols ~= nil then
		local o = opts.symbols
		local d = parser.symbols
		if o.pkg ~= nil then
			d.pkg = o.pkg
		end
		if o.star ~= nil then
			d.star = o.star
		end
		if o.issue ~= nil then
			d.issue = o.issue
		end
		if o.time ~= nil then
			d.time = o.time
		end
		if o.separator ~= nil then
			d.separator = o.separator
		end
	end
	if opts.sizes ~= nil then
		local o = opts.sizes
		local d = ui.sizes
		if o.side ~= nil then
			if o.side.width ~= nil then
				d.side.width = o.side.width
			end
		end
		if o.popup ~= nil then
			if o.popup.height ~= nil and o.popup.width ~= nil then
				d.popup.height = o.popup.height
				d.popup.width = o.popup.width
			end
		end
	end
	if opts.highlight ~= nil then
		local o = opts.colors
		local d = ui.colors
		if o.pkg ~= nil then
			d.pkg = o.pkg
		end
		if o.star ~= nil then
			d.star = o.star
		end
		if o.issue ~= nil then
			d.issue = o.issue
		end
		if o.time ~= nil then
			d.time = o.time
		end
	end
	if opts.curl ~= nil then
		remote.curl = opts.curl
	end
	if opts.readme_action ~= nil then
		parser.proc_readme = opts.readme_action
	end
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
	ui.insert_mappings(ui.buf_action())
end

vim.api.nvim_create_user_command("Marketplace", function()
	M.open()
end, {})

return M
