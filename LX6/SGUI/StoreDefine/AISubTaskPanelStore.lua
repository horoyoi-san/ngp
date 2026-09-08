-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AISubTaskPanelStore.lua
-- Decompiled from: 01598_AISubTaskPanelStore.lua_2ec0ba6d0253.luajit

local MassNPCConversationConfig = LTConfig.MassNPCConversationConfig
C_AISubTaskPanelStore = DefClass("C_AISubTaskPanelStore", C_AISubTaskPanelStore, C_StoreGroup)
GroupName2Class.AISubTaskPanelStore = C_AISubTaskPanelStore
local M = C_AISubTaskPanelStore
local SHOW_TYPE = {
	["RY~"] = 0,
	["I\nRl"] = 1
}

M.ctor = function(self)
	self.textId = 0
	self.enableByDialog = true
	self.enableBySelf = false
end

M.OnAwake = function(self)
	self.msgEvents = {
		[gEventConstants.DIALOG_START] = self.CreateActionWithArgs(self, "OnDialogStateChange", false),
		[gEventConstants.DIALOG_END] = self.CreateActionWithArgs(self, "OnDialogStateChange", true)
	}
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshText(self)
	self.RefreshState(self)
end

M.OnDialogStateChange = function(self, show)
	self.enableByDialog = show

	self.RefreshState(self)
end

M.RefreshState = function(self)
	self.bindData.showTextCtrl = self.enableByDialog and self.enableBySelf and SHOW_TYPE.SHOW or SHOW_TYPE.HIDE
end

M.RefreshText = function(self)
	if self.textId <= 0 then
		local cfg = MassNPCConversationConfig.GetConfig(self.textId)

		if cfg then
			self.enableBySelf = true
			self.bindData.text = cfg.Content

			return
		end
	end

	self.enableBySelf = false
end

M.OpenAIText = function(self, id)
	self.textId = id

	self.RefreshText(self)
	self.RefreshState(self)
end

M.CloseAIText = function(self)
	self.textId = 0

	self.RefreshText(self)
	self.RefreshState(self)
end
