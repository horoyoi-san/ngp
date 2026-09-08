-- Original chunk: @Lua\LuaFiles\LX6\Manager\Dialog\DialogManager.lua
-- Decompiled from: 00510_DialogManager.lua_1bf440f353fa.luajit

local CS_DCTManager = L18.Script.LX6.Dialog.DCTManager.Instance
local DialogVoiceConfig = LTConfig.DialogVoiceConfig
C_DialogManager = DefClass("C_DialogManager", C_DialogManager)
local M = C_DialogManager

M.ctor = function(self)
	self.VideoCallInRunning = false
	self.openedPanels = {}

	self:InitContents()

	self.dialog22Mini = false
end

M.ShowGeneralDialog = function(self, dialogId, dialogResource, speakNpc, dialogParam, endCallback)
	if not L50.L50App.Scene then
		return false
	end

	dialogParam = dialogParam or self:CreateDialogParam()

	if dialogResource then
		dialogParam.dialogSource = dialogResource
	end

	if speakNpc then
		dialogParam.speakNpc = speakNpc
	end

	return L18.Script.LX6.Dialog.DialogManager.ShowGeneralDialog(dialogId, dialogParam, endCallback)
end

M.CloseDialog = function(self, force)
	if not L50.L50App.Scene then
		return
	end

	L50.L50App.Scene.DialogManager:CloseDialog(force)
end

M.IsDialogRunning = function(self)
	if not L50.L50App.Scene then
		return false
	end

	return L50.L50App.Scene.DialogManager:IsDialoging()
end

M.IsBranchShowing = function(self)
	if not L50.L50App.Scene then
		return false
	end

	return L50.L50App.Scene.DialogManager:IsBranchShowing()
end

M.CloseCertainDialog = function(self, firstId)
	if not L50.L50App.Scene then
		return
	end

	L50.L50App.Scene.DialogManager:CloseCertainDialog(firstId)
end

M.GetCurrentDialogId = function(self)
	if not L50.L50App.Scene then
		return 0
	end

	return L50.L50App.Scene.DialogManager:GetCurrentMainDialogId()
end

M.GetFirstDialogId = function(self)
	if not L50.L50App.Scene then
		return 0
	end

	return L50.L50App.Scene.DialogManager:GetFirstMainDialogId()
end

M.GetCurrentDialogType = function(self)
	if not L50.L50App.Scene then
		return 0
	end

	return L50.L50App.Scene.DialogManager:GetCurrentMainDialogType()
end

M.GetFirstDialogType = function(self)
	if not L50.L50App.Scene then
		return 0
	end

	return L50.L50App.Scene.DialogManager:GetFirstMainDialogType()
end

M.OpenCallInPanel = function(self, dialogId, connectAnim, acceptCb, refuseCb, topName, hostImage)
	if self:GetCurrentDialogType() ~= 22 then
		self:CloseCertainDialog(self:GetFirstDialogId())
	end

	local data = {
		Tags = connectAnim and {
			"?I\\x9d\\x82\\xaaO",
			"\\xbc;.1}\\x9eU\\xf89\\xa3\\xb4"
		} or {
			"?I\\x9d\\x82\\xaaO"
		},
		CallIn_dialogId = dialogId,
		CallIn_acceptCb = acceptCb,
		CallIn_refuseCb = refuseCb,
		CallIn_topName = topName,
		CallIn_hostImage = hostImage
	}

	gPanelManager:CheckShow(gPanelId.S_DIALOG_22N_PANEL, data)
end

M.PlayDialogVoice = function(self, dialogVoiceId, npcId, npcSoundId, isVirtualNpc, grouLastId)
	if not L50.L50App.Scene then
		return
	end

	if not npcSoundId then
		local cfg = DialogVoiceConfig.GetConfig(dialogVoiceId)

		if not cfg then
			print_error("DialogVoice未找到Config，dialogVoiceId=" .. dialogVoiceId)

			return
		end

		npcSoundId = cfg.SoundId
	end

	isVirtualNpc = isVirtualNpc or false
	grouLastId = grouLastId or dialogVoiceId

	L50.L50App.Scene.DialogManager:ShowNpcDialog(dialogVoiceId, npcId, npcSoundId, isVirtualNpc, grouLastId)
