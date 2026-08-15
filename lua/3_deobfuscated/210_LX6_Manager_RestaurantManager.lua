local function print_debug(...)
	_G.print_debug("[RestaurantManager]", ...)
end

local function print_warn(...)
	_G.print_warn("[RestaurantManager]", ...)
end

local function print_error(...)
	_G.print_error("[RestaurantManager]", ...)
end

local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local RestaurantConfig = LTConfig.RestaurantConfig
local RestaurantNpcDailyConfig = LTConfig.RestaurantNpcDailyConfig
local RestaurantFoodConfig = LTConfig.RestaurantFoodConfig
local LayerConstants = LX6.Constants.LayerConstants
local RestaurantCameraConfig = LTConfig.RestaurantCameraConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local RestaurantCameraSetConfig = LTConfig.RestaurantCameraSetConfig
local StaticProps = {
	NPC_ACTIONS = {
		SIT_IDLE = 1001
	},
	ORDER_MODE = {
		INVITE = 2,
		ALONE = 1,
		DATE = 3
	},
	DATE_STAGE = {
		NORMAL_ORDER = 3,
		PET_ANIMAL_ORDER = 2,
		PET_ANIMAL_TWO = 1,
		MAID_TEA_ORDER = 4,
		NONE = -1
	},
	GAME_STAGE = {
		ORDER = 1,
		DINE = 2,
		NONE = 0
	}
}
C_RestaurantManager = DefClass("C_RestaurantManager", C_RestaurantManager, nil, StaticProps)
local M = C_RestaurantManager

function M:ctor()
	self.dateStage = M.DATE_STAGE.NONE
	self.dateStageTask = nil
	self.setCamera = false
	self.currentGameplayId = nil
	self.curFoodList = nil
	self.isDinnerAlone = true
	self.curInteractionType = 0
	self.stuffNpc = nil
	self.inviteCsUnit = nil
	self.clientNpcInvited = false
	self.clientNpcCultivationId = nil
	self.inviteCameraSetId = 0
	self.invitePos = nil
	self.inviteTimeline = nil
	self.inviteTimelinePos = nil
	self.servingTimeline = nil
	self.servingTimelinePos = nil
	self.clientDefaultDateTask = 0

	function self.timelineEatCb()
		return
	end

	self.eatDialogId = -1
	self.eatDialogCb = nil
	self.datingNpcInRestaurant = false
	self.dateNpcCultivationId = nil
	self.dateNpcTask = nil
	self.dateTaskId = nil
	self.dateSpecialFoods = nil
	self.dateTaskDesc = ""
	self.dateDateTask = 0
	self.dateAnimalTask = nil
	self.dateAnimal = nil
	self.releaseLoadTimer = nil
	self.loadedTimeline = {}
	self.srcModelDict = {
		eating = "main_A106001_gm_actor(1)",
		hello = "被邀请者",
		beforeeat = "main_A106001_gm_actor(1)"
	}

	function self.dinnerDialogEndHandler()
		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END, self.dinnerDialogEndHandler)
		self:RevertRestaurantCameraView()
	end

	self.releaseTime = 60
	self.actionSignals = {
		Cheers = false,
		Drink = false,
		Chat = false,
		Exit = false,
		Eat = false
	}
	self.curInteractionPanel = nil
	self.curEatType = 0
	self.targetEatType = 0
	self.ORDER_STATE = {
		SUBMIT = 2,
		EXIT = 3,
		TAKE_PHONE = 1
	}
	self.curCameraSetId = nil
	self.msgEvents = {
		[gEventConstants.RESTAURANT_INVITE_NPC] = function (eventId, data)
			self:InviteClientNpc(data.npcId, data.gameplayId)
		end,
		[gEventConstants.ON_BEGIN_PORTAL] = function (eventId, data)
			self:OnBeginPortal()
		end
	}

	for event, func in pairs(self.msgEvents) do
		gMessageManager:AddMessageListener(event, func)
	end

	self.startRecordTime = 0
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		self.eatDialogId = -1
		self.curBuyFoodInfo = nil

		self:ClearDateNpc(nil, true)
		self:ClearInviteClientNpc()
		self:ClearDateStage(nil, true)
		self:ClearDateData(nil, true)
		self:ClearDateAnimal(nil, true)
		self:RevertRestaurantCameraView()
		self:UpdateGameplayId(nil)
		self:ReleaseTimeline()

		if self.preLoadTimer then
			self.preLoadTimer:Stop()

			self.preLoadTimer = nil
		end

		if gPanelManager:IsPanelShowing(gPanelId.S_RESTAURANT) then
			gPanelManager:Close(gPanelId.S_RESTAURANT)
		end
	end
