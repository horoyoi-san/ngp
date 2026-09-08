-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\Gangster\BigMapTooltip_GangsterSelf.lua
-- Decompiled from: 01020_BigMapTooltip_GangsterSelf.lua_20c4daff6b38.luajit

C_BigMapTooltip_GangsterSelf = DefClass("C_BigMapTooltip_GangsterSelf", C_BigMapTooltip_GangsterSelf, C_BigMapTooltipBase)
local M = C_BigMapTooltip_GangsterSelf
local FactionConfig = LTConfig.FactionConfig

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "gangsterSelfInfo") then
		return
	end

	self:GetStore("MapGangsterSelfTooltipStore")
	self:SetUpHeader()
	self:SetUpLocation()

	local info = self.tooltipInfo.gangsterSelfInfo
	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterSelfScrollStore"):GetStoreByWidget(self.store.scroll.content)

	self:SetUpScroll(scrollStore, info)
end

M.SetUpScroll = function(self, scrollStore, info)
	local cfg = FactionConfig.GetConfig(info.gangsterId)
	scrollStore.desc = cfg.FactionDescription or ""
end
