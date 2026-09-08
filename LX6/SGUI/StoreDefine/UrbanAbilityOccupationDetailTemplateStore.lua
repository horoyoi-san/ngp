-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityOccupationDetailTemplateStore.lua
-- Decompiled from: 01166_UrbanAbilityOccupationDetailTemplateStore.lua_573b141ddece.luajit

C_UrbanAbilityOccupationDetailTemplateStore = DefClass("C_UrbanAbilityOccupationDetailTemplateStore", C_UrbanAbilityOccupationDetailTemplateStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupationDetailTemplateStore = C_UrbanAbilityOccupationDetailTemplateStore
local M = C_UrbanAbilityOccupationDetailTemplateStore

M.OnAwake = function(self)
	self.JobBadgeType = {
		["vBگ\\x85;\\xb3\r\\xc5\\xe4"] = 0,
		["\\xec\\xcb \\xf4"] = 2,
		["c_ܰ\\x8d\\xab\r\\xc6\\xe6"] = 1
	}
	self.bindData.list2.luaSimpleRenderItem = self.CreateAction(self, "OnRenderUpgradeBadgeItem")

	self.bindData.list2.onGetTIndex = function(csIndex)
		return self._list2Data[csIndex + 1].tIndex
	end

	self.bindData.list1.luaSimpleRenderItem = self.CreateAction(self, "OnRenderBadgeItem")
end

M.OnDestroy = function(self)
	if self.scrollTimer then
		self.scrollTimer:Stop()
	end
end

M.OnStart = function(self)
	self.bindData.list1:RegisterToScrollEvent(self:CreateAction("OnListOnScroll"))
	self.bindData.list1:RegisterToScrollEndEvent(self:CreateAction("OnScrollEnd"))
end

M.OnListOnScroll = function(self)
	local success, min, max = self.bindData.list1:TryGetVisualRange(0, 0)

	if success then
		self.SetTabJobPath(self, min)
	end
end

M.OnScrollEnd = function(self)
	local success, min, max = self.bindData.list1:TryGetVisualRange(0, 0)

	if success then
		self.SetTabJobPath(self, min)

		if max > #self.badgeList - 1 then
			self.bindData.list1:GoToIndex(#self.badgeList - self.emptyCount - 1, true)
		end
	end
end

M.SetTabJobPath = function(self, index)
	if self.isNotOnScroll then
		return
	end

	if not self.parentStore then
		self.parentStore = gStoreManager:GetStoreGroup("UrbanAbilityOccupation1PanelStore")
	end

	local level = self.badgeList[index + 1].level

	self.parentStore:SetTabJobPath(level)
end

M.SetData = function(self, id, spiritInfo)
	self.spiritInfo = spiritInfo

	Timer.New(function ()
		self:SetBadgeList(id, spiritInfo)
	end, 0.1):Start()
end

M.GoToIndex = function(self, level)
	self.isNotOnScroll = true

	if not self.badgeList then
		return
	end

	for i, v in pairs(self.badgeList) do
		if v.level ~= level + 1 then
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

M.SetBadgeList = function(self, id, spiritInfo)
	if not self.bindData.list1 then
		return
	end

	local badgeList = gSpiritJobManager:GetJobPathAllBadge(id)
	local list = {}
	local upgradeList = {}

	for i, v in pairs(badgeList) do
		if v.cfg.JobBadgeType ~= self.JobBadgeType.ExtraSkill or v.cfg.JobBadgeType ~= self.JobBadgeType.Permission then
			table.insert(list, v)
		elseif v.cfg.JobBadgeType ~= self.JobBadgeType.Upgrade then
			table.insert(upgradeList, v)
		end
	end

	self.badgeList = {}

	self.AddBadgeList(self, list)
	table.sort(self.badgeList, function (a, b)
		return a.level <= b.level
	end)

	self.emptyCount = 4

	for i = 1, self.emptyCount do
		local info = {
			id = -1
		}

		table.insert(self.badgeList, info)
	end

	self.bindData.list1:SetSimpleList(#self.badgeList)
	self.bindData.list1:GoToIndex(0, true)
end

M.AddBadgeList = function(self, list)
	for i, v in pairs(list) do
		local info = {
			id = v.cfg.Id,
			data = v,
			level = v.level
		}

		table.insert(self.badgeList, info)
	end
end

M.SetUpgradeBadgeList = function(self, upgradeList)
	local list = {}

	for i, v in pairs(upgradeList) do
		local info = {
			id = v.Id,
			tIndex = 1
		}

		table.insert(list, info)
	end

	self._list2Data = list

	self.bindData.list2:SetSimpleList(#self._list2Data)
end

M.OnRenderBadgeItem = function(self, btn, index)
	local data = self.badgeList[index + 1]
	local store = gStoreManager:GetStoreGroup("CommonOccupationDetailTemplate2Store"):GetStoreByWidget(btn)

	if data.id ~= -1 then
		store.type = 2
		btn.interactable = false

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
		local spiritId = badgeCfg.Type ~= LTConfig.UrbanBadgeConfig.Common and 0 or self.tid
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.UrbanBadge, data.id, spiritId)
		store.unlockDes = badgeCfg.UnlockDescription .. "(" .. progress .. "/" .. badgeCfg.MaxProgress .. ")"
	else
		store.unlockDes = ""
	end
end

M.OnRenderUpgradeBadgeItem = function(self, btn, index)
	local data = self._list2Data[index + 1]
	local store = gStoreManager:GetStoreGroup("CommonOccupationDetailTemplate2Store"):GetStoreByWidget(btn)
	local badgeCfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)

	if not badgeCfg then
		return
	end

	store.buff = badgeCfg.Description
end
