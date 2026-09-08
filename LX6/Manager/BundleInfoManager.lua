-- Original chunk: @Lua\LuaFiles\LX6\Manager\BundleInfoManager.lua
-- Decompiled from: 00176_BundleInfoManager.lua_9f3d501bd1f8.luajit

local M = {
	infos = {}
}

M.Add = function(self, itemMsg)
	self.infos[tostring(itemMsg.Id)] = itemMsg
end

M.Get = function(self, id)
	return self.infos[tostring(id)]
end

M.Remove = function(self, id)
	self.infos[tostring(id)] = nil
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.infos = {}
	end
end

gBundleInfoManager = M
