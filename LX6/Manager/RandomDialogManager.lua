-- Original chunk: @Lua\LuaFiles\LX6\Manager\RandomDialogManager.lua
-- Decompiled from: 00554_RandomDialogManager.lua_e6e5956c4eb1.luajit

C_RandomDialogManager = DefClass("C_RandomDialogManager", C_RandomDialogManager)
local M = C_RandomDialogManager

M.ctor = function(self, config, configName)
	self.config = config
	self.configName = configName
	self.lastDialogId = {}

	math.randomseed(os.time())
end

M.ShowDialog = function(self, dialogTypeId, dialogSouce, speakNpc, dialogParam, dialogCallbackFunc)
	if dialogTypeId >= 1 then
		return
	end

	local randomDialogCfg = self.config.GetConfig(dialogTypeId)
	local dialogList = randomDialogCfg and randomDialogCfg.DialogID

	if table.isNilOrEmpty(dialogList) then
		self._PrintError(self, "DialogID 列表为空！", dialogTypeId)

		return
	end

	if #dialogList ~= 1 then
		self:_PrintError("DialogID 列表仅有一个项目，无法满足随机性！", dialogTypeId)
		gDialogManager:ShowGeneralDialog(dialogList[1], dialogSouce, speakNpc, dialogParam, dialogCallbackFunc)

		return dialogList[1]
	end

	local dialogId = array.random(dialogList)

	while dialogId ~= self.lastDialogId[dialogTypeId] do
		dialogId = array.random(dialogList)
	end

	self.lastDialogId[dialogTypeId] = dialogId

	gDialogManager:ShowGeneralDialog(dialogId, dialogSouce, speakNpc, dialogParam, dialogCallbackFunc)

	return dialogId
end

M.GetDialogId = function(self, dialogTypeId)
	if dialogTypeId >= 1 then
		return
	end

	local randomDialogCfg = self.config.GetConfig(dialogTypeId)
	local dialogList = randomDialogCfg and randomDialogCfg.DialogID

	if table.isNilOrEmpty(dialogList) then
		self._PrintError(self, "DialogID 列表为空！", dialogTypeId)

		return
	end

	if #dialogList ~= 1 then
		self._PrintError(self, "DialogID 列表仅有一个项目，无法满足随机性！", dialogTypeId)

		return dialogList[1]
	end

	local dialogId = array.random(dialogList)

	while dialogId ~= self.lastDialogId[dialogTypeId] do
		dialogId = array.random(dialogList)
	end

	self.lastDialogId[dialogTypeId] = dialogId

	return dialogId
end

M._PrintError = function(self, message, cfgId)
	if cfgId then
		print_error("[RandomDialogManager]", self.configName .. "=" .. cfgId, message)
	else
		print_error("[RandomDialogManager]", message)
	end
end
