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
-- 			width = 42,
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
	if not opts then
		return
	end
	local symbols = opts.symbols
	if symbols then
		local parser_symbols = parser.symbols
		parser_symbols.pkg = symbols.pkg or parser_symbols.pkg
		parser_symbols.star = symbols.star or parser_symbols.star
		parser_symbols.issue = symbols.issue or parser_symbols.issue
		parser_symbols.time = symbols.time or parser_symbols.time
		parser_symbols.separator = symbols.separator or parser_symbols.separator
	end
	local sizes = opts.sizes
	if sizes then
		local ui_sizes = ui.sizes
		ui_sizes.side.width = sizes.side and sizes.side.width or ui_sizes.side.width
		ui_sizes.popup.height = sizes.popup and sizes.popup.height or ui_sizes.popup.height
		ui_sizes.popup.width = sizes.popup and sizes.popup.width or ui_sizes.popup.width
	end
	local highlight = opts.highlight
	if highlight then
		local ui_colors = ui.colors
		ui_colors.pkg = highlight.pkg or ui_colors.pkg
		ui_colors.star = highlight.star or ui_colors.star
		ui_colors.issue = highlight.issue or ui_colors.issue
		ui_colors.time = highlight.time or ui_colors.time
	end
	remote.curl = opts.curl or remote.curl
	parser.proc_readme = opts.readme_action or parser.proc_readme
end

function M.open()
	local flag = 0
	for _, _ in ipairs(vim.fn.win_findbuf("Marketplace")) do
		flag = flag + 1
	end
	if flag ~= 0 then
		return
	end
	if M.cache.raw_str == nil or M.cache.raw_str == "" then
		vim.notify("Pulling plugin list, this should take a while...", vim.log.levels.WARN)
		M.cache.raw_str = remote.request(remote.url_list.plugins)
	end
	if M.cache.formatted_line == nil then
		local str = parser.parse_plugin_list(M.cache.raw_str)
		M.cache.formatted_line = parser.to_table(str)
	end
	ui.create_hl_groups()
	ui.spawn_side(M.cache.formatted_line)
	ui.highlight_glyphs()
	ui.insert_mappings()
end

return M
