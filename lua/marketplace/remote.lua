local remote = {}
local suffix = " 2>dev/null"

remote.curl = "curl -s "

-- basically getting the raw txt
function remote.request(url)
	local handle = io.popen(remote.curl .. url .. suffix)
	if handle == nil then
		return ""
	end
	local success, _, _ = handle:close()
	if not success then
		return ""
	end
	local response = handle:read("*all")
	handle:close()
	return response
end

return remote
