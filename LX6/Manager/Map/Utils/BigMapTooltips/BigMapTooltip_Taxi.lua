-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_Taxi.lua
-- Decompiled from: 01015_BigMapTooltip_Taxi.lua_4dbac20ee3f2.luajit

C_BigMapTooltip_Taxi = DefClass("C_BigMapTooltip_Taxi", C_BigMapTooltip_Taxi, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Taxi
local CAN_GO_TYPE = 0

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "taxiInfo") then
		return
	end

	self:GetStore("MapTaxiTooltipStore")

	local info = self.tooltipInfo.taxiInfo

	self:SetUpHeader()

	self.store.type = info.cantTaxiType or CAN_GO_TYPE
	local scrollStore = gStoreManager:GetStoreGroup("MapTaxiScrollStore"):GetStoreByWidget(self.store.taxiScroll.content)

	self.store.taxiScroll:GoToPos(Vector2.zero, true)
	self:SetUpScrollLocation(scrollStore)

	scrollStore.money = "#C(jinyuebi_Text)" .. tostring(info.cost or 0)

	self:SetUpScroll(scrollStore, info)
end

M.SetUpScroll = function(self, scrollStore, info)
	scrollStore.desc = info.desc or ""
end

M.OnActive = function(self)
	self.TryRegisterNavArea(self)
end

M.OnInActive = function(self)
	self.TryUnRegisterNavArea(self)
end

M.TryRegisterNavArea = function(self)
	self.GetStore(self, "MapTaxiTooltipStore")

	if not self.store or not self.store.navArea then
		return
	end

	if self.source == EBigMapSelectSource.TaxiListPanel then
		self.store.navArea.enabled = true
		self.navAreaRegistered = true
	else
		self.store.navArea.enabled = false
		self.navAreaRegistered = true
	end
end

M.TryUnRegisterNavArea = function(self)
	self.GetStore(self, "MapTaxiTooltipStore")

	if not self.store or not self.store.navArea then
		return
	end

	if self.navAreaRegistered then
		self.store.navArea.enabled = false
	end

	self.navAreaRegistered = false
end
