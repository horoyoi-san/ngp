-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RestaurantGameplayHudTabStore.lua
-- Decompiled from: 00905_RestaurantGameplayHudTabStore.lua_738e1740e28e.luajit

local RestaurantConfig = LTConfig.RestaurantConfig
local RestaurantCameraSetConfig = LTConfig.RestaurantCameraSetConfig
C_RestaurantGameplayHudTabStore = DefClass("C_RestaurantGameplayHudTabStore", C_RestaurantGameplayHudTabStore)
C_RestaurantGameplayHudTabStore = DefClass("C_RestaurantGameplayHudTabStore", C_RestaurantGameplayHudTabStore, C_StoreGroup)
GroupName2Class.RestaurantGameplayHudTabStore = C_RestaurantGameplayHudTabStore
local M = C_RestaurantGameplayHudTabStore

M.OnStart = function(self)
	gRestaurantManager.curInteractionPanel = self

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.RegisterScrollEvent(self)
	end
end

M.OnShow = function(self, panelId, data)
	self.bDestroy = false

	self:RegisterMessageEvents(self:GetMessageEvents())

	self.isInviteMode = false
	self.cameraConfig = {}
	self.curCameraIndex = 0
	self.maxCameraIndex = 0
	self.autoShowButtons = false
	self.inviteCsUnit = nil
	self.npcDailyCfg = nil
	self.gameplayId = 0
	self.gameplayHudProStore = nil
	self.isHideExit = false
	self.openTime = Time.unscaledTime
	self.unlockMax = RestaurantConfig.UnlockExitTime
	self.isPhotoOpen = false
	self.npcInCameraLastState = nil
	self.idleTimer = 0
	self.idleIntervalRange = {}
	self.isNpcBlockIdleTimer = false
	self.isChatBlockIdleTimer = false
	self.isAfterMealActive = false
	self.afterMealStage = 0
	self.gameplayHudProStore = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")
	gRestaurantManager.curInteractionPanel = self
	self.isInviteMode = data.isInviteMode
	self.gameplayId = data.gameplayId
	self.useCustomLeaveDialog = data.useCustomLeaveDialog
	self.customLeaveDialogId = data.customLeaveDialogId
	self.useCustomChatDialog = data.useCustomChatDialog
	self.customChatDialogId = data.customChatDialogId

	if self.isInviteMode then
		self.isHideExit = true
		self.idleIntervalRange = RestaurantConfig.FreeTalkInterval
		self.isAfterMealActive = false
		self.afterMealStage = 0
		self.inviteCsUnit = data.inviteCsUnit
		self.npcDailyCfg = gRestaurantManager:GetCurrentInviteNpcDailyCfg()

		if self.npcDailyCfg and self.npcDailyCfg.Id then
			self.ShowDialog(self, self.npcDailyCfg.Dialog_Beforeeat)
		end
	end

	self.RefreshButtonState(self, false)

	self.autoShowButtons = true

	self.RefreshExitBtn(self)

	local cameraSetCfg = RestaurantCameraSetConfig.GetConfig(data.cameraSetId)

	if not cameraSetCfg then
		print_error("RestaurantCameraSetConfig is nil, cameraSetId=", data.cameraSetId, "策划检查配置！！！")
	else
		local cameraIdList = self.isInviteMode and cameraSetCfg.Camera_EatInvite or cameraSetCfg.Camera_EatAlone
		self.cameraConfig = gRestaurantManager:GetCameraConfigByIdList(cameraIdList)
		self.maxCameraIndex = #self.cameraConfig
		self.curCameraIndex = 0
	end

	gStoreManager:InvokeStoreMethod("GameplayHudProPanelStore", "RefreshBtnState")
	DoCallBack(data.onShowCallback)
end

M.OnClose = function(self)
	if self.npcInCameraTimer then
		self.npcInCameraTimer:Stop()

		self.npcInCameraTimer = nil
	end

	self.ClearMessageEvents(self)
end

M.OnDestroy = function(self)
	self.bDestroy = true
	self.isInviteMode = nil
	self.cameraConfig = nil
	self.curCameraIndex = nil
	self.maxCameraIndex = nil
	self.autoShowButtons = nil
	self.inviteCsUnit = nil
	self.npcDailyCfg = nil
	self.gameplayId = nil
	self.gameplayHudProStore = nil
	self.isHideExit = nil
	self.openTime = nil
	self.unlockMax = nil
	self.isPhotoOpen = nil
	self.npcInCameraLastState = nil
	self.idleTimer = nil
	self.idleIntervalRange = nil
	self.isNpcBlockIdleTimer = nil
	self.isChatBlockIdleTimer = nil
	self.isAfterMealActive = nil
	self.afterMealStage = nil
	self.useCustomLeaveDialog = nil
	self.customLeaveDialogId = nil
	self.useCustomChatDialog = nil
	self.customChatDialogId = nil
