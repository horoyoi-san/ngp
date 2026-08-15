local PanelRedDotConfig = LTConfig.PanelRedDotConfig
local M = {
	CheckChatHasRedDot = function (callback)
		local chatRedCount = gChatManager:GetTotalUnreadCount()

		if chatRedCount > 0 then
			callback(true)

			return
		end

		gFriendManager:AskFriendRed(function (count)
			local hasRedDot = count > 0

			callback(hasRedDot)
		end)
	end,
	CheckNpcChatHasRedDot = function (callback)
		local chatRedCount = gNpcChatManager:GetTotalUnreadCount()

		callback(chatRedCount > 0)
	end
}
gRedDotUtils = M
