-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\Gangster\BigMapTooltip_GangsterCoreCamp.lua
-- Decompiled from: 01023_BigMapTooltip_GangsterCoreCamp.lua_4ab8bde75af1.luajit

C_BigMapTooltip_GangsterCoreCamp = DefClass("C_BigMapTooltip_GangsterCoreCamp", C_BigMapTooltip_GangsterCoreCamp, C_BigMapTooltipBase)
local M = C_BigMapTooltip_GangsterCoreCamp
local FactionConfig = LTConfig.FactionConfig
local InfluenceEventConfig = LTConfig.FactionInfluenceEventConfig
local DropConfig = LTConfig.DropConfig

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "gangsterCoreCampInfo") then
		return
	end

	self:GetStore("MapGangsterCoreCampTooltipStore")
	self:SetUpLocation()

	local info = self.tooltipInfo.gangsterCoreCampInfo
	local gangsterCfg = FactionConfig.GetConfig(info.gangsterId)
	local influenceCfg = InfluenceEventConfig.GetConfig(info.influenceId)

	self:SetUpHeaderWithParams(influenceCfg.TooltipHeaderId, nil, gangsterCfg.name)

	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterCoreCampScrollStore"):GetStoreByWidget(self.store.scroll.content)
	self.danger = influenceCfg.EventIntensity
	self.store.dangerList.onGetTIndex = self.bigMap:CreateAction("OnGetDangerStarTIndex", self)

	self.store.dangerList:SetSimpleList(5)

	self._showBuffDetail = false
	self.store.showBuffDetail = 0
	self.store.influenceDetailList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderBuffDetailItem", self)

	self:SetUpScroll(scrollStore, info, influenceCfg, gangsterCfg)
end

M.OnSimpleRenderWeaponListItem = function(self, btn, index)
	local data = self.cachedWeaponDatas[index + 1] or {}

	gWeaponManager:OnCommonItemRender(btn, index, data)
end

M.SetUpScroll = function(self, scrollStore, info, influenceCfg, gangsterCfg)
	scrollStore.desc = gangsterCfg.FactionDescription
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

	self.eventGivenDatas = {}
	local influence = gMapSubSystem_Gangster:GetGangsterInfluence(info.gangsterId)

	for i = 1, #influenceCfg.CampBuffExplanation do
		local shreshold = influenceCfg.CampBuffExplanation[i].Shreshold

		if shreshold < influence then
			table.insert(self.eventGivenDatas, influenceCfg.CampBuffExplanation[i])
		end
	end

	scrollStore.influenceList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderInfluenceItem", self)
	scrollStore.influenceList.luaSimpleDynamicRenderItem = self.bigMap:CreateAction("OnRenderInfluenceItem", self)

	scrollStore.influenceList:SetSimpleList(#self.eventGivenDatas)

	local factionInfluenceInfo = DropConfig.GetConfig(influenceCfg.DropDisplay).FactionInfluenceInfo
	local influenceNum = factionInfluenceInfo and factionInfluenceInfo[1].Influence or 0
	self.store.influenceText = string.format("%d%%", influenceNum)
	scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)
	scrollStore.clickShowWeapons = self.bigMap:CreateAction("OnClickShowWeapon", self)
	scrollStore.clickShowBuffs = self.bigMap:CreateAction("OnGamePadClickBuff", self)

	self.store.influenceDetailList:SetSimpleList(#self.eventGivenDatas)

	scrollStore.showList = #self.eventGivenDatas <= 0 and 1 or 0

	self:SetUpDropsWithId(influenceCfg.Drop, scrollStore.rewardList)
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
	store.isConquered = data.conquered and 1 or 0
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
	local info = self.tooltipInfo.gangsterCoreCampInfo
	local influenceCfg = InfluenceEventConfig.GetConfig(info.influenceId)

	self.ShowGamePadItemPanelWithId(self, influenceCfg.Drop)
end

M.OnClickShowWeapon = function(self)
	if self.cachedWeaponDatas and #self.cachedWeaponDatas <= 0 then
		gCommonItemManager:OnShowItemList(self.cachedWeaponDatas, 0)
	end
end

M.OnGamePadClickBuff = function(self)
	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterCoreCampScrollStore"):GetStoreByWidget(self.store.scroll.content)

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
