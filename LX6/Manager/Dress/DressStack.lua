-- Original chunk: @Lua\LuaFiles\LX6\Manager\Dress\DressStack.lua
-- Decompiled from: 00534_DressStack.lua_e18f31ea612f.luajit

local DragEventListener = SGUI.EventSystems.DragEventListener
local FashionBaseConfig = LTConfig.FashionBaseConfig
local FashionConfig = LTConfig.FashionConfig
gDressStack = gDressStack or {}
local M = gDressStack
local EInputButton = {
	["V'{O"] = 0,
	["1A\\x95\\x8a\\x8fD"] = 2,
	["\\xa7\\xa5\\xa7\\xa2"] = 1
}

M.Init = function(self)
	self.initFinish = false
	self.isRegister = false
	self.banMove = false
	self.banMoveHandler = nil
	self.hitHandler = nil
	self.lightPrefabOp = nil
	self.lightPrefab = nil
	self.basePanel = nil
	self.CameraRotateSpeed = 0
	self.banRotate = false
	self.cameraOffset = nil
	self.initTimer = nil
	self.delayUnloadLightTimer = nil
	self.dragging = false
	self.draggingUpDown = false
	self.lastPos = nil
	self.draggingGamePad = false
	self.gamePadPos = false
	self.isL2RespondInput = false
	self.isR2RespondInput = false
	self.firstMovementState = nil
	self.firstMovementStateParam = nil
	self.firstIsDressForm = nil
	self.firstIsDummyMode = nil
end

local panelStack = {}
local panelDict = {}
local stackSourceSet = {}

local UPDATE_DICT = function()
	table.clear(panelDict)

	for index, t in ipairs(panelStack) do
		local id = t.panelId
		panelDict[id] = index
	end
end

M.SetDressStack = function(self, panelId, enable, params)
	local wasEmpty = #panelStack ~= 0

	if not enable then
		if panelDict[panelId] ~= nil then
			return
		end

		local index = panelDict[panelId]

		table.remove(panelStack, index)
		UPDATE_DICT()
	elseif panelDict[panelId] ~= nil then
		local t = {
			panelId = panelId,
			params = params
		}

		table.insert(panelStack, 1, t)
		UPDATE_DICT()
	else
		local index = panelDict[panelId]
		local t = table.remove(panelStack, index)
		local tParams = t.params

		if not tParams.verticalButton or not not gCS.LuaUtils.IsNull(tParams.verticalButton) then
			t.params = params
		end

		table.insert(panelStack, 1, t)
		UPDATE_DICT()
	end

	if enable and wasEmpty and params and params.movementState then
		self.firstMovementState = params.movementState
		self.firstMovementStateParam = params.movementStateParam
		self.firstIsDressForm = params.isDressForm or false
	end

	if enable and wasEmpty and params and params.isDummyMode then
		self.firstIsDummyMode = params.isDummyMode or false
	end

	if enable and params and params.source and not stackSourceSet[params.source] then
		stackSourceSet[params.source] = true

		self:HandleSourceEnter(params.source)
	end

	self:UpdateDressPanelStack()
end

M.UpdateDressPanelStack = function(self)
	if #panelStack < 0 then
		self:RemoveEvent()

		if next(stackSourceSet) then
			for source, _ in pairs(stackSourceSet) do
				self:HandleSourceExit(source)
			end

			table.clear(stackSourceSet)
		end
	else
		local top = panelStack[1]
		local params = top.params

		self:RefreshPanelBinding(params.verticalButton, params.basePanel, params.rightStickCustomNavRespond, params.L2CustomNavRespond, params.R2CustomNavRespond, params.banRotate)
		self:RegisterEvent()
	end
end

M.HandleSourceEnter = function(self, source)
	if source ~= "milkCar" then
		LX6.Units.Module.UnitFashionInfoModule.AskOpenOrCloseFashionPanel(true, source)
	end
end

M.HandleSourceExit = function(self, source)
	if source ~= "milkCar" then
		LX6.Units.Module.UnitFashionInfoModule.AskOpenOrCloseFashionPanel(false, source)
	end
end

M.RegisterEvent = function(self)
	if self.isRegister then
		self.initFinish = true

		self:ResetCameraOffset()

		return
	end

	if not self.firstIsDummyMode then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.DressDefaultAction)
	end

	self.banMoveHandler = function(eventId, data)
		self:SetBanMove(data)
	end

	self.hitHandler = function(_, data)
		self:HandleHit(data)
	end

	gMessageManager:AddMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.banMoveHandler)
	gMessageManager:AddMessageListener(gEventConstants.PRE_HIT_UNIT, self.hitHandler)

	self.updateHandler = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandler)
	gDressCamera:CreateHiddenArea()
	self:LoadLight()

	if self.firstMovementState then
		gDressCamera:SetCameraHide(true, gPanelId.S_CHANGE_DRESS, self.firstIsDressForm)
	end

	self:AfterInitCamera()

	self.isRegister = true
end

