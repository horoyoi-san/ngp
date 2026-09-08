-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceHelicopterPanelStore.lua
-- Decompiled from: 00787_PoliceHelicopterPanelStore.lua_7fb5eaeebedc.luajit

C_PoliceHelicopterPanelStore = DefClass("C_PoliceHelicopterPanelStore", C_PoliceHelicopterPanelStore, C_StoreGroup)
GroupName2Class.PoliceHelicopterPanelStore = C_PoliceHelicopterPanelStore
local M = C_PoliceHelicopterPanelStore
local Screen = UnityEngine.Screen
local DragEventListener = SGUI.EventSystems.DragEventListener
M.roadMoveMinAngle = -20
M.roadMoveMaxAngle = 40
M.manualMoveMinAngle = -20
M.manualMoveMaxAngle = 60
M.roadAimTime = 5
M.manualAimTime = 3
M.maxFieldOfView = 50
M.minFieldOfView = 10
M.stopFieldOfView = 30

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.crimsList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderInteractionItem")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.zoomRespond.luaGamePadInputChanged = self.CreateAction(self, "OnZoomChanged")
	end
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.msgEvents = {
		[gEventConstants.SWITCH_HELICOPTER_MODE] = self.CreateAction(self, self.SwitchScanMode),
		[gEventConstants.HELICOPTER_TARGET_CHANGE] = self.CreateAction(self, self.HelicopterAimChange),
		[gEventConstants.HELICOPTER_SPEED_CHANGE] = self.CreateAction(self, self.HelicopterSpeedChange),
		[gEventConstants.HELICOPTER_UNITS_CHANGE] = self.CreateAction(self, self.HelicopterUnitsChange),
		[gEventConstants.HELICOPTER_MOVE_MODE_CHANGE] = self.CreateAction(self, self.HelicopterMoveModeChange),
		[gEventConstants.HELICOPTER_SEARCH_MODE_CHANGE] = self.CreateAction(self, self.HelicopterSearchModeChange)
	}

	self.RegisterMessageEvents(self, self.msgEvents)

	if not self.bindData.operateId then
		self.bindData.operateId = gStoreButtonMgr:RegisterOperation({
			["\\xde\\xc9\r\\xf5"] = 8,
			["\\xca\\xcf\t\r\\xf5"] = 5,
			["O\\xba\\xac\\x86\\xb2"] = 0,
			["\\xbb\\xa3\\xa4x7\\xea*"] = 1
		})
	end

	data = data:ToTable()
	self.bindData.isStart = false
	self.bindData.isSucceed = false
	self.data = data
	self.bindData.showFrame = data.searchMode ~= 3 and 1 or 0
	self.bindData.searchMode = data.searchMode
	self.bindData.frameFadeMode = data.frameFade ~= true
	self.bindData.frameFadeValue = 1
	self.bindData.moveType = data.type
	self.bindData.type = data.searchMode ~= 0 and 0 or 1
	L50.L50App.Scene.GamePlayUtils.helicopterMoveMode = data.type
	self.bindData.curXAngle = 30
	self.bindData.frameEnter = 0
	self.bindData.manualMoveMaxSpeed = 8
	self.bindData.transHigh = LTConfig.GameConfig.HelicopterHigh
	self.bindData.units = self:GetUnitsListByArr(data.pids)
	local pos = data.pos + Vector3.up * self.bindData.transHigh

	L50.L50App.Scene.GamePlayUtils:OnStartHelicopter(pos, function (tran)
		gLuaTimeMgrUtils.Delay(function ()
			gLuaTimeMgrUtils.Delay(function ()
				gBlackScreenManager:CloseTransition(gBlackScreenId.POLICE_HELICOPTER, 1)
			end, 1, nil, , true)
			data.cb:DynamicInvoke()
		end, 0.5, nil, , true)

		self.bindData.gadgetObj = tran
		self.bindData.gadgetStartPosY = tran.position.y

		if self:IsAutoMove() then
			self.bindData.curYAngle = 0
		else
			self.bindData.curYAngle = self.bindData.gadgetObj.localEulerAngles.y
		end

		self.bindData.light = tran:Find("Light")
		self.bindData.follow = tran:Find("Follow")
		self.bindData.isStart = true
		gGadgetManager.curHelicopterPos = self.bindData.gadgetObj.position

		self:OnMouseMove(nil, Vector2.zero)
	end)
	self:RefreshWidth()

	self.bindData.mouseAction = self:CreateAction("OnMouseMove")

	gMessageManager:AddMessageListener(gEventConstants.MOUSE_MOVE, self.bindData.mouseAction)

	self.bindData.exitBtn.luaClick = self:CreateAction("OnClickClose")
	self.bindData.rightStickCustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickRespondInput")
	local dragBtn = DragEventListener.Get(self.bindData.dragBtn.gameObject)
	dragBtn.onDrag = self:CreateAction("OnDrag")
	self.bindData.fill = 0
	self.bindData.root.localPosition = Vector3.zero
	self.bindData.openScan.luaClick = self:CreateAction("OnClickOpenScan")
	self.bindData.closeScan.luaClick = self:CreateAction("OnClickCloseScan")
	self.bindData.scanMode = 0
	self.bindData.scanBtnShow = 1

	if L50.L50App.Scene.GamePlayUtils.helicopterIsScanMode then
		self.SetScanMode(self, true)
	end

	self.bindData.curFov = 50
