-- slash commands
SLASH_MB1 = "/mb"

---------------------------------------------------------------------------------------------------
function MB_slashCommands(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
	command = string.lower(command)
    if command == "show" then
        mBagsWowHeadLinks:BagPane()
    end
end
SlashCmdList["MB"] = MB_slashCommands
---------------------------------------------------------------------------------------------------
