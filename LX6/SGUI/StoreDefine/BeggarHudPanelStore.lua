-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BeggarHudPanelStore.lua
-- Decompiled from: 01672_BeggarHudPanelStore.lua_d278b8fb08a6.luajit

C_BeggarHudPanelStore = DefClass("C_BeggarHudPanelStore", C_BeggarHudPanelStore, C_StoreGroup)
GroupName2Class.BeggarHudPanelStore = C_BeggarHudPanelStore
local M = C_BeggarHudPanelStore
local BeggarConfig = LTConfig.BeggarConfig
local MyPlayerManager = gCS.MyPlayerManager
local BeggarDrawConfig = LTConfig.BeggarDrawConfig
local AgentConfig = LTConfig.AgentConfig
local ABPVarManager = MuGenStates.Logic.ABPVarManager
local LogicStateMachineManager = gCS.LogicStateMachineManager

M.ctor = function(self)
	self.STAGE_TYPE = {
		["\\xfb\\xfe3:7\n\\xd6"] = 1,
		["XW\\x85Cs\\x90\\xd7`MSPk"] = 0
	}
	self.NPC_DIALOG_STAGE = {
		["jiSMg?=="] = 1,
		["d{牻;\\x8c%\\xfb\\xdc"] = 0,
		["tfE]q04*"] = 2,
		["sfEGz!#7"] = 3
	}
	self.paintUrl = "Assets/Res/SGUI/Panel/Beggar/BeggerPaintingTask.prefab"
	self.paintResUrl = "Assets/Res/SGUI/Panel/Beggar/S_PaintingFeedback.prefab"
	self.GAMEPLAY_TYPE = {
		["\\xfd\\xfe2<+\\xc5"] = 0,
		["}\\x8f\\x8b\\x81\\x82"] = 1
	}
	self.GAMEPLAY_TAB_TYPE = {
		["\\x9b\\x90,\\x85^\\xd0"] = 0,
		["T\rS~"] = -1
	}
	self.GAMEPLAY_STYLE_ID = {
		["}\\x8f\\x8b\\x81\\x82"] = 4
	}
end

M.OnAwake = function(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.typeId = data.typeId
	self.styleId = data.styleId
	self.curDoingStyleId = 0
	self.promote = data.promote
	self.lastData = nil

	gBeggarManager:OnInit()

	self.isShow = true
	self.gameplayHud = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if self.gameplayHud then
		slot3 = self.gameplayHud

		slot3:RegisterBtnBackCallback(function ()
			local beggarPanel = gStoreManager:GetStoreGroup("BeggarHudPanelStore")

			if beggarPanel then
				beggarPanel:OnBtnBackCallback()
			end
		end)
	end

	self.InitBeggar(self)
	self.SwitchToFreeLook(self)
end

M.OnClose = function(self)
	self.isShow = false

	if not self.gameplayHud then
		self.gameplayHud = gStoreManager:GetStoreGroup("GameplayHudPanelStore")
	end

	if self.gameplayHud then
		self.gameplayHud.bindData.btnExit.interactable = true

		self.gameplayHud:RegisterBtnBackCallback(nil)

		self.gameplayHud = nil
	end

	self:SwitchToNormalFreeLook()
	gMessageManager:SendMessage(gEventConstants.BEGGAR_END, self.spot or 1)

	if self.exitSignal and self.exitSignal <= 0 then
		LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.exitSignal)
	end

	gBeggarManager:StopBeggar(self.lastData)

	self.lastData = nil
	self.currentRenderStore = nil
	self.curShowData = nil

	if self.typeId ~= self.GAMEPLAY_STYLE_ID.PAINT then
		self.ClosePaintingGame(self)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.DIALOG_END] = function (eventId, FirstDialogId)
			if FirstDialogId ~= self.currentWaitDialog then
				self:OnWaitDialogEnd()
			end
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnSimpleClickList")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.actionId[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = BeggarConfig.GetConfig(data)

	if cfg then
		store.title = cfg.Name
		store.icon = cfg.Icon

		btn:SetPCKeyInfoWithOutTip(cfg.PCKeyId, 2)
		btn:SetPCKeyInfoTipNameId(cfg.ButtonNameId)
		store.ctrlImg:ChangeImageAction(cfg.ControllerKeyID, 0, nil, 0, 2)
		store.ctrlImg:ChangeImageActionNameId(cfg.ControllerKeyID, cfg.ButtonNameId)
	end
end

