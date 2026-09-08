-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComputerNormalTaskPanelStore.lua
-- Decompiled from: 02055_ComputerNormalTaskPanelStore.lua_ea145bd689bf.luajit

C_ComputerNormalTaskPanelStore = DefClass("C_ComputerNormalTaskPanelStore", C_ComputerNormalTaskPanelStore, C_NormalTaskPanelStore)
GroupName2Class.ComputerNormalTaskPanelStore = C_ComputerNormalTaskPanelStore
local M = C_ComputerNormalTaskPanelStore

local GetComputerTaskGuideStore = function()
	return gStoreManager:GetStoreGroup("ComputerCoreHudTaskGuideStore")
end

local ApplyCurrentTaskOnlyMode = function(self)
	self.bindData.shortcut = 1
	self.bindData.giveup = 1
	self.bindData.listType = 2
	self.bindData.nEventName = ""

	self.bindData.setCurTaskBtn:SetActive(false)
	self.bindData.nTaskGuideBtn:SetActive(false)
	self.bindData.nQuitBtn:SetActive(false)
end

M.OnAwake = function(self)
	M.base.OnAwake(self)

	self.p = GetComputerTaskGuideStore()
end

M.OnShow = function(self, data)
	self.p = GetComputerTaskGuideStore()

	M.base.OnShow(self, data)
	ApplyCurrentTaskOnlyMode(self)
end

M.CheckAndShowChildCounter = function(self)
	self.childCounterData = nil
	self.bindData.listType = 2
end

M.RefreshCurrentTaskDes = function(self)
	self.p = GetComputerTaskGuideStore()

	if not self.p or not self.p.curTaskInfo then
		return
	end

	self:SwitchTaskInfo(gTaskUtils:FormatTaskDes(self.p.curTaskInfo.EventObjective or "", self.p.curTaskInfo.TaskId))
end

M.RefreshTaskInfo = function(self)
	self.p = GetComputerTaskGuideStore()

	M.base.RefreshTaskInfo(self)
	ApplyCurrentTaskOnlyMode(self)
end

M.RefreshTrueBranchList = function(self)
	self.branchList = {}
	self.curBranchListIndex = -1
	self.curIsTrueBranch = false
	self.bindData.listType = 2
end

M.RefreshCurrentTaskEventUI = function(self)
	self.bindData.nEventName = ""
end

M.HandleTaskShortCut = function(self)
	self.isTaskGuideBtnActive = false

	ApplyCurrentTaskOnlyMode(self)
end

M.ShowGiveUpButton = function(self)
	self.SetGiveUpButtonActive(self, false)
end

M.SetShortCutButtonActive = function(self)
	self.isTaskGuideBtnActive = false
	self.bindData.shortcut = 1
	self.bindData.listType = 2
end

M.OnClickBtn = function(self)
end

M.OnClickGpsSwitch = function(self)
end

M.OnSwitchGpsShowMode = function(self)
	ApplyCurrentTaskOnlyMode(self)
end

M.OnChangeCurDes = function(self)
	self.RefreshCurrentTaskDes(self)
end