end

function M:GetRestaurantCfg(gameplayId)
	for i = 0, RestaurantConfig.count - 1 do
		local cfg = RestaurantConfig.LoadAt(i)

		if cfg.GamePlayType == gameplayId then
			return cfg
		end
	end

	return nil
end

function M:GetNpcSpecialFoodCfg(npcCultivationId, dateTask)
	dateTask = dateTask or self.clientDefaultDateTask

	for i = 0, RestaurantNpcDailyConfig.count - 1 do
		local cfg = RestaurantNpcDailyConfig.LoadAt(i)

		if cfg.Npcid == npcCultivationId and cfg.DateTask == dateTask then
			local specialFood = cfg.FoodSpecial
			local foodCfg = RestaurantFoodConfig.GetConfig(specialFood)

			return foodCfg
		end
	end

	return nil
end

function M:GetNpcDailyCfg(npcCultivationId, dateTask)
	dateTask = dateTask or self.clientDefaultDateTask

	for i = 0, RestaurantNpcDailyConfig.count - 1 do
		local cfg = RestaurantNpcDailyConfig.LoadAt(i)

		if cfg.Npcid == npcCultivationId and cfg.DateTask == dateTask then
			return cfg
		end
	end

	return nil
end

function M:GetCurrentInviteNpcDailyCfg()
	return self:GetNpcDailyCfg(self:GetInviteCultivationId(), self:GetInviteDateTask())
end

function M:OnInviteNpcOutOfRange()
	self.inviteCsUnit = nil
	self.clientNpcInvited = false
end

