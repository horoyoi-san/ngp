-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\RoomPhoneChatRootStore.lua
-- Decompiled from: 01267_RoomPhoneChatRootStore.lua_38c37bc7f08e.luajit

C_RoomPhoneChatRootStore = DefClass("C_RoomPhoneChatRootStore", C_RoomPhoneChatRootStore, C_StoreGroup)
GroupName2Class.RoomPhoneChatRootStore = C_RoomPhoneChatRootStore
local M = C_RoomPhoneChatRootStore

M.OnAwake = function(self)
	self.bindData.fullscreenBtn.luaClick = self.CreateAction(self, self.HideSelf)
	self.bindData.returnBtn.luaClick = self.CreateAction(self, self.HideSelf)
end

M.OnStart = function(self)
	local navArea = self.bindData.fullscreenBtn.cachedNavArea

	if gClientUtils.NotNil(navArea) then
		gCS.LuaUtils.SetNavAreaPanelId(navArea, gPanelId.S_ONLINE_ROOM_PANEL)
	end

	self.mainPanel = gStoreManager:GetStoreGroup("OnlineRoomPanelStore")
end

M.HideSelf = function(self)
	if self.mainPanel then
		self.mainPanel:HideChat()
	else
		self.rootWidget:SetActive(false)
	end
end
