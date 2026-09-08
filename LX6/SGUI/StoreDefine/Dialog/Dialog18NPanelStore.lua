-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\Dialog18NPanelStore.lua
-- Decompiled from: 01999_Dialog18NPanelStore.lua_e9dbf78dc641.luajit

C_Dialog18NPanelStore = DefClass("C_Dialog18NPanelStore", C_Dialog18NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog18NPanelStore = C_Dialog18NPanelStore
local M = C_Dialog18NPanelStore

M.InitDialogComponent = function(self, data)
	if not self.bindData.TL1 then
		return
	end

	self.SetText(self, data.Content_Message)
end

M.SetText = function(self, message)
	local messageList = string.split(message, "|", false)
	self.bindData.TL1.activation = false
	self.bindData.TL2.activation = false
	self.bindData.TR1.activation = false
	self.bindData.TR2.activation = false

	if #messageList == 4 then
		self.bindData.TL1text = message
		self.bindData.TL1.activation = true

		return
	end

	if #messageList[1] <= 0 then
		self.bindData.TL1text = messageList[1]
		self.bindData.TL1.activation = true
	end

	if #messageList[2] <= 0 then
		self.bindData.TL2text = messageList[2]
		self.bindData.TL2.activation = true
	end

	if #messageList[3] <= 0 then
		self.bindData.TR1text = messageList[3]
		self.bindData.TR1.activation = true
	end

	if #messageList[4] <= 0 then
		self.bindData.TR2text = messageList[4]
		self.bindData.TR2.activation = true
	end
end