M.RemoveEvent = function(self)
	if not self.isRegister then
		return
	end

	if self.delayUnloadLightTimer then
		self.delayUnloadLightTimer:Stop()

		self.delayUnloadLightTimer = nil
	end

	if not self.firstIsDummyMode then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.DressLeave)
	end

	UpdateBeat:RemoveListener(self.updateHandler)

	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

	if self.firstMovementState then
		gCS.CameraDataMgr.cinemachineManager:ExitMovementState(self.firstMovementState, self.firstMovementStateParam)
	end

	gMessageManager:RemoveMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.banMoveHandler)
	gMessageManager:RemoveMessageListener(gEventConstants.PRE_HIT_UNIT, self.hitHandler)
	gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(0, 1)
	gDressCamera:RemoveHiddenArea()

	if self.firstMovementState then
		gDressCamera:SetCameraHide(false, gPanelId.S_CHANGE_DRESS)
	end

	self.firstMovementState = nil
	self.firstMovementStateParam = nil
	self.firstIsDressForm = nil
	self.firstIsDummyMode = nil
	local hasUnloadLight = false

	if next(stackSourceSet) then
		for source, _ in pairs(stackSourceSet) do
			if source ~= "milkCar" then
				self.delayUnloadLightTimer = Timer.New(function ()
					self.delayUnloadLightTimer = nil

					self:UnloadLight()
				end, 2):Start()
				hasUnloadLight = true
			end
		end

		table.clear(stackSourceSet)
	end

	if not hasUnloadLight then
		self:UnloadLight()

		hasUnloadLight = true
	end

	self.isRegister = false

	gMessageManager:SendMessage(gEventConstants.FASHION_STACK_REAL_EXIT)
end

M.SetBanMove = function(self, data)
	self.banMove = data ~= 0
end

M.HandleHit = function(self, data)
	data = data:ToTable()
	local mePID = gCS.MyPlayerManager.PlayerUnit.Pid

	if not ulong.equals(data.HitPid, mePID) then
		return
	end

	local stack = table.clone(panelStack)

	for _, panel in ipairs(stack) do
		gPanelManager:Close(panel.panelId)
	end
end

M.LoadLight = function(self)
	if self.delayUnloadLightTimer then
		self.delayUnloadLightTimer:Stop()

		self.delayUnloadLightTimer = nil

		self:UnloadLight()
	end

	local isInDoor = gMapSystem.lastIndoorId == 0
	local outPath = "Res/Prefab/Sector/WorldMap_Release/prefab_light/DynamicLights/Dressingsystem_lights.prefab"
	local inDoorPath = "Res/Prefab/Sector/WorldMap_Release/prefab_light/DynamicLights/Dressingsystem_lights_indoor.prefab"
	local path = isInDoor and inDoorPath or outPath
	local position = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local rotation = gCS.MyPlayerManager.PlayerUnit.PlayerObj.rotation
	self.lightPrefabOp = gResourceManager:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		local lightPrefab = UnityEngine.GameObject.Instantiate(loadOp.asset)
		lightPrefab.gameObject.name = isInDoor and "FashionLight_InDoor" or "FashionLight_OutDoor"
		lightPrefab.gameObject.transform.position = position
		lightPrefab.gameObject.transform.rotation = rotation

		lightPrefab.gameObject.transform:SetLocalScale(1)

		self.lightPrefab = lightPrefab
	end)
end

M.UnloadLight = function(self)
	gResourceManager:UnloadAssetLoadOp(self.lightPrefabOp)

	if self.lightPrefab and not gCS.LuaUtils.IsNull(self.lightPrefab) then
		GameObject.Destroy(self.lightPrefab)

		self.lightPrefab = nil
	end
end

M.RefreshPanelBinding = function(self, verticalButton, basePanel, rightStickCustomNavRespond, L2CustomNavRespond, R2CustomNavRespond, banRotate)
	if verticalButton then
		local gestureListener = SGUI.EventSystems.GestureEventListener.Get(verticalButton.gameObject)
		gestureListener.onZoom = self:CreateAction("OnGestureZoom")
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false

		gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(FashionConfig.CameraYRange[1], FashionConfig.CameraYRange[2])

		local dragListener = DragEventListener.Get(verticalButton.gameObject)
		dragListener.onDrag = self:CreateAction("OnDrag")
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if rightStickCustomNavRespond then
			rightStickCustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickRespondInput")
		end

		if L2CustomNavRespond then
			L2CustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnL2RespondInput")
		end

		if R2CustomNavRespond then
			R2CustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnR2RespondInput")
		end
	end

	self.basePanel = basePanel
	self.banMove = false
	self.initFinish = false
	self.CameraRotateSpeed = FashionConfig.CameraRotateSpeed
	self.banRotate = banRotate
end

M.AfterInitCamera = function(self)
	self:ResetCameraOffset()

	if self.firstMovementState then
		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(self.firstMovementState, self.firstMovementStateParam)
	end

	self.initTimer = Timer.New(function ()
		self.initFinish = true
		self.initTimer = nil
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end, 1):Start()
end