M.OnSimpleClickList = function(self, btn, index)
	local data = self.actionId[index + 1]

	if not data then
		return
	end

	self.OnSwitchBeggingActionClick(self, data)
end

M.InitBeggar = function(self)
	self.spot = gBeggarManager.spotId or 1
	self.currentStage = self.STAGE_TYPE.WAIT_BEGGING
	self.finishPanelShown = nil
	self.targetBeggingAction = nil
	self.currentBeggingAction = nil
	self.startTime = nil
	self.lastDialogEndTime = nil
	self.currentDialogTypeId = nil
	self.currentWaitDialog = nil
	self.targetDialogTypeId = nil
	self.stopBegTime = nil
	self.exp = 0
	self.totalReward = 0
	self.isBegged = false
	self.isFinished = false
	self.closeTime = BeggarConfig.CloseTime or 1
	self.dialogCD = BeggarConfig.DialogCD or 3
	self.npcDialogStage = self.NPC_DIALOG_STAGE.WAIT_START
	self.finishTime = nil
	self.debugSyncData = false
	self.disableAllBtn = false

	if not self.randomDialogMgr then
		self.randomDialogMgr = C_RandomDialogManager.new(LTConfig.BeggarRandomSelectionConfig, "BeggarRandomSelectionConfig")
	end

	self.actionId = gBeggarManager:GetBeggarActionInfo(self.styleId)

	self.bindData.list:SetSimpleList(#self.actionId)

	self.bindData.time = "00:00"
	self.bindData.money = 0
	self.bindData.scrollNumGroup.startNum = 0

	self.bindData.scrollNumGroup:SetToStartNum()

	local styleCfg = LTConfig.BeggarStyleConfig.GetConfig(self.styleId)
	self.bindData.type = styleCfg and styleCfg.Desc or ""
	self.bindData.style = ""
	self.bindData.promote = self.promote and 1 or 0
	self.enterSignal = styleCfg and styleCfg.EnterGameplaySignal or 0
	self.exitSignal = styleCfg and styleCfg.ExitGameplaySignal or 0
	self.abpVar = styleCfg and styleCfg.ABPVar or 0
	self.bindData.showReviewingCtrl = 0

	if self.abpVar <= 0 then
		ABPVarManager.SetInt(MyPlayerManager.PlayerUnit, self.abpVar, 0)
	end

	if self.enterSignal <= 0 then
		LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.enterSignal)
	end

	if self.typeId ~= self.GAMEPLAY_STYLE_ID.PAINT then
		self.InitPaintingGame(self)
	else
		self.InitDefaultGame(self)
	end
end

M.OnUpdate = function(self)
	if self.currentStage == self.STAGE_TYPE.WAIT_BEGGING or not self.isFinished then
		if self.startTime and not self.isFinished then
			local deltaTime = gLuaDataManager.serverTime - self.startTime
			self.bindData.time = self.GetTimeString(self, deltaTime)
		end

		if self.lastDialogEndTime and not self.isFinished then
			if self.npcDialogStage ~= self.NPC_DIALOG_STAGE.WAIT_NEXT then
				local deltaTime = os.time() - self.lastDialogEndTime

				if self.dialogCD >= deltaTime then
					self.lastDialogEndTime = nil

					self.ShowNextDialog(self)
				end
			else
				self.lastDialogEndTime = nil
			end
		end
	end

	if self.finishTime then
		local deltaTime = os.time() - self.finishTime

		if self.closeTime >= deltaTime then
			self.finishTime = nil

			gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
		end
	end

	if self.curGameplayType ~= self.GAMEPLAY_TYPE.PAINT then
		self.UpdatePaint(self)
	end
end

M.RefreshBtnState = function(self, newDisableBtn)
	if newDisableBtn == self.disableAllBtn then
		self.disableAllBtn = newDisableBtn

		if self.gameplayHud then
			self.gameplayHud.bindData.btnExit.interactable = not newDisableBtn
		end

		self.bindData.list:RefreshList()
	end
end

M.OnSwitchBeggingActionClick = function(self, targetAction)
	if targetAction and targetAction <= 0 and self.currentBeggingAction == targetAction and not self.targetBeggingAction and (self.currentStage ~= self.STAGE_TYPE.WAIT_BEGGING or self.currentStage ~= self.STAGE_TYPE.BEGGING) then
		if self.currentBeggingAction then
			self.targetBeggingAction = targetAction

			self.SwitchBeggingAction(self)
		else
			self.targetBeggingAction = targetAction

			self.SwitchBeggingAction(self)

			if self.curDoingStyleId == self.styleId then
				self.curDoingStyleId = self.styleId

				self:RequestBegAction(self.promote and UX.Game.BegBehaviorType.StartWithPromotion or UX.Game.BegBehaviorType.Start)
			end

			self.isBegged = true

			gBeggarManager:ActivateRelatedAP(self.spot)
		end
	end
