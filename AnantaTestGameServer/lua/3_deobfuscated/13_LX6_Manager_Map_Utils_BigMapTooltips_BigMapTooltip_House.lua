C_BigMapTooltip_House = DefClass("C_BigMapTooltip_House", C_BigMapTooltip_House, C_BigMapTooltipBase)
local M = C_BigMapTooltip_House
local OWNED = 0
local NOT_OWNED = 1

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("houseInfo") then
		return
	end

	self:GetStore("MapHouseTooltipStore")

	local info = self.tooltipInfo.houseInfo

	self:SetUpHeader()
	self:SetUpLocation()

	self.store.haved = info.owned and OWNED or NOT_OWNED
	self.store.petCount = info.petCount or 0
	self.store.parkingSpaceCount = info.parkingSpaceCount or 0
	self.store.bedroomCount = info.bedroomCount or 0
	self.store.desc = info.desc or ""
end
