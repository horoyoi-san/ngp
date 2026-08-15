C_CollectionRewardTipStore = DefClass("C_CollectionRewardTipStore", C_CollectionRewardTipStore, C_StoreGroup)
GroupName2Class.CollectionRewardTipStore = C_CollectionRewardTipStore
local M = C_CollectionRewardTipStore

function M:OnShow(panelId, data)
	self.areaIndex = data.areaIndex
	local info = data.GalleryReward
	local showCount = true

	if showCount then
		self.bindData.showCountCtrl = 0
		local countNow = info.countNow
		local countAll = info.countAll
		self.bindData.count = "(" .. countNow .. "/" .. countAll .. ")"
	else
		self.bindData.showCountCtrl = 1
	end

	self.bindData.name = info.name
	self.bindData.typeName = info.typeName
	self.bindData.icon = info.sIcon
	local ani = self.bindData.openAni
	local duration = ani.clip.length

	Timer.New(function ()
		gPanelManager:Close(panelId)
	end, duration):Start()
end

function M:OnClose()
	return
end
