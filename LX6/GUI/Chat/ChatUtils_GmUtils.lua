-- Original chunk: @Lua\LuaFiles\LX6\GUI\Chat\ChatUtils_GmUtils.lua
-- Decompiled from: 00295_ChatUtils_GmUtils.lua_030a4e7c6dda.luajit

local GmUtils = {
	SkipNpcChatDialog = function (chatId)
		local store = gStoreManager:GetStoreGroup("ChattingToNpcPanelStore")

		if not store.STATE_EnableOnce then
			store = gStoreManager:GetStoreGroup("NpcChattingToNpcPanelStore")
		end

		local nextMsgCo = nil

		if store.STATE_EnableOnce then
			local msg = store.lastMessage
			nextMsgCo = coroutine.start(function ()
				while msg do
					store.waitForEllipsisBubble = false

					store:OnClickChatBG()
					coroutine.step()
				end

				gClientToGameSceneDelegate:AskCloseNpcChatWnd(chatId)
				gChatManager.cs:ClearAllNpcDialogChat()
				gClientUtils.CloseMainPhonePanel()
			end)
		end

		Timer.New(function ()
			coroutine.stop(nextMsgCo)
			gClientToGameSceneDelegate:AskCloseNpcChatWnd(chatId)
			gChatManager.cs:ClearAllNpcDialogChat()
			FrameTimer.New(function ()
				gClientUtils.CloseMainPhonePanel()
			end, 1, 100):Start()
		end, 2):Start()
	end
}

return GmUtils
