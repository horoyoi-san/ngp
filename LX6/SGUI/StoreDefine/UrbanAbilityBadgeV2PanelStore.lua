-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityBadgeV2PanelStore.lua
-- Decompiled from: 01195_UrbanAbilityBadgeV2PanelStore.lua_aed07092b90c.luajit

C_UrbanAbilityBadgeV2PanelStore = DefClass("C_UrbanAbilityBadgeV2PanelStore", C_UrbanAbilityBadgeV2PanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityBadgeV2PanelStore = C_UrbanAbilityBadgeV2PanelStore
local M = C_UrbanAbilityBadgeV2PanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityV2PanelStore")
	self.panelNavArea = nil
	self.isTooltipOpen = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isEmptyEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.isTooltipOpen = false
	self.lastSelectIndex = nil
	self.lastSelectBtn = nil

	self.SetBadgeData(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	self.isTooltipOpen = false
end

M.OnDestroy = function(self)
	self.panelNavArea = nil
	self.isTooltipOpen = false
	self.lastSelectBtn = nil
	self.lastSelectIndex = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.ShowPanel = function(self, cfg)
	self.defaultCfg = cfg

	self.SetBadgeData(self)
	self.LocateDefaultBadge(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_SYNC_URBAN_BADGEINFO] = self.CreateAction(self, "OnSyncBadgeInfo")
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnSimpleClickList")
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetListTIndex")
end

M.OnClickCloseBtn = function(self)
	if self.isTooltipOpen then
		return
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_Vx_UrbanAbilityBasicFeaturePanel_close")
	Timer.New(function ()
		self.urbanAbilityStore:CloseCurrentTab()
	end, 0.2):Start()
end

M.OnGetListTIndex = function(self, index)
	local data = self.allList[index + 1]

	if data then
		return data.tIndex
	end

	return 1
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.allList[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= 0 then
		self.RenderTitleItem(self, btn, data)
	else
		self.RenderBadgeListItem(self, btn, data)
	end
end

M.OnSimpleClickList = function(self, btn, index)
end

M.OnSyncBadgeInfo = function(self)
	self.SetBadgeData(self)
end

M.SetBadgeData = function(self)
	self.allList = {}
	local curSpiritId = self.urbanAbilityStore:GetCurSpiritTid()
	local spiritBadges = self:GetSpiritBadgeList(curSpiritId)

	if #spiritBadges <= 0 then
		local _, _, qualityList, quality = gUrbanAbilityManager:GetSpiritAllBadgeNum(curSpiritId)

		table.insert(self.allList, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			groupType = gUrbanAbilityManager.BADGE_TYPE.FIGHT_SPIRIT,
			title = LTConfig.TextScriptTextConfig.GetConfig(89901251).Text,
			qualityList = self:BuildQualityList(qualityList, quality)
		})
		table.insert(self.allList, {
			["a\\x9f\\x8a\\x86Y"] = 1,
			badges = spiritBadges
		})
	end

	local commonBadges = self.GetCommonBadgeList(self)

	if #commonBadges <= 0 then
		local _, _, qualityList, quality = gUrbanAbilityManager:GetAllCommonBadgeNum()

		table.insert(self.allList, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			groupType = gUrbanAbilityManager.BADGE_TYPE.COMMON,
			title = LTConfig.TextScriptTextConfig.GetConfig(89901250).Text,
			qualityList = self:BuildQualityList(qualityList, quality)
		})
		table.insert(self.allList, {
			["a\\x9f\\x8a\\x86Y"] = 1,
			badges = commonBadges
		})
	end

	self.bindData.isEmpty = #self.allList <= 0 and self.isEmptyEnum._false or self.isEmptyEnum._true

	self.bindData.list:SetSimpleList(#self.allList)
end

M.LocateDefaultBadge = function(self)
	if not self.defaultCfg then
		return
	end

	local targetId = self.defaultCfg.Id
	local targetType = self.defaultCfg.Type

	if targetId then
		for i, group in ipairs(self.allList) do
			if group.tIndex ~= 1 and group.badges then
				for _, badge in ipairs(group.badges) do
					if badge.id ~= targetId then
						self.lastSelectIndex = targetId

						self.bindData.list:GoToIndex(i - 1, true)

						self.defaultCfg = nil

						return
					end
				end
			end
		end
	elseif targetType then
		for i, group in ipairs(self.allList) do
			if group.tIndex ~= 0 and group.groupType ~= targetType then
				self.bindData.list:GoToIndex(i - 1, true)

				self.defaultCfg = nil

				return
			end
		end
	end

	self.defaultCfg = nil
end

M.GetCommonBadgeList = function(self)
	local Badges = gPlayerManager.infoMinor.bindData.Badges
	local activeList = {}
	local inactiveList = {}

	for i = 0, LTConfig.UrbanBadgeConfig.count - 1 do
		local cfg = LTConfig.UrbanBadgeConfig.LoadAt(i)

		if cfg and not cfg.OnlyServer and cfg.Type ~= gUrbanAbilityManager.BADGE_TYPE.COMMON then
			local data = {
				id = cfg.Id,
				sort = cfg.Quality
			}

			if Badges[cfg.Id] and Badges[cfg.Id].Active then
				table.insert(activeList, data)
			elseif not cfg.HideWhenLocked then
				table.insert(inactiveList, data)
			end
		end
	end

	return self.SortAndMergeList(self, activeList, inactiveList)
end

M.GetSpiritBadgeList = function(self, curSpiritId)
	local spirit = gSpiritManager:GetSpirit(curSpiritId)

	if not spirit then
		return {}
	end

	local Badges = spirit.SpiritInfo.InfoBadge.Badges
	local activeList = {}
	local inactiveList = {}

	for i = 0, LTConfig.UrbanBadgeConfig.count - 1 do
		local cfg = LTConfig.UrbanBadgeConfig.LoadAt(i)

		if cfg and not cfg.OnlyServer and cfg.FightspiritId ~= gSpiritManager.DefaultFemale2DefaultMaleSpiritId(curSpiritId) and cfg.Type ~= gUrbanAbilityManager.BADGE_TYPE.FIGHT_SPIRIT then
			local data = {
				id = cfg.Id,
				sort = cfg.Quality
			}

			if Badges[cfg.Id] and Badges[cfg.Id].Active then
				table.insert(activeList, data)
			elseif not cfg.HideWhenLocked then
				table.insert(inactiveList, data)
			end
		end
	end

	return self.SortAndMergeList(self, activeList, inactiveList)
end

M.SortAndMergeList = function(self, activeList, inactiveList)
	table.sort(activeList, function (a, b)
		return b.sort <= a.sort
	end)
	table.sort(inactiveList, function (a, b)
		return b.sort <= a.sort
	end)

	local result = {}

	for _, v in ipairs(activeList) do
		table.insert(result, {
			id = v.id
		})
	end

	for _, v in ipairs(inactiveList) do
		table.insert(result, {
			id = v.id
		})
	end

	return result
end

M.BuildQualityList = function(self, qualityList, quality)
	local result = {}

	for i, v in pairs(quality) do
		if v <= 1 then
			table.insert(result, {
				quality = v,
				num = #qualityList[v]
			})
		end
	end

	return result
end

M.GetBadgesForType = function(self, badgeType)
	if badgeType ~= gUrbanAbilityManager.BADGE_TYPE.COMMON then
		return gPlayerManager.infoMinor.bindData.Badges
	elseif badgeType ~= gUrbanAbilityManager.BADGE_TYPE.FIGHT_SPIRIT then
		local curSpiritId = self.urbanAbilityStore:GetCurSpiritTid()
		local spirit = gSpiritManager:GetSpirit(curSpiritId)

		if spirit then
			return spirit.SpiritInfo.InfoBadge.Badges
		end
	end

	return {}
end

M.RenderTitleItem = function(self, btn, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadgeTitleTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.title

	store.badgeCountlist.onGetTIndex = function(_)
		return 0
	end

	store.badgeCountlist.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderBadgeCountItem", data.qualityList)

	store.badgeCountlist:SetSimpleList(#data.qualityList)
end

M.RenderBadgeListItem = function(self, btn, data)
	local storeGroup = gStoreManager:GetStoreGroup("UrbanAbilityBadgeListTemplate")

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

	if not store then
		return
	end

	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderInnerBadgeItem", data.badges)
	store.list.luaSimpleClick = self:CreateActionWithArgs("OnClickInnerBadgeItem", data.badges)

	store.list:SetSimpleList(#data.badges)
end

M.OnRenderInnerBadgeItem = function(self, badges, btn, index)
	local badgeData = badges[index + 1]

	if not badgeData then
		return
	end

	self.RenderBadgeItem(self, btn, badgeData)
end

M.OnClickInnerBadgeItem = function(self, badges, btn, index)
	local badgeData = badges[index + 1]

	if not badgeData then
		return
	end

	if self.lastSelectIndex ~= badgeData.id then
		btn.SetSelected(btn, false)

		self.lastSelectIndex = nil
		self.lastSelectBtn = nil

		return
	end

	if self.lastSelectBtn then
		self.lastSelectBtn:SetSelected(false)
	end

	btn.SetSelected(btn, true)

	self.lastSelectIndex = badgeData.id
	self.lastSelectBtn = btn
end

M.RenderBadgeItem = function(self, btn, data)
	local storeGroup = gStoreManager:GetStoreGroup("UrbanAbilityBadgeTemplateStore")

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

	if not store then
		return
	end

	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	local Badges = self:GetBadgesForType(cfg.Type)
	local serverData = Badges[data.id]
	store.name.text = cfg.Name

	store:Commit("guideId", cfg.GuideId, COMMIT_FORCE)

	store.isLock = serverData and serverData.Active and 1 or 0
	store.iconId = cfg.Image

	store:Commit("iconId", cfg.Image, COMMIT_FORCE)

	store.quality = cfg.Quality - 1
	local args = {
		cfg = cfg,
		serverData = serverData
	}
	store.button.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", args)
	store.button.luaTooltipPopup = self:CreateAction("OnTooltipPopup")

	if self.lastSelectIndex ~= data.id then
		btn.SetSelected(btn, true)

		self.lastSelectBtn = btn
	end
end

M.OnRenderBadgeCountItem = function(self, qualityList, btn, index)
	local store = gStoreManager:GetStoreGroup("UrbanBadgeCountTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = qualityList[index + 1]

	if not data then
		return
	end

	store.quality = data.quality - 1
	store.num = data.num
end

M.OnRenderToolTips = function(self, arg, btn, PopUp, index)
	local store = gStoreManager:GetStoreGroup("UrbanBadgeTooltipStore"):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	store.level = arg.cfg.Quality - 1
	store.title = arg.cfg.Name
	store.buff = arg.cfg.Description

	if arg.serverData and arg.serverData.Active then
		store.lockCtrl = 1
	else
		store.lockCtrl = 0
	end

	if arg.cfg.UnlockDescription then
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.UrbanBadge, arg.cfg.Id, 0)
		local unlockDescription = arg.cfg.UnlockDescription .. "(" .. progress .. "/" .. arg.cfg.MaxProgress .. ")"
		store.lock = unlockDescription
	end
end

M.OnTooltipPopup = function(self, btn, isPopup, index)
	self.isTooltipOpen = isPopup
end
