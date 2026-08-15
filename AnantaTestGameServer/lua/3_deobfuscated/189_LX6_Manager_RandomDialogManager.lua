C_RandomDialogManager = DefClass("C_RandomDialogManager", C_RandomDialogManager)
local M = C_RandomDialogManager

function M:ctor(config, configName)
	self.config = config
	self.configName = configName
	self.lastDialogId = {}

	math.randomseed(os.time())
end

function M:ShowDialog(dialogTypeId, dialogSouce, speakNpc, dialogParam, dialogCallbackFunc)
	if dialogTypeId < 1 then
		return
	end

	local randomDialogCfg = self.config.GetConfig(dialogTypeId)
	local dialogList = randomDialogCfg and randomDialogCfg.DialogID

	if table.isNilOrEmpty(dialogList) then
		self:_PrintError("DialogID 列表为空！", dialogTypeId)

		return
	end

	if #dialogList == 1 then
		self:_PrintError("DialogID 列表仅有一个项目，无法满足随机性！", dialogTypeId)
		gDialogManager:ShowGeneralDialog(dialogList[1], dialogSouce, speakNpc, dialogParam, dialogCallbackFunc)

		return dialogList[1]
	end

	local dialogId = array.random(dialogList)

	while dialogId == self.lastDialogId[dialogTypeId] do
		dialogId = array.random(dialogList)
	end

	self.lastDialogId[dialogTypeId] = dialogId

	gDialogManager:ShowGeneralDialog(dialogId, dialogSouce, speakNpc, dialogParam, dialogCallbackFunc)

	return dialogId
end

function M:_PrintError(message, cfgId)
	if cfgId then
		print_error("[RandomDialogManager]", self.configName .. "=" .. cfgId, message)
	else
		print_error("[RandomDialogManager]", message)
	end
end
