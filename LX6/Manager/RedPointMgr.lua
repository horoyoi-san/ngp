-- Original chunk: @Lua\LuaFiles\LX6\Manager\RedPointMgr.lua
-- Decompiled from: 00178_RedPointMgr.lua_ad873ade9501.luajit

local RedDotMgr = SGUI.RedDotMgr
local RedDotConfig = LTConfig.PanelRedDotConfig
local MobileMenuConfig = LTConfig.MobileMenuSGuiConfig
C_RedDotMgr = DefClass("C_RedDotMgr", C_RedDotMgr)
local M = C_RedDotMgr

M.ctor = function(self)
end

M.Log = function(self, ...)
	print_debug("[C_RedDotMgr]", ...)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self:ClearAllRedDot()
	end
end

M.RegisterRedDotByKey = function(self, id, isShow)
	local key = RedDotConfig.GetConfig(id)

	if not key then
		return
	end

	self:RegisterRedDot(isShow, key.Name)
end

M.RegisterRedDot = function(self, isShown, key, force)
	RedDotMgr.LuaSetRedDot(isShown, key, force)
end

M.ClearAllRedDot = function(self)
	RedDotMgr.ClearAllRedDot()
end

M.ClearRedDot = function(self, key)
	RedDotMgr.ClearRedDotByKey(key)
end

M.OnInit = function(self)
	local mobileMenuRedKey = RedDotConfig.GetConfig(RedDotConfig.MainPhone).Name

	for i = 0, MobileMenuConfig.count - 1 do
		local cfg = MobileMenuConfig.LoadAt(i)
		local redCfg = RedDotConfig.GetConfig(cfg.RedDotId)

		if redCfg then
			RedDotMgr.AddRedDotChild(mobileMenuRedKey, redCfg.Name)
		end
	end
end

gRedPointMgr = gRedPointMgr or C_RedDotMgr.new()
