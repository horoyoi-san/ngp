-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoScientistData.lua
-- Decompiled from: 00100_PlayerInfoScientistData.lua_1ee2e9d6c1da.luajit

C_PlayerInfoScientistData = DefClass("C_PlayerInfoScientistData", C_PlayerInfoScientistData, C_PlayerDataBase)
local M = C_PlayerInfoScientistData

M.InitPlayerInfo = function(self, playerInfo)
	local sciInfo = playerInfo.InfoJob and playerInfo.InfoJob.ScientistInfo
	local t = self.DataSet_Template
	t.UnlockedEnchantAffixIds = {}

	if sciInfo and sciInfo.UnlockedEnchantAffixIds then
		for affixId, _ in pairs(sciInfo.UnlockedEnchantAffixIds) do
			t.UnlockedEnchantAffixIds[affixId] = true
		end
	end

	t.PendingEnchantWeaponInstanceId = sciInfo and sciInfo.PendingEnchantWeaponInstanceId or 0
	t.PendingEnchantSlots = sciInfo and sciInfo.PendingEnchantSlots or {}

	self.bindData:RefreshData(t)
end
