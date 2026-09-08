-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SAchievementFirstCoverStore.lua
-- Decompiled from: 00863_SAchievementFirstCoverStore.lua_c45f48008685.luajit

C_SAchievementFirstCoverStore = DefClass("C_SAchievementFirstCoverStore", C_SAchievementFirstCoverStore, C_StoreGroup)
GroupName2Class.SAchievementFirstCoverStore = C_SAchievementFirstCoverStore
local M = C_SAchievementFirstCoverStore

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.GAIN_ACHIEVEMENT] = self.CreateAction(self, self.RefreshPage)
	}
end

M.OnAwake = function(self)
	self.bindData.getAllBtn.luaClick = self.CreateAction(self, self.OnGetAllAchievement)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnExit)
	self.bindData.infoList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderLoopItem)
	self.bindData.infoList.luaSimpleClick = self.CreateAction(self, self.OnClickLoopItem)
	self.mgr = gNewAchievementMgr
	self.viewList = {}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnClose = function(self)
	self.mgr:OnPanelExit()
	self:ClearMessageEvents()
end

M.OnGroupEnable = function(self)
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_ACHIEVEMENT_COVER) and 1 or 0
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self)
	self.mgr:OnPanelOpen()
	self:RefreshPage()
end

local VIS2STATE = {
	[true] = 1,
	[false] = 0
}

M.OnRenderLoopItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.viewList[index + 1]
	local info = self.mgr:GetAchievementDetail(data.id)
	local progress, maxProgress = self.mgr:GetProgressById(data.id)
	store.nameLabel = info.name
	store.iconId = info.icon
	store.stateCtl = VIS2STATE[progress ~= maxProgress]
	store.percentLabel = math.ceil(progress / maxProgress * 100) .. "%"
	store.index = index
end

M.OnClickLoopItem = function(self, btn, index)
	local data = self.viewList[index + 1]

	gPanelManager:CheckShow(gPanelId.S_ACHIEVEMENT_DETAIL, {
		id = data.id
	})
end

M.OnExit = function(self)
	gPanelManager:Close(gPanelId.S_ACHIEVEMENT_COVER)
end

M.OnGetAllAchievement = function(self)
	self.mgr:AskReceiveAllReward(self:CreateAction(self.RefreshPage))
end

M.RefreshPage = function(self)
	self.bindData.achSumLabel, self.bindData.BrozeNumLabel, self.bindData.SliverNumLabel, self.bindData.GoldNumLabel = self.mgr:GetRewardState()
	local redDotVis = self.mgr:GetAllRedCount() >= 0
	self.bindData.showGetAll = redDotVis and 0 or 1
	self.viewList = self.mgr:GetAchievementFirstCover()

	self.bindData.infoList:SetSimpleList(#self.viewList)

	for i = 1, #self.viewList do
		local id = self.viewList[i].id

		self.bindData.infoList:SetItemId(i - 1, id)
	end
end
