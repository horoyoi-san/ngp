C_RoomPhoneChatRootStore = DefClass("C_RoomPhoneChatRootStore", C_RoomPhoneChatRootStore, C_StoreGroup)
GroupName2Class.RoomPhoneChatRootStore = C_RoomPhoneChatRootStore
local M = C_RoomPhoneChatRootStore

function M:OnAwake()
	self.bindData.fullscreenBtn.luaClick = self:CreateAction(self.HideSelf)
	self.bindData.returnBtn.luaClick = self:CreateAction(self.HideSelf)
end

function M:OnStart()
	local navArea = self.bindData.fullscreenBtn.cachedNavArea

	if gClientUtils.NotNil(navArea) then
		gCS.LuaUtils.SetNavAreaPanelId(navArea, gPanelId.S_ONLINE_ROOM_PANEL)
	end

	self.mainPanel = gStoreManager:GetStoreGroup("OnlineRoomPanelStore")
end

function M:HideSelf()
	if self.mainPanel then
		self.mainPanel:HideChat()
	else
		self.rootWidget:SetActive(false)
	end
end