end

M.OnUpdate = function(self)
	if not self.isInviteMode then
		return
	end

	if self.isHideExit and self.unlockMax >= Time.unscaledTime - self.openTime then
		self.isHideExit = false

		self.RefreshExitBtn(self)
		print_notice("Npc动作播放又烂了，强制激活退出按钮！！！！")
	end

	if self.DEBUG then
		print_notice("self.isAfterMealActive", self.isAfterMealActive, "self.isNpcBlockIdleTimer", self.isNpcBlockIdleTimer, "self.isChatBlockIdleTimer", self.isChatBlockIdleTimer, "self.afterMealStage", self.afterMealStage)
	end

	if self.isAfterMealActive and not self.isNpcBlockIdleTimer and not self.isChatBlockIdleTimer then
		self.idleTimer = self.idleTimer - Time.deltaTime

		if self.idleTimer < 0 then
			self.OnAfterMealIdle(self)
		end
	end
end

M.UpdateNpcInCameraState = function(self)
	local unit = self.inviteCsUnit

	if not unit or L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
		return
	end

	local mainCamera = gCS.CameraDataMgr.MainCamera
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(unit.UpBodyPosition, mainCamera, 0, 0, 0)
	local isVisible = z > 0 and x > 0 and x < UnityEngine.Screen.width and y > 0 and y > UnityEngine.Screen.height
	self.npcInCameraLastState = isVisible

	if isVisible then
		gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantNpcInCamera)
	end
end

M.ProcessCommonGameplayOutwardSignal = function(self, _, signal)
	local pid = signal.GetPid(signal)
	local signalId = signal.GetCfgId(signal)

	if pid ~= gCS.MyPlayerManager.PlayerUnitId then
		if signalId ~= LTConfig.GameplaySignalOutwardConfig.RestaurantShowInteractButton then
			self.RefreshButtonState(self, true)
			self.SetActionButtonsActive(self, true)
		elseif signalId ~= LTConfig.GameplaySignalOutwardConfig.RestaurantLeave then
			self.Exit(self)
		else
			print_warn("[Restaurant] ProcessOutwardSignal not supported signal=", signalId)
		end

		return
	end

	if not self.isInviteMode or not self.inviteCsUnit or pid == self.inviteCsUnit.Pid then
		return
	end

	if signalId ~= LTConfig.GameplaySignalOutwardConfig.RestaurantNpcComment then
		self.OnNpcComment(self)
	elseif signalId ~= LTConfig.GameplaySignalOutwardConfig.RestaurantDrinkWater then
		self.OnNpcDrinkWater(self)
	elseif signalId ~= LTConfig.GameplaySignalOutwardConfig.RestaurantAfterMealTalk then
		self.OnNpcAfterMealTalk(self)
	elseif signalId ~= LTConfig.GameplaySignalOutwardConfig.RestaurantShowInteractButton then
		self.RefreshButtonState(self, true)
		self.SetActionButtonsActive(self, true)
	elseif signalId ~= LTConfig.GameplaySignalOutwardConfig.RestaurantLeave then
		self.Exit(self)
	else
		print_warn("[Restaurant] ProcessOutwardSignal not supported signal=", signalId)
	end
end

M.ShowRestaurantDialog = function(self, dialogId, endCallback)
	slot3 = gDialogManager

	slot3:ShowGeneralDialog(dialogId, gDialogSource.Restaurant, nil, , function (_, _, state, nextDialogId)
		if self.bDestroy then
			return
		end

		if nextDialogId ~= 0 and state ~= 0 and endCallback then
			endCallback()
		end
	end)
end

M.PickNpcCommentDialogId = function(self)
	if not self.npcDailyCfg then
		return false, 0
	end

	local foodList = gRestaurantManager.curFoodList or {}
	local dialogList = {}
	local favorList = self.npcDailyCfg.Dialog_Favored or {}

	for i = 1, #favorList do
		local favor = favorList[i]

		if favor.gameplayid ~= self.gameplayId then
			for j = 1, #foodList do
				if foodList[j] ~= favor.foodid then
					table.insert(dialogList, favor.dialogid)
				end
			end
		end
	end

	if #dialogList <= 0 then
		return true, dialogList[math.random(#dialogList)]
	end

	return false, 0
end

M.OnNpcComment = function(self)
	local isFavored, dialogId = self.PickNpcCommentDialogId(self)

	if isFavored then
		gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantNpcFavored)
	else
		gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantNpcNormal)
	end

	if dialogId <= 0 then
		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Restaurant)
	end

	self.isHideExit = false

	self.RefreshExitBtn(self)
