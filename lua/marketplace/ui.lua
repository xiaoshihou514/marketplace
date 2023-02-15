local ui = {}

-- reuse buffers
ui.popupbuf = nil
ui.sidebuf = nil
-- since window objects get destroyed after :q, we spawn new ones on call
ui.dims = {
	popup = {
		height = 35,
		width = 120,
	},
	side = {
		width = 40,
	},
}

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
		vim.api.nvim_buf_set_name(ui.popupbuf, "Nvim Marketplace")
	end
	if ui.sidebuf == nil then
		ui.sidebuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(ui.sidebuf, "modifiable", false)
		vim.api.nvim_buf_set_name(ui.sidebuf, "Nvim Marketplace")
	end
end

-- displays the popup buffer with given text
function ui.spawn_popup(text)
	ui.init_buf_if_nil()
	ui.set_text(text, ui.popupbuf)
	-- display the buffer
	vim.api.nvim_open_win(ui.popupbuf, true, create_popup_window_opts(ui.dims.height, ui.dims.width))
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
	vim.cmd(ui.dims.side.width .. " vsplit")
	vim.opt.splitright = right

	-- swap out buffer
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, ui.sidebuf)
end

function ui.set_text(text, buf)
	ui.init_buf_if_nil()
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, text)
end

function ui.insert_mappings(mappings) end
return ui
