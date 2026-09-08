-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ScratchCardType2Store.lua
-- Decompiled from: 01944_ScratchCardType2Store.lua_91fb8b5ce962.luajit

C_ScratchCardType2Store = DefClass("C_ScratchCardType2Store", C_ScratchCardType2Store, C_ScratchCardType1Store)
GroupName2Class.ScratchCardType2Store = C_ScratchCardType2Store
local M = C_ScratchCardType2Store

M.GetShowCount = function(self)
	return 20
end

M.GetZoneRowCount = function(self)
	return 4
end

M.GetMaxReward = function(self)
	return LTConfig.PoiGameConfig.ScratchType3MaxReward
end

M.GetRewardTipsList = function(self)
	return LTConfig.PoiGameConfig.ScratchType2RewardTipsList
end