M.ResetCameraOffset = function(self, spiritInfo)
	if not spiritInfo then
		local unit = self:GetCurrentUnit()
		local ctx = gDressManager:GetSpiritContext(nil, , unit)

		if ctx and ctx.spiritInfo then
			ctx.spiritInfo.spiritId = ctx.spiritId
		end

		spiritInfo = ctx and ctx.spiritInfo
	end

	if not spiritInfo then
		return
	end

	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritInfo.spiritId)

	if not spiritCfg then
		return
	end

	local agentCfg = LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)

	if not agentCfg then
		return
	end

	local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

	if modelCfg then
		local FashionBaseCfg = FashionBaseConfig.GetConfig(modelCfg.CameraBodyType or modelCfg.BodyType)

		if FashionBaseCfg then
			self.cameraOffset = FashionBaseCfg.CameraOffset
		end
	end
end

M.Update = function(self)
	if not self.initFinish then
		return
	end

	if not self.banRotate and self.draggingGamePad and self.gamePadPos and self.gamePadPos == Vector2.zero then
		if math.abs(self.gamePadPos.x) <= 3 then
			self:RotateModel(self.gamePadPos.x <= 0 and self.CameraRotateSpeed * 0.3 or -self.CameraRotateSpeed * 0.3)
		end

		if math.abs(self.gamePadPos.y) <= 3 then
			self:VerticalMoveCamera(-self.gamePadPos.y * 0.01)
		end
	end

	if self.isL2RespondInput then
		gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = 0.1
	end

	if self.isR2RespondInput then
		gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = -0.1
	end
end

M.GetCurrentUnit = function(self)
	local top = panelStack[1]

	if top and top.params and top.params.unitProvider then
		return top.params.unitProvider()
	end

	return gCS.MyPlayerManager.PlayerUnit
end

M.RotateModel = function(self, x)
	local top = panelStack[1]

	if top and top.params and top.params.weaponParentProvider then
		local weaponParent = top.params.weaponParentProvider()

		if weaponParent and not gCS.LuaUtils.IsNull(weaponParent) and weaponParent.transform.childCount <= 0 then
			local euler = weaponParent.transform.eulerAngles
			euler.y = euler.y + x
			weaponParent.transform.eulerAngles = euler

			return
		end
	end

	gDressManager:TransformPlayer(x, self:GetCurrentUnit())
end

local camTempVerticalVec3 = Vector3.New(0, 0, 0)

M.VerticalMoveCamera = function(self, y)
	if self.cameraOffset ~= nil then
		return
	end

	local camY = y + camTempVerticalVec3.y
	camY = Mathf.Clamp(camY, self.cameraOffset[1], self.cameraOffset[2])

	camTempVerticalVec3:Set(0, camY, 0)
	gMessageManager:SendMessage(gEventConstants.FASHION_CAM_SET_OFFSET, camY)
end

M.ResetVerticalOffset = function(self)
	camTempVerticalVec3 = Vector3.New(0, 0, 0)
end

M.OnGestureZoom = function(self, zoom)
	if not self.initFinish then
		return
	end

	if gCS.LuaUtils.GetCurrentHoverGo() ~= self.basePanel.gameObject then
		if gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled ~= false then
			gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled = true
		end

		if zoom <= 0 then
			gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = 0.1
		elseif zoom >= 0 then
			gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = -0.1
		end
	end
end

M.OnDrag = function(self, eventData)
	local delta = eventData.delta

	if delta:SqrMagnitude() >= 3 then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if eventData.button ~= EInputButton.Left then
			if not self.banRotate then
				self:RotateModel(-delta.x * self.CameraRotateSpeed * 0.05 * FashionConfig.ChangeCameraOffsetMouseDPI)
			end
		elseif eventData.button ~= EInputButton.Middle and not self.banMove then
			self:VerticalMoveCamera(-delta.y * FashionConfig.ChangeCameraOffsetMouseDPI * 0.1)
		end
	else
		if math.abs(delta.x) <= 4 and not self.banRotate then
			self:RotateModel(-delta.x * self.CameraRotateSpeed * 0.05 * FashionConfig.ChangeCameraOffsetMouseDPI)
		end

		if math.abs(delta.y) <= 4 then
			self:VerticalMoveCamera(-delta.y * FashionConfig.ChangeCameraOffsetMouseDPI * 0.01)
		end
	end
end

M.OnRightStickRespondInput = function(self, context)
	if context.started then
		self.draggingGamePad = true
	end

	if context.performed then
		local rotateParam = context:ReadValueVector2()
		self.gamePadPos = rotateParam * Time.deltaTime * 300 * -1
	end

	if context.canceled then
		self.draggingGamePad = false
		self.gamePadPos = nil
	end
end

M.OnL2RespondInput = function(self, context)
	if context.started then
		if gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled ~= false then
			gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled = true
		end

		self.isL2RespondInput = true
	end

	if context.canceled then
		self.isL2RespondInput = false
	end
end

M.OnR2RespondInput = function(self, context)
	if context.started then
		if gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled ~= false then
			gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled = true
		end

		self.isR2RespondInput = true
	end

	if context.canceled then
		self.isR2RespondInput = false
	end
end

M.CreateAction = function(self, action, target)
	return function (...)
		target = target or M

		if type(action) ~= "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

gDressStack = M
