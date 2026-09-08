-- Original chunk: @Lua\LuaFiles\LX6\Guide\NewGuideMgr_GM.lua
-- Decompiled from: 00366_NewGuideMgr_GM.lua_d64d1bfe66fd.luajit

local M = C_NewGuideMgr

M.GmNewActiveGuide = function(self, guideId, counter)
	self.ClientDebug = true

	self.ActiveGuide(self, guideId, counter)
end

M.GmNewStopGuide = function(self)
	self.StopGuide(self)
end

M.GmNewSwitchGuide = function(self, isOpen)
	self.gmEnableGuide = isOpen

	if not isOpen then
		self.StopGuide(self)

		self.delayedActiveGuideData = nil

		self.RefreshDynamicUpdate(self)
		print_notice("[NewGuideMgr] 引导已全局禁用")
	else
		print_notice("[NewGuideMgr] 引导已全局启用")
	end
end

M.GmSetClientDebug = function(self, enable)
	self.ClientDebug = enable

	print_notice("[NewGuideMgr] ClientDebug =", enable)
end

M.GmActiveGuideFromCreator = function(self, btCreator)
	self.StopGuide(self)

	local bt = btCreator.Create()
	bt._gmCleanupPanelIds = self.CollectGuidePanelIds(self, bt)
	self.activeGuideBT = bt

	if self.enableDebug and self.activeGuideBT and self.activeGuideBT.MarkCounterDirty then
		self.activeGuideBT:MarkCounterDirty()
	end

	self.RefreshDynamicUpdate(self)
end
