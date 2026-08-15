C_BigMapTooltip_Taxi = DefClass("C_BigMapTooltip_Taxi", C_BigMapTooltip_Taxi, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Taxi
local CAN_GO_TYPE = 0

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("taxiInfo") then
		return
	end

	self:GetStore("MapTaxiTooltipStore")

	local info = self.tooltipInfo.taxiInfo

	self:SetUpHeader()
	self:SetUpLocation()

	self.store.money = info.cost or 0
	self.store.type = info.cantTaxiType or CAN_GO_TYPE
	local scrollStore = gStoreManager:GetStoreGroup("MapTaxiScrollStore"):GetStoreByWidget(self.store.taxiScroll.content)

	self.store.taxiScroll:GoToPos(Vector2.zero, true)
	self:SetUpScroll(scrollStore, info)
end

function M:SetUpScroll(scrollStore, info)
	scrollStore.desc = info.desc or ""
end

function M:OnActive()
	self:TryRegisterNavArea()
end

function M:OnInActive()
	self:TryUnRegisterNavArea()
end

function M:TryRegisterNavArea()
	self:GetStore("MapTaxiTooltipStore")

	if not self.store or not self.store.navArea then
		return
	end

	if self.source ~= EBigMapSelectSource.TaxiListPanel then
		self.store.navArea.enabled = true
		self.navAreaRegistered = true
	else
		self.store.navArea.enabled = false
		self.navAreaRegistered = true
	end
end

function M:TryUnRegisterNavArea()
	self:GetStore("MapTaxiTooltipStore")

	if not self.store or not self.store.navArea then
		return
	end

	if self.navAreaRegistered then
		self.store.navArea.enabled = false
	end

	self.navAreaRegistered = false
end
