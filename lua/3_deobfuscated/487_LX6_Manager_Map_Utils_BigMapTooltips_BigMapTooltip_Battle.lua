C_BigMapTooltip_Battle = DefClass("C_BigMapTooltip_Battle", C_BigMapTooltip_Battle, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Battle
local DANGEROUS = 1
local SAFE = 0
local NORMAL_TRI = 0
local GREY_TRI = 1

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("battleInfo") then
		return
	end

	self:GetStore("MapBattleTooltipStore")
	self:SetUpHeader()
	self:SetUpLocation()

	local info = self.tooltipInfo.battleInfo
	local combatPower = self:GetCurrentBattlePara()
	local threshold = LTConfig.CollectionConfig.DangerousBattleThreshold
	local danger = threshold < info.difficulty - combatPower
	self.store.warning = danger and DANGEROUS or SAFE
	local difficultyIndices = {}

	for i = 1, info.difficulty do
		table.insert(difficultyIndices, {
			tIndex = NORMAL_TRI,
			color = danger and DANGEROUS or SAFE
		})
	end

	for i = info.difficulty + 1, 5 do
		table.insert(difficultyIndices, {
			tIndex = GREY_TRI
		})
	end

	function self.store.difficultyList.luaSimpleRenderItem(btn, index)
		self:OnRenderDifficultyItem(btn, index, difficultyIndices[index + 1])
	end

	self.store.difficultyList:SetSimpleList(#difficultyIndices)

	local scrollStore = gStoreManager:GetStoreGroup("MapBattleScrollStore"):GetStoreByWidget(self.store.battleScroll.content)

	if info.abilityIds and #info.abilityIds > 0 then
		self.store.addAbility = 1

		self:SetUpAbilityList(self.store.abilityList, info.abilityIds)
	else
		self.store.hasAbility = 0
	end

	self.store.battleScroll:GoToPos(Vector2.zero, true)
	self:SetUpScroll(scrollStore, info)
end

function M:SetUpScroll(scrollStore, info)
	scrollStore.desc = info.desc or ""

	self:SetUpDropsWithId(info.dropId, scrollStore.rewardList)
	gWeaponManager:InitRenderList(scrollStore.weaponList)

	local weaponDatas = {}

	for i = 1, #info.recommendWeapons do
		local weaponId = info.recommendWeapons[i]
		local weaponCfg = LTConfig.WeaponConfig.GetConfig(weaponId)

		if weaponCfg then
			table.insert(weaponDatas, {
				itemId = weaponId
			})
		end
	end

	self.cachedWeaponDatas = weaponDatas

	scrollStore.weaponList:SetList(weaponDatas)

	scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)
	scrollStore.clickShowWeapons = self.bigMap:CreateAction("OnClickShowWeapon", self)
end

function M:OnRenderDifficultyItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)

	if store then
		if data.tIndex == NORMAL_TRI then
			store.color = data.color
		else
			store.color = SAFE
		end
	end
end

function M:GetCurrentBattlePara()
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local spiritInfo = gSpiritManager:GetSpirit(spiritId)

	if not spiritInfo then
		return 0
	end

	local badges = spiritInfo.SpiritInfo.InfoBadge.Badges

	if table.isNilOrEmpty(badges) then
		return 0
	end

	local total = 0

	for i, v in pairs(badges) do
		if not v.Active then
			-- Nothing
		else
			local cfg = LTConfig.UrbanBadgeConfig.GetConfig(i)

			if cfg and cfg.BattlePara and cfg.BattlePara > 0 then
				total = total + cfg.BattlePara
			end
		end
	end

	return total
end

function M:OnClickShowReward()
	local info = self.tooltipInfo.battleInfo

	self:ShowGamePadItemPanelWithId(info.dropId)
end

function M:OnClickShowWeapon()
	if self.cachedWeaponDatas and #self.cachedWeaponDatas > 0 then
		gCommonItemManager:OnShowItemList(self.cachedWeaponDatas, 0)
	end
end