function M:GetCommentDialogId(gameplayId, foodIdList, npcCultivationId, dateTask)
	local curNpcDailyConfig = self:GetNpcDailyCfg(npcCultivationId, dateTask)

	if curNpcDailyConfig == nil then
		print_warn("获取不到NpcDaily数据,请检查RestaurantNpcDailyConfig配表, npc=", npcCultivationId)

		return 0
	end

	local dialogList = {}
	local favorList = curNpcDailyConfig.Dialog_Favored

	for i = 1, #favorList do
		if gameplayId == favorList[i].gameplayid then
			for j = 1, #foodIdList do
				if foodIdList[j] == favorList[i].foodid then
					table.insert(dialogList, favorList[i].dialogid)
				end
			end
		end
	end

	if #dialogList < 1 then
		local dialogNormalList = curNpcDailyConfig.Dialog_Normal

		return self:GetDialogIdByGameplayId(dialogNormalList, self.currentGameplayId)
	elseif #dialogList == 1 then
		return dialogList[1]
	elseif #dialogList > 1 then
		return dialogList[math.random(1, #dialogList)]
	end
end

function M:SetInviteCameraSetId(id)
	self.inviteCameraSetId = id
end

function M:SetInviteParams(invitePos, inviteTimeline, inviteTimelinePos)
	self.invitePos = invitePos
	self.inviteTimeline = inviteTimeline

	if self.inviteTimeline == "" then
		self.inviteTimeline = nil
	end

	self.inviteTimelinePos = inviteTimelinePos
end

function M:SetServingParams(servingTimeline, servingTimelinePos)
	self.servingTimeline = servingTimeline

	if self.servingTimeline == "" then
		self.servingTimeline = nil
	end

	self.servingTimelinePos = servingTimelinePos
end

function M:AfterInviteClientNpc()
	local curRestaurantCfg = self:GetRestaurantCfg(self.currentGameplayId)
	local curNpcDailyCfg = self:GetNpcDailyCfg(self.clientNpcCultivationId, self.clientDefaultDateTask)

	if not curNpcDailyCfg then
		return
	end

	local inviteTimeline = self.inviteTimeline

	if not inviteTimeline then
		if not curRestaurantCfg or not curRestaurantCfg.Invitetl or not curNpcDailyCfg then
			print_error("餐饮店进场tl错误")

			return
		else
			inviteTimeline = curRestaurantCfg.Invitetl
		end
	end

	if self.inviteCsUnit then
		local tlData = gTimelineManager:Timeline_CreateTimelineData()
		local dynamicDialog = self:GetDialogIdByGameplayId(curNpcDailyCfg.Dialog_tl, self.currentGameplayId)

		if dynamicDialog and dynamicDialog > 0 then
			tlData.dynamicDialogIds = {
				dynamicDialog
			}
		end

		local bindInfos = {}
		local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.inviteCsUnit.Pid, self.srcModelDict.hello, nil)

		table.insert(bindInfos, c_bindInfo)

		tlData.bindUnitInfos = bindInfos

		gCS.BaseUnitUtils.SetUnitLogicalHidden(self.inviteCsUnit, true, LX6.Units.LogicalHiddenCause.GamePlay)

		function tlData.onPlayCb()
			if gDataSetManager:GetUnitData(self.inviteCsUnitPid) then
				gCS.BaseUnitUtils.SetUnitLogicalHidden(self.inviteCsUnit, false, LX6.Units.LogicalHiddenCause.GamePlay)
			end
		end

		function tlData.onFinishCb()
			self:StartRestaurantOrder(self.currentGameplayId, true, self.inviteCameraSetId)
		end

		if not gClientUtils.IsNil(self.inviteTimelinePos) then
			tlData.pos = self.inviteTimelinePos.position
			tlData.rot = self.inviteTimelinePos.eulerAngles
		end

		if self.preLoadTimer then
			self.preLoadTimer:Stop()

			self.preLoadTimer = nil
		end

		self.preLoadTimer = Timer.New(function ()
			self.preLoadTimer = nil

			gPanelManager:Preload(gPanelId.S_GAMEPLAY_HUD_PANEL)
		end, 0.5):Start()

		gTimelineManager:Timeline_LoadAndPlay(inviteTimeline, tlData)
	else
		print_error("self.inviteCsUnit 为空,邀约timeline播放失败")
	end

	self.inviteTimelinePos = nil
	self.inviteTimeline = nil
	self.invitePos = nil
end

function M:StartRestaurantOrder(gameplayId, isInvitePoint, cameraSetId)
	local InviteMode = isInvitePoint and self:IsJustInviteNpc()
	self.curCameraSetId = InviteMode and self.inviteCameraSetId or cameraSetId

	self:UpdateGameplayId(gameplayId)

	if self.curCameraSetId == nil then
		print_error("镜头组id获取不到")

		return
	end

	local cameraSetCfg = RestaurantCameraSetConfig.GetConfig(self.curCameraSetId)

	if cameraSetCfg == nil then
		print_error("餐饮店镜头组未找到对应cfg，id=", self.curCameraSetId)

		return
	end

	if InviteMode then
		gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
			gameplayType = "RestaurantOrder",
			params = {
				focusNpc = self.inviteCsUnit,
				mode = M.ORDER_MODE.INVITE,
				gameplayId = self.currentGameplayId,
				cameraIdList = cameraSetCfg.Camera_OrderInvite
			}
		})
	else
		gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
			gameplayType = "RestaurantOrder",
			params = {
				mode = M.ORDER_MODE.ALONE,
				gameplayId = self.currentGameplayId,
				cameraIdList = cameraSetCfg.Camera_OrderAlone
			}
		})
	end
end

