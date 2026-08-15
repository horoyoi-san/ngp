C_BigMapTooltipBase = DefClass("C_BigMapTooltipBase", C_BigMapTooltipBase)
local M = C_BigMapTooltipBase

function M:ctor()
	self.SHOW_BTN = 0
	self.HIDE_BTN = 1
	self.SHOW_PIN = 0
	self.HIDE_PIN = 1
end

function M:OnActive()
	return
end

function M:OnInActive()
	return
end

function M:SetUpInfo()
	return
end

function M:SetUpActions(store, actions, blockReason)
	if blockReason or not actions or #actions == 0 then
		store.showMainBtn = self.HIDE_BTN

		return
	end

	store.showMainBtn = self.SHOW_BTN
	store.clickMain = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[1], self)
	store.mainBtnText = gMapUIUtils.GetElementActionName(actions[1])
end

function M:OnPerformAction(action)
	if self.element then
		self.bigMap:OnPerformAction(self.element, action)
	end
end

function M:PretendClick(blockReason, actions)
	if blockReason or not actions or #actions == 0 then
		return
	end

	self:OnPerformAction(actions[1])
end

function M:SetUpHeader()
	local header = self.tooltipInfo.header

	if not header then
		print_error("BigMapTooltipBase:SetUpHeader: No header info provided in tooltipInfo,element:\n" .. gGpsTools.GetGpsDebugDesc(self.element.instanceId))

		return
	end

	self.store.imageId = header.imageId or 0
	self.store.name = header.name or ""
	self.store.subtitle = header.subtitle or ""
end

function M:SetUpHeaderWithParams(imageId, name, subtitle)
	self.store.imageId = imageId or 0
	self.store.name = name or ""
	self.store.subtitle = subtitle or ""
end

local HIDE_SPECIFIC_SPIRIT = 1
local SHOW_SPECIFIC_SPIRIT = 0

function M:SetUpSpecificSpirits(info)
	if info.specificSpirits and #info.specificSpirits > 0 then
		local list = {}

		for _, spiritId in ipairs(info.specificSpirits) do
			local cfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
			local iconId = cfg and cfg.SHeadIconID

			if iconId and iconId > 0 then
				table.insert(list, {
					tIndex = 0,
					iconId = iconId
				})
			end
		end

		self.store.hasSpecificSpirit = SHOW_SPECIFIC_SPIRIT

		function self.store.specificSpiritList.luaSimpleRenderItem(btn, index)
			local store = gStoreManager:GetStoreGroup("SwapAvatarTemplate"):GetStoreByWidget(btn)
			local data = list[index + 1]
			store.avatarIconId = data.iconId
		end

		self.store.specificSpiritList:SetSimpleList(#list)

		return
	end

	self.store.hasSpecificSpirit = HIDE_SPECIFIC_SPIRIT
end

function M:SetUpLocation()
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(self.element.raidId, self.element:GetWorldPos().x, self.element:GetWorldPos().z)

	if blockId then
		local cfg = LTConfig.CollectionBlockConfig.GetConfig(blockId)
		self.store.location = cfg and cfg.BlockName or ""
	end
end

function M:SetUpDropsWithIds(dropIds, dropList)
	local simpleDropRewards = {}

	if dropIds and #dropIds > 0 then
		local dropListParam = {}

		for i = 1, #dropIds do
			table.insert(dropListParam, {
				dropId = dropIds[i]
			})
		end

		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)
	end

	if not table.isNilOrEmpty(simpleDropRewards) then
		function dropList.luaSimpleRenderItem(item, index)
			gCommonItemManager:OnCommonItemRender(item, index, simpleDropRewards[index + 1])
		end

		dropList:SetSimpleList(#simpleDropRewards)
	end
end

function M:SetUpDropsWithId(dropId, dropList)
	self:SetUpDropsWithIds({
		dropId
	}, dropList)
end

function M:ShowGamePadItemPanelWithId(dropId)
	self:ShowGamePadItemPanelWithIds({
		dropId
	})
end

function M:ShowGamePadItemPanelWithIds(dropIds)
	local simpleDropRewards = {}

	if dropIds and #dropIds > 0 then
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

function M:SetUpAbilityList(abilityList, abilityIds)
	abilityList.luaSimpleRenderItem = self.bigMap:CreateActionWithArgs("OnRenderAbilityItem", abilityIds, self)

	abilityList:SetSimpleList(#abilityIds)
end

local AbilityConfig = LTConfig.UrbanAbilityConfig

function M:OnRenderAbilityItem(abilityIds, btn, index)
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

function M:GetStore(storeName)
	if not self.store then
		self.store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(self.root)
	end
end

function M:ValidateTooltipInfo(infoName)
	local info = self.tooltipInfo[infoName]

	if info == nil then
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
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterSelf")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterSmallCamp")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterRandomEvent")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterCoreCamp")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/Gangster/BigMapTooltip_GangsterInformation")
dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltip_Faction")

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
	[EMapTooltipType.GangsterInformation] = C_BigMapTooltip_GangsterInformation
}
