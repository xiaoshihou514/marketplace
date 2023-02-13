local remote = {}
remote.cert_path = nil
local suffix = " > dev/null"
function remote.request(url)
	local handle = nil
	if remote.cert_path ~= nil then
		handle = io.popen("curl -s --cacert " .. remote.cert_path .. " " .. url .. suffix)
	else
		handle = io.popen("curl -s " .. url .. suffix)
	end
	if handle == nil then
		return ""
	end
	local response = handle:read("*a")
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
