-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BedInteractionPanelStore.lua
-- Decompiled from: 01670_BedInteractionPanelStore.lua_8ea3b12fc8d5.luajit

C_BedInteractionPanelStore = DefClass("C_BedInteractionPanelStore", C_BedInteractionPanelStore, C_StoreGroup)
GroupName2Class.BedInteractionPanelStore = C_BedInteractionPanelStore
local M = C_BedInteractionPanelStore

M.ctor = function(self)
end

M.GetParent = function(self)
	return gStoreManager:GetStoreGroup("GameplayHudPanelStore")
end

M.OnAwake = function(self)
	self.bindData.sleepBtn.luaClick = self.CreateAction(self, "PlaySleep", gHomeInteractionManager)
	self.bindData.turnOverBtn.luaClick = self.CreateAction(self, "PlayBedTurnOver", gHomeInteractionManager)
	self.bindData.switchSideBtn.luaClick = self.CreateAction(self, "PlayBedSwitchSide", gHomeInteractionManager)
	self.bindData.exerciseBtn.luaClick = self.CreateAction(self, "PlayExercise", gHomeInteractionManager)
	self.bindData.wakeUpBtn.luaClick = self.CreateAction(self, "PlayGetUp", gHomeInteractionManager)
end

M.OnShow = function(self, panelId, data)
	gHomeInteractionManager:RegisterStore(self)

	self.bindData.isBedDouble = gHomeInteractionManager:CheckIsSingleBed() and 0 or 1

	self:RefreshInteraction()
end

M.RefreshInteraction = function(self)
	local inInteraction = gHomeInteractionManager.actionSignals ~= 0
	self.bindData.isHouseAction = inInteraction and 1 or 0

	self:GetParent():SetBtnBackState(inInteraction)
end

M.OnClose = function(self)
	gHomeInteractionManager:UnRegisterStore()
end

M.OnActiveDeviceChange = function(self, device)
end
