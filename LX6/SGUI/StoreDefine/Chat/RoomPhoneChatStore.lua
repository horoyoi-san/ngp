-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\RoomPhoneChatStore.lua
-- Decompiled from: 02117_RoomPhoneChatStore.lua_135c384207c6.luajit

C_RoomPhoneChatStore = DefClass("C_RoomPhoneChatStore", C_RoomPhoneChatStore, C_ChattingToFriendPanelStore)
GroupName2Class.RoomPhoneChatStore = C_RoomPhoneChatStore
local M = C_RoomPhoneChatStore

M.OnAwake = function(self)
	M.base.OnAwake(self)

	self.onShowTimer = FrameTimer.New(function ()
		M.base.OnShow(self, nil, {
			topChannelId = gChatTopChannel.Channels,
			subChannelId = UX.Game.MessageChannel.Room
		})
	end, 1):Start()
end

M.OnDestroy = function(self)
	self.onShowTimer:Stop()
	M.base.OnClose(self)
	M.base.OnDestroy(self)
end
