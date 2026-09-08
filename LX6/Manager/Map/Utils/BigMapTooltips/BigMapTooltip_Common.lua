-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_Common.lua
-- Decompiled from: 01017_BigMapTooltip_Common.lua_0b56bbe053d5.luajit

C_BigMapTooltip_Common = DefClass("C_BigMapTooltip_Common", C_BigMapTooltip_Common, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Common

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "commonInfo") then
		return
	end

	self:GetStore("MapCommonTooltipStore")

	local info = self.tooltipInfo.commonInfo

	self:SetUpHeader()
	self:SetUpLocation()

	self.store.desc = info.desc or ""
end
