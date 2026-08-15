local GameplayEvent = MuGenStates.Logic.GameplayEvent
local SunbathCameraConfig = LTConfig.SunbathCameraConfig
local SunbathConfig = LTConfig.SunbathConfig
local GameplayHudDescGroupConfig = LTConfig.GameplayHudDescGroupConfig
local SunbathNpcDailyConfig = LTConfig.SunbathNpcDailyConfig
local MessageConfig = LTConfig.MessageConfig
local NPCChatGamePlayTypeConfig = LTConfig.NPCChatGamePlayTypeConfig
gSunbathManager = gSunbathManager or {}
local M = {
	isPlayAction = false,
	curIsDouble = false,
	musicPanelIsShow = false,
	npcPid = 0,
	curCameraIndex = 0,
	isHideBtn = true,
	inviteNpcTime = 0,
	npcId = 0,
	isInGame = false,
	isEnter = false,
	cameraCfg = {},
	CameraType = {
		Double = 2,
		Solo = 1
	},
	dialogFirstIdList = {},
	RegisterDynamicUpdate = function (self, registure)
		if registure then
			gLuaClient:RegisterDynamicUpdate("gSunbathManager", self)
		else
			gLuaClient:UnregisterDynamicUpdate("gSunbathManager", self)
		end
	end,
	CreateAction = function (self, action, target)
		return function (...)
			target = target or self

			if type(action) == "string" then
				if target[action] then
					return target[action](target, ...)
				end
			else
				return action(target, ...)
			end
		end
	end,
	SunbathExit = function (self)
		gDialogManager:CloseCertainDialog(gDialogManager:GetFirstDialogId())
		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_SHOW_START, self.DialogShowStart)
		gMessageManager:RemoveMessageListener(gEventConstants.TIMELINE_END, self.TimeLineEnd)
		gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_CLOSE, self.PanelOnClose)

		gSunbathManager.isInGame = false
		self.dialogFirstIdList = {}

		if self.sceneNodeGo and not gCS.LuaUtils.IsNull(self.sceneNodeGo) then
			GameObject.Destroy(self.sceneNodeGo)
		end
	end,
	LoadSceneNode = function (self, parent)
		self.isloadScene = true
		local sceneNodePath = "Res/MiniGame/Prefab/Sunbath/SunbathSceneNode.prefab"
		self.sceneNodeOp = gResourceManager:LoadAssetWithCallBack(sceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
			local sceneNodeGo = UnityEngine.GameObject.Instantiate(loadOp.asset)
			sceneNodeGo.gameObject.name = "SunbathSceneNode"

			sceneNodeGo.gameObject.transform:SetParent(parent.transform)
			sceneNodeGo.gameObject.transform:SetLocalPosition(Vector3.zero)

			sceneNodeGo.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
			self.sceneNodeGo = sceneNodeGo
			self.node = self.sceneNodeGo.transform:GetComponent(typeof(L18.Gameplay.SunbathSceneNode))
		end)
	end,
	SetNpcId = function (self, npcId)
		self.npcId = npcId

		self:InitMoodTagList()
	end,
	GetNpcId = function (self)
		return self.npcId or 0
	end,
	SetNpcPid = function (self, csUnit)
		self.npcPid = csUnit.Pid
		self.csUnit = csUnit
		self.inviteNpcTime = gLogicTime.time
	end,
	GetNpcUnit = function (self)
		return self.csUnit
	end,
	GetNpcPid = function (self)
		return self.npcPid or 0
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if gSwitchSceneType.Image <= switchType then
			self.npcId = nil
			self.npcPid = nil
			self.csUnit = nil
		end
	end,
	InitSunbathCameraConfig = function (self)
		if table.isNilOrEmpty(self.cameraCfg) then
			self.cameraCfg = {}

			for index = 0, SunbathCameraConfig.count - 1 do
				local cfg = SunbathCameraConfig.LoadAt(index)

				if cfg then
					self.cameraCfg[cfg.Id] = cfg
				end
			end
		end
	end,
	GetSunbathCameraCfg = function (self, id)
		if table.isNilOrEmpty(self.cameraCfg) then
			self:InitSunbathCameraConfig()
		end

		return self.cameraCfg[id] or {}
	end,
	OnEnterBeachPlay = function (self, data)
		if type(data) ~= "table" then
			data = data:ToTable()
		end

		function self.DialogEnd(_, dialogId)
			self:ListenDialogEnd(dialogId)
			self:RefreshInteractionTime()
		end

		gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.DialogEnd)

		function self.DialogShowStart(_, dialogId)
			self:ListenDialogShowStart(dialogId)
			self:RefreshInteractionTime()
		end

		function self.DialogShowEnd(_, dialogId)
			self:RefreshInteractionTime()
		end

		function self.TimeLineEnd()
			if self.inTimeline then
				self.inTimeline = false

				self:RefreshBtnState()
				self:SetEnable(true)
			end
		end

		function self.PanelOnClose(eventId, panelId)
			if panelId == gPanelId.S_RADIO_PLAYER_PANEL then
				self.musicPanelIsShow = false
			end
		end

		gMessageManager:AddMessageListener(gEventConstants.DIALOG_SHOW_START, self.DialogShowStart)
		gMessageManager:AddMessageListener(gEventConstants.DIALOG_SHOW_END, self.DialogShowEnd)
		gMessageManager:AddMessageListener(gEventConstants.TIMELINE_END, self.TimeLineEnd)
		gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.PanelOnClose)

		self.isInGame = true
		self.isEnter = true
		self.inTimeline = true
		self.cameraSetId = 1
		self.isSolo = data.isSolo
		self.musicIsPlay = false
		self.isHideBtn = true

		gPanelManager:CheckShow(gPanelId.GAMEPLAY_HUD_PRO_PANEL, {
			groupId = self.isSolo and GameplayHudDescGroupConfig.SINGLE_BEACH or GameplayHudDescGroupConfig.MUL_BEACH,
			closeCallback = self:CreateAction("OnEndOfPlay"),
			switchViewCallback = self:CreateAction("BeachSwitchCamera")
		})

		self.interactionStore = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")

		self:RefreshInteractionTime()
		self:SetEnable(false)
		self:RegisterDynamicUpdate(true)
	end,
	SetEndDialog = function (self, dialogId)
		self.checkDialogId = dialogId
	end,
	OnUpdate = function (self)
		if not self.isEnter or not self.isInGame then
			return
		end

		if gDialogManager:IsDialogRunning() or self.musicPanelIsShow then
			self:RefreshInteractionTime()
		end

		if not self.isSolo then
			if SunbathConfig.NoInteractionShortTime <= gLogicTime.time - self.shorInteractionTime then
				self.shorInteractionTime = gLogicTime.time

				gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathNoInteractionShortTime)
				gCS.LogicStateMachineManager.SendGameplayEvent(self.csUnit, GameplayEvent.SunbathNoInteractionShortTime)
				gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
					signalKey = "RandomChat"
				})
			end

			if SunbathConfig.NoInteractionLongTime <= gLogicTime.time - self.longInteractionTime then
				self.longInteractionTime = gLogicTime.time

				gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathNoInteractionLongTime)
				gCS.LogicStateMachineManager.SendGameplayEvent(self.csUnit, GameplayEvent.SunbathNoInteractionLongTime)
				gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
					signalKey = "ExitGamePlayChat"
				})
			end
		end
	end,
	RefreshInteractionTime = function (self)
		self.longInteractionTime = gLogicTime.time
		self.shorInteractionTime = gLogicTime.time
	end,
	OnEndOfPlay = function (self)
		self:SunbathExit()
		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END, self.DialogEnd)
		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_SHOW_END, self.DialogShowEnd)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "ExitSunBathGameplay"
		})
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathExit)
	end,
	ClearData = function (self)
		self.isEnter = false
		self.csUnit = nil
		self.npcId = nil
		self.npcPid = nil
		self.checkDialogId = nil

		self:RegisterDynamicUpdate(false)
	end,
	PlayBeachDrink = function (self)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathDrink)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "Drink"
		})
		print_debug("[C_HomeInteractionManager] PlayDrink")
		self:RefreshInteractionTime()
	end,
	PlayBeachChat = function (self)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathChat)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.csUnit, GameplayEvent.SunbathChat)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "PlayerChat"
		})
		print_debug("[C_HomeInteractionManager] PlayChat")
		self:RefreshInteractionTime()
	end,
	PlayBeachCheers = function (self)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathCheers)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.csUnit, GameplayEvent.SunbathCheers)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "PlayerCheers"
		})
		print_debug("[C_HomeInteractionManager] PlayCheers")
		self:RefreshInteractionTime()
	end,
	ChangeBeachMusic = function (self)
		self.musicPanelIsShow = true

		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "TurnOnMusic"
		})
		self:RefreshInteractionTime()
	end,
	BeachSwitchCamera = function (self)
		local cameraType = self.CameraType.Solo
		local maxCount = self.node.soloCameraList.Count

		if not self.isSolo then
			cameraType = self.CameraType.Double
			maxCount = self.node.doubleCameraList.Count
		end

		if maxCount <= self.curCameraIndex then
			self.curCameraIndex = -1
		end

		self.node:SetCameraActive(cameraType, self.curCameraIndex)

		self.curCameraIndex = self.curCameraIndex + 1
	end,
	PlaySunbathInviteNpcAction = function (self)
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathInviteNpc)

		if self.csUnit then
			gCS.LogicStateMachineManager.SendGameplayEvent(self.csUnit, GameplayEvent.SunbathInviteNpc)
		end
	end,
	SetBtnState = function (self, isHide)
		self.isHideBtn = isHide

		self:RefreshBtnState()
	end,
	RefreshBtnState = function (self)
		if self.interactionStore then
			self.interactionStore:RefreshBtnState()
		end
	end,
	SetEnable = function (self, enable)
		if self.interactionStore then
			self.interactionStore:SetEnable(enable)
		end
	end,
	CheckIsShow = function (self)
		return self.isHideBtn and not self.isPlayAction and not gDialogManager:IsDialogRunning()
	end
}
local DialogType = {
	ScapeChat = 3,
	ShortTime = 4,
	TouristChat = 2,
	RandomChat = 1,
	LongTime = 6,
	Start = 0,
	NormalTime = 5
}

