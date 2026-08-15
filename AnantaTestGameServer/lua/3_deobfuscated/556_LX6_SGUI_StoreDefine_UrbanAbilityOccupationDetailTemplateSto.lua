C_UrbanAbilityOccupationDetailTemplateStore = DefClass("C_UrbanAbilityOccupationDetailTemplateStore", C_UrbanAbilityOccupationDetailTemplateStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupationDetailTemplateStore = C_UrbanAbilityOccupationDetailTemplateStore
local M = C_UrbanAbilityOccupationDetailTemplateStore

function M:OnAwake()
	self.JobBadgeType = {
		ExtraSkill = 0,
		Upgrade = 2,
		Permission = 1
	}
	self.bindData.list2.luaRenderItem = self:CreateAction("OnRenderUpgradeBadgeItem")
	self.bindData.list1.luaRenderItem = self:CreateAction("OnRenderBadgeItem")
end

function M:OnDestroy()
	if self.scrollTimer then
		self.scrollTimer:Stop()
	end
end

function M:OnStart()
	self.bindData.list1:RegisterToScrollEvent(self:CreateAction("OnListOnScroll"))
	self.bindData.list1:RegisterToScrollEndEvent(self:CreateAction("OnScrollEnd"))
end

function M:OnListOnScroll()
	local success, min, max = self.bindData.list1:TryGetVisualRange(0, 0)

	if success then
		self:SetTabJobPath(min)
	end
end

function M:OnScrollEnd()
	local success, min, max = self.bindData.list1:TryGetVisualRange(0, 0)

	if success then
		self:SetTabJobPath(min)

		if max >= #self.badgeList - 1 then
			self.bindData.list1:GoToIndex(#self.badgeList - self.emptyCount - 1, true)
		end
	end
end

function M:SetTabJobPath(index)
	if self.isNotOnScroll then
		return
	end

	if not self.parentStore then
		self.parentStore = gStoreManager:GetStoreGroup("UrbanAbilityOccupation1PanelStore")
	end

	local level = self.badgeList[index + 1].level

	self.parentStore:SetTabJobPath(level)
end

function M:SetData(id, spiritInfo)
	self.spiritInfo = spiritInfo

	Timer.New(function ()
		self:SetBadgeList(id, spiritInfo)
	end, 0.1):Start()
end

function M:GoToIndex(level)
	self.isNotOnScroll = true

	if not self.badgeList then
		return
	end

	for i, v in pairs(self.badgeList) do
		if v.level == level + 1 then
			self.bindData.list1:GoToIndex(i - 1, ture)

			break
		end
	end

	if self.scrollTimer then
		self.scrollTimer:Stop()
	end

	self.scrollTimer = Timer.New(function ()
		self.isNotOnScroll = false
	end, 2):Start()
end

function M:SetBadgeList(id, spiritInfo)
	if not self.bindData.list1 then
		return
	end

	local badgeList = gSpiritJobManager:GetJobPathAllBadge(id)
	local list = {}
	local upgradeList = {}

	for i, v in pairs(badgeList) do
		if v.cfg.JobBadgeType == self.JobBadgeType.ExtraSkill or v.cfg.JobBadgeType == self.JobBadgeType.Permission then
			table.insert(list, v)
		elseif v.cfg.JobBadgeType == self.JobBadgeType.Upgrade then
			table.insert(upgradeList, v)
		end
	end

	self.badgeList = {}

	self:AddBadgeList(list)
	table.sort(self.badgeList, function (a, b)
		return a.level < b.level
	end)

	self.emptyCount = 4

	for i = 1, self.emptyCount do
		local info = {
			id = -1
		}

		table.insert(self.badgeList, info)
	end

	self.bindData.list1:SetList(self.badgeList)
	self.bindData.list1:GoToIndex(0, true)
end

function M:AddBadgeList(list)
	for i, v in pairs(list) do
		local info = {
			id = v.cfg.Id,
			data = v,
			level = v.level
		}

		table.insert(self.badgeList, info)
	end
end

function M:SetUpgradeBadgeList(upgradeList)
	local list = {}

	for i, v in pairs(upgradeList) do
		local info = {
			id = v.Id,
			tIndex = 1
		}

		table.insert(list, info)
	end

	self.bindData.list2:SetList(list)
end

function M:OnRenderBadgeItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("CommonOccupationDetailTemplate2Store"):GetStoreByWidget(btn)

	if data.id == -1 then
		store.type = 2

		return
	end

	local badge = self.spiritInfo.InfoBadge.Badges[data.id]

	if badge and badge.Active then
		store.isLock = 0
	else
		store.isLock = 1
	end

	local badgeCfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)

	if not badgeCfg then
		return
	end

	store.des = badgeCfg.Name
	store.buff = badgeCfg.Description
	store.icon = badgeCfg.Image
	store.level = gUIUtils:NumToRoman(data.data.level)
	store.type = badgeCfg.JobBadgeType

	if badgeCfg.UnlockDescription then
		local spiritId = badgeCfg.Type == LTConfig.UrbanBadgeConfig.Common and 0 or self.tid
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.UrbanBadge, data.id, spiritId)
		store.unlockDes = badgeCfg.UnlockDescription .. "(" .. progress .. "/" .. badgeCfg.MaxProgress .. ")"
	else
		store.unlockDes = ""
	end
end

function M:OnRenderUpgradeBadgeItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("CommonOccupationDetailTemplate2Store"):GetStoreByWidget(btn)
	local badgeCfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)

	if not badgeCfg then
		return
	end

	store.buff = badgeCfg.Description
end
