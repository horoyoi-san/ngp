local RestaurantConfig = LTConfig.RestaurantConfig
local RestaurantCameraSetConfig = LTConfig.RestaurantCameraSetConfig
C_RestaurantInteractionPanelStore = DefClass("C_RestaurantInteractionPanelStore", C_RestaurantInteractionPanelStore, C_StoreGroup)
GroupName2Class.RestaurantInteractionPanelStore = C_RestaurantInteractionPanelStore
local M = C_RestaurantInteractionPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.btnChat.luaClick = self:CreateAction("OnClickBtnChat")
	self.bindData.btnCheers.luaClick = self:CreateAction("OnClickBtnCheers")
	self.bindData.btnDrink.luaClick = self:CreateAction("OnClickBtnDrink")
	self.isInviteMode = false
	self.cameraConfig = {}
	self.curCameraIndex = 0
	self.maxCameraIndex = 0
	self.autoShowButtons = false
	self.inviteCsUnit = nil
	self.npcDailyCfg = nil
	self.gameplayId = 0
	self.gameplayHudPanelStore = nil
	self.isHideExit = false
	self.openTime = Time.unscaledTime
	self.unlockMax = RestaurantConfig.UnlockExitTime
	self.idleTimer = 0
	self.idleCount = 0
	self.idleIntervalRange = {}
	self.isPlayerBlockIdleTimer = false
	self.isNpcBlockIdleTimer = false
	self.isChatBlockIdleTimer = false
	self.ignoreCurPlayerAction = false
	self.idleDialogHandler = nil
	self.isStartFirstEat = false
	self.selfActionStage = 0
	self.selfActionFinishStage = 5
	self.lastEatTime = nil
	self.isNpcProcessEnd = false
	self.npcActionStage = 0
	self.npcActionMaxStage = 10
	self.npcDrinkProbability = 0
end

function M:OnShow(panelId, data)
	self.gameplayHudPanelStore = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	self.gameplayHudPanelStore:RegisterBtnBackCallback(function ()
		self:OnClickBtnExit()
	end)
	self.gameplayHudPanelStore:RegisterBtnSwitchViewCallback(function ()
		self:OnClickBtnSwitchCamera()
	end)
	self.gameplayHudPanelStore:SetBtnSwitchViewState(true)

	gRestaurantManager.curInteractionPanel = self
	self.isInviteMode = data.isInviteMode
	self.gameplayId = data.gameplayId
	self.bindData.showInviteButtonsCtrl = self.isInviteMode and 1 or 0

	if self.isInviteMode then
		self.isHideExit = true
		self.npcDrinkProbability = RestaurantConfig.DrinkProb
		self.idleIntervalRange = RestaurantConfig.FreeTalkInterval

		self:RefreshIdleTimer()

		self.inviteCsUnit = data.inviteCsUnit
		self.npcDailyCfg = gRestaurantManager:GetCurrentInviteNpcDailyCfg()

		if self.npcDailyCfg.Id then
			self:ProcessNpcAction()
		end
	end

	self:RefreshButtonState(false)

	self.autoShowButtons = true

	self:RefreshExitBtn()

	local cameraSetCfg = RestaurantCameraSetConfig.GetConfig(data.cameraSetId)

	if not cameraSetCfg then
		print_error("RestaurantCameraSetConfig is nil, cameraSetId=", data.cameraSetId, "策划检查配置！！！")
	end

	local cameraIdList = self.isInviteMode and cameraSetCfg.Camera_EatInvite or cameraSetCfg.Camera_EatAlone
	self.cameraConfig = gRestaurantManager:GetCameraConfigByIdList(cameraIdList)
	self.maxCameraIndex = #self.cameraConfig
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	if self.processNpcActionCo then
		coroutine.stop(self.processNpcActionCo)
	end

	self.doActionLock = nil
	self.currentCallback = nil
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnClose()
	return
end