function M:EndRestaurantOrder(buyFoodInfo, mode)
	self.curFoodList = buyFoodInfo.FoodIdList
	self.curBuyFoodInfo = buyFoodInfo
	local curRestaurantCfg = self:GetRestaurantCfg(self.currentGameplayId)
	local isInvite = mode == M.ORDER_MODE.INVITE and self:IsJustInviteNpc()
	local isDate = mode == M.ORDER_MODE.DATE and self.datingNpcInRestaurant

	if isDate then
		local cfg = self:GetCurrentInviteNpcDailyCfg()

		if cfg then
			self:SendSignalToGadget(cfg.OrderFinishSignal)
		else
			print_error("NpcDailyCfg is nil, cultivationId=", self:GetInviteCultivationId(), "dateTask=", self:GetInviteDateTask())
		end
	elseif isInvite then
		self:SendSignalToGadget("RESTAURANT_ORDER_FINISH_INVITE")
	else
		self:SendSignalToGadget("RESTAURANT_ORDER_FINISH_ALONE")
	end

	local tlData = gTimelineManager:Timeline_CreateTimelineData()

	function tlData.onFinishCb()
		self:SwitchOrderState(self.ORDER_STATE.SUBMIT)
		self:StartInteractionPlay(isInvite or isDate)
	end

	if isInvite or isDate then
		self.eatDialogId = self:GetCommentDialogId(self.currentGameplayId, self.curFoodList, self:GetInviteCultivationId(), self:GetInviteDateTask())
	end

	if not self.servingTimeline then
		if not curRestaurantCfg or not curRestaurantCfg.Servingtl then
			print_error("餐饮店过场tl错误")

			return
		else
			self.servingTimeline = curRestaurantCfg.Servingtl
		end
	end

	if not gClientUtils.IsNil(self.servingTimelinePos) then
		tlData.pos = self.servingTimelinePos.position
		tlData.rot = self.servingTimelinePos.eulerAngles
	end

	gTimelineManager:Timeline_LoadAndPlay(self.servingTimeline, tlData)

	self.servingTimeline = nil
	self.servingTimelinePos = nil
end

function M:OnBeginPortal()
	self:ExitRestaurantOrder(false)
end

function M:Spoon_ExitRestaurantOrder()
	self:ExitRestaurantOrder(true)
end

function M:ExitRestaurantOrder(switchAction)
	if not self.temp_inGame then
		return
	end

	self.temp_inGame = false

	if self.setFreeLook then
		gCS.CameraDataMgr.cinemachineManager:DisableCustomFreeLook(0.5, nil)

		self.setFreeLook = nil
	end

	self:SetReleaseTimer()
	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	self:RevertRestaurantCameraView()

	if switchAction and self.lastOrderState ~= gRestaurantManager.ORDER_STATE.EXIT then
		self:SwitchOrderState(gRestaurantManager.ORDER_STATE.EXIT)
	end
end

function M:StartInteractionPlay(isInvite)
	self.startRecordTime = Time.time
	self.isDinnerAlone = not isInvite

	gGamePlayTransitionMgr:EnterGamePlay(gGamePlayTransitionMgr.GamePlayType.Eat)
	self:SetSignal("Eat")

	self.targetEatType = self.isDinnerAlone and 1 or 6

	gGamePlayTransitionMgr:CheckSwitchAction()

	local params = nil

	if isInvite then
		params = {
			isInviteMode = true,
			inviteCsUnit = self.inviteCsUnit,
			cameraSetId = self.datingNpcInRestaurant and self.dateCameraId or self.curCameraSetId,
			gameplayId = self.currentGameplayId
		}
	else
		params = {
			isInviteMode = false,
			cameraSetId = self.curCameraSetId,
			gameplayId = self.currentGameplayId
		}
	end

	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
		gameplayType = "RestaurantInteraction",
		params = params
	})
end

