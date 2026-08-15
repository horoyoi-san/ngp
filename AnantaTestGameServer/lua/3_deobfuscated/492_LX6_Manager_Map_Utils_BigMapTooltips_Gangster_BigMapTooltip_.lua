C_BigMapTooltip_GangsterSelf = DefClass("C_BigMapTooltip_GangsterSelf", C_BigMapTooltip_GangsterSelf, C_BigMapTooltipBase)
local M = C_BigMapTooltip_GangsterSelf
local FactionConfig = LTConfig.FactionConfig

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("gangsterSelfInfo") then
		return
	end

	self:GetStore("MapGangsterSelfTooltipStore")
	self:SetUpHeader()
	self:SetUpLocation()

	local info = self.tooltipInfo.gangsterSelfInfo
	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterSelfScrollStore"):GetStoreByWidget(self.store.scroll.content)

	self:SetUpScroll(scrollStore, info)
end

function M:SetUpScroll(scrollStore, info)
	local cfg = FactionConfig.GetConfig(info.gangsterId)
	scrollStore.desc = cfg.FactionDescription or ""
end