local function NpcPlayEvent(dialogType)
	local npcPlayEvent = nil

	if dialogType == DialogType.ShortTime then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathOpenEyes)

		npcPlayEvent = GameplayEvent.SunbathOpenEyes
	elseif dialogType == DialogType.NormalTime then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathRubEyes)

		npcPlayEvent = GameplayEvent.SunbathRubEyes
	elseif dialogType == DialogType.LongTime then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathRealex)

		npcPlayEvent = GameplayEvent.SunbathRealex
	end

	local npcUnit = gSunbathManager:GetNpcUnit()

	if npcUnit then
		gCS.LogicStateMachineManager.SendGameplayEvent(npcUnit, GameplayEvent.SunbathRubEyes)
	end
end

function M:GetSunbathRandomDialog(dialogType)
	local npcId = gSunbathManager:GetNpcId()
	local cfg = nil

	for i = 0, SunbathNpcDailyConfig.count - 1 do
		local cfg1 = SunbathNpcDailyConfig.LoadAt(i)

		if cfg1.NpcId == npcId then
			cfg = cfg1

			break
		end
	end

	if not cfg then
		NpcPlayEvent(dialogType)

		return self.dialogId or 0
	end

	local function GetRandom(list)
		if #list == 0 then
			return nil
		end

		return list[math.random(1, #list)]
	end

	local dialogId = 0

	if dialogType == DialogType.Start then
		dialogId = GetRandom(cfg.Dialog_Start)

		self:PlaySunbathInviteNpcAction()
	elseif dialogType == DialogType.RandomChat then
		dialogId = GetRandom(cfg.Dialog_RandomChat)
	elseif dialogType == DialogType.TouristChat then
		dialogId = GetRandom(cfg.Dialog_TouristChat)
	elseif dialogType == DialogType.ScapeChat then
		dialogId = GetRandom(cfg.Dialog_ScapeChat)
	elseif dialogType == DialogType.ShortTime then
		dialogId = cfg.Dialog_SoloSleep[1].DialogId
	elseif dialogType == DialogType.NormalTime then
		dialogId = cfg.Dialog_SoloSleep[2].DialogId
	elseif dialogType == DialogType.LongTime then
		dialogId = cfg.Dialog_SoloSleep[3].DialogId
	end

	NpcPlayEvent(dialogType)
	gSunbathManager:SetEndDialog(dialogId)
	gSunbathManager:SetBtnState(false)

	return dialogId or 0
end

function M:SunbathInvite(cfgId)
	local cfg = NPCChatGamePlayTypeConfig.GetConfig(cfgId)

	if cfg == nil then
		print_error("当前配置id找不到对应的config数据")

		return
	end

	gClientToGameDelegate:AskSimulationInviteNpc(cfgId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_error("AskSimulationInviteNpc failed, error =", gCS.Error.GetNameById(err))
		end
	end
end

function M:StateTreeSunbathEnter()
	self.isPlayAction = true

	self:RefreshBtnState()
end

function M:StateTreeSunbathExit()
	self.isPlayAction = false

	self:RefreshBtnState()
end

function M:ListenDialogEnd(dialogId)
	if self.checkDialogId == dialogId then
		self:SetBtnState(true)
	end

	if self.dialogFirstIdList[dialogId] then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathExitChat)
		MuGenStates.Logic.ABPVarManager.SetBool(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.InSunbathTalk, false)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.csUnit, GameplayEvent.SunbathExitChat)
		MuGenStates.Logic.ABPVarManager.SetBool(self.csUnit, LTConfig.ABPVarConfig.InSunbathTalk, false)
	end
end

function M:ListenDialogShowStart(dialogId)
	if self.dialogFirstIdList[dialogId] then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathEnterChat)
		MuGenStates.Logic.ABPVarManager.SetBool(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.InSunbathTalk, true)
		gCS.LogicStateMachineManager.SendGameplayEvent(self.csUnit, GameplayEvent.SunbathEnterChat)
		MuGenStates.Logic.ABPVarManager.SetBool(self.csUnit, LTConfig.ABPVarConfig.InSunbathTalk, true)
	end

	if not self.moodTagList then
		return
	end

	local moodTag = self.moodTagList[dialogId]

	if moodTag then
		local cfg = LTConfig.DialogConfig.GetConfig(dialogId)

		if cfg.LeftName == "<player>" then
			MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, 43, moodTag)
		else
			MuGenStates.Logic.ABPVarManager.SetInt(self.csUnit, 43, moodTag)
		end
	end
