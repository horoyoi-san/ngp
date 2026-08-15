C_BigMapTooltip_Common = DefClass("C_BigMapTooltip_Common", C_BigMapTooltip_Common, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Common

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("commonInfo") then
		return
	end

	self:GetStore("MapCommonTooltipStore")

	local info = self.tooltipInfo.commonInfo

	self:SetUpHeader()
	self:SetUpLocation()

	self.store.desc = info.desc or ""
end
