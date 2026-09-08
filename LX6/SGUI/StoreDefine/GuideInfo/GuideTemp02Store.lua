-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideInfo\GuideTemp02Store.lua
-- Decompiled from: 01995_GuideTemp02Store.lua_c3a0e940780b.luajit

C_GuideTemp02Store = DefClass("C_GuideTemp02Store", C_GuideTemp02Store, C_GuideTempTabBaseStore)
GroupName2Class.GuideTemp02Store = C_GuideTemp02Store
local M = C_GuideTemp02Store

M.PlayTaskStartAnim = function(self)
	self.bindData.anim:Play()
end

M.IsAnimPlaying = function(self)
	return self.bindData.anim.isPlaying
end

M.SkipCurrentAnim = function(self)
	self._SkipAnim(self, self.bindData.anim)
end