function M:ExitInteractionPlay(isInvite)
	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(0.5, nil)

	self.setFreeLook = true
	self.curInteractionPanel = nil

	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)

	if isInvite then
		self:SendSignalToGadget("RESTAURANT_INTERACTION_FINISH_INVITE")
	else
		self:SendSignalToGadget("RESTAURANT_INTERACTION_FINISH_ALONE")
	end

	local recordTime = Time.time - self.startRecordTime

	local function exitFunc()
		local curRestaurantCfg = self:GetRestaurantCfg(self.currentGameplayId)
		local curRestaurantId = curRestaurantCfg.Id

		self:SetSignal("Exit")
		gGamePlayTransitionMgr:CheckSwitchAction()
		self:ClearSignals()
		gGamePlayTransitionMgr:EndGamePlay(gGamePlayTransitionMgr.GamePlayType.Eat)
		self:ClearInviteClientNpc()

		if self.curBuyFoodInfo then
			self.curBuyFoodInfo.MealTime = recordTime
		end

		gClientToGameSceneDelegate:AskRestaurantBuyFoods(self.curBuyFoodInfo).Callback = function (errID)
			if errID ~= 0 then
				print_error("AskRestaurantBuyFoods failed, error =", gCS.Error.GetNameById(errID))
			end
		end

		local playresult = {
			PlayType = UX.Game.UrbanGamePlayType.Restaurant,
			RestaurantResult = {
				RestaurantId = curRestaurantId
			}
		}

		gClientToGameDelegate:AskCompleteUrbanPlay(playresult)
	end

	if isInvite then
		gBlackScreenManager:AutoTransition(gBlackScreenId.RESTAURANT_INVITE, nil, false, false, 0.5, 1, 0.5, exitFunc)
	else
		exitFunc()
	end
end

function M:CheckConfigNoOk(unit, cfg)
	if cfg.eatType and cfg.eatType ~= 0 and cfg.eatType ~= self.targetEatType then
		return true
	end

	if cfg.eatNextTime and cfg.eatNextTime ~= 0 then
		if not self.curInteractionPanel or not self.curInteractionPanel.lastEatTime then
			return true
		end

		local lastTime = self.curInteractionPanel.lastEatTime
		local nowTime = Time.time

		if cfg.eatNextTime < nowTime - lastTime then
			return true
		end
	end

	return false
end

function M:OnActionChange(unit, cfg)
	if self.curInteractionPanel then
		self.curInteractionPanel:OnActionChange(cfg)
	else
		print_debug("[RestaurantManager] #NoCreateIssue 目前交互面板没有打开，忽略 GamePlayTransition eat 信号 ", cfg.Id)
	end
end

function M:InviteClientNpc(npcCultivationId, gameplayId)
	self:UpdateGameplayId(gameplayId)

	local clientNpcCultivationCfg = NpcCultivationConfig.GetConfig(npcCultivationId)

	self:ClearInviteClientNpc()
	self:GetRandomFashionList(npcCultivationId, function (fashionList)
		self.inviteCsUnit = gNpcInviteManager:InviteClientNpcForGamePlayWithPos(clientNpcCultivationCfg.RestaurantNpcid, gameplayId, self, self.invitePos, nil, fashionList)

		if self.inviteCsUnit then
			self.inviteCsUnitPid = self.inviteCsUnit.Pid
			self.clientNpcCultivationId = npcCultivationId
			self.clientNpcInvited = true
		end

		self:AfterInviteClientNpc()
	end)
end

function M:ClearInviteClientNpc()
	if self.clientNpcInvited and self.inviteCsUnit and gDataSetManager:GetUnitData(self.inviteCsUnitPid) then
		gNpcInviteManager:RemoveClientInviteNpc(self.inviteCsUnit)

		self.inviteCsUnit = nil
		self.clientNpcInvited = false
	end
end

function M:IsJustInviteNpc()
	return self.clientNpcInvited and not self.datingNpcInRestaurant
end

function M:SetDateNpc(npc_csunit, taskId, gameplayId, NPCTreat, NPCCultivationId)
	self:UpdateGameplayId(gameplayId)
	self:ClearDatingNpc()
	self:ClearInviteClientNpc()

	self.dateNpcTask = taskId
	self.inviteCsUnit = npc_csunit
	self.NPCTreat = NPCTreat
	self.datingNpcInRestaurant = true
	self.dateNpcCultivationId = NPCCultivationId
end

function M:ClearDateNpc(taskId, force)
	if force or self.dateNpcTask == taskId then
		self:ClearDatingNpc()
	end
