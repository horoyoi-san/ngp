-- Original chunk: @Lua\LuaFiles\LX6\GUI\NpcChat\NpcChatUtils_GmUtils.lua
-- Decompiled from: 00308_NpcChatUtils_GmUtils.lua_3fc4ea72e7d6.luajit

local GmUtils = {
	SkipNpcChatDialog = function (chatId)
		local store = gStoreManager:GetStoreGroup("NpcChatChattingPanelStore")

		if not store.STATE_EnableOnce then
			store = gStoreManager:GetStoreGroup("NpcChatN2NChattingPanel")
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
				gNpcChatManager:ClearAllNpcDialogChat()
				gClientUtils.CloseMainPhonePanel()
			end)
		end

		Timer.New(function ()
			coroutine.stop(nextMsgCo)
			gClientToGameSceneDelegate:AskCloseNpcChatWnd(chatId)
			gNpcChatManager:ClearAllNpcDialogChat()
			FrameTimer.New(function ()
				gClientUtils.CloseMainPhonePanel()
			end, 1, 100):Start()
		end, 2):Start()
	end
}

return GmUtils