end

M.OnNpcDrinkWater = function(self)
	local drinkProb = RestaurantConfig.DrinkProb

	if math.random() < drinkProb then
		gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantNpcDrink)
	else
		gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantNpcNotDrink)
	end
end

M.OnNpcAfterMealTalk = function(self)
	if not self.npcDailyCfg then
		return
	end

	self.RefreshButtonState(self, false)

	self.isAfterMealActive = true
	self.afterMealStage = 1

	self.RefreshIdleTimer(self)
end

M.RefreshButtonState = function(self, isShow)
	if self.gameplayHudProStore then
		self.gameplayHudProStore:SetEnable(isShow)
	end
end

M.SetActionButtonsActive = function(self, isShow)
	local store = self.gameplayHudProStore

	if not store then
		return
	end

	for _, list in ipairs({
		store.btnList,
		store.switchList
	}) do
		for i = 1, #list do
			local btnId = list[i].btnId

			if isShow then
				if store.checkAction[btnId] then
					store.checkAction[btnId]()
				else
					store.SetButtonActive(store, btnId, true)
				end

				if store.checkInterAction[btnId] then
					store.checkInterAction[btnId]()
				end
			else
				store.SetButtonActive(store, btnId, false)
			end
		end
	end
end

M.RefreshExitBtn = function(self)
	if self.gameplayHudProStore then
		self.gameplayHudProStore:SetBtnBackState(not self.isHideExit)
	end
end

M.SwitchCamera = function(self, bindVCam)
	if self.maxCameraIndex < 0 then
		return
	end

	self.curCameraIndex = self.curCameraIndex + 1

	if self.maxCameraIndex >= self.curCameraIndex then
		self.curCameraIndex = 0

		bindVCam.gameObject:SetActive(false)

		return
	end

	local cfg = self.cameraConfig[self.curCameraIndex]

	if cfg then
		local myUnit = gCS.MyPlayerManager.PlayerUnit

		bindVCam.gameObject:SetActive(true)
		gRestaurantManager:SetCameraView(myUnit, cfg, bindVCam)
	end
end

M.OnClickBtnSwitchCamera = function(self, vcam)
	local bindVCam = vcam or self.gameplayHudProStore and self.gameplayHudProStore.bindData.VCam

	if not gClientUtils.IsNil(bindVCam) then
		self.SwitchCamera(self, bindVCam)
	end
end

M.ShowDialog = function(self, dialogId)
	if dialogId <= 0 then
		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Restaurant)
	end
end

M.RefreshIdleTimer = function(self)
	self.idleTimer = math.random() * (self.idleIntervalRange[2] - self.idleIntervalRange[1]) + self.idleIntervalRange[1]

	print_debug("刷新下一次闲置间隔", self.idleTimer)
end

M.OnAfterMealIdle = function(self)
	if not self.isInviteMode then
		print_error("单人不需要闲置")

		return
	end

	if not self.npcDailyCfg then
		return
	end

	if self.afterMealStage ~= 1 then
		self.afterMealStage = 2
		self.isNpcBlockIdleTimer = true

		gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantNpcSit)

		local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(self.npcDailyCfg.Npcid)
		local dialogId = npcCfg and npcCfg.NoActionDialog or 0

		if dialogId ~= 0 then
			self.isNpcBlockIdleTimer = false

			self.RefreshIdleTimer(self)
		else
			self.ShowRestaurantDialog(self, dialogId, function ()
				self.isNpcBlockIdleTimer = false

				self:RefreshIdleTimer()
			end)
		end
	elseif self.afterMealStage ~= 2 then
		self.isAfterMealActive = false
		self.isNpcBlockIdleTimer = true

		gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantNpcBye)
		self:PlayNpcByeDialogAndExit()
	end
end

M.PlayNpcByeDialogAndExit = function(self)
	self.isAfterMealActive = false
	self.afterMealStage = 0
	self.isNpcBlockIdleTimer = true

	gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantNpcBye)

	local npcCfg = self.npcDailyCfg and LTConfig.NpcCultivationConfig.GetConfig(self.npcDailyCfg.Npcid)
	local dialogId = 0
	dialogId = (not self.useCustomLeaveDialog or self.customLeaveDialogId) and (npcCfg and npcCfg.LeaveDialog or 0)

	if dialogId ~= 0 then
		self.isNpcBlockIdleTimer = false

		self.Exit(self)

		return
	end

	self.ShowRestaurantDialog(self, dialogId, function ()
		self.isNpcBlockIdleTimer = false

		self:Exit()
	end)
