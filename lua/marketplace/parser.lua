local parser = {}
parser.symbol = {
	pkg = "",
	star = "",
	issue = "",
	time = "",
}
-- helper to add string to result given its column
local function add_comp(result, column, component)
	if column == 0 then
		-- plugin author/name
		-- e.g folke/noice.nvim
		result = result .. component
	elseif column == 1 then
		-- stars
		result = result .. " " .. parser.symbol.star .. " " .. component .. "\n"
	elseif column == 2 then
		-- open issues
		result = result .. " " .. parser.symbol.issue .. " " .. component
	elseif column == 3 then
		-- last updated time
		result = result .. " " .. parser.symbol.time .. " " .. component:sub(1, 10) .. "\n"
	elseif column == 4 then
		result = result .. component
	end
end
-- Parse raw plugin list string into something more displayable
-- e.g  LunarVim/LunarVim  13136
--      233  2023-01-31
--     🌙 LunarVim is an IDE layer for Neovim. Completely free and community driven.
function parser.parse_plugin_list(raw)
	-- remove the first line
	local temp = string.gsub(raw, "^.-\n", "", 1)
	local res = ""
	for line in string.gmatch(temp, "(.-)\n") do
		res = res .. parser.symbol.pkg .. " "
		local col = 0
		for component in string.gmatch(line, "%S+") do
			add_comp(res, col, component)
		end
		res = res .. "\n"
	end
	return res
end
return parser
