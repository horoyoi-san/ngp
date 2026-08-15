local DragEventListener = SGUI.EventSystems.DragEventListener
local FashionBaseConfig = LTConfig.FashionBaseConfig
local FashionConfig = LTConfig.FashionConfig
gDressSetPanelCamera = gDressSetPanelCamera or {}
local M = gDressSetPanelCamera
local panelStack = {}
local panelDict = {}

local function UPDATE_DICT()
	table.clear(panelDict)

	for index, t in ipairs(panelStack) do
		local id = t.panelId
		panelDict[id] = index
	end
end

function M:SetDressPanelCamera(panelId, enable, params)
	if not enable then
		if panelDict[panelId] == nil then
			return
		end

		local index = panelDict[panelId]

		table.remove(panelStack, index)
		UPDATE_DICT()
	elseif panelDict[panelId] == nil then
		local t = {
			panelId = panelId,
			params = params
		}

		table.insert(panelStack, 1, t)
		UPDATE_DICT()
	else
		local index = panelDict[panelId]
		local t = table.remove(panelStack, index)

		table.insert(panelStack, 1, t)
		UPDATE_DICT()
	end

	self:UpdateDressPanelCamera()
end

function M:UpdateDressPanelCamera()
	if #panelStack <= 0 then
		self:RemoveEvent()
	else
		local top = panelStack[1]
		local params = top.params

		self:InitCamera(params.verticalButton, params.basePanel, params.rightStickCustomNavRespond, params.L2CustomNavRespond, params.R2CustomNavRespond, params.banRotate)
		self:RegisterEvent()
	end
end

function M:RegisterEvent()
	if self.isRegister then
		self.countFinish = true

		return
	end

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.DressDefaultAction)

	function self.handler(eventId, data)
		self:SetBanMove(data)
	end

	function self.hitHandler(_, data)
		self:HandleHit(data)
	end

	gMessageManager:AddMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.handler)
	gMessageManager:AddMessageListener(gEventConstants.PRE_HIT_UNIT, self.hitHandler)

	self.updateHandler = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandler)
	gDressCamera:CreateHiddenArea()
	gDressCamera:SetCameraHide(true, gPanelId.S_CHANGE_DRESS)
	self:LoadLight()
	self:AfterInitCamera()

	self.isRegister = true
end

function M:RemoveEvent()
	if not self.isRegister then
		return
	end

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.DressLeave)
	UpdateBeat:RemoveListener(self.updateHandler)

	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

	gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.TryFashion, nil)
	gMessageManager:RemoveMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.handler)
	gMessageManager:RemoveMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.hitHandler)
	gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(0, 1)
	gDressCamera:RemoveHiddenArea()
	gDressCamera:SetCameraHide(false, gPanelId.S_CHANGE_DRESS)
	self:UnloadLight()

	self.isRegister = false
end

function M:HandleHit(data)
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

function M:LoadLight()
	local isInDoor = gMapSystem.lastIndoorId ~= 0
	local outPath = "Res/Prefab/Sector/WorldMap_Release/prefab_light/DynamicLights/Dressingsystem_lights.prefab"
	local inDoorPath = "Res/Prefab/Sector/WorldMap_Release/prefab_light/DynamicLights/Dressingsystem_lights_indoor.prefab"
	local path = isInDoor and inDoorPath or outPath
	local position = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local rotation = gCS.MyPlayerManager.PlayerUnit.PlayerObj.rotation
	self.lightPrefabOp = gResourceManager:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		local lightPrefab = UnityEngine.GameObject.Instantiate(loadOp.asset)
		lightPrefab.gameObject.name = "FashionLight"
		lightPrefab.gameObject.transform.position = position
		lightPrefab.gameObject.transform.rotation = rotation

		lightPrefab.gameObject.transform:SetLocalScale(1)

		self.lightPrefab = lightPrefab
	end)
end

function M:UnloadLight()
	gResourceManager:UnloadAssetLoadOp(self.lightPrefabOp)

	if self.lightPrefab and not gCS.LuaUtils.IsNull(self.lightPrefab) then
		GameObject.Destroy(self.lightPrefab)

		self.lightPrefab = nil
	end
end

function M:InitCamera(verticalButton, basePanel, rightStickCustomNavRespond, L2CustomNavRespond, R2CustomNavRespond, banRotate)
	if verticalButton then
		local gestureListener = SGUI.EventSystems.GestureEventListener.Get(verticalButton.gameObject)
		gestureListener.onZoom = self:CreateAction("OnGestureZoom")
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false

		gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(FashionConfig.CameraYRange[1], FashionConfig.CameraYRange[2])

		local baseUpdownButton = DragEventListener.Get(verticalButton.gameObject)
		baseUpdownButton.onBeginDrag = self:CreateAction("OnBaseUpDownBtnPress")
		baseUpdownButton.onEndDrag = self:CreateAction("OnBasUpDowneBtnRelease")
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
	self.countFinish = false
	self.CameraRotateSpeed = FashionConfig.CameraRotateSpeed
	self.banRotate = banRotate
end

