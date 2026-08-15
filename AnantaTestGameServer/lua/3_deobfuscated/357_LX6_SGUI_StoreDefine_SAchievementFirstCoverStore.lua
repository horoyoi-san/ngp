local RedDotMgr = SGUI.RedDotMgr
C_SAchievementFirstCoverStore = DefClass("C_SAchievementFirstCoverStore", C_SAchievementFirstCoverStore, C_StoreGroup)
GroupName2Class.SAchievementFirstCoverStore = C_SAchievementFirstCoverStore
local M = C_SAchievementFirstCoverStore

function M:ctor()
	self.msgEvents = {
		[gEventConstants.GAIN_ACHIEVEMENT] = self:CreateAction(self.RefreshPage)
	}
end

function M:OnAwake()
	self.bindData.getAllBtn.luaClick = self:CreateAction(self.OnGetAllAchievement)
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnExit)
	self.bindData.infoList.luaSimpleRenderItem = self:CreateAction(self.OnRenderLoopItem)
	self.bindData.infoList.luaSimpleClick = self:CreateAction(self.OnClickLoopItem)
	self.mgr = gNewAchievementMgr
	self.viewList = {}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnClose()
	self.mgr:OnPanelExit()
	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_ACHIEVEMENT_COVER) and 1 or 0
end

function M:OnGroupDisable()
	return
end

function M:OnShow()
	self.mgr:OnPanelOpen()
	self:RefreshPage()
end

local VIS2STATE = {
	[true] = 1,
	[false] = 0
}

function M:OnRenderLoopItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.viewList[index + 1]
	local info = self.mgr:GetAchievementDetail(data.id)
	local progress, maxProgress = self.mgr:GetProgressById(data.id)
	store.nameLabel = info.name
	store.iconId = info.icon
	store.stateCtl = VIS2STATE[progress == maxProgress]
	store.percentLabel = math.ceil(progress / maxProgress * 100) .. "%"
	store.index = index
end

function M:OnClickLoopItem(btn, index)
	local data = self.viewList[index + 1]

	gPanelManager:CheckShow(gPanelId.S_ACHIEVEMENT_DETAIL, {
		id = data.id
	})
end

function M:OnExit()
	gPanelManager:Close(gPanelId.S_ACHIEVEMENT_COVER)
end

function M:OnGetAllAchievement()
	self.mgr:AskReceiveAllReward(self:CreateAction(self.RefreshPage))
end

function M:RefreshPage()
	self.bindData.achSumLabel, self.bindData.BrozeNumLabel, self.bindData.SliverNumLabel, self.bindData.GoldNumLabel = self.mgr:GetRewardState()
	local redDotVis = self.mgr:GetAllRedCount() > 0
	self.bindData.showGetAll = redDotVis and 0 or 1
	self.viewList = self.mgr:GetAchievementFirstCover()

	self.bindData.infoList:SetSimpleList(#self.viewList)

	for i = 1, #self.viewList do
		local id = self.viewList[i].id

		self.bindData.infoList:SetItemId(i - 1, id)
	end
end
