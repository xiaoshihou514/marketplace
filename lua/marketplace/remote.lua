local remote = {}
local suffix = " 2>/dev/null"

remote.curl = "curl -s "
remote.url_list = {
	plugins = "https://nvim.sh/s",
	tags = "https://nvim.sh/t",
	search_plugin = "https://nvim.sh/s/",
	search_tag = "https://nvim.sh/t/",
	rawgit = "https://rawgithubusercontent.com/",
}

-- basically getting the raw txt
function remote.request(url)
	local handle = io.popen(remote.curl .. url .. suffix)
	if handle == nil then
		return ""
	end
	local response = handle:read("*all")
	local success, _, _ = handle:close()
	if not success or response == nil or response == "" then
		vim.notify("Unable to get plugin list", vim.log.levels.WARN)
		return ""
	end
	return response
end

return remote