end

function M:InitMoodTagList()
	local npcId = gSunbathManager:GetNpcId()
	local cfg = nil

	for i = 0, SunbathNpcDailyConfig.count - 1 do
		local cfg1 = SunbathNpcDailyConfig.LoadAt(i)

		if cfg1.NpcId == npcId then
			cfg = cfg1

			break
		end
	end

	self.moodTagList = {}
	self.dialogFirstIdList = {}

	for k, v in pairs(cfg.CharacterDialogIdList) do
		local dialogCfg = LTConfig.CharacterDialogConfig.GetConfig(v)

		if dialogCfg then
			self.dialogFirstIdList[dialogCfg.Dialogid] = true

			if dialogCfg.MoodTag and #dialogCfg.MoodTag > 0 then
				for i, v2 in pairs(dialogCfg.MoodTag) do
					self.moodTagList[v2.dialogid] = v2.moodtagid
				end
			end
		else
			print_error("SunbathNpcDailyConfig 找不到对应的CharacterDialogConfig 配置，id=", v)
		end
	end
end

function M:GetNpcDailyCfg()
	local npcId = self:GetNpcId()

	for i = 0, SunbathNpcDailyConfig.count - 1 do
		local cfg1 = SunbathNpcDailyConfig.LoadAt(i)

		if cfg1.NpcId == npcId then
			return cfg1
		end
	end

	return nil
end

function M:GetDialogFirstId()
	local npcDailyCfg = self:GetNpcDailyCfg()

	if not npcDailyCfg then
		return 0
	end

	return npcDailyCfg.Dialog_Start
end

function M:GetDialogSecondId()
	local npcDailyCfg = self:GetNpcDailyCfg()

	if not npcDailyCfg then
		return 0
	end

	return npcDailyCfg.Dialog_StartSecond
end

gSunbathManager = M
