-- maybe warn users if curl are not found
if os.execute("curl --version") ~= 0 then
	vim.api.nvim_err_writeln("curl is not installed! You may want to setup an alternative or the plugin would not work")
	return
end

-- make sure this file is loaded only once
if vim.g.market_loaded == 1 then
	return
end
vim.g.market_loaded = 1

-- create any global command that does not depend on user setup
-- usually it is better to define most commands/mappings in the setup function
-- Be careful to not overuse this file!
--
-- :Marketplace
local M = require("marketplace")
vim.api.nvim_create_user_command("Marketplace", function()
	M.open()
end, {})