function M:OnUpdate()
	if not self.isInviteMode then
		return
	end

	if self.isHideExit and self.unlockMax < Time.unscaledTime - self.openTime then
		self.isHideExit = false

		self:RefreshExitBtn()
		print_notice("Npc动作播放又烂了，强制激活退出按钮！！！！")
	end

	if self.DEBUG then
		print_notice("self.isNpcProcessEnd", self.isNpcProcessEnd, "self.isPlayerBlockIdleTimer", self.isPlayerBlockIdleTimer, "self.isNpcBlockIdleTimer", self.isNpcBlockIdleTimer, "self.isChatBlockIdleTimer", self.isChatBlockIdleTimer, "self.npcActionStage", self.npcActionStage, "self.idleCount", self.idleCount, "self.npcActionStage", self.npcActionStage, "gRestaurantManager.curEatType", gRestaurantManager.curEatType, "gRestaurantManager.targetEatType", gRestaurantManager.targetEatType)
	end

	if self.isNpcProcessEnd and not self.isPlayerBlockIdleTimer and not self.isNpcBlockIdleTimer and not self.isChatBlockIdleTimer then
		if self.idleTimer < 0 then
			self:RefreshIdleTimer()
			self:OnPlayerIdle()
		end

		self.idleTimer = self.idleTimer - Time.deltaTime
	end
end

function M:CurNpcDoAction(action, callback)
	local lastCallback = self.currentCallback
	self.currentCallback = callback

	if lastCallback then
		print_warn("RestaurantPanel NpcDoAction Failed, Lock", action)
		lastCallback()
	end

	self.doActionLock = true

	self:NpcDoAction(self.inviteCsUnit, action, function ()
		self.doActionLock = false
		local currentCallback = self.currentCallback

		if currentCallback then
			self.currentCallback = nil

			currentCallback()
		end
	end)
end

function M:NpcDoAction(csUnit, action, callback)
	if not action then
		print_error("餐饮店Npc交互流程行为配置为空")
		callback()

		return
	end

	if csUnit and action.actionid ~= 0 then
		gRestaurantManager:PlaySingleAction(csUnit, action.actionid, action.groupid, 0, 0.5, 0, nil, callback)
	end

	if csUnit and action.expressionid ~= 0 then
		if csUnit.ModelSlot.ExpressionController then
			csUnit.ModelSlot.ExpressionController:Init(csUnit, 2)
			csUnit.ModelSlot.ExpressionController:PlaySpecialExpression(action.expressionid, 0, true, 0)
		else
			print_warn("RestaurantPanel => Npc Play Expression Failed, ExpressionController is Nil (模型未配置表情组件).", csUnit.NpcId, csUnit.Pid)
		end
	end
end

function M:Interaction_SelfAction(signalName)
	gRestaurantManager:SetSignal(signalName)

	local ok = gGamePlayTransitionMgr:CheckSwitchAction()

	if not ok then
		print_warn("RestaurantPanel Interaction_SelfAction Failed, CheckSwitchAction Failed.", gCS.MyPlayerManager.PlayerUnit.State.nowInteractiveAction, gCS.MyPlayerManager.PlayerUnit.State.ActionGroupId)

		return
	end

	self.autoShowButtons = true

	self:RefreshButtonState(false)

	if self.isInviteMode then
		self:RefreshIdleTimer()

		self.isPlayerBlockIdleTimer = true
	end
end

function M:OnActionChange(cfg)
	if cfg.eatType and cfg.eatType ~= 0 then
		if not self.isInviteMode and gRestaurantManager.targetEatType == self.selfActionFinishStage then
			self:Exit()
		end

		self.lastEatTime = Time.time
		gRestaurantManager.curEatType = cfg.eatType
		gRestaurantManager.targetEatType = cfg.eatType + 1

		if gRestaurantManager.targetEatType > 8 then
			gRestaurantManager.targetEatType = gRestaurantManager.targetEatType - 5
		end
	end

	if cfg.eatNextTime and cfg.eatNextTime ~= 0 then
		gRestaurantManager.targetEatType = gRestaurantManager.curEatType
	end

	if self.isInviteMode and self.isPlayerBlockIdleTimer then
		self.isPlayerBlockIdleTimer = false

		print_debug("主角主动动作结束，解除idleTimer阻碍")
	end

	if self.autoShowButtons then
		self.autoShowButtons = false

		self:RefreshButtonState(true)
	end

	if cfg.TargetAniType == 14051 then
		self:RefreshButtonState(false)
	end