end

M.OnClickBtnPhoto = function(self)
	self.isPhotoOpen = true
	self.npcInCameraTimer = Timer.New(function ()
		self:UpdateNpcInCameraState()
	end, 1, -1)

	self.npcInCameraTimer:Start()
	self:UpdateNpcInCameraState()
	gTakePhotoUtils.TryTakePhoto(nil, {
		["\\xd0\\xc82'\\xf4"] = true
	})

	local waitForBlackScreenTimer = Timer.New(function ()
		if self.inviteCsUnit and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(self.inviteCsUnit) then
			gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantTakePhoto)
		end

		gCS.CameraDataMgr.cinemachineManager:DisableCustomFreeLook(0.5, nil)
	end, 0.5)

	waitForBlackScreenTimer:Start()
end

M.OnPhotoClosed = function(self)
	self.isPhotoOpen = false
	self.npcInCameraLastState = nil

	if self.npcInCameraTimer then
		self.npcInCameraTimer:Stop()

		self.npcInCameraTimer = nil
	end

	if self.inviteCsUnit and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(self.inviteCsUnit) then
		gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantPhotoClose)
	end
end

M.OnClickBtnChat = function(self)
	if self.useCustomChatDialog and self.customChatDialogId <= 0 then
		self.isChatBlockIdleTimer = true

		self.ShowRestaurantDialog(self, self.customChatDialogId, function ()
			self.isChatBlockIdleTimer = false
		end)

		return
	end

	local unit = self.inviteCsUnit

	if L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
		return
	end

	self.isChatBlockIdleTimer = true
	local agentId = unit.ClientData.AgentId
	slot3 = gClientToGameDelegate

	slot3:GetCharacterRandomDialog(agentId, LTConfig.CharacterDialogConfig.MainTagType.standtalk, {
		223
	}).Callback = function (err, rpcDialogId)
		if self.bDestroy then
			return
		end

		if err == LTConfig.MessageConfig.Ok or rpcDialogId ~= 0 then
			print_error("GetCharacterRandomDialog error: ", err)

			self.isChatBlockIdleTimer = false

			return
		end

		slot2 = self

		slot2:ShowRestaurantDialog(rpcDialogId, function ()
			self.isChatBlockIdleTimer = false
		end)
	end
end

M.OnClickBtnCheers = function(self)
	self:SetActionButtonsActive(false)
	gRestaurantManager:SendGameplayInwardSignalToMe(LTConfig.GameplaySignalInwardConfig.RestaurantToast)

	if self.isInviteMode then
		gRestaurantManager:SendGameplayInwardSignalToNpc(LTConfig.GameplaySignalInwardConfig.RestaurantToast)

		if self.npcDailyCfg then
			self.ShowDialog(self, self.npcDailyCfg.Dialog_cheers)
		end
	end
end

M.OnClickBtnDrink = function(self)
	self:SetActionButtonsActive(false)
	gRestaurantManager:SendGameplayInwardSignalToMe(LTConfig.GameplaySignalInwardConfig.RestaurantDrinkWater)
end

M.OnClickBtnEatFries = function(self)
	self:SetActionButtonsActive(false)
	gRestaurantManager:SendGameplayInwardSignalToMe(LTConfig.GameplaySignalInwardConfig.RestaurantEatfries)
end

M.OnClickBtnExit = function(self)
	if self.isInviteMode then
		self.PlayNpcByeDialogAndExit(self)
	else
		self.Exit(self)
	end
end

M.Exit = function(self)
	self:OnClose()
	gRestaurantManager:ExitInteractionPlay(self.isInviteMode, false)
end

M.RegisterScrollEvent = function(self)
	local scrollEventListener = SGUI.EventSystems.ScrollEventListener.Get(self.bindData.backgroundWidget.gameObject)

	local onScroll = function(eventData)
		local scrollDeltaX = eventData.scrollDelta.x

		if scrollDeltaX == 0 then
			local ccm = gCS.CameraDataMgr.Instance.cameraControllerManager
			ccm.ZoomValue = ccm.ZoomValue + scrollDeltaX * LTConfig.GameConfig.WheelScrollCamZoom
		end
	end

	scrollEventListener.onScroll = onScroll
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = self.CreateAction(self, self.ProcessCommonGameplayOutwardSignal),
		[gEventConstants.PHOTO_CONTROLLER_DESTROY] = self.CreateAction(self, self.OnPhotoClosed)
	}
end