end

M.OnUpdate = function(self)
	if not self.bindData.isStart or self.IsTrackMode(self) and self.bindData.isSucceed or gCS.LuaUtils.IsNull(self.bindData.follow) then
		return
	end

	if self.bindData.gadgetObj then
		gGadgetManager.curHelicopterPos = self.bindData.gadgetObj.position
	end

	if self.bindData.rotateParam then
		self.OnMouseMove(self, nil, self.bindData.rotateParam)
	end

	self.RefreshManualMove(self)
	self.RefreshAim(self)

	if self.IsFrameSearchMode(self) then
		self.RefreshFrameView(self)

		return
	end

	if self.bindData.isAim then
		if not self.bindData.aimFinish then
			if self.bindData.fill ~= 0 and self.bindData.aimUnit then
				slot1 = gReliableRpcManager

				slot1:RegisterRPC(gClientToGameSceneDelegate.AskHelicopterNpc, self.bindData.aimUnit.Pid, 0, function (err)
					if err == LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)
					end
				end)
			end

			local totalTime = self:IsAutoMove() and self.roadAimTime or self.manualAimTime
			self.bindData.fill = self.bindData.fill + gLogicTime.deltaTime / totalTime

			if self.bindData.fill > 1 then
				self.OnAimFinish(self)
			else
				self.bindData.state = 1
			end
		end
	elseif self.bindData.isWarnAim then
		self.bindData.state = 3
		self.bindData.fill = 0
	else
		self.bindData.state = 0
		self.bindData.fill = 0
		self.bindData.aimFinish = false
	end
end

M.RefreshManualMove = function(self)
	if self.IsAutoMove(self) or gCS.LuaUtils.IsNull(self.bindData.gadgetObj) then
		self.bindData.showStaticTip = 0

		return
	end

	self.bindData.gadgetObj.localEulerAngles = Vector3.New(0, self.bindData.curYAngle, 0)
	local speedRate = Mathf.Clamp(1 - (self.bindData.curXAngle - self.manualMoveMinAngle) / (self.manualMoveMaxAngle - self.manualMoveMinAngle), 0, 1)
	speedRate = speedRate >= 0.1 and 0 or 1 - (1 - speedRate) / 0.9
	speedRate = 1 - (1 - speedRate) * (1 - speedRate)
	local isStop = self.bindData.curFov >= self.stopFieldOfView and not self:IsFrameSearchMode()
	self.bindData.showStaticTip = isStop and 1 or 2

	if isStop then
		speedRate = 0
	elseif not self.IsFrameSearchMode(self) then
		speedRate = speedRate * (self.bindData.curFov - self.stopFieldOfView) / (self.maxFieldOfView - self.stopFieldOfView)
	end

	local speed = self.bindData.manualMoveMaxSpeed * speedRate

	if not self.data.gadgetRigid then
		self.data.gadgetRigid = self.bindData.gadgetObj:GetComponent(typeof(UnityEngine.Rigidbody))
		self.data.gadgetRigid.isKinematic = false
	elseif gCS.LuaUtils.IsNull(self.data.gadgetRigid) then
		return
	end

	local pos = self.bindData.gadgetObj.position
	pos.y = self.bindData.gadgetStartPosY
	self.bindData.gadgetObj.position = pos
	self.data.gadgetRigid.velocity = self.bindData.gadgetObj.forward * speed
