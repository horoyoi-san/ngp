-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\Gangster\BigMapTooltip_GangsterRandomEvent.lua
-- Decompiled from: 01022_BigMapTooltip_GangsterRandomEvent.lua_dfb7989b5b02.luajit

C_BigMapTooltip_GangsterRandomEvent = DefClass("C_BigMapTooltip_GangsterRandomEvent", C_BigMapTooltip_GangsterRandomEvent, C_BigMapTooltipBase)
local M = C_BigMapTooltip_GangsterRandomEvent
local InfluenceEventConfig = LTConfig.FactionInfluenceEventConfig
local FactionConfig = LTConfig.FactionConfig
local DropConfig = LTConfig.DropConfig

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "gangsterRandomEventInfo") then
		return
	end

	self:GetStore("MapGangsterNormalFightTooltipStore")
	self:SetUpLocation()

	local info = self.tooltipInfo.gangsterRandomEventInfo
	local ownerGangsterId = gMapSubSystem_Gangster:GetCurrentInfluenceEventGangsterId(info.influenceId)

	if not ownerGangsterId then
		print_warn("BigMapTooltip_GangsterRandomEvent: current faction not found, influenceId=" .. tostring(info.influenceId))

		return
	end

	local ownerGangsterCfg = FactionConfig.GetConfig(ownerGangsterId)
	local configuredGangsterId = gMapSubSystem_Gangster:GetConfiguredInfluenceEventGangsterId(info.influenceId)
	local influenceCfg = InfluenceEventConfig.GetConfig(info.influenceId)
	local headerCfg = gMapSubSystem_Gangster:GetCurrentInfluenceEventDisplayConfig(info.influenceId, ownerGangsterId)

	if not ownerGangsterCfg or not configuredGangsterId or not influenceCfg or not headerCfg then
		return
	end

	self:SetUpHeaderWithParams(headerCfg.TooltipHeaderId, nil, ownerGangsterCfg.name)

	self.danger = influenceCfg.EventIntensity
	self.store.dangerList.onGetTIndex = self.bigMap:CreateAction("OnGetDangerStarTIndex", self)

	self.store.dangerList:SetSimpleList(5)

	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterNormalFightTooltipStore"):GetStoreByWidget(self.store.scroll.content)
	self._showBuffDetail = false
	self.store.showBuffDetail = 0
	self.store.influenceDetailList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderBuffDetailItem", self)

	self:SetUpScroll(scrollStore, configuredGangsterId, influenceCfg)
end

M.OnSimpleRenderWeaponListItem = function(self, btn, index)
	local data = self.cachedWeaponDatas[index + 1] or {}

	gWeaponManager:OnCommonItemRender(btn, index, data)
end

M.SetUpScroll = function(self, scrollStore, configuredGangsterId, influenceCfg)
	scrollStore.weaponList.luaSimpleRenderItem = self.bigMap:CreateAction("OnSimpleRenderWeaponListItem", self)
	local weaponDatas = {}

	for i = 1, #influenceCfg.RecommendedWeapons do
		local weaponId = influenceCfg.RecommendedWeapons[i]
		local weaponCfg = LTConfig.SceneitemConfig.GetConfig(weaponId)

		if weaponCfg then
			table.insert(weaponDatas, {
				itemId = weaponId
			})
		end
	end

	self.cachedWeaponDatas = weaponDatas

	scrollStore.weaponList:SetSimpleList(#self.cachedWeaponDatas)
	self:SetUpDropsWithId(influenceCfg.Drop, scrollStore.rewardList)

	self.eventGivenDatas = {}
	local influence = gMapSubSystem_Gangster:GetGangsterInfluence(configuredGangsterId)

	for i = 1, #influenceCfg.CampBuffExplanation do
		local shreshold = influenceCfg.CampBuffExplanation[i].Shreshold

		if shreshold < influence then
			table.insert(self.eventGivenDatas, influenceCfg.CampBuffExplanation[i])
		end
	end

	local factionInfluenceInfo = DropConfig.GetConfig(influenceCfg.DropDisplay).FactionInfluenceInfo
	local influenceNum = factionInfluenceInfo and factionInfluenceInfo[1].Influence or 0
	scrollStore.influenceText = string.format("%d%%", influenceNum)
	scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)
	scrollStore.clickShowWeapons = self.bigMap:CreateAction("OnClickShowWeapon", self)
	scrollStore.clickShowBuffs = self.bigMap:CreateAction("OnGamePadClickBuff", self)

	self.store.influenceDetailList:SetSimpleList(#self.eventGivenDatas)
end

M.OnGetDangerStarTIndex = function(self, index)
	index = index + 1

	return index < self.danger and 0 or 1
end

M.OnRenderInfluenceItem = function(self, btn, index)
	index = index + 1
	local data = self.eventGivenDatas[index]
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)
	store.content = data.Explanation
	store.iconId = data.IconId
	btn.luaRenderTooltip = self.bigMap:CreateAction("OnRenderPopupBuffDetailItem", self)
end

M.OnRenderPopupBuffDetailItem = function(self, btn, comp, index)
	if index ~= 0 then
		local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(comp)
		store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderBuffDetailItem", self)

		store.list:SetSimpleList(#self.eventGivenDatas)
	end
end

M.OnRenderBuffDetailItem = function(self, btn, index)
	index = index + 1
	local data = self.eventGivenDatas[index]
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)
	store.content = data.Explanation
	store.iconId = data.IconId
end

M.OnClickShowReward = function(self)
	local info = self.tooltipInfo.gangsterRandomEventInfo
	local influenceCfg = InfluenceEventConfig.GetConfig(info.influenceId)

	self.ShowGamePadItemPanelWithId(self, influenceCfg.Drop)
end

M.OnClickShowWeapon = function(self)
	if self.cachedWeaponDatas and #self.cachedWeaponDatas <= 0 then
		gCommonItemManager:OnShowItemList(self.cachedWeaponDatas, 0)
	end
end

M.OnGamePadClickBuff = function(self)
	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterNormalFightScrollStore"):GetStoreByWidget(self.store.scroll.content)

	if not scrollStore.influenceList then
		return
	end

	if #self.eventGivenDatas <= 0 then
		local openedPop = false
		local btns = scrollStore.influenceList.items
		local btnTable = btns.ToTable(btns)

		if #btnTable <= 0 then
			for i = 1, #btnTable do
				local btn = btnTable[i]

				if btn.isTooltipOpen then
					openedPop = true

					btn.CloseTooltip(btn)
				end
			end

			if not openedPop then
				btnTable[1]:OpenTooltip()
			end
		end
	else
		scrollStore.influenceList:TryCloseToolTip(true)
	end
end
