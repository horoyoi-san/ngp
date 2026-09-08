-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityBasicFeatureV2Store.lua
-- Decompiled from: 01193_UrbanAbilityBasicFeatureV2Store.lua_2d1bb78e0910.luajit

C_UrbanAbilityBasicFeatureV2Store = DefClass("C_UrbanAbilityBasicFeatureV2Store", C_UrbanAbilityBasicFeatureV2Store, C_StoreGroup)
GroupName2Class.UrbanAbilityBasicFeatureV2Store = C_UrbanAbilityBasicFeatureV2Store
local M = C_UrbanAbilityBasicFeatureV2Store

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityV2PanelStore")
	self.allList = {}
	self.spiritViewData = nil
	self.abilityType = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.SetFeatureData(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.ShowPanel = function(self, abilityType)
	self.abilityType = abilityType

	self.SetFeatureData(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_CHANGE_SPIRITVIEW_DATA] = self.CreateAction(self, "OnChangeSpiritViewData"),
		[gEventConstants.ON_SYNC_SPIRIT_ABILITYINFO] = self.CreateAction(self, "SetFeatureData")
	}
end

M.OnChangeSpiritViewData = function(self, eventId, data)
	if not data.data.alreadyJoin and not data.data.canJoin then
		return
	end

	self.spiritViewData = gSpiritManager:GetSpirit(data.data.id)

	self:SetFeatureData()
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnSimpleClickList")
end

M.OnClickCloseBtn = function(self)
	if gCommonItemManager.itemToolTipRefBtn then
		gCommonItemManager:CloseItemToolTips()

		return
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_Vx_UrbanAbilityBasicFeaturePanel_close")
	Timer.New(function ()
		self.urbanAbilityStore:CloseCurrentTab()
	end, 0.2):Start()
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.allList[index + 1]

	if not data then
		return
	end

	self.RenderFeatureItem(self, btn, data, index)
end

M.OnSimpleClickList = function(self, btn, index)
	local data = self.allList[index + 1]

	if not data then
		return
	end
end

M.SetFeatureData = function(self)
	self.allList = {}

	if self.abilityType then
		local typeCfg = LTConfig.UrbanAbilityUrbanAbilityTypeConfig.GetConfig(self.abilityType)
		self.bindData.title.text = LTConfig.TextScriptTextConfig.GetConfig(89901570).Text:format(typeCfg.Name)
	end

	self.spiritViewData = gSpiritManager:GetSpirit(self.urbanAbilityStore:GetCurSpiritTid())

	if not self.spiritViewData then
		self.bindData.list:SetSimpleList(0)

		return
	end

	local spiritAbilities = self.spiritViewData.SpiritInfo.SpiritAbilities

	for _, abilityData in pairs(spiritAbilities) do
		local cfg = LTConfig.UrbanAbilityConfig.GetConfig(abilityData.TemplateId)

		if cfg and cfg.AbilityType ~= self.abilityType then
			local info = {
				id = abilityData.TemplateId,
				abilityData = abilityData,
				cfg = cfg,
				title = cfg.Name,
				icon = cfg.Icon,
				bg = cfg.Texture,
				itemToolTipData = gCommonItemManager:GetItemRenderData(cfg.ConsumableId)
			}
			local maxExp = gUrbanAbilityManager:GetAbilityInfoMaxExp(abilityData.TemplateId)
			local curExp = abilityData.Exp

			if maxExp <= 0 then
				info.progress = curExp .. "/" .. maxExp
				info.progressValue = curExp / maxExp
				info.serialNum = gUrbanAbilityManager:GetAbilityInterval(curExp / maxExp)
			else
				info.progress = "0/0"
				info.progressValue = 0
				info.serialNum = ""
			end

			info.buff = ""
			info.iconItems = {}

			if cfg.IncreaseIconList then
				for _, iconId in pairs(cfg.IncreaseIconList) do
					table.insert(info.iconItems, {
						IconId = iconId
					})
				end
			end

			info.contentItems = {}
			local buffId = cfg.InitBuffId

			if buffId and cfg.MaxLevel then
				local nextLockSet = false

				for level = 1, cfg.MaxLevel do
					local buffCfg = LTConfig.UrbanAbilityBuffConfig.GetConfig(buffId + level - 1)

					if buffCfg then
						local isLock = abilityData.Level <= level
						local titleContent = level

						if isLock then
							local lockExp = self:GetExpByLevel(cfg.Id, level)
							titleContent = LTConfig.UrbanAbilityConfig.AbilityProficiencyNeed:format(lockExp)
						end

						local isNextLock = false

						if isLock and not nextLockSet then
							isNextLock = true
							nextLockSet = true
						end

						table.insert(info.contentItems, {
							titleContent = titleContent,
							buff = buffCfg.BuffExplain,
							progressValue = info.progressValue,
							tIndex = isLock and 1 or 0,
							isNextLock = isNextLock
						})
					end
				end
			end

			table.insert(self.allList, info)
		end
	end

	table.sort(self.allList, function (a, b)
		return a.id <= b.id
	end)
	self.bindData.list:SetSimpleList(#self.allList)
end

M.RenderFeatureItem = function(self, btn, data, index)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBasicFeatureTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.title or ""
	store.progressLabel = data.progress or ""
	store.progress = data.progressValue or 0
	store.serialNum = data.serialNum or ""

	store:Commit("guideId", data.cfg.GuideId, COMMIT_FORCE)
	store:Commit("icon", data.icon, COMMIT_FORCE)
	store:Commit("bg", data.bg, COMMIT_FORCE)

	if data.iconItems then
		store.iconList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderIconItem", data.iconItems)

		store.iconList:SetSimpleList(#data.iconItems)

		store.iconListBtn.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderIconListTooltip, index)
	end

	if data.contentItems then
		store.contentList.onGetTIndex = self:CreateActionWithArgs("OnGetContentListTIndex", data.contentItems)
		store.contentList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderContentItem", data.contentItems)
		store.contentList.luaSimpleDynamicRenderItem = self:CreateActionWithArgs("OnRenderContentItem", data.contentItems)

		store.contentList:SetSimpleList(#data.contentItems)
	end
end

M.OnRenderIconListTooltip = function(self, featureIndex, btn, popup, index)
	local data = self.allList[featureIndex + 1]

	if not data then
		return
	end

	gCommonItemManager:OnRenderToolTips(data.itemToolTipData, btn, popup, index)
end

M.OnRenderIconItem = function(self, iconItems, btn, index)
	local itemData = iconItems[index + 1]

	if not itemData then
		return
	end

	local store = gStoreManager:GetStoreGroup("FeatureSourceIconStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.icon = itemData.IconId
end

M.OnGetContentListTIndex = function(self, contentItems, index)
	local data = contentItems[index + 1]

	if data then
		return data.tIndex
	end

	return 0
end

M.OnRenderContentItem = function(self, contentItems, btn, index)
	local data = contentItems[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("UrbanAbilityBasicFeatureContentTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.titleContent or ""
	store.endCtrl = index == #contentItems - 1 and 0 or 1
	store.nextCtrl = data.isNextLock and 1 or 0

	store:Commit("buff", data.buff, COMMIT_IMMEDIATELY)
end

M.GetExpByLevel = function(self, abilityId, level)
	local cfg = LTConfig.UrbanAbilityLevelUpExpConfig.GetConfig(abilityId)

	if cfg then
		local sumExp = 0
		local index = 1

		while level <= index do
			sumExp = sumExp + cfg["Exp" .. index]
			index = index + 1
		end

		return sumExp
	end

	return 0
end