end

M.OnMouseMove = function(self, eventId, data)
	if gCS.LuaUtils.IsNull(self.bindData.follow) then
		gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.bindData.mouseAction)

		return
	end

	if self.IsAutoMove(self) and self.bindData.isSucceed then
		return
	end

	if not self.bindData.curYAngle then
		return
	end

	local curYAngle = self.bindData.curYAngle + data.x * 0.1
	local curXAngle = self.bindData.curXAngle - data.y * 0.2

	if self.IsAutoMove(self) then
		if self.roadMoveMaxAngle >= curXAngle then
			curXAngle = self.roadMoveMaxAngle
		end

		if curXAngle >= self.roadMoveMinAngle then
			curXAngle = self.roadMoveMinAngle
		end
	else
		if self.manualMoveMaxAngle >= curXAngle then
			curXAngle = self.manualMoveMaxAngle
		end

		if curXAngle >= self.manualMoveMinAngle then
			curXAngle = self.manualMoveMinAngle
		end
	end

	self.bindData.curXAngle = curXAngle
	self.bindData.curYAngle = curYAngle

	if self.IsAutoMove(self) then
		self.bindData.follow.localEulerAngles = Vector3.New(curXAngle, curYAngle, 0)
	else
		self.bindData.follow.localEulerAngles = Vector3.New(curXAngle, 0, 0)
	end
end

M.RefreshAim = function(self)
	self:RefreshWidth()

	local screenPos = self.bindData.root.localPosition + Vector3.New(self.bindData.realWidth, self.bindData.realHeight, 0) * 0.5
	screenPos.x = screenPos.x * Screen.width / self.bindData.realWidth
	screenPos.y = screenPos.y * Screen.height / self.bindData.realHeight
	local lightPos = L50.L50App.Scene.GamePlayUtils:GetCrossPlanPos(screenPos, self.data.pos.y)
	local dir = lightPos - self.bindData.light.position
	local angle = Quaternion.LookRotation(dir).eulerAngles
	self.bindData.light.eulerAngles = angle

	if self:IsFrameSearchMode() then
		return
	end

	local isAim = false
	local unitList = self.bindData.aimUnit and {
		self.bindData.aimUnit
	} or self.bindData.units
	local canSeeThroughObstacle = self:IsScanMode()
	local camPos = not canSeeThroughObstacle and gCS.CameraDataMgr.MainCamera.transform.position or nil

	for i = 1, #unitList do
		local unit = unitList[i]

		if not L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
			local pos = unit.UpBodyPosition
			local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
			local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.root.parent, Vector3.New(x, y, 0))
			local delta = UIPos - self.bindData.root.localPosition
			local inRange = math.abs(delta.x) >= 105 and math.abs(delta.y) <= 75

			if inRange and not canSeeThroughObstacle and not L50.L50App.Scene.HackManager:CheckVisiableForHelicopter(camPos, pos) then
				inRange = false
			end

			if inRange then
				isAim = true

				break
			end
		end
	end

	self.bindData.isAim = isAim

	if self.IsTrackMode(self) and not self.bindData.isAim then
		if Time.frameCount % 3 ~= 0 then
			self.bindData.isWarnAim = L50.L50App.Scene.GamePlayUtils:IsHelicopterVehicleAim(self.bindData.root)
		end
	else
		self.bindData.isWarnAim = false
	end
end

M.RefreshFrameView = function(self)
	local units = self.bindData.units

	if not units or #units ~= 0 then
		self.RefreshFrameFadeValue(self, false)

		return
	end

	local isInFrame = true
	local singleTarget = #units ~= 1
	local canSeeThroughObstacle = self:IsScanMode()
	local camPos = not canSeeThroughObstacle and gCS.CameraDataMgr.MainCamera.transform.position or nil

	for i = 1, #units do
		local unit = units[i]

		if L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
			isInFrame = false
		else
			local pos = unit.UpBodyPosition
			local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
			local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.root.parent, Vector3.New(x, y, 0))
			local delta = UIPos - self.bindData.root.localPosition

			if singleTarget then
				self.bindData.npcTip.localPosition = delta
			end

			if math.abs(delta.x) < 300 or math.abs(delta.y) > 200 then
				isInFrame = false
			elseif not canSeeThroughObstacle and not L50.L50App.Scene.HackManager:CheckVisiableForHelicopter(camPos, pos) then
				isInFrame = false
			end
		end
	end

	if not singleTarget then
		self.bindData.npcTip.localPosition = Vector3.New(99999, 99999, 0)
	end

	self:RefreshFrameFadeValue(isInFrame)

	if isInFrame == (self.bindData.frameEnter ~= 1) then
		self.bindData.frameEnter = isInFrame and 1 or 0

		print_debug("RefreshFrameView", isInFrame)

		for i = 1, #units do
			local unit = units[i]

			if not L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
				slot11 = gReliableRpcManager

				slot11:RegisterRPC(gClientToGameSceneDelegate.AskHelicopterNpc, unit.Pid, isInFrame and 3 or 4, function (err)
					if err == LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)
					end
				end)
			end
		end
	end
