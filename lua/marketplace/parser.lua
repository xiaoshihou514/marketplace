local parser = {}
parser.symbols = {
	pkg = "",
	star = "",
	issue = "",
	time = "",
	separator = "─",
}
local url_list = require("marketplace.remote").url_list
-- helper for parsing
local function add_comp(result, column, component)
	-- remove spaces, we would add them manually
	component = string.gsub(component, "%s", "")
	if column == 0 then
		-- author/name
		result = result .. component
	elseif column == 1 then
		-- stars
		result = result .. " " .. parser.symbols.star .. " " .. component .. "\n"
	elseif column == 2 then
		-- open issues
		result = result .. parser.symbols.issue .. " " .. component
	elseif column == 3 then
		-- last updated time
		result = result .. " " .. parser.symbols.time .. " " .. component:sub(1, 10) .. "\n"
	elseif column > 3 then
		result = result .. component .. " "
	end
	return result
end

-- Parse raw plugin list string into something more displayable
-- e.g  LunarVim/LunarVim  13136
--      233  2023-01-31
--     🌙 LunarVim is an IDE layer for Neovim. Completely free and community driven.
function parser.parse_plugin_list(raw)
	local separator = parser.symbols.separator
	for _ = 1, require("marketplace.ui").sizes.side.width - 3 do
		separator = separator .. parser.symbols.separator
	end
	-- remove the first line
	local temp = string.gsub(raw, "^.-\n", "", 1)
	local res = ""
	-- match line
	for line in string.gmatch(temp, "(.-)\n") do
		res = res .. parser.symbols.pkg .. " "
		local col = 0
		-- match spaces
		for component in string.gmatch(line, "%S+%s%s*") do
			res = add_comp(res, col, component)
			col = col + 1
		end
		-- one for new line, another one for separating plugins
		res = res .. "\n" .. separator .. "\n"
	end
	return res
end

-- turn string into a table so buffers accept them
function parser.to_table(parsed)
	local res = {}
	for line in string.gmatch(parsed, "(.-)\n") do
		table.insert(res, line)
	end
	return res
end

-- gets possible README url from author/plugin
function parser.get_readme(str)
	local res = {}
	-- return a table of possible readme urls
	-- https://githubusercontent.com/NvChad/ui/main/README(.*)
	res:insert(url_list.rawgit .. str .. "/main/README.md")
	res:insert(url_list.rawgit .. str .. "/main/README")
	res:insert(url_list.rawgit .. str .. "/main/README.txt")
	return res
end

-- use tools like mdcat to beautify markdown
-- by default it does nothing
function parser.proc_readme(markdown)
	return markdown
end
return parser
