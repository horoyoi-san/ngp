-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_House.lua
-- Decompiled from: 01012_BigMapTooltip_House.lua_699b52bc0b82.luajit

C_BigMapTooltip_House = DefClass("C_BigMapTooltip_House", C_BigMapTooltip_House, C_BigMapTooltipBase)
local M = C_BigMapTooltip_House
local OWNED = 0
local NOT_OWNED = 1

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "houseInfo") then
		return
	end

	self:GetStore("MapHouseTooltipStore")

	local info = self.tooltipInfo.houseInfo

	self:SetUpHeader()

	self.store.haved = info.owned and OWNED or NOT_OWNED
	local scrollStore = gStoreManager:GetStoreGroup("MapHouseScrollStore"):GetStoreByWidget(self.store.houseScroll.content)

	self.store.houseScroll:GoToPos(Vector2.zero, true)
	self:SetUpScrollLocation(scrollStore)

	scrollStore.desc = info.desc or ""
	self.capacityRenderList = {}
	local countByKey = {
		ParkingSpace = info.ParkingSpaceCount or 0,
		WeaponCabinet = info.WeaponCabinetCount or 0,
		Collection = info.CollectionCount or 0,
		FashionShowcase = info.FashionShowcaseCount or 0,
		Pet = info.PetCount or 0
	}

	for _, entry in ipairs(LTConfig.HouseConfig.HouseMapCollection) do
		local count = countByKey[entry.HousCollection] or 0

		if count <= 0 then
			local textCfg = entry.name and entry.name == 0 and LTConfig.TextConfig.GetConfig(entry.name)

			table.insert(self.capacityRenderList, {
				count = count,
				iconId = entry.icon or 0,
				name = textCfg and textCfg.Text or ""
			})
		end
	end

	scrollStore.list.luaSimpleRenderItem = function(btn, index)
		local info = self.capacityRenderList[index + 1]
		local store = gStoreManager:GetStoreGroup("MapHouseAttributeStore"):GetStoreByWidget(btn)
		store.count = info.count
		store.iconId = info.iconId
		store.name = info.name
	end

	scrollStore.list:SetSimpleList(#self.capacityRenderList)
end

M.SetUpActions = function(self, store, actions, blockReason)
	if not actions or #actions ~= 0 then
		store.showMainBtn = self.HIDE_BTN

		return
	end

	store.showMainBtn = self.SHOW_BTN

	if blockReason then
		store.mainBtnText = blockReason
		store.mainBtnInteractable = false

		return
	end

	store.mainBtnInteractable = true
	store.clickMain = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[1], self)
	store.mainBtnText = gMapUIUtils.GetElementActionName(actions[1])
end