end

function M:ClearDateAnimal(taskId, force)
	if force or self.dateAnimalTask == taskId then
		self.dateAnimal = nil
		self.dateAnimalTask = nil
	end
end

function M:ClearDatingNpc()
	if self.datingNpcInRestaurant then
		self.datingNpcInRestaurant = false
		self.inviteCsUnit = nil
		self.dateNpcTask = nil
		self.dateNpcCultivationId = nil
	end
end

function M:SetDateStage(stage, taskId)
	self.dateStage = stage
	self.dateStageTask = taskId
end

function M:ClearDateStage(taskId, force)
	if force or self.dateStageTask == taskId then
		self.dateStage = M.DATE_STAGE.NONE
		self.dateStageTask = nil
	end
end

function M:SetDateData(specialFoods, taskDescription, taskId, cameraId, dateTask)
	self.dateSpecialFoods = specialFoods
	self.dateTaskDesc = taskDescription
	self.dateTaskId = taskId
	self.dateCameraId = cameraId
	self.dateDateTask = dateTask
end

function M:ClearDateData(taskId, force)
	if force or self.dateTaskId == taskId then
		self.dateSpecialFoods = nil
		self.dateTaskDesc = ""
		self.dateTaskId = nil
		self.dateCameraId = nil
		self.dateDateTask = 0
	end
end

function M:IsInviteNpc()
	return self.clientNpcInvited or self.datingNpcInRestaurant
end

function M:UpdateGameplayId(gameplayId)
	self.currentGameplayId = gameplayId
end

function M:RecordAndLoadTimeline(timelineName, timelineData)
	timelineData = timelineData or gTimelineManager:Timeline_CreateTimelineData()
	timelineData.preLoadReleaseType = 3

	gTimelineManager:Timeline_TimelinePreLoad(timelineName, timelineData)
	table.insert(self.loadedTimeline, timelineName)
end

function M:SetReleaseTimer()
	self:RemoveReleaseTimer()

	if not table.isNilOrEmpty(self.loadedTimeline) then
		self.releaseLoadTimer = Timer.New(function ()
			self:ReleaseTimeline()
		end, self.releaseTime, nil, true):Start()
	end
end

function M:RemoveReleaseTimer()
	if self.releaseLoadTimer then
		self.releaseLoadTimer:Stop()

		self.releaseLoadTimer = nil
	end
end

function M:ReleaseTimeline()
	if self.loadedTimeline then
		for i = 1, #self.loadedTimeline do
			gTimelineManager:Timeline_DiscardTimeline(self.loadedTimeline[i])
		end

		self.loadedTimeline = {}
	end
end

function M:GetCameraConfigByIdList(idList)
	local cfgList = {}

	for _, id in pairs(idList) do
		local cfg = RestaurantCameraConfig.GetConfig(id)

		if cfg then
			table.insert(cfgList, cfg)
		else
			print_error("餐饮店镜头未找到有效配置，cameraId=", id)
		end
	end

	return cfgList
end

function M:GetDialogIdByGameplayId(dialogDataList, gameplayId)
	if not dialogDataList or not gameplayId then
		return 0
	end

	for i = 1, #dialogDataList do
		if gameplayId == dialogDataList[i].gameplayid then
			return dialogDataList[i].dialogid
		end
	end

	return 0
end

function M:SetRestaurantCameraView(csUnit, mode, cfg, bindVcam)
	local target = csUnit.ModelSlot and csUnit.ModelSlot.upbodySlot or csUnit.PlayerObj

	if mode == M.ORDER_MODE.ALONE then
		if cfg then
			gCS.CameraDataMgr.cinemachineManager.SetFixCamFacingTarget(bindVcam, target, cfg.OrderAloneDistance, cfg.OrderAloneScreenX, cfg.OrderAloneScreenY, cfg.OrderAloneFov)
		else
			gCS.CameraDataMgr.cinemachineManager.SetFixCamFacingTarget(bindVcam, target, 2.5, 0.78, 0.7)
		end
	elseif cfg then
		gCS.CameraDataMgr.cinemachineManager.SetFixCamFacingTarget(bindVcam, target, cfg.OrderDistance, cfg.OrderScreenX, cfg.OrderScreenY, cfg.OrderFov)
	else
		gCS.CameraDataMgr.cinemachineManager.SetFixCamFacingTarget(bindVcam, target, 2.5, 0.78, 0, -1)
	end

	self.setCamera = true

	gCS.CameraDataMgr:SetMainCameraCullingMask(gPanelId.S_RESTAURANT, LayerConstants.AllWithoutPlayer)