end

M.SwitchBeggingAction = function(self)
	if self.targetBeggingAction then
		self.currentStage = self.STAGE_TYPE.BEGGING
		self.currentBeggingAction = self.targetBeggingAction
		self.targetBeggingAction = nil
		local actionCfg = LTConfig.BeggarConfig.GetConfig(self.currentBeggingAction)
		self.bindData.style = actionCfg and actionCfg.Name or ""

		if self.abpVar <= 0 then
			local value = actionCfg and actionCfg.ABPVarValue or 0

			ABPVarManager.SetInt(MyPlayerManager.PlayerUnit, self.abpVar, value or 0)
		end

		gBeggarManager:PlaySound(actionCfg and actionCfg.SoundId, MyPlayerManager.PlayerUnit.LocalPosition, MyPlayerManager.PlayerUnit.IsMe)
	end
end

M.RequestBegAction = function(self, behaviorType)
	if self.styleId and self.spot then
		if gGameSwitch.EnableBeggerStory then
			gClientToGameDelegate:AskBegBehaviorStory(self.styleId, gBeggarManager.gadgetId, behaviorType)
		else
			slot2 = gClientToGameDelegate

			slot2:AskBegBehavior(self.styleId, self.spot, behaviorType).Callback = function (err, data)
				if data and data.StartTime then
					self.startTime = data.StartTime
				end

				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end
			end
		end
	end
end

M.OnSyncData = function(self, data)
	local newTotalReward = data.TotalReward + data.TotalRewardFromPlayer

	if not self.isFinished then
		self:ChangeDialog(data.DialogId)
		self:ChangeReward(newTotalReward)
		gBeggarManager:OnSpotDataChange(self.spot, data.NpcGatherLimit, data.NpcGatherRate, data.NpcIds)
	end

	self.totalReward = newTotalReward
	self.exp = data.Exp

	if self.debugSyncData then
		local deltaTime = data.LastUpdateTime - data.StartTime

		print_notice("乞丐同步数据，持续时间： ", deltaTime, ",奖励：", newTotalReward, ",exp=", self.exp)
	end

	self.lastData = data
end

M.ChangeReward = function(self, newTotalReward)
	self.bindData.money = tostring(newTotalReward)

	if self.totalReward == newTotalReward then
		self.bindData.scrollNumGroup.startNum = self.totalReward
		self.bindData.scrollNumGroup.targetNum = newTotalReward

		self.bindData.scrollNumGroup:SetToStartNum()
		self.bindData.scrollNumGroup:Play()

		self.totalReward = newTotalReward
	end
end

M.ChangeDialog = function(self, newDialogId)
	self.currentDialogTypeId = newDialogId

	if self.npcDialogStage ~= self.NPC_DIALOG_STAGE.WAIT_START then
		self.currentWaitDialog = self.randomDialogMgr:ShowDialog(self.currentDialogTypeId, gDialogSource.Beggar)

		if self.currentWaitDialog then
			self.npcDialogStage = self.NPC_DIALOG_STAGE.IN_DIALOG
		end
	end
end

M.ShowPaintResDialog = function(self, msg)
	if msg then
		self.currentWaitDialog = BeggarConfig.PaintingAIDialog
		self.npcDialogStage = self.NPC_DIALOG_STAGE.PAINT_RES
		local param = gDialogManager:CreateDialogParam()
		param.CustomStr = msg

		gDialogManager:ShowGeneralDialog(BeggarConfig.PaintingAIDialog, gDialogSource.Beggar, nil, param)
	end
end

M.OnWaitDialogEnd = function(self)
	if self.isFinished then
		return
	end

	if self.npcDialogStage ~= self.NPC_DIALOG_STAGE.IN_DIALOG or self.npcDialogStage ~= self.NPC_DIALOG_STAGE.PAINT_RES then
		self.lastDialogEndTime = os.time()
		self.npcDialogStage = self.NPC_DIALOG_STAGE.WAIT_NEXT
	end
end

