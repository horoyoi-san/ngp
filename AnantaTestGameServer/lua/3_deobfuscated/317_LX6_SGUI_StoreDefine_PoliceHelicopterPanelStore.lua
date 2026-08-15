C_PoliceHelicopterPanelStore = DefClass("C_PoliceHelicopterPanelStore", C_PoliceHelicopterPanelStore, C_StoreGroup)
GroupName2Class.PoliceHelicopterPanelStore = C_PoliceHelicopterPanelStore
local M = C_PoliceHelicopterPanelStore
local Screen = UnityEngine.Screen
local DragEventListener = SGUI.EventSystems.DragEventListener
M.isSucceed = false
M.mouseAction = nil
M.isStart = false

function M:ctor()
	return
end

function M:OnAwake()
	return
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
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	data = data:ToTable()
	self.isStart = false
	self.isSucceed = false
	self.data = data
	self.transHigh = LTConfig.GameConfig.HelicopterHigh

	if data.pid then
		self.unit = gCS.SceneDataMgr.GetUnit(data.pid)
	end

	local pos = data.pos + Vector3.up * self.transHigh

	L50.L50App.Scene.GamePlayUtils:OnStartHelicopter(pos, function (tran)
		gLuaTimeMgrUtils.Delay(function ()
			gBlackScreenManager:CloseTransition(gBlackScreenId.POLICE_HELICOPTER, 1)
		end, 1)

		self.light = tran:Find("Light")
		self.follow = tran:Find("Follow")
		self.isStart = true

		self:OnMouseMove(nil, Vector2.zero)
		data.cb:DynamicInvoke()
	end)
	self:RefreshWidth()

	self.mouseAction = self:CreateAction("OnMouseMove")

	gMessageManager:AddMessageListener(gEventConstants.MOUSE_MOVE, self.mouseAction)

	self.bindData.exitBtn.luaClick = self:CreateAction("OnClickClose")
	self.bindData.rightStickCustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickRespondInput")
	local dragBtn = DragEventListener.Get(self.bindData.dragBtn.gameObject)
	dragBtn.onDrag = self:CreateAction("OnDrag")
	self.bindData.fill = 0
	self.bindData.root.localPosition = Vector3.zero
	self.curYAngle = 0
	self.curXAngle = 0
end

function M:OnUpdate()
	if not self.isStart or self.isSucceed then
		return
	end

	self:RefreshAim()

	if self.rotateParam then
		self:OnMouseMove(nil, self.rotateParam)
	end

	if self.isAim then
		self.bindData.state = 1
		self.bindData.fill = self.bindData.fill + 0.01

		if self.bindData.fill >= 1 then
			self:OnSucceed()
		end
	elseif self.isWarnAim then
		self.bindData.state = 3
		self.bindData.fill = 0
	else
		self.bindData.state = 0
		self.bindData.fill = 0
	end
end

M.screenLimitX = 100
M.screenLimitY = 100

function M:OnMouseMove(eventId, data)
	if not self.follow then
		return
	end

	if self.isSucceed then
		return
	end

	self.curYAngle = self.curYAngle + data.x * 0.1
	self.curXAngle = self.curXAngle - data.y * 0.2

	if self.curXAngle > 40 then
		self.curXAngle = 40
	end

	if self.curXAngle < -20 then
		self.curXAngle = -20
	end

	self.follow.localEulerAngles = Vector3.New(self.curXAngle, self.curYAngle, 0)
end

function M:RefreshAim()
	self:RefreshWidth()

	local screenPos = self.bindData.root.localPosition + Vector3.New(self.realWidth, self.realHeight, 0) * 0.5
	screenPos.x = screenPos.x * Screen.width / self.realWidth
	screenPos.y = screenPos.y * Screen.height / self.realHeight
	local lightPos = L50.L50App.Scene.GamePlayUtils:GetCrossPlanPos(screenPos, self.data.pos.y)
	local dir = lightPos - self.light.position
	local angle = Quaternion.LookRotation(dir).eulerAngles
	self.light.eulerAngles = angle
	local pos = self.unit.UpBodyPosition
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.root.parent, Vector3.New(x, y, 0))
	local delta = UIPos - self.bindData.root.localPosition
	self.isAim = math.abs(delta.x) < 70 and math.abs(delta.y) < 50

	if not self.isAim then
		if Time.frameCount % 3 == 0 then
			self.isWarnAim = L50.L50App.Scene.GamePlayUtils:IsHelicopterVehicleAim(self.bindData.root)
		end
	else
		self.isWarnAim = false
	end
end

function M:RefreshWidth()
	if Screen.width * 9 > Screen.height * 16 then
		self.realHeight = 1080
		self.realWidth = Screen.width / Screen.height * 1080
	else
		self.realHeight = Screen.height / Screen.width * 1920
		self.realWidth = 1920
	end
end

function M:OnDrag(eventPointer)
	self:OnMouseMove(nil, eventPointer.delta)
end

function M:OnSucceed()
	self.isSucceed = true
	self.bindData.state = 2

	gLuaTimeMgrUtils.Delay(function ()
		gClientToGameDelegate:AskPoliceStopHelicopterDispatch().Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
				print_error("AskPoliceStopHelicopterDispatch error:" .. err)

				return
			end

			gLuaTimeMgrUtils.Delay(function ()
				gPanelManager:Close(gPanelId.S_POLICE_HELICOPTER)
			end, 1, nil, nil, true)
		end
	end, 1, nil, nil, true)
end

function M:OnClickClose()
	gPanelManager:Close(gPanelId.S_POLICE_HELICOPTER)
end

function M:OnClose()
	L50.L50App.Scene.GamePlayUtils:OnEndHelicopter()
	gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.mouseAction)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnRightStickRespondInput(context)
	if context.performed then
		self.rotateParam = context:ReadValueVector2() * 2
	elseif context.canceled then
		self.rotateParam = nil
	end
end
