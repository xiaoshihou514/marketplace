local ui = {}

-- reuse buffers
ui.popupbuf = nil
ui.sidebuf = nil
-- since window objects get destroyed after :q, we spawn new ones on call
ui.sizes = {
	popup = {
		height = 28,
		width = 100,
	},
	side = {
		width = 42,
	},
}
ui.colors = {
	pkg = "#56b6c2",
	star = "#e5b84e",
	issue = "#be95ff",
	time = "#229a58",
}
-- all the imports
local parser = require("marketplace.parser")
local remote = require("marketplace.remote")
ui.action = function(plugin)
	local urls = parser.get_readme_url(plugin)
	if urls == nil then
		return
	end
	local response = nil
	for _, url in ipairs(urls) do
		response = remote.request(url)
		if response ~= "" and string.sub(response, 1, 3) ~= "404" then
			break
		end
	end
	if response == "" then
		vim.notify("Unable to get README for the plugin...", vim.log.levels.WARN)
	else
		ui.spawn_popup(parser.to_table(parser.proc_readme(response)))
	end
end

local function create_popup_window_opts(height, width)
	-- display dims
	local lines = vim.o.lines - vim.o.cmdheight
	local columns = vim.o.columns
	-- calc relative pos
	local row = math.floor((lines - height) / 2)
	local col = math.floor((columns - width) / 2)
	local popup_layout = {
		height = height,
		width = width,
		row = row,
		col = col,
		relative = "editor",
		style = "minimal",
		border = "rounded",
		zindex = 45,
	}

	return popup_layout
end

-- init the buffer we want to display
function ui.init_buf_if_nil()
	if ui.popupbuf == nil then
		ui.popupbuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(ui.popupbuf, "modifiable", false)
		vim.api.nvim_buf_set_name(ui.popupbuf, "Marketplace README")
	end
	if ui.sidebuf == nil then
		ui.sidebuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(ui.sidebuf, "modifiable", false)
		vim.api.nvim_buf_set_name(ui.sidebuf, "Marketplace")
	end
end

-- displays the popup buffer with given text
function ui.spawn_popup(text)
	ui.init_buf_if_nil()
	-- ui.set_text(text, ui.popupbuf)
	-- display the buffer
	vim.api.nvim_open_win(ui.popupbuf, true, create_popup_window_opts(ui.sizes.popup.height, ui.sizes.popup.width))
	vim.api.nvim_set_current_buf(ui.popupbuf)
	local id = vim.fn.termopen("")
	vim.fn.chansend(id, text)
end

function ui.spawn_side(text)
	-- init buffer
	ui.init_buf_if_nil()
	ui.set_text(text, ui.sidebuf)

	-- create the vsplit
	local right = vim.opt.splitright
	if right == nil then
		right = true
	end
	vim.opt.splitright = not right
	vim.cmd(ui.sizes.side.width .. " vsplit")
	vim.opt.splitright = right

	-- swap out buffer
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, ui.sidebuf)
	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "relativenumber", false)
	vim.api.nvim_win_set_option(win, "number", false)
end

function ui.create_hl_groups()
	vim.cmd("highlight marketplace_pkg guifg=" .. ui.colors.pkg)
	vim.cmd("highlight marketplace_star guifg=" .. ui.colors.star)
	vim.cmd("highlight marketplace_issue guifg=" .. ui.colors.issue)
	vim.cmd("highlight marketplace_time guifg=" .. ui.colors.time)
end

function ui.highlight_glyphs()
	local symbols = parser.symbols
	vim.fn.matchadd("marketplace_pkg", symbols.pkg)
	vim.fn.matchadd("marketplace_star", symbols.star)
	vim.fn.matchadd("marketplace_issue", symbols.issue)
	vim.fn.matchadd("marketplace_time", symbols.time)
end

function ui.set_text(text, buf)
	ui.init_buf_if_nil()
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, text)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

ui.buf_action = function()
	local symbols = parser.symbols
	local on_line = vim.api.nvim_get_current_line()
	if string.find(on_line, symbols.pkg) and string.find(on_line, symbols.star) then
		-- plugin line
		ui.action(string.match(on_line, symbols.pkg .. "%s[\128-\255]*([^%s]+)"))
	elseif string.find(on_line, symbols.time) and string.find(on_line, symbols.issue) then
		-- issue & update time line
		-- get the line above
		on_line = vim.api.nvim_buf_get_lines(
			ui.sidebuf,
			vim.api.nvim_win_get_cursor(0)[1] - 2,
			vim.api.nvim_win_get_cursor(0)[1] - 1,
			false
		)[1]
		ui.action(string.match(on_line, symbols.pkg .. "%s[\128-\255]*([^%s]+)"))
	elseif string.find(on_line, symbols.separator) then
		-- separator, do nothing
	else
		-- description line
		-- get the line 2 lines above
		on_line = vim.api.nvim_buf_get_lines(
			ui.sidebuf,
			vim.api.nvim_win_get_cursor(0)[1] - 3,
			vim.api.nvim_win_get_cursor(0)[1] - 2,
			false
		)[1]
		ui.action(string.match(on_line, symbols.pkg .. "%s[\128-\255]*([^%s]+)"))
	end
end
function ui.insert_mappings()
	vim.api.nvim_buf_set_keymap(
		ui.sidebuf,
		"n",
		"<CR>",
		"<CMD>lua require('marketplace.ui').buf_action()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(ui.popupbuf, "n", "q", "<CMD>q<CR>", { noremap = true, silent = true })
end
return ui
