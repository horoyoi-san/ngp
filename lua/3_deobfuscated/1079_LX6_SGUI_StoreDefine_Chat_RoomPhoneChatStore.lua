C_RoomPhoneChatStore = DefClass("C_RoomPhoneChatStore", C_RoomPhoneChatStore, C_ChattingToFriendPanelStore)
GroupName2Class.RoomPhoneChatStore = C_RoomPhoneChatStore
local M = C_RoomPhoneChatStore

function M:OnAwake()
	M.base.OnAwake(self)

	self.onShowTimer = FrameTimer.New(function ()
		M.base.OnShow(self, nil, {
			topChannelId = gChatTopChannel.Channels,
			subChannelId = UX.Game.MessageChannel.Room
		})
	end, 1):Start()
end

function M:OnDestroy()
	self.onShowTimer:Stop()
	M.base.OnClose(self)
	M.base.OnDestroy(self)
end
