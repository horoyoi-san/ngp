-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideInfo\GuideTemp03Store.lua
-- Decompiled from: 01996_GuideTemp03Store.lua_c3f9f827ead5.luajit

C_GuideTemp03Store = DefClass("C_GuideTemp03Store", C_GuideTemp03Store, C_GuideTempTabBaseStore)
GroupName2Class.GuideTemp03Store = C_GuideTemp03Store
local M = C_GuideTemp03Store

M.PlayTaskStartAnim = function(self)
	self.bindData.anim:Play()
end

M.IsAnimPlaying = function(self)
	return self.bindData.anim.isPlaying
end

M.SkipCurrentAnim = function(self)
	self._SkipAnim(self, self.bindData.anim)
end