function M:AfterInitCamera()
	local FashionBaseCfg = FashionBaseConfig.GetConfig(gDressManager.CurrentSpiritInfo.CameraBodyType)

	if FashionBaseCfg then
		self.cameraOffset = FashionBaseCfg.CameraOffset
	end

	gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.TryFashion, nil)

	self.timer = Timer.New(function ()
		self.countFinish = true
		self.timer = nil
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end, 1):Start()
end

function M:OnlyRemoveListener()
	UpdateBeat:RemoveListener(self.updateHandler)
end

function M:DestroyCamera()
	UpdateBeat:RemoveListener(self.updateHandler)

	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

	gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.TryFashion, nil)
	gDressCamera:SetCameraHide(false, gPanelId.S_CHANGE_DRESS)
	gMessageManager:RemoveMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.handler)
	gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(0, 1)
	gDressCamera:RemoveHiddenArea()

	self.banMove = false
	self.countFinish = false
	self.basePanel = nil
	self.handler = nil
	self.banRotate = false
end

function M:SetBanMove(data)
	self.banMove = data == 0
end

function M:Update()
	if not self.countFinish or self.banRotate then
		return
	end

	if (self.dragging or self.draggingUpDown) and self.lastPos and self.lastPos.x and self.lastPos.y then
		local curPos = gUtils:GetTouchPosition()

		if self.lastPos.x - curPos.x ~= 0 or self.lastPos.y - curPos.y ~= 0 then
			if self.draggingUpDown then
				self:ChangeCameraOffset(self.lastPos.x - curPos.x > 0 and self.CameraRotateSpeed or -self.CameraRotateSpeed, self.lastPos.y - curPos.y, 0)
			else
				self:ChangeCameraOffset(0, self.lastPos.y - curPos.y, 0)
			end
		end

		self.lastPos = curPos
	end

	if self.dragGamePad and self.gamePadPos and self.gamePadPos ~= Vector2.zero then
		if math.abs(self.gamePadPos.x) > 3 then
			self:ChangeCameraOffset(self.gamePadPos.x > 0 and self.CameraRotateSpeed * 0.3 or -self.CameraRotateSpeed * 0.3, 0, 0)
		end

		if math.abs(self.gamePadPos.y) > 3 then
			self:ChangeCameraOffset(0, -self.gamePadPos.y * 0.01, 0)
		end
	end

	if self.isL2RespondInput then
		gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = 0.1
	end

	if self.isR2RespondInput then
		gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = -0.1
	end
end

local camTempVec3 = Vector3.New(0, 0, 0)

function M:ChangeCameraOffset(x, y)
	if self.cameraOffset == nil then
		return
	end

	if x == 0 then
		local camY = camTempVec3.y + y * FashionConfig.ChangeCameraOffsetMouseDPI

		if camY < self.cameraOffset[1] then
			camY = self.cameraOffset[1]
		end

		if self.cameraOffset[2] < camY then
			camY = self.cameraOffset[2]
		end

		camTempVec3:Set(0, camY, 0)
		gMessageManager:SendMessage(gEventConstants.FASHION_CAM_SET_OFFSET, camY)
	end

	if x ~= 0 then
		gDressManager:TransformPlayer(FashionConfig.ChangeCameraOffsetMouseDPI * x)
	end
end

function M:OnGestureZoom(zoom)
	if not self.countFinish then
		return
	end

	if gCS.LuaUtils.GetCurrentHoverGo() == self.basePanel.gameObject then
		if gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled == false then
			gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled = true
		end

		if zoom > 0 then
			gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = 0.1
		elseif zoom < 0 then
			gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = -0.1
		end
	end
end

function M:OnBaseUpDownBtnPress(eventData)
	if eventData.button == 2 then
		if not self.banMove then
			self.dragging = true
			self.lastPos = gUtils:GetTouchPosition()
		end
	elseif eventData.button == 0 then
		self.draggingUpDown = true
		self.lastPos = gUtils:GetTouchPosition()
	end
end

function M:OnBasUpDowneBtnRelease(eventData)
	if eventData.button == 2 then
		self.dragging = false
		self.lastPos = nil
	elseif eventData.button == 0 then
		self.draggingUpDown = false
		self.lastPos = nil
	end
end

function M:OnRightStickRespondInput(context)
	if context.started then
		self.dragGamePad = true
	end

	if context.performed then
		local rotateParam = context:ReadValueVector2()
		self.gamePadPos = rotateParam * Time.deltaTime * 300 * -1
	end

	if context.canceled then
		self.dragGamePad = false
		self.gamePadPos = nil
	end
end

function M:OnL2RespondInput(context)
	if context.started then
		if gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled == false then
			gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled = true
		end

		self.isL2RespondInput = true
	end

	if context.canceled then
		self.isL2RespondInput = false
	end
end

function M:OnR2RespondInput(context)
	if context.started then
		if gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled == false then
			gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled = true
		end

		self.isR2RespondInput = true
	end

	if context.canceled then
		self.isR2RespondInput = false
	end
end

function M:CreateAction(action, target)
	return function (...)
		target = target or M

		if type(action) == "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

gDressSetPanelCamera = M