M.ShowNextDialog = function(self)
	if self.npcDialogStage ~= self.NPC_DIALOG_STAGE.PAINT_RES then
		return
	end

	self.currentWaitDialog = self.randomDialogMgr:ShowDialog(self.currentDialogTypeId, gDialogSource.Beggar)

	if self.currentWaitDialog then
		self.npcDialogStage = self.NPC_DIALOG_STAGE.IN_DIALOG
	else
		self.npcDialogStage = self.NPC_DIALOG_STAGE.WAIT_START
	end
end

M.OnStopBegging = function(self)
	self.targetBeggingAction = nil
	self.isFinished = true
	self.stopBegTime = os.time()
end

M.OnFinishBegging = function(self)
	if self.gameplayHud then
		self.gameplayHud.bindData.btnExit.interactable = true
	end

	self.finishPanelShown = true
end

M.GetTimeString = function(self, deltaTime)
	local hour = math.floor(deltaTime / 3600)
	local min = math.floor((deltaTime - hour * 3600) / 60)
	local second = math.floor(deltaTime % 60)

	if hour <= 0 then
		return string.format("%02d:%02d:%02d", hour, min, second)
	else
		return string.format("%02d:%02d", min, second)
	end
end

M.OnBtnBackCallback = function(self)
	if not self.isFinished then
		self.OnStopBegging(self)

		if self.isBegged then
			self:RequestBegAction(UX.Game.BegBehaviorType.Stop)
			gBeggarManager:InactivateRelatedAP(self.spot)
		else
			if self.gameplayHud then
				self.gameplayHud.bindData.btnExit.interactable = true
			end

			self.OnFinishBegging(self)
		end
	end

	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	gBeggarManager:StopSound()
end

M.OnRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.currentRenderStore = store

	store:ShowPanel(self.curShowData)

	self.curShowData = nil
end

M.InitDefaultGame = function(self)
	self.bindData.showGameplay = 0
	self.curGameplayType = self.GAMEPLAY_TYPE.DEFAULT
	self.curGameplayTabType = self.GAMEPLAY_TAB_TYPE.NONE
	self.bindData.container.url = ""
	self.bindData.result.url = ""
end

M.InitPaintingGame = function(self)
	gBeggarManager:ResetPaintTaskInfo()

	self.bindData.showGameplay = 0
	self.curGameplayType = self.GAMEPLAY_TYPE.PAINT
	self.curGameplayTabType = self.GAMEPLAY_TAB_TYPE.NONE

	self:RefreshPaintingTaskInfo()
	self:OnSwitchBeggingActionClick(12)
end

M.ClosePaintingGame = function(self)
	self.paintReviewPoint = nil

	self:ClosePaintingResult()
	gBeggarManager:AskGiveUpPaintTask()
end

M.RefreshPaintingTaskInfo = function(self)
	local enableFixCam = false

	if gBeggarManager:HasPaintTask() then
		if gBeggarManager:InPaintingTask() then
			self.curGameplayTabType = self.GAMEPLAY_TAB_TYPE.PAINTING
			enableFixCam = true
			self.bindData.container.url = ""
		else
			local content = self.bindData.container.content

			if content then
				gBeggarManager:RefreshPaintingTaskContent(content)
			else
				slot3 = self.bindData.container

				slot3:SetUrlWithCallback(self.paintUrl, function (widget)
					gBeggarManager:RefreshPaintingTaskContent(widget)
				end)
			end

			self.curGameplayTabType = self.GAMEPLAY_TAB_TYPE.NONE
		end
	else
		self.bindData.container.url = ""
		self.curGameplayTabType = self.GAMEPLAY_TAB_TYPE.NONE
	end

	self.bindData.tabRect.selectedIndex = self.curGameplayTabType
	self.curShowData = nil

	if enableFixCam then
		self.SwitchToFixCamera(self)

		self.bindData.showGameplay = 1

		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, false)
	else
		self.SwitchToFreeLook(self)

		self.bindData.showGameplay = 0

		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, true)
	end
end

M.RefreshRefuseText = function(self, store, taskInfo)
	local time = math.max(0, math.floor(taskInfo.finishTime - gLuaDataManager.serverTime))
	store.refuseText = string.format(BeggarConfig.PaintRefuseText, time)
end