end

function M:RefreshButtonState(isShow)
	self.bindData.showButtonsCtrl = isShow and 1 or 0

	self.gameplayHudPanelStore:SetHideNodeState(isShow)
end

function M:RefreshExitBtn()
	self.gameplayHudPanelStore:SetBtnBackState(not self.isHideExit)
end

function M:ProcessNpcAction()
	self.processNpcActionCo = coroutine.start(function ()
		while true do
			if not self.doActionLock then
				self.processNpcActionCo = nil

				self:ProcessNpcActionImpl()

				return
			end

			coroutine.step()
		end
	end)
end

function M:ProcessNpcActionImpl()
	if self.isNpcBlockIdleTimer then
		return
	end

	if self.npcActionStage < self.npcActionMaxStage then
		self.npcActionStage = self.npcActionStage + 1
	end

	print_debug("RestaurantNpc SwitchActionStage=", self.npcActionStage)

	if self.npcActionStage == 1 then
		self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.BeforeEatAction), function ()
			self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.SittoEatAction), function ()
				self:ProcessNpcAction()
			end)
		end)
		self:ShowDialog(self.npcDailyCfg.Dialog_Beforeeat)
	elseif self.npcActionStage == 2 then
		self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.EatAction1), function ()
			self:ProcessNpcAction()
		end)
	elseif self.npcActionStage == 3 then
		self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.EatFavorAction), function ()
			self:ProcessNpcAction()
		end)

		if gRestaurantManager.eatDialogId > 0 then
			gDialogManager:ShowGeneralDialog(gRestaurantManager.eatDialogId, gDialogSource.Restaurant)
		end

		self.isHideExit = false

		self:RefreshExitBtn()
	elseif self.npcActionStage == 4 then
		if math.random() > 0.5 then
			self:ProcessNpcAction()
		else
			self:CurNpcDoAction(self.npcDailyCfg.DrinkAction, function ()
				self:ProcessNpcAction()
			end)
		end
	elseif self.npcActionStage == 5 then
		self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.EatAction2), function ()
			self:ProcessNpcAction()
		end)
	elseif self.npcActionStage == 6 then
		self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.EatAction3), function ()
			self:ProcessNpcAction()
		end)
	elseif self.npcActionStage == 7 then
		self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.EatAction4), function ()
			self:ProcessNpcAction()
		end)
	elseif self.npcActionStage == 8 then
		self:RefreshButtonState(false)
		self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.EattoSitAction), function ()
			self:ProcessNpcAction()
		end)

		local dialogId = gRestaurantManager:GetDialogIdByGameplayId(self.npcDailyCfg.Dialog_eatend, self.gameplayId)

		if dialogId > 0 then
			gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Restaurant)
		end
	elseif self.npcActionStage == 9 then
		self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.EatEndAction), function ()
			self.isNpcProcessEnd = true

			self:ProcessNpcAction()
		end)
	elseif self.npcActionStage == 10 then
		self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.AfterEatIdleAction))
	end
end

function M:SwitchCamera()
	self.curCameraIndex = self.curCameraIndex + 1

	if self.maxCameraIndex < self.curCameraIndex then
		self.bindData.VCam.gameObject:SetActive(false)

		self.curCameraIndex = 0
	else
		if self.curCameraIndex == 1 then
			self.bindData.VCam.gameObject:SetActive(true)
		end

		local cfg = self.cameraConfig[self.curCameraIndex]

		gUtils:SetCameraView(gCS.MyPlayerManager.PlayerUnit, cfg, self.bindData.VCam.gameObject)
	end
end

