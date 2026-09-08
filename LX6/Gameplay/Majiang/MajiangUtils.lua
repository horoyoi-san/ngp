-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangUtils.lua
-- Decompiled from: 00345_MajiangUtils.lua_9e327da59431.luajit

local M = {
	GetPanelStore = function (self)
		return gStoreManager:GetStoreGroup("MajiangPanelStore")
	end,
	GetMiddleStore = function (self)
		return gStoreManager:GetStoreGroup("MajiangMiddlePanelStore")
	end,
	GetChiSelectorStore = function (self)
		return gStoreManager:GetStoreGroup("MajiangChiSelectorStore")
	end,
	GetRoundDrawStore = function (self)
		return gStoreManager:GetStoreGroup("MajiangRoundDrawStore")
	end,
	GetReachStatusStore = function (self)
		return gStoreManager:GetStoreGroup("MajiangReachGameStatusStore")
	end,
	GetTeachPanelStore = function (self)
		return gStoreManager:GetStoreGroup("MajiangTeachPanelStore")
	end
}
gMaJiangUtils = M