M.UpdatePaint = function(self)
	if gBeggarManager:HasPaintTask() and not gBeggarManager:InPaintingTask() then
		local content = self.bindData.container.content

		if content then
			local store = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

			if store then
				self:RefreshRefuseText(store, gBeggarManager:GetCurPaintTaskInfo())
			end
		end
	end

	if self.paintReviewPoint and not gCS.LuaUtils.IsNull(self.paintReviewPoint) then
		local headPoint = self.paintReviewPoint.position
		local iconPos = Vector3.New(headPoint.x, headPoint.y, headPoint.z)
		local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(iconPos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
		local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.loadingRect.parent, Vector3.New(x, y, 0))

		self.bindData.loadingRect:SetLocalPositionXY(UIPos.x, UIPos.y)
	end
end

M.ShowPaintingResult = function(self, level, money, agentCid, npcPid)
	math.randomseed(os.time())

	self.paintResInfo = {
		level = level,
		money = money,
		agentCid = agentCid
	}
	local content = self.bindData.result.content

	if content then
		self.RefreshPaintingResultContent(self, content)
	else
		slot6 = self.bindData.result

		slot6:SetUrlWithCallback(self.paintResUrl, function (widget)
			self:RefreshPaintingResultContent(widget)
		end)
	end

	local signals = nil

	if level ~= gBeggarManager.PAINTING_RES_LEVEL.GREAT then
		signals = BeggarConfig.PaintReactionExciting
	elseif level ~= gBeggarManager.PAINTING_RES_LEVEL.BAD then
		signals = BeggarConfig.PaintReactionAngry
	end

	if signals and #signals <= 0 then
		local unit = gCS.SceneDataMgr.GetUnit(npcPid)

		if unit then
			local signal = array.random(signals)

			LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
		end
	end
end

M.RefreshPaintingResultContent = function(self, widget)
	if not self.paintResInfo then
		return
	end

	if not widget then
		return
	end

	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	if self.paintResInfo.agentCid <= 0 then
		local agentCfg = AgentConfig.GetConfig(self.paintResInfo.agentCid)

		if agentCfg then
			store.head = agentCfg.HeadIcon
		end
	end

	store.level = self.paintResInfo.level
	store.money = (self.paintResInfo.money > 0 and "+" or "-") .. tostring(self.paintResInfo.money)

	if self.paintResTimer then
		self.paintResTimer:Stop()

		self.paintResTimer = nil
	end

	self.paintResTimer = Timer.New(function ()
		self:ClosePaintingResult()
	end, 3):Start()
end

M.ClosePaintingResult = function(self)
	if self.paintResTimer then
		self.paintResTimer:Stop()

		self.paintResTimer = nil
	end

	if self.bindData.result then
		self.bindData.result.url = ""
	end
end

M.PaintNPCBeginReview = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit then
		self.paintReviewPoint = unit.ModelSlot.headSlot
		self.bindData.showReviewingCtrl = 1
	end
end

M.PaintNPCFinishReview = function(self)
	self.paintReviewPoint = nil
	self.bindData.showReviewingCtrl = 0
end

M.SwitchToFixCamera = function(self)
	if self.enableFixCam then
		return
	end

	self.enableFixCam = true
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("BeggarHudPanel")

	if not cmRegister then
		return
	end

	local playerTrans = MyPlayerManager.PlayerUnit.PlayerObj
	local worldPos = playerTrans.TransformPoint(playerTrans, BeggarConfig.DrawCamera1.offsetx, BeggarConfig.DrawCamera1.offsety, BeggarConfig.DrawCamera1.offsetz)
	local dir = Quaternion.Euler(BeggarConfig.DrawCamera1.eulerx, BeggarConfig.DrawCamera1.eulery, BeggarConfig.DrawCamera1.eulerz) * Vector3.forward
	local worldEuler = Quaternion.LookRotation(playerTrans.TransformDirection(playerTrans, dir)).eulerAngles
	local cameraName = "FixCam1"
	local cm = cmRegister.GetVcamByName(cmRegister, cameraName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFixCameraData(cm.gameObject, worldPos, worldEuler, BeggarConfig.DrawCamera1.fov)
	cmRegister:EnableVCamera(cameraName, LX6.Cinemachine.EVcamPriority.Panel)
end

M.SwitchToFreeLook = function(self)
	if not self.enableFixCam then
		return
	end

	self.enableFixCam = false
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("BeggarHudPanel")

	if cmRegister then
		cmRegister.DisableAllVCamera(cmRegister)
	end

	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(BeggarConfig.FreeLockActionStatusId, BeggarConfig.FreeLockActionSwitchTime, nil, 5)
end

M.SwitchToNormalFreeLook = function(self)
	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(BeggarConfig.FreeLockActionSwitchTime, nil, 5)
end