end

M.GetExternalVoiceId = function(self, dialogId)
	return L18.Script.LX6.Dialog.DialogUtils.GetExternalVoiceId(dialogId)
end

M.SetDebugMode = function(self, mode)
	self.DebugMode = mode
end

M.ShowDialogInteractionActionFinish = function(self, dialogId, npc, isFromServer, dialogParam)
	if not L50.L50App.Scene then
		return false
	end

	self.InteractionMode = true
	self.interactionTarget = nil
	self.interactionSubMenus = nil
	dialogParam = dialogParam or self:CreateDialogParam()
	dialogParam.speakNpc = npc
	local result = L50.L50App.Scene.DialogManager:ShowInteractionDialog(dialogId, dialogParam)
	self.InteractionMode = false

	return result
end

M.ProcessDialogBranch = function(self, flag)
	for _, store in pairs(self.openedPanels) do
		if store and store.branches and #store.branches <= 0 then
			store:ShowBranchByCircle(not flag)
		end
	end
end

M.GetTruckOrderDialogId = function(self, condition)
	if not L50.L50App.Scene then
		return 0
	end

	return L50.L50App.Scene.DialogManager:GetAIDialogId(condition, 1)
end

M.ShowTruckOrderDialog = function(self, dialogId, info, cb)
	if not L50.L50App.Scene then
		return false
	end

	local posOffset = {
		0.08740234,
		0,
		0.0213623
	}
	local rotOffset = {
		0,
		-178.997,
		0
	}
	local cfg = LTConfig.AIdialoguberConfig.GetConfig(dialogId)
	local pos = info.EndPos.Pos
	local rot = info.EndPos.Rot
	local npcId = info.DeliveryNpc.NpcId
	local param = self:CreateDialogParam()
	local dctConfig = gDialogCameraManager:GetDCTConfig()
	dctConfig.customPosition = Vector3.New(pos.X - posOffset[1], pos.Y - posOffset[2], pos.Z - posOffset[3])
	dctConfig.customRotation = Vector3.New(rot.X - rotOffset[1], rot.Y - rotOffset[2], rot.Z - rotOffset[3])
	dctConfig.dynamicNpcs = {
		npcId,
		CS_DCTManager:GetCurrentRoleNpcId()
	}
	dctConfig.dynamicTemplateId = cfg.UseDialogCamera and 1400 or 0
	param.DCTConfig = dctConfig

	return L50.L50App.Scene.DialogManager:ShowAIDialog(dialogId, 1, param, cb)
end

M.RefreshPanelData = function(self, panelId, data)
	if self.openedPanels[panelId] then
		self.openedPanels[panelId]:RefreshPanel(data)

		return true
	end

	return false
end

M.UpdateDialogDuration = function(self, panelId, newDuration)
	if self.openedPanels[panelId] then
		self.openedPanels[panelId]:OnDialogDurationChanged(newDuration)
	end
end

M.ManualRemovePanel = function(self, panelId)
	self.openedPanels[panelId] = nil
end

M.RunScriptFunc = function(self, text, id)
	return gDialogAction:RunFunc(text, id)
end

M.CreateDialogParam = function(self)
	if not L50.L50App.Scene then
		return nil
	end

	return L50.L50App.Scene.DialogManager:CreateDialogParam()
end

M.HideDialogContent = function(self, panelId)
	local panel = self.openedPanels[panelId]

	if panel then
		panel:HideDialogContent()
	end
end

M.InitContents = function(self)
	self.contentInfos = {}
	self.contentOrder = {}
	self.existContentIds = {}
	self.blendTime = 0.1
	self.blendRate = 0
	self.enableUpdate = false
	self.mainDialogId = 0
end

M.GetMainInfo = function(self)
	if self.mainDialogId ~= 0 then
		return nil
	end

	return self.contentInfos[self.mainDialogId]
end

M.EnableUpdate = function(self, enable)
	if self.enableUpdate ~= enable then
		return
	end

	self.enableUpdate = enable

	if enable then
		gLuaClient:RegisterDynamicUpdate("DialogManager", self)
	else
		gLuaClient:UnregisterDynamicUpdate("DialogManager")
	end
end

