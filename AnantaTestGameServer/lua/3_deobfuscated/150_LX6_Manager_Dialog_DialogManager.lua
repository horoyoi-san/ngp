local CS_DialogManager = L18.Script.LX6.Dialog.DialogManager
local CS_DCTManager = L18.Script.LX6.Dialog.DCTManager.Instance
local DialogVoiceConfig = LTConfig.DialogVoiceConfig
C_DialogManager = DefClass("C_DialogManager", C_DialogManager)
local M = C_DialogManager

function M:ctor()
	self.VideoCallInRunning = false
	self.openedPanels = {}
end

function M:ShowGeneralDialog(dialogId, dialogResource, speakNpc, dialogParam, endCallback)
	dialogParam = dialogParam or self:CreateDialogParam()

	if dialogResource then
		dialogParam.dialogSource = dialogResource
	end

	if speakNpc then
		dialogParam.speakNpc = speakNpc
	end

	return CS_DialogManager.ShowGeneralDialog(dialogId, dialogParam, endCallback)
end

function M:ShowNextDialog(dialogId, firstId, curId)
	firstId = firstId or 0
	curId = curId or 0

	CS_DialogManager.ShowNextDialog(dialogId, firstId, curId)
end

function M:CloseDialog(force)
	CS_DialogManager.CloseDialog(force)
end

function M:IsDialogRunning()
	return CS_DialogManager.IsDialoging()
end

function M:IsBranchShowing()
	return CS_DialogManager.IsBranchShowing()
end

function M:CloseCertainDialog(firstId)
	CS_DialogManager.CloseCertainDialog(firstId)
end

function M:GetCurrentDialogId()
	return CS_DialogManager.GetCurrentMainDialogId()
end

function M:GetFirstDialogId()
	return CS_DialogManager.GetFirstMainDialogId()
end

function M:GetCurrentDialogType()
	return CS_DialogManager.GetCurrentMainDialogType()
end

function M:GetFirstDialogType()
	return CS_DialogManager.GetFirstMainDialogType()
end

function M:OpenCallInPanel(dialogId, connectAnim, acceptCb, refuseCb, topName, hostImage)
	if self:GetCurrentDialogType() == 22 then
		self:CloseCertainDialog(self:GetFirstDialogId())
	end

	local data = {
		Tags = connectAnim and {
			"CallIn",
			"ConnectAnim"
		} or {
			"CallIn"
		},
		CallIn_dialogId = dialogId,
		CallIn_acceptCb = acceptCb,
		CallIn_refuseCb = refuseCb,
		CallIn_topName = topName,
		CallIn_hostImage = hostImage
	}

	gPanelManager:CheckShow(gPanelId.S_DIALOG_22N_PANEL, data)
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		self:CloseDialog(true)
	end
end

function M:PlayDialogVoice(dialogVoiceId, npcId, npcSoundId, isVirtualNpc, grouLastId)
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

	CS_DialogManager.ShowNpcDialog(dialogVoiceId, npcId, npcSoundId, isVirtualNpc, grouLastId)
end

function M:SetDebugMode(mode)
	self.DebugMode = mode
end

function M:ShowDialogInteractionActionFinish(dialogId, npc, isFromServer, dialogParam)
	self.InteractionMode = true
	self.interactionTarget = nil
	self.interactionSubMenus = nil
	dialogParam = dialogParam or self:CreateDialogParam()
	dialogParam.speakNpc = npc
	local result = CS_DialogManager.ShowInteractionDialog(dialogId, dialogParam)
	self.InteractionMode = false

	return result
end

function M:ProcessDialogBranch(flag)
	for _, store in pairs(self.openedPanels) do
		if store and store.branches and #store.branches > 0 then
			store:ShowBranchByCircle(not flag)
		end
	end
end

function M:GetTruckOrderDialogId(condition)
	return CS_DialogManager.GetAIDialogId(condition, 1)
end

function M:ShowTruckOrderDialog(dialogId, info, cb)
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

	return CS_DialogManager.ShowAIDialog(dialogId, 1, param, cb)
end

function M:RefreshPanelData(panelId, data)
	if self.openedPanels[panelId] then
		self.openedPanels[panelId]:RefreshPanel(data)

		return true
	end

	return false
end

function M:AttachContent(extraContent)
	self.attachContentText = extraContent

	for _, value in pairs(self.openedPanels) do
		value:OnAttachContentChanged()
	end
end

function M:ManualRemovePanel(panelId)
	self.openedPanels[panelId] = nil
end

function M:SelectInteractionBranch(index)
	if self.interactionTarget then
		self.interactionTarget:OnSubClick(index)
	end
end

function M:RunScriptFunc(text, id)
	return gDialogAction:RunFunc(text, id)
end

function M:CreateDialogParam()
	return CS_DialogManager.CreateDialogParam()
end

function M:HideDialogContent(panelId)
	local panel = self.openedPanels[panelId]

	if panel then
		panel:HideDialogContent()
	end
end

gDialogManager = gDialogManager or C_DialogManager.new()
