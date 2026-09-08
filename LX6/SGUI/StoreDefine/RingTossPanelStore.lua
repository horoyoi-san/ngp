-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RingTossPanelStore.lua
-- Decompiled from: 00909_RingTossPanelStore.lua_701a2b3980a3.luajit

C_RingTossPanelStore = DefClass("C_RingTossPanelStore", C_RingTossPanelStore, C_StoreGroup)
GroupName2Class.RingTossPanelStore = C_RingTossPanelStore
local M = C_RingTossPanelStore
local Input = UnityEngine.Input
local DragEventListener = SGUI.EventSystems.DragEventListener
local PoiGameConfig = LTConfig.PoiGameConfig
local PoiGameRingTossConfig = LTConfig.PoiGameRingTossConfig
local RingTossManager = L50.Gameplay.RingToss.RingTossManager
local BOSS_REWARD_ID = 22

M.ctor = function(self)
	self.Init(self)
end

M.Init = function(self)
	self.isAimingState = false
	self.isArrowMoving = false
	self.hasDecideDirection = false
	self.curPressTime = 0
	self.isPressingSpace = false
	self.hasDecideForce = false
	self.curForceValue = 0
	self.curMovingDirection = -1
	self.curArrowZAngle = 0
	self.curStage = 3
	self.lastTouchPosX = nil
	self.gamepadStickInputX = 0
	self.stickUpdateHandler = nil
	self.aimMoveRatePC = 1
	self.aimMoveRateGamepad = 20
	self.rewardList = {}
	self.curRingCnt = 0
	self.dicHasPlayAnimation = {}

	for i = 1, PoiGameConfig.RingToss_RingCount do
		table.insert(self.rewardList, -1)
	end
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.stageEnum = {
		["]\\xa1\\xb5\\xaa\\xa4"] = 1,
		["\\xc9\\xc9\r6\\xf4"] = 3,
		["GN~lM\n6"] = 0,
		["K\\x9e\\x9c\\x86R"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.stageEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnUpdate = function(self)
	if self.isAimingState then
		return
	end

	if self.isPressingSpace then
		if not self.hasDecideForce then
			self.hasDecideForce = true
		end

		self.curPressTime = self.curPressTime + Time.deltaTime

		if PoiGameConfig.RingToss_MaxForceTime < self.curPressTime then
			self.curPressTime = PoiGameConfig.RingToss_MaxForceTime
		end

		self.SetProgressValue(self, self.curPressTime / PoiGameConfig.RingToss_MaxForceTime)
	elseif self.hasDecideForce then
		local progress = self.GetProgressValue(self)
		self.curForceValue = PoiGameConfig.RingToss_MinThrowForce + progress * (PoiGameConfig.RingToss_MaxThrowForce - PoiGameConfig.RingToss_MinThrowForce)
		self.isPressingSpace = false

		self.DoShootMotion(self)
	end
end

M.GetArrowStore = function(self)
	if not self.arrowStore then
		self.arrowStore = gStoreManager:GetStoreGroup("RingTossArrowPanelStore")

		if self.arrowStore then
			self.SyncArrowStoreState(self)
		end
	end

	return self.arrowStore
end

M.SyncArrowStoreState = function(self)
	local arrowStore = self.arrowStore

	if not arrowStore then
		return
	end

	if arrowStore.SetStage then
		arrowStore.SetStage(arrowStore, self.curStage)
	end

	if arrowStore.SetArrowLocalEulerAngles then
		arrowStore.SetArrowLocalEulerAngles(arrowStore, 0, 0, self.curArrowZAngle)
	end

	if arrowStore.SetProgressValue then
		arrowStore.SetProgressValue(arrowStore, self.curPressTime / PoiGameConfig.RingToss_MaxForceTime)
	end
end

M.SetProgressValue = function(self, value)
	local arrowStore = self.GetArrowStore(self)

	if arrowStore and arrowStore.SetProgressValue then
		arrowStore.SetProgressValue(arrowStore, value)
	end
end

M.GetProgressValue = function(self)
	local arrowStore = self.GetArrowStore(self)

	if arrowStore and arrowStore.GetProgressValue then
		return arrowStore.GetProgressValue(arrowStore)
	end

	return 0
end

M.SetArrowLocalEulerAngles = function(self, x, y, z)
	local arrowStore = self.GetArrowStore(self)

	if arrowStore and arrowStore.SetArrowLocalEulerAngles then
		arrowStore.SetArrowLocalEulerAngles(arrowStore, x, y, z)
	end
end

M.SetStage = function(self, stage)
	self.curStage = stage
	self.bindData.stage = stage
	local arrowStore = self.GetArrowStore(self)

	if arrowStore and arrowStore.SetStage then
		arrowStore.SetStage(arrowStore, stage)
	end
end

M.ConvertArrowAngleToWorldDir = function(self)
	local cameraForward = gCS.CameraDataMgr.MainCamera.transform.forward
	local cameraRight = gCS.CameraDataMgr.MainCamera.transform.right
	local angleRad = math.rad(self.curArrowZAngle)
	local forwardOffset = math.cos(angleRad)
	local rightOffset = math.sin(angleRad)
	local throwDir = cameraForward * forwardOffset + cameraRight * rightOffset
	throwDir.y = 0.3
	throwDir = throwDir.normalized

	return throwDir
end

M.DoShootMotion = function(self)
	self.curPressTime = 0

	self.SetProgressValue(self, 0)

	self.hasDecideForce = false

	RingTossManager.PlayerDoShoot(self.worldDir, self.curForceValue)

	self.curForceValue = 0
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self:SetProgressValue(0)
	self:SetArrowLocalEulerAngles(0, 0, 0)
	self:SetStage(self.stageEnum.prepare)
	self:Init()
	self.bindData.itemList:SetSimpleList(#self.rewardList)

	if RingTossManager.IsInAimState() then
		self.EnterAimState(self)
	end
end

M.EnterAimState = function(self)
	self.SetStage(self, self.stageEnum.direction)

	self.isAimingState = true
	self.isArrowMoving = true
	self.curArrowZAngle = 0

	self.SetArrowLocalEulerAngles(self, 0, 0, 0)

	self.curGame = RingTossManager.GetCurrentRingTossGame()
end

M.OnClose = function(self)
	self.StopStickUpdate(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.RING_TOSS_ENTER_AIM] = function ()
			self:EnterAimState()
		end,
		[gEventConstants.RING_TOSS_AFTER_THROW] = function ()
			self:SetStage(self.stageEnum.prepare)
		end,
		[gEventConstants.RING_TOSS_GAME_SETTLED] = function ()
			self:SetStage(self.stageEnum.scores)
			self:DestroyRingTossGame(false)
			gPanelManager:Close(self.m_Id)
		end,
		[gEventConstants.RING_TOSS_SINGLE_RESULT] = function (eventId, data)
			self:OnRingTossSingleResult(eventId, data)
		end,
		[gEventConstants.RING_TOSS_RESULT_CORRECTED] = function (eventId, throwIndex)
			self:OnRingTossResultCorrected(throwIndex)
		end
	}
end

M.OnRingTossSingleResult = function(self, eventId, data)
	self.curRingCnt = self.curRingCnt + 1
	self.rewardList[self.curRingCnt] = data

	self.bindData.itemList:SetSimpleList(#self.rewardList)
end

M.OnRingTossResultCorrected = function(self, throwIndex)
	if throwIndex ~= nil or throwIndex <= 1 or throwIndex <= #self.rewardList then
		return
	end

	self.rewardList[throwIndex] = 0

	self.bindData.itemList:SetSimpleList(#self.rewardList)
end

M.RegisterWidget = function(self)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItemListItem")
	self.bindData.itemList.onGetTIndex = self.CreateAction(self, "OnGetBtnTIndex")
	self.bindData.finalCloseBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.spaceBtn.luaPress = self.CreateAction(self, "OnPressSpaceBtn")
	self.bindData.spaceBtn.luaRelease = self.CreateAction(self, "OnReleaseSpaceBtn")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.mouseMoveResponse.luaGamePadInputChanged = self.CreateAction(self, "OnMouseMove")
	else
		local dragBtn = DragEventListener.Get(self.bindData.dragBtn.gameObject)
		dragBtn.onBeginDrag = self.CreateAction(self, "OnBtnBeginDrag")
		dragBtn.onDrag = self.CreateAction(self, "OnBtnDragging")
		dragBtn.onEndDrag = self.CreateAction(self, "OnBtnEndDrag")
	end
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local data = self.rewardList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data ~= BOSS_REWARD_ID then
		store.typeCtrl = 2

		return
	end

	if data and data <= 0 then
		local cfg = PoiGameRingTossConfig.GetConfig(data)

		if cfg then
			store.iconId = cfg.SguiID
			store.count = ""

			if cfg.Level ~= 1 then
				store.quality = 0
			elseif cfg.Level ~= 2 then
				store.quality = 3
			elseif cfg.Level ~= 3 then
				store.quality = 5
			end

			if self.dicHasPlayAnimation[index] == true then
				self.dicHasPlayAnimation[index] = true
				local DEFAULT_ANIMATION = "S_Vx_CommonItem156_open"

				if store.quality > 5 then
					DEFAULT_ANIMATION = "S_Vx_CommonItem156_open_Golden"
				end

				if store.animation and store.animation:GetClip(DEFAULT_ANIMATION) then
					store.animation:Play(DEFAULT_ANIMATION)
				end
			end
		end
	elseif data ~= -1 then
		store.typeCtrl = 1
	else
		store.typeCtrl = 0
	end
end

M.OnGetBtnTIndex = function(self, index)
	local data = self.rewardList[index + 1]

	if data ~= BOSS_REWARD_ID then
		return 1
	end

	if data and data <= 0 then
		return 0
	else
		return 1
	end
end

M.OnClickCloseBtn = function(self)
	self:DestroyRingTossGame(true)
	gPanelManager:Close(self.m_Id)
end

M.OnPressSpaceBtn = function(self)
	if self.isPressingSpace then
		return
	end

	if not self.isAimingState then
		return
	end

	self.hasDecideDirection = true
	self.isArrowMoving = false
	self.isAimingState = false

	self.StopStickUpdate(self)
	self.SetStage(self, self.stageEnum.power)

	self.worldDir = self.ConvertArrowAngleToWorldDir(self)

	RingTossManager.TransitionToChargingUp()

	self.isPressingSpace = true
end

M.OnReleaseSpaceBtn = function(self)
	if not self.isPressingSpace then
		return
	end

	self.isPressingSpace = false
end

M.OnMouseMove = function(self, context)
	if not self.isAimingState or not self.isArrowMoving then
		if context.canceled then
			self.StopStickUpdate(self)
		end

		return
	end

	if context.started then
		local v = context:ReadValueVector2()
		self.gamepadStickInputX = v and v.x or 0

		if self.stickUpdateHandler ~= nil then
			self.stickUpdateHandler = UpdateBeat:CreateListener(self.OnStickUpdate, self)

			UpdateBeat:AddListener(self.stickUpdateHandler)
		end

		if self.gamepadStickInputX == 0 then
			self.ApplyAimDelta(self, self.gamepadStickInputX)
		end
	elseif context.performed then
		local v = context:ReadValueVector2()
		self.gamepadStickInputX = v and v.x or 0
	elseif context.canceled then
		self.StopStickUpdate(self)
	end
end

M.OnStickUpdate = function(self)
	if not self.isAimingState or not self.isArrowMoving then
		self.StopStickUpdate(self)

		return
	end

	if self.gamepadStickInputX == 0 then
		self.ApplyAimDelta(self, self.gamepadStickInputX)
	end
end

M.StopStickUpdate = function(self)
	self.gamepadStickInputX = 0

	if self.stickUpdateHandler then
		UpdateBeat:RemoveListener(self.stickUpdateHandler)

		self.stickUpdateHandler = nil
	end
end

M.OnBtnBeginDrag = function(self, eventData)
	self.lastTouchPosX = eventData.position.x
end

M.OnBtnDragging = function(self, eventData)
	if not self.isAimingState or not self.isArrowMoving then
		return
	end

	local curX = eventData.position.x

	if self.lastTouchPosX ~= nil then
		self.lastTouchPosX = curX

		return
	end

	local deltaX = curX - self.lastTouchPosX
	self.lastTouchPosX = curX

	if deltaX == 0 then
		self.ApplyAimDelta(self, deltaX)
	end
end

M.OnBtnEndDrag = function(self, eventData)
	self.lastTouchPosX = nil
end

M.GetAimMoveRate = function(self)
	if gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.KeyboardMouse then
		return self.aimMoveRateGamepad * PoiGameConfig.RingToss_AimSwingSpeedGamepad
	end

	return self.aimMoveRatePC * PoiGameConfig.RingToss_AimSwingSpeed
end

M.ApplyAimDelta = function(self, deltaX)
	self.curArrowZAngle = self.curArrowZAngle + deltaX * self.GetAimMoveRate(self) * Time.deltaTime
	local maxAngle = PoiGameConfig.RingToss_AimSwingAngle

	if maxAngle >= self.curArrowZAngle then
		self.curArrowZAngle = maxAngle
	elseif self.curArrowZAngle >= -maxAngle then
		self.curArrowZAngle = -maxAngle
	end

	self.SetArrowLocalEulerAngles(self, 0, 0, self.curArrowZAngle)

	local blendValue = self.curArrowZAngle / maxAngle
	blendValue = -math.max(-1, math.min(1, blendValue))

	gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, blendValue, 0)
end

M.DestroyRingTossGame = function(self, abort)
	gRingTossNetMgr:Leave(abort)
	RingTossManager.DestroyGameSceneNode()
end