end

M.RefreshFrameFadeValue = function(self, isInFrame)
	if not self.bindData.frameFadeMode or not self.IsFrameSearchMode(self) then
		self.bindData.frameFadeValue = 1

		return
	end

	self.bindData.frameFadeValue = isInFrame and 1 or 0
end

M.IsAutoMove = function(self)
	return self.bindData.moveType ~= 0
end

M.IsManualMove = function(self)
	return self.bindData.moveType ~= 1
end

M.IsTargetUnit = function(self, unit)
	if not unit or not self.bindData.units then
		return false
	end

	for i = 1, #self.bindData.units do
		if self.bindData.units[i] ~= unit then
			return true
		end
	end

	return false
end

M.RefreshWidth = function(self)
	if Screen.width * 9 <= Screen.height * 16 then
		self.bindData.realHeight = 1080
		self.bindData.realWidth = Screen.width / Screen.height * 1080
	else
		self.bindData.realHeight = Screen.height / Screen.width * 1920
		self.bindData.realWidth = 1920
	end
end

M.OnDrag = function(self, eventPointer)
	self.OnMouseMove(self, nil, eventPointer.delta)
end

M.OnRenderInteractionItem = function(self, btn, index)
	local name = self.data.crimsList[index + 1]
	local store = gStoreManager:GetStoreGroup("HelicopterCrimsStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.text = name
end

M.RefreshCrims = function(self)
	self.data.crimsList = L50.L50App.Scene.GamePlayUtils:GetAgentCrimsText(self.bindData.aimUnit):ToTable()

	self.bindData.crimsList:SetSimpleList(#self.data.crimsList)

	local cfg = LTConfig.AgentConfig.GetConfig(self.bindData.aimUnit.TemplateId)
	self.bindData.crimTitle = cfg.Name
end

M.OnAimFinish = function(self)
	self.bindData.aimFinish = true

	if not self.IsTrackMode(self) then
		if self.IsTargetUnit(self, self.bindData.aimUnit) then
			self.bindData.isSucceed = true
			self.bindData.state = 2
		else
			self.bindData.state = 3
		end

		self.RefreshCrims(self)

		if not self.IsFrameSearchMode(self) then
			slot1 = gReliableRpcManager

			slot1:RegisterRPC(gClientToGameSceneDelegate.AskHelicopterNpc, self.bindData.aimUnit.Pid, 1, function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end)
		end
	else
		self.bindData.isSucceed = true
		self.bindData.state = 2

		gLuaTimeMgrUtils.Delay(function ()
			slot0 = gClientToGameDelegate

			slot0:AskPoliceStopHelicopterDispatch().Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
					print_error("AskPoliceStopHelicopterDispatch error:" .. err)

					return
				end
			end
		end, 1, nil, , true)
	end
end

M.OnClickClose = function(self)
	gPanelManager:Close(gPanelId.S_POLICE_HELICOPTER)
end

M.OnClose = function(self)
	self.bindData.aimUnit = nil
	self.bindData.units = nil

	self.SetScanMode(self, false)

	if self.bindData.operateId then
		gStoreButtonMgr:UnRegisterOperation(self.bindData.operateId)

		self.bindData.operateId = nil
	end

	self:ClearMessageEvents()
	L50.L50App.Scene.GamePlayUtils:OnEndHelicopter()
	gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.bindData.mouseAction)

	L50.L50App.Scene.GamePlayUtils.helicopterIsScanMode = false

	gCS.CameraDataMgr.cinemachineManager:SetFov(50, 0, 0, false)

	gGadgetManager.curHelicopterPos = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnRightStickRespondInput = function(self, context)
	if context.performed then
		self.bindData.rotateParam = context.ReadValueVector2(context) * 2
	elseif context.canceled then
		self.bindData.rotateParam = nil
	end
end

M.OnClickOpenScan = function(self)
	if self.IsScanMode(self) then
		return
	end

	self.SetScanMode(self, true)
end

M.OnClickCloseScan = function(self)
	if not self.IsScanMode(self) then
		return
	end

	self.SetScanMode(self, false)
end

M.SwitchScanMode = function(self, _, param)
	self.SetScanMode(self, param[0])
	self.SetScanBtnShow(self, param[1])
end

M.HelicopterAimChange = function(self, _, unit)
	if not self.IsFrameSearchMode(self) and self.bindData.isAim and unit then
		slot3 = gReliableRpcManager

		slot3:RegisterRPC(gClientToGameSceneDelegate.AskHelicopterNpc, unit.Pid, 2, function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end)
	end

	self.bindData.aimUnit = unit
end

M.HelicopterSpeedChange = function(self, _, speed)
	self.bindData.manualMoveMaxSpeed = speed
end

M.HelicopterUnitsChange = function(self, _, arr)
	self.bindData.units = self.GetUnitsListByArr(self, arr)
end

M.GetUnitsListByArr = function(self, arr)
	local list = {}
	local pids = arr.ToTable(arr)

	if pids then
		for i = 1, #pids do
			local u = L50.L50App.Scene.GamePlayUtils:GetLogicUnitByPid(pids[i])

			if u then
				list[#list + 1] = u
			end
		end
	end

	return list
end

M.HelicopterMoveModeChange = function(self, _, type)
	self.bindData.moveType = type
	self.data.type = type
	L50.L50App.Scene.GamePlayUtils.helicopterMoveMode = type
	self.bindData.gadgetStartPosY = self.bindData.gadgetObj.position.y

	if self.IsAutoMove(self) then
		self.bindData.curYAngle = 0
	else
		self.bindData.curYAngle = self.bindData.gadgetObj.localEulerAngles.y
	end
end

M.HelicopterSearchModeChange = function(self, _, mode, frameFade)
	self.bindData.aimFinish = false
	self.bindData.isSucceed = false
	self.bindData.showFrame = mode ~= 3 and 1 or 0
	self.bindData.searchMode = mode
	self.bindData.type = mode ~= 0 and 0 or 1
	self.bindData.state = 0
	self.bindData.fill = 0

	if frameFade == nil then
		self.bindData.frameFadeMode = frameFade ~= true
	end

	self:RefreshFrameFadeValue(self.bindData.frameEnter ~= 1)

	if self:IsTrackMode() then
		self.bindData.curFov = 50

		self.SetScanMode(self, false)
	end
end

M.IsFrameSearchMode = function(self)
	return self.bindData.showFrame ~= 1
end

M.IsSearchShowCrim = function(self)
	return self.bindData.searchMode ~= 1
end

M.IsTrackMode = function(self)
	return self.bindData.searchMode ~= 0
end

M.SetScanMode = function(self, open)
	self.bindData.scanMode = open and 1 or 0

	L50.L50App.Scene.GamePlayUtils:OnSwitchHelicopterScan(open)
	gClientToGameSceneDelegate:AskHelicopterScanChange(open)
end

M.SetScanBtnShow = function(self, open)
	self.bindData.scanBtnShow = open and 1 or 0
end

M.IsScanMode = function(self)
	return self.bindData.scanMode ~= 1
end

M.OnZoomChanged = function(self, context)
	if context.phase == 2 then
		return
	end

	local delta = -context.ReadValueVector2(context).y / 20

	self.SetFovByFocus(self, delta)
end

M.SetFovByFocus = function(self, delta)
	local curFOV = gCS.CameraDataMgr.MainCamera.fieldOfView + delta

	if self.maxFieldOfView >= curFOV then
		curFOV = self.maxFieldOfView
	end

	if curFOV >= self.minFieldOfView then
		curFOV = self.minFieldOfView
	end

	gCS.CameraDataMgr.cinemachineManager:SetFov(curFOV, 0.1, 0, false)

	self.bindData.curFov = curFOV
end