end

function M:RevertRestaurantCameraView()
	if self.setCamera then
		gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.S_RESTAURANT)

		self.setCamera = false
	end
end

function M:SetCameraView(unit, cfg, bindVCam)
	local trans = unit.PlayerObj
	local pos = trans:TransformPoint(cfg.PositionX, cfg.PositionY, cfg.PositionZ)
	local rot = Quaternion.Euler(trans.eulerAngles.x + cfg.RotationX, trans.eulerAngles.y + cfg.RotationY, trans.eulerAngles.z + cfg.RotationZ)
	bindVCam.transform.position = pos
	bindVCam.transform.rotation = rot

	gCS.LuaUtils.SetVCameraFOV(bindVCam, cfg.CameraFov)
end

function M:ClearSignals()
	for k, _ in pairs(self.actionSignals) do
		self.actionSignals[k] = false
	end
end

function M:GetSignal(key)
	local keys = table.keys(self.actionSignals)

	if table.contains(keys, key) then
		print_debug("[debug] actionSignals ", key, self.actionSignals[key])

		if self.actionSignals[key] then
			self.actionSignals[key] = false

			return true
		end

		return false
	else
		print_error("RestaurantManager没有相应动作信号，key=", key)
	end

	return false
end

function M:SetSignal(key)
	local keys = table.keys(self.actionSignals)

	if table.contains(keys, key) then
		if self.actionSignals[key] then
			print_warn("重复设置RestaurantManager动作信号，key=", key)

			return
		end

		self.actionSignals[key] = true
	else
		print_error("RestaurantManager没有相应动作信号，key=", key)
	end
end

function M:IsRestaurantEnterEat()
	return self:GetSignal("Eat")
end

function M:IsRestaurantExitEat()
	return self:GetSignal("Exit")
end

function M:IsRestaurantDrink()
	return self:GetSignal("Drink")
end

function M:IsRestaurantCheers()
	return self:GetSignal("Cheers")
end

function M:IsRestaurantChat()
	return self:GetSignal("Chat")
end

function M:IsDinnerAlone()
	return self.isDinnerAlone
end

function M:PlaySingleAction(csUnit, type, group, allTime, fadeInTime, startTime, realEnd, actionEndCB, transitionSchemaIndex)
	csUnit = csUnit or gCS.MyPlayerManager.PlayerUnit

	if group == nil then
		group = csUnit.State.ActionGroupId
	end

	if allTime == nil then
		allTime = -1
	end

	if fadeInTime == nil then
		fadeInTime = -1
	end

	if startTime == nil then
		startTime = 0
	end

	if realEnd == nil then
		realEnd = false
	end

	if transitionSchemaIndex == nil then
		transitionSchemaIndex = 0
	end

	gCS.AnimControllerManager.PlayAction(csUnit, type, group, allTime, startTime, fadeInTime, realEnd, actionEndCB, transitionSchemaIndex)
end

function M:SwitchOrderState(state)
	self.lastOrderState = state
	gCS.TransitionMgr.restaurantOrderState = state

	gCS.LuaUtils.CheckSwitchAction(true, true, false, 0)
end

function M:GetInviteCultivationId()
	return self.datingNpcInRestaurant and self.dateNpcCultivationId or self.clientNpcCultivationId
end

function M:GetInviteDateTask()
	return self.datingNpcInRestaurant and self.dateDateTask or self.clientDefaultDateTask
end