function M:GetRandomElement(list)
	if not list then
		return nil
	end

	return list[math.random(#list)]
end

function M:ShowDialog(dialogCfg)
	local dialogId = gRestaurantManager:GetDialogIdByGameplayId(dialogCfg, self.gameplayId)

	if dialogId > 0 then
		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Restaurant)
	end
end

function M:GetDialogId(dialogCfg)
	return gRestaurantManager:GetDialogIdByGameplayId(dialogCfg, self.gameplayId)
end

function M:RefreshIdleTimer()
	self.idleTimer = math.random() * (self.idleIntervalRange[2] - self.idleIntervalRange[1]) + self.idleIntervalRange[1]

	print_debug("刷新下一次闲置间隔", self.idleTimer)
end

function M:OnPlayerIdle()
	if not self.isInviteMode then
		print_error("单人不需要闲置")

		return
	end

	self.idleCount = self.idleCount + 1

	if self.idleCount == 1 then
		self.isNpcBlockIdleTimer = true

		if not self.doActionLock then
			self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.SitAction))
		end

		local dialogId = self:GetDialogId(self.npcDailyCfg.Dialog_sit)

		if dialogId == 0 then
			self.isNpcBlockIdleTimer = false
		else
			function self.idleDialogHandler(eventId, FirstDialogId)
				if FirstDialogId ~= dialogId then
					return
				end

				gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END, self.idleDialogHandler)

				self.idleDialogHandler = nil
				self.isNpcBlockIdleTimer = false
			end

			gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.idleDialogHandler)
			gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Restaurant)
		end

		return
	end

	if self.idleCount == 2 then
		self:RefreshButtonState(false)

		self.isNpcBlockIdleTimer = true

		if not self.doActionLock then
			self:CurNpcDoAction(self:GetRandomElement(self.npcDailyCfg.GoodbyeAction))
		end

		if self.idleDialogHandler then
			gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END, self.idleDialogHandler)

			self.idleDialogHandler = nil
		end

		local dialogId = self:GetDialogId(self.npcDailyCfg.Dialog_goodbye)

		if dialogId == 0 then
			self:Exit()
		else
			function self.idleDialogHandler(eventId, FirstDialogId)
				if FirstDialogId ~= dialogId then
					return
				end

				gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END, self.idleDialogHandler)

				self.idleDialogHandler = nil

				self:Exit()
			end

			gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.idleDialogHandler)
			gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Restaurant)
		end
	end
end

function M:OnClickBtnChat()
	self.isChatBlockIdleTimer = true
	local dialogId = self:GetDialogId(self.npcDailyCfg.Dialog_AfterDinner)

	if dialogId == 0 then
		self.isChatBlockIdleTimer = false
	else
		function self.playerDialogHandler(_, FirstDialogId)
			if FirstDialogId ~= dialogId then
				return
			end

			gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END, self.playerDialogHandler)

			self.isChatBlockIdleTimer = false
		end

		gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.playerDialogHandler)
		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Restaurant)
	end
end

function M:OnClickBtnCheers()
	self:Interaction_SelfAction("Cheers")

	if self.isInviteMode then
		local action = nil

		if self.npcActionStage <= 1 then
			action = self.npcDailyCfg.CheersAction1
		elseif self.npcActionStage <= 4 then
			action = self.npcDailyCfg.CheersAction2
		elseif self.npcActionStage == 5 then
			action = self.npcDailyCfg.CheersAction3
		elseif self.npcActionStage == 6 then
			action = self.npcDailyCfg.CheersAction4
		else
			action = self.npcDailyCfg.CheersAction5
		end

		self:CurNpcDoAction(action, function ()
			self:ProcessNpcAction()
		end)
		self:ShowDialog(self.npcDailyCfg.Dialog_cheers)
	end
end

function M:OnClickBtnDrink()
	self:Interaction_SelfAction("Drink")
end

function M:OnClickBtnSwitchCamera()
	self:SwitchCamera()
end

function M:OnClickBtnExit()
	if self.isInviteMode then
		self.idleCount = 1

		self:OnPlayerIdle()
	else
		self:Exit()
	end
end

function M:Exit()
	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	gRestaurantManager:ExitInteractionPlay(self.isInviteMode)
end
