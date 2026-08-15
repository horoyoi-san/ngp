C_BigMapTooltip_GangsterRandomEvent = DefClass("C_BigMapTooltip_GangsterRandomEvent", C_BigMapTooltip_GangsterRandomEvent, C_BigMapTooltipBase)
local M = C_BigMapTooltip_GangsterRandomEvent
local InfluenceEventConfig = LTConfig.FactionInfluenceEventConfig
local FactionConfig = LTConfig.FactionConfig

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("gangsterRandomEventInfo") then
		return
	end

	self:GetStore("MapGangsterNormalFightTooltipStore")
	self:SetUpLocation()

	local info = self.tooltipInfo.gangsterRandomEventInfo
	local gangsterCfg = FactionConfig.GetConfig(info.gangsterId)
	local influenceCfg = InfluenceEventConfig.GetConfig(info.influenceId)

	self:SetUpHeaderWithParams(influenceCfg.TooltipHeaderId, nil, gangsterCfg.name)

	self.danger = influenceCfg.EventIntensity
	self.store.dangerList.onGetTIndex = self.bigMap:CreateAction("OnGetDangerStarTIndex", self)

	self.store.dangerList:SetSimpleList(5)

	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterNormalFightScrollStore"):GetStoreByWidget(self.store.scroll.content)
	self._showBuffDetail = false
	self.store.showBuffDetail = 0
	self.store.influenceDetailList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderBuffDetailItem", self)

	self:SetUpScroll(scrollStore, info, influenceCfg)
end

function M:SetUpScroll(scrollStore, info, influenceCfg)
	gWeaponManager:InitRenderList(scrollStore.weaponList)

	local weaponDatas = {}

	for i = 1, #influenceCfg.RecommendedWeapons do
		local weaponId = influenceCfg.RecommendedWeapons[i]
		local weaponCfg = LTConfig.WeaponConfig.GetConfig(weaponId)

		if weaponCfg then
			table.insert(weaponDatas, {
				itemId = weaponId
			})
		end
	end

	self.cachedWeaponDatas = weaponDatas

	scrollStore.weaponList:SetList(self.cachedWeaponDatas)

	self.eventGivenDatas = {}

	for i = 1, #influenceCfg.EventBuffExplanation do
		table.insert(self.eventGivenDatas, influenceCfg.EventBuffExplanation[i])
	end

	scrollStore.influenceList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderInfluenceItem", self)
	scrollStore.influenceList.luaSimpleDynamicRenderItem = self.bigMap:CreateAction("OnRenderInfluenceItem", self)

	scrollStore.influenceList:SetSimpleList(#self.eventGivenDatas)

	scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)
	scrollStore.clickShowWeapons = self.bigMap:CreateAction("OnClickShowWeapon", self)
	scrollStore.clickShowBuffs = self.bigMap:CreateAction("OnGamePadClickBuff", self)

	self.store.influenceDetailList:SetSimpleList(#self.eventGivenDatas)
end

function M:OnGetDangerStarTIndex(index)
	index = index + 1

	return index <= self.danger and 0 or 1
end

function M:OnRenderInfluenceItem(btn, index)
	index = index + 1
	local data = self.eventGivenDatas[index]
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)
	store.content = data.Explanation
	store.iconId = data.IconId
	btn.luaRenderTooltip = self.bigMap:CreateAction("OnRenderPopupBuffDetailItem", self)
end

function M:OnRenderPopupBuffDetailItem(btn, comp, index)
	if index == 0 then
		local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(comp)
		store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderBuffDetailItem", self)

		store.list:SetSimpleList(#self.eventGivenDatas)
	end
end

function M:OnRenderBuffDetailItem(btn, index)
	index = index + 1
	local data = self.eventGivenDatas[index]
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)
	store.content = data.Explanation
	store.iconId = data.IconId
end

function M:OnClickShowReward()
	local info = self.tooltipInfo.gangsterRandomEventInfo
	local influenceCfg = InfluenceEventConfig.GetConfig(info.influenceId)
	local dropIds = gMapSubSystemUtils:GetDropIdListByTaskLineId(influenceCfg.RelatedEventId)

	self:ShowGamePadItemPanelWithIds(dropIds)
end

function M:OnClickShowWeapon()
	if self.cachedWeaponDatas and #self.cachedWeaponDatas > 0 then
		gCommonItemManager:OnShowItemList(self.cachedWeaponDatas, 0)
	end
end

function M:OnGamePadClickBuff()
	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterNormalFightScrollStore"):GetStoreByWidget(self.store.scroll.content)

	if not scrollStore.influenceList then
		return
	end

	if #self.eventGivenDatas > 0 then
		local openedPop = false
		local btns = scrollStore.influenceList.items
		local btnTable = btns:ToTable()

		if #btnTable > 0 then
			for i = 1, #btnTable do
				local btn = btnTable[i]

				if btn.isTooltipOpen then
					openedPop = true

					btn:CloseTooltip()
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