function M:GetRandomFashionList(npcCultivationId, callback)
	local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcCultivationId)
	local spiritId = npcCultivationCfg.FightSpiritID

	gClientToGameDelegate:AskGetNpcRandomWearFashions(spiritId).Callback = function (err, list)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			callback(0)
		else
			callback(list)
		end
	end
end

function M:Spoon_RestaurantDateIn(taskId, npc, DateNpcCultivationId, GameplayId, CameraId, DateTask, DateTaskDescriptionId, SpecialFoods, NPCTreat, autoShowOrderPanel)
	self.temp_inGame = true

	gCS.LookAtIkModule.StopLookAtIkPlugin(npc)
	gCS.UnitLookAtTargetModule.SetLookAtTargetEnabled(npc, false)
	self:SetDateStage(M.DATE_STAGE.NORMAL_ORDER, taskId)
	self:SetDateNpc(npc, taskId, GameplayId, NPCTreat, DateNpcCultivationId)

	local conf = TextCommonTextConfig.GetConfig(DateTaskDescriptionId)

	self:SetDateData(SpecialFoods, conf and conf.Text or "", taskId, CameraId, DateTask)

	local cameraSetCfg = RestaurantCameraSetConfig.GetConfig(CameraId)
	local cameraIdList = {}

	if cameraSetCfg then
		cameraIdList = cameraSetCfg.Camera_OrderInvite
	else
		print_error("RestaurantCameraSetConfig is nil, cameraSetId = ", CameraId, "策划检查配置！！！")
	end

	if autoShowOrderPanel then
		gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
			gameplayType = "RestaurantOrder",
			params = {
				focusNpc = self.inviteCsUnit,
				mode = C_RestaurantManager.ORDER_MODE.DATE,
				gameplayId = self.currentGameplayId,
				cameraIdList = cameraIdList,
				npcTreat = self.NPCTreat
			}
		})
	end
end

function M:Spoon_RestaurantDateOut(taskId)
	self:ClearDateStage(taskId)
	self:ClearDateNpc(taskId)
	self:ClearDateData(taskId)
end

function M:Spoon_RestaurantInvite(gameplayId, cameraSetId, invitePos, inviteTimeline, inviteTimelinePos, servingTimeline, servingTimelinePos, retrigger, entityInstanceId)
	self.temp_inGame = true

	if retrigger then
		if self.gadgetEntityInstanceId ~= entityInstanceId then
			print_error("重新点餐的机关和邀请NPC的机关不是同一个！", self.gadgetEntityInstanceId, entityInstanceId)
		end

		if gameplayId == 0 then
			gameplayId = self.currentGameplayId or gameplayId
		end

		gRestaurantManager:StartRestaurantOrder(gameplayId, true, cameraSetId)

		return
	end

	self.gadgetEntityInstanceId = entityInstanceId
	local cfg = self:GetRestaurantCfg(gameplayId)

	if cfg then
		self:SetInviteParams(invitePos, inviteTimeline, inviteTimelinePos)
		self:SetInviteCameraSetId(cameraSetId)
		gClientToGameSceneDelegate:AskRestaurantInviteNpc(cfg.Id)

		if servingTimelinePos then
			self:SetServingParams(servingTimeline, servingTimelinePos)
		end
	else
		print_error("邀请Npc出错，RestaurantConfig表里找不到对应的餐饮店配置，gameplayId = ", gameplayId)
	end
end

function M:Spoon_StartRestaurantOrder(gameplayId, cameraSetId, isInvitePoint, servingTimeline, servingTimelinePos, entityInstanceId)
	self.temp_inGame = true
	self.gadgetEntityInstanceId = entityInstanceId

	self:SetServingParams(servingTimeline, servingTimelinePos)

	if isInvitePoint == 0 then
		self:StartRestaurantOrder(gameplayId, false, cameraSetId)
	elseif isInvitePoint == 1 then
		self:StartRestaurantOrder(gameplayId, true, cameraSetId)
	end
end

function M:SendSignalToGadget(signalKey)
	local signal = {
		signalKey = signalKey,
		entityInstanceId = self.gadgetEntityInstanceId
	}

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, signal)
end

gRestaurantManager = gRestaurantManager or C_RestaurantManager.new()
