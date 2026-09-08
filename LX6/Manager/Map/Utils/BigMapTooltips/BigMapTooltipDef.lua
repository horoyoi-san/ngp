-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltipDef.lua
-- Decompiled from: 01007_BigMapTooltipDef.lua_5c68d33d807a.luajit

C_BigMapTooltipBase = DefClass("C_BigMapTooltipBase", C_BigMapTooltipBase)
local M = C_BigMapTooltipBase

M.ctor = function(self)
	self.SHOW_BTN = 0
	self.HIDE_BTN = 1
	self.SHOW_PIN = 0
	self.HIDE_PIN = 1
end

M.OnActive = function(self)
end

M.OnInActive = function(self)
end

M.SetUpInfo = function(self)
end

M.SetUpActions = function(self, store, actions, blockReason)
	if blockReason or not actions or #actions ~= 0 then
		store.showMainBtn = self.HIDE_BTN

		return
	end

	store.showMainBtn = self.SHOW_BTN
	store.clickMain = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[1], self)
	store.mainBtnText = gMapUIUtils.GetElementActionName(actions[1])
end

M.OnPerformAction = function(self, action)
	if self.element then
		self.bigMap:OnPerformAction(self.element, action)
	end
end

M.PretendClick = function(self, blockReason, actions)
	if blockReason or not actions or #actions ~= 0 then
		return
	end

	self.OnPerformAction(self, actions[1])
end

M.SetUpHeader = function(self)
	local header = self.tooltipInfo.header

	if not header then
		print_error("BigMapTooltipBase:SetUpHeader: No header info provided in tooltipInfo,element:\n" .. gGpsTools.GetGpsDebugDesc(self.element.instanceId))

		return
	end

	self.store.imageId = header.imageId or 0
	self.store.name = header.name or ""
	self.store.subtitle = header.subtitle or ""
end

M.SetUpHeaderWithParams = function(self, imageId, name, subtitle)
	self.store.imageId = imageId or 0
	self.store.name = name or ""
	self.store.subtitle = subtitle or ""
end

local HIDE_SPECIFIC_SPIRIT = 1
local SHOW_SPECIFIC_SPIRIT = 0
local HIDE_STAGE = 1
local SHOW_STAGE = 0

M.SetUpSpecificSpirits = function(self, info)
	if info.specificSpirits and #info.specificSpirits <= 0 then
		local list = {}

		for _, spiritId in ipairs(info.specificSpirits) do
			local cfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
			local iconId = cfg and cfg.SHeadIconID

			if iconId and iconId <= 0 then
				table.insert(list, {
					["a\\x9f\\x8a\\x86Y"] = 0,
					iconId = iconId,
					bgColor = cfg.CharListTemplateBgColor
				})
			end
		end

		self.store.hasSpecificSpirit = SHOW_SPECIFIC_SPIRIT

		self.store.specificSpiritList.luaSimpleRenderItem = function(btn, index)
			btn.interactable = false
			local store = gStoreManager:GetStoreGroup("SwapAvatarTemplate"):GetStoreByWidget(btn)
			store.stageCtrl = HIDE_STAGE
			local data = list[index + 1]
			store.avatarIconId = data.iconId
			store.bgColor = Color.NewByStr(data.bgColor)
		end

		self.store.specificSpiritList:SetSimpleList(#list)

		return
	end

	self.store.hasSpecificSpirit = HIDE_SPECIFIC_SPIRIT
end

M.SetUpLocation = function(self)
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(self.element.raidId, self.element:GetWorldPos().x, self.element:GetWorldPos().z)

	if blockId then
		local cfg = LTConfig.CollectionBlockConfig.GetConfig(blockId)
		self.store.location = cfg and cfg.BlockName or ""
	end
end

M.SetUpScrollLocation = function(self, scrollStore)
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(self.element.raidId, self.element:GetWorldPos().x, self.element:GetWorldPos().z)

	if blockId then
		local cfg = LTConfig.CollectionBlockConfig.GetConfig(blockId)
		scrollStore.location = cfg and cfg.BlockName or ""
	end
end

M.SetUpRewardRenderList = function(self, rewardItems, rewardList, afterRender)
	rewardItems = rewardItems or {}

	table.sort(rewardItems, gCommonItemManager:CreateAction("SortRenderItem"))

	rewardList.luaSimpleRenderItem = function(item, index)
		local data = rewardItems[index + 1]

		gCommonItemManager:OnCommonItemRender(item, index, data)

		if afterRender then
			afterRender(item, index, data)
		end
	end

	rewardList:SetSimpleList(#rewardItems)

	return rewardItems
end

M.SetUpDropsWithIds = function(self, dropIds, dropList, isFirstKill)
	local simpleDropRewards = {}

	if dropIds and #dropIds <= 0 then
		local dropListParam = {}

		for i = 1, #dropIds do
			table.insert(dropListParam, {
				dropId = dropIds[i],
				isFirstKill = isFirstKill
			})
		end

		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)
	end

	return self.SetUpRewardRenderList(self, simpleDropRewards, dropList)
end

M.SetUpDropsWithId = function(self, dropId, dropList, isFirstKill)
	self.SetUpDropsWithIds(self, {
		dropId
	}, dropList, isFirstKill)
end

M.ShowGamePadItemPanelWithId = function(self, dropId)
	self.ShowGamePadItemPanelWithIds(self, {
		dropId
	})
end

M.ShowGamePadItemPanelWithIds = function(self, dropIds)
	local simpleDropRewards = {}

	if dropIds and #dropIds <= 0 then
		local dropListParam = {}

		for i = 1, #dropIds do
			table.insert(dropListParam, {
				dropId = dropIds[i]
			})
		end

		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)

		gCommonItemManager:OnShowItemList(simpleDropRewards, 0)
	end