local NewContentInfo = function(id, message, style)
	return {
		["\\x8d1.;}\\x8fr\\xcd6\\xad\\xbc"] = 0,
		["\\xa7\\xb0\\xbfZ1\\xed\n"] = 0,
		["^\\xba\\xa3\\xa8\\xb3"] = 0,
		["G[ܺ\\x81\\x88\\xda\\xd1"] = 0,
		["M\\x98\\x89\\x8bU"] = 0,
		id = id,
		message = message,
		style = style or 0
	}
end

M.SetMainContent = function(self, dialogId, dialogMessage)
	self:RemoveMainContent()

	if string.is_null_or_empty(dialogMessage) then
		return
	end

	self.contentInfos[dialogId] = NewContentInfo(dialogId, dialogMessage, 0)
	self.mainDialogId = dialogId
	self.existContentIds[dialogId] = true

	self:EnableUpdate(true)
end

M.RemoveMainContent = function(self)
	if self.mainDialogId ~= 0 then
		return
	end

	local id = self.mainDialogId
	self.existContentIds[id] = nil

	if self.contentInfos[id] and self.contentInfos[id].stage ~= 0 then
		self:RemoveContentInfo(id)
	end
end

M.AddContent = function(self, dialogId, dialogMessage, style)
	self:Log("添加附加对话内容, dialogId=" .. dialogId)

	self.contentInfos[dialogId] = NewContentInfo(dialogId, dialogMessage, style)

	table.insert(self.contentOrder, 1, dialogId)

	self.existContentIds[dialogId] = true

	self:EnableUpdate(true)
end

M.RemoveContent = function(self, dialogId)
	self.existContentIds[dialogId] = nil

	if self.contentInfos[dialogId] and self.contentInfos[dialogId].stage ~= 0 then
		self:RemoveContentInfo(dialogId)
	end
end

M.RemoveContentInfo = function(self, dialogId)
	self:Log("删除附加对话内容, dialogId=" .. dialogId)

	self.contentInfos[dialogId] = nil

	if self.mainDialogId ~= dialogId then
		self.mainDialogId = 0
	end

	local _, index = table.find(self.contentOrder, dialogId)

	if index then
		table.remove(self.contentOrder, index)
	end

	if next(self.contentInfos) ~= nil then
		self:EnableUpdate(false)
	end
end

M.OnUpdate = function(self)
	self.blendRate = self.blendRate + gLogicTime.unscaledDeltaTime / self.blendTime

	if self:AdvanceInflightStage() then
		return
	end

	if self:StartNextFadeOut() then
		return
	end

	self:StartNextFadeIn()
end

M.AdvanceInflightStage = function(self)
	for id, info in pairs(self.contentInfos) do
		if info.stage ~= 1 or info.stage ~= 3 then
			if self.blendRate > 1 then
				info.stage = info.stage + 1

				self:Log("附加内容状态切换, dialogId=" .. id .. " newStage=" .. info.stage)

				if info.stage ~= 4 then
					self.blendRate = 0

					self:RemoveContentInfo(id)
				end
			end

			return true
		end
	end

	return false
end

M.StartNextFadeOut = function(self)
	for id, info in pairs(self.contentInfos) do
		if not self.existContentIds[id] then
			info.stage = 3
			self.blendRate = 0

			self:Log("附加内容状态切换, dialogId=" .. id .. " newStage=" .. info.stage)

			return true
		end
	end

	return false
end

M.StartNextFadeIn = function(self)
	local mainInfo = self:GetMainInfo()

	if mainInfo and mainInfo.stage ~= 0 then
		mainInfo.stage = 1
		self.blendRate = 0

		self:Log("附加内容状态切换, dialogId=" .. self.mainDialogId .. " newStage=" .. mainInfo.stage)

		return true
	end

	for _, id in ipairs(self.contentOrder) do
		local info = self.contentInfos[id]

		if info and info.stage ~= 0 then
			info.stage = 1
			self.blendRate = 0

			self:Log("附加内容状态切换, dialogId=" .. id .. " newStage=" .. info.stage)

			return true
		end
	end

	return false
end

M.Log = function(self, msg)
	if self.debugMode then
		print_debug("[Dialog]" .. msg)
	end
end

gDialogManager = gDialogManager or C_DialogManager.new()
