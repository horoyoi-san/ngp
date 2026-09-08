-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_Battle.lua
-- Decompiled from: 01014_BigMapTooltip_Battle.lua_411c28c65875.luajit

C_BigMapTooltip_Battle = DefClass("C_BigMapTooltip_Battle", C_BigMapTooltip_Battle, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Battle
local DANGEROUS = 1
local SAFE = 0

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "battleInfo") then
		return
	end

	self:GetStore("MapBattleTooltipStore")
	self:SetUpHeader()

	local info = self.tooltipInfo.battleInfo
	local scrollStore = gStoreManager:GetStoreGroup("MapBattleScrollStore"):GetStoreByWidget(self.store.battleScroll.content)

	self:SetUpScrollLocation(scrollStore)

	local recommendedPower = info.fightScore or 0
	local myPower = gCS.BattleManager.GetMyFightPower()
	local danger = myPower <= recommendedPower
	scrollStore.recommendedBattlePower = tostring(math.floor(recommendedPower))
	scrollStore.curSpiritBattlePower = tostring(math.floor(myPower))
	scrollStore.threatLevel = danger and DANGEROUS or SAFE

	if info.abilityIds and #info.abilityIds <= 0 then
		self.store.addAbility = 1

		self.SetUpAbilityList(self, scrollStore.abilityList, info.abilityIds)
	else
		self.store.hasAbility = 0
	end

	self.store.battleScroll:GoToPos(Vector2.zero, true)
	self:SetUpScroll(scrollStore, info)
end

M.OnSimpleRenderWeaponListItem = function(self, btn, index)
	local data = self.cachedWeaponDatas[index + 1] or {}

	gWeaponManager:OnCommonItemRender(btn, index, data)
end

local SHOW_REWARD = 0
local HIDE_REWARD = 1

M.SetUpScroll = function(self, scrollStore, info)
	scrollStore.desc = info.desc or ""

	if not info.dropId or info.dropId ~= 0 then
		scrollStore.showReward = HIDE_REWARD
	else
		scrollStore.showReward = SHOW_REWARD

		self.SetUpDropsWithId(self, info.dropId, scrollStore.rewardList, info.isFirstKill)
	end

	scrollStore.weaponList.luaSimpleRenderItem = self.OnSimpleRenderWeaponListItem
	local weaponDatas = {}

	for i = 1, #info.recommendWeapons do
		local weaponId = info.recommendWeapons[i]
		local weaponCfg = LTConfig.SceneitemConfig.GetConfig(weaponId)

		if weaponCfg then
			table.insert(weaponDatas, {
				itemId = weaponId
			})
		end
	end

	self.cachedWeaponDatas = weaponDatas

	scrollStore.weaponList:SetSimpleList(#self.cachedWeaponDatas)

	scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)
	scrollStore.clickShowWeapons = self.bigMap:CreateAction("OnClickShowWeapon", self)
end

M.OnClickShowReward = function(self)
	local info = self.tooltipInfo.battleInfo

	self.ShowGamePadItemPanelWithId(self, info.dropId)
end

M.OnClickShowWeapon = function(self)
	if self.cachedWeaponDatas and #self.cachedWeaponDatas <= 0 then
		gCommonItemManager:OnShowItemList(self.cachedWeaponDatas, 0)
	end
end