end

M.SetUpAbilityList = function(self, abilityList, abilityIds)
	abilityList.luaSimpleRenderItem = self.bigMap:CreateActionWithArgs("OnRenderAbilityItem", abilityIds, self)

	abilityList:SetSimpleList(#abilityIds)
end

local AbilityConfig = LTConfig.UrbanAbilityConfig

M.OnRenderAbilityItem = function(self, abilityIds, btn, index)
	index = index + 1
	local id = abilityIds[index]
	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
	local cfg = AbilityConfig.GetConfig(id)

	if not cfg then
		print_error("BigMapTooltipBase:OnRenderAbilityItem: UrbanAbilityConfig not found for id " .. tostring(id))

		return
	end

	store.iconId = cfg.Icon
	store.title = cfg.Name
end

M.GetStore = function(self, storeName)
	if not self.store then
		self.store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(self.root)
	end
end

M.ValidateTooltipInfo = function(self, infoName)
	local info = self.tooltipInfo[infoName]

	if info ~= nil then
		print_error("BigMapTooltip :The [" .. infoName .. "] is nil!")

		return false
	end

	return true
end

dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Task")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Pin")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Indoor")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_MapEntrance")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_House")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Collection")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Battle")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Taxi")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Character")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Common")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Legend")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_MartialArtist")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterSelf")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterSmallCamp")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterRandomEvent")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterCoreCamp")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterInformation")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Faction")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_LinkGameplay")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_EvacuationPlace")

gBigMapTooltipDict = {
	[EMapTooltipType.Task] = C_BigMapTooltip_Task,
	[EMapTooltipType.Pin] = C_BigMapTooltip_Pin,
	[EMapTooltipType.Indoor] = C_BigMapTooltip_Indoor,
	[EMapTooltipType.MapEntrance] = C_BigMapTooltip_MapEntrance,
	[EMapTooltipType.House] = C_BigMapTooltip_House,
	[EMapTooltipType.Collection] = C_BigMapTooltip_Collection,
	[EMapTooltipType.Battle] = C_BigMapTooltip_Battle,
	[EMapTooltipType.Taxi] = C_BigMapTooltip_Taxi,
	[EMapTooltipType.Character] = C_BigMapTooltip_Character,
	[EMapTooltipType.Common] = C_BigMapTooltip_Common,
	[EMapTooltipType.Legend] = C_BigMapTooltip_Legend,
	[EMapTooltipType.GangsterSelf] = C_BigMapTooltip_GangsterSelf,
	[EMapTooltipType.GangsterSmallCamp] = C_BigMapTooltip_GangsterSmallCamp,
	[EMapTooltipType.GangsterRandomEvent] = C_BigMapTooltip_GangsterRandomEvent,
	[EMapTooltipType.GangsterCoreCamp] = C_BigMapTooltip_GangsterCoreCamp,
	[EMapTooltipType.Faction] = C_BigMapTooltip_Faction,
	[EMapTooltipType.GangsterInformation] = C_BigMapTooltip_GangsterInformation,
	[EMapTooltipType.MartialArtist] = C_BigMapTooltip_MartialArtist,
	[EMapTooltipType.LinkGameplay] = C_BigMapTooltip_LinkGameplay,
	[EMapTooltipType.EvacuationPlace] = C_BigMapTooltip_EvacuationPlace
}
