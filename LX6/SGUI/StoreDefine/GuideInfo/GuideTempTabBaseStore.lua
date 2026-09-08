-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideInfo\GuideTempTabBaseStore.lua
-- Decompiled from: 01206_GuideTempTabBaseStore.lua_99ef164b84a2.luajit

C_GuideTempTabBaseStore = DefClass("C_GuideTempTabBaseStore", C_GuideTempTabBaseStore, C_StoreGroup)
local M = C_GuideTempTabBaseStore

M.OnStart = function(self)
	local mainPanelStore = gStoreManager:GetStoreGroup("GuideTempPanelStore")

	if mainPanelStore and mainPanelStore.params and mainPanelStore.params.openedByTask then
		self.PlayTaskStartAnim(self)
	else
		self.PlayNormalStartAnim(self)
	end
end

M.PlayTaskStartAnim = function(self)
end

M.PlayNormalStartAnim = function(self)
end

M.IsAnimPlaying = function(self)
	return false
end

M.SkipCurrentAnim = function(self)
end

M._SkipAnim = function(self, anim)
	anim.clip:SampleAnimation(anim.gameObject, 1000)
	anim:Stop()
end
