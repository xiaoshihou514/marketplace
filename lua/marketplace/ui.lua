local ui = {}

ui.buf = nil
ui.dims = {
	height = 35,
	width = 120,
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
	if ui.buf == nil then
		ui.buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(ui.buf, "modifiable", false)
		vim.api.nvim_buf_set_name(ui.buf, "Nvim Marketplace")
	end
end

function ui.spawn_win()
	ui.init_buf_if_nil()
	-- display the buffer
	vim.api.nvim_open_win(ui.buf, true, create_popup_window_opts(ui.dims.height, ui.dims.width))
end

function ui.set_text(text)
	ui.init_buf_if_nil()
	vim.api.nvim_buf_set_lines(ui.buf, 0, -1, true, text)
end

function insert_mappings(mappings) end
return ui
