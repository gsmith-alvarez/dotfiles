-- user commands
local commands = Config.safe_require "commands"
if not commands then
	return
end
-- Plugin management
commands.register "pack"
