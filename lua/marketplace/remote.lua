local remote = {}
local suffix = " 2>dev/null"
remote.curl = "curl -s "
function remote.request(url)
	local handle = nil
	handle = io.popen(remote.curl .. url .. suffix)
	if handle == nil then
		return ""
	end
	local response = handle:read("*all")
	handle:close()
	return response
end
URL = {
	plugins = "https://nvim.sh/s",
	tags = "https://nvim.sh/t",
	search_plugin = "https://nvim.sh/s/",
	search_tag = "https://nvim.sh/t/",
	rawgit = "https://rawgithubusercontent.com/",
}
return remote
