-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FanChouTiSelectPanelStore.lua
-- Decompiled from: 01855_FanChouTiSelectPanelStore.lua_9318dda78534.luajit

C_FanChouTiSelectPanelStore = DefClass("C_FanChouTiSelectPanelStore", C_FanChouTiSelectPanelStore, C_StoreGroup)
GroupName2Class.FanChouTiSelectPanelStore = C_FanChouTiSelectPanelStore
local M = C_FanChouTiSelectPanelStore
local Input = UnityEngine.Input
local GameDevice = SGUI.GameDevice
local UCursorInput = SGUI.UCursorInput
local Rigidbody = UnityEngine.Rigidbody
local Screen = UnityEngine.Screen
local FixedUpdateBeat = FixedUpdateBeat
local FREEZE_ROTATION = 112
local GameInputManager = LX6.Manager.GameInputManager

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.isMobilePlatform = not gCS.LuaUtils.IsNonMobileAdaptive()

	if gCS.CameraDataMgr.MainCamera then
		self.camera = gCS.CameraDataMgr.MainCamera
	end
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.UnregisterFixedDrag(self)
	self.UnregisterTargetFly(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay, false, UnityEngine.CursorLockMode.None)

	self.slotEntity = data[3]
	self.instanceId = self.slotEntity.entityInstanceId
	self.targetItemName = data.targetItemName
	local entityY = self.slotEntity.gameObject.transform.position.y
	self.dragTargetY = entityY + (data.dragTargetYOffset or 0.7)
	self.dragMaxSpeed = data.dragMaxSpeed or 1.3
	self.targetFlyDistance = data.targetFlyDistance or 0.38
	self.targetFlyLiftYOffset = data.targetFlyLiftYOffset or 0
	self.targetFlyLiftDuration = data.targetFlyLiftDuration or 1.5
	self.targetFlyDuration = data.targetFlyDuration or 1.5
	self.targetFlyHoldDuration = data.targetFlyHoldDuration or 0.8
	self.targetFlySpeed = data.targetFlySpeed or 20

	self:SetItemsPhysics(true)
	self:InitGameState()
	self:ResetCursorPosition()
	self.bindData.PadCancelBtn:SetActive(false)
	self:SetBanButton()
end

M.OnClose = function(self)
	self.UnregisterFixedDrag(self)
	self.UnregisterTargetFly(self)
	self.SetItemsPhysics(self, false)
	UCursorInput.Inst.SetCursorDisplay(true)
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay)
	self.ClearBanButton(self)
end

M.SetBanButton = function(self)
	if not self.buttonBanId then
		self.buttonBanId = gStoreButtonMgr:RegisterOperation({
			["\\xca\\xcf\t\r\\xf5"] = 5,
			["\\xbb\\xa3\\xa4x7\\xea*"] = 0,
			groupId = LTConfig.HudDescGroupConfig.FanChouTi
		})
	end
end

M.ClearBanButton = function(self)
	if self.buttonBanId then
		gStoreButtonMgr:UnRegisterOperation(self.buttonBanId)

		self.buttonBanId = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device

	if not self.gamepadMode then
		self.bindData.selectBtnActive = true
	else
		self.bindData.selectBtnActive = false
	end

	if self.selectedItem then
		self.ReleaseItem(self)
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.SelectBtn.luaClick = self:CreateAction(self.OnClickSelectBtn)
	self.bindData.FakeSelectBtn.luaClick = self:CreateAction(self.OnClickFakeSelectBtn)
	self.bindData.PadCancelBtn.luaClick = self:CreateAction(self.OnClickPadCancelBtn)
	self.bindData.SelectBtn.luaBeginDrag = self:CreateAction("OnBeginDrag")
	self.bindData.SelectBtn.luaDrag = self:CreateAction("OnDrag")
	self.bindData.SelectBtn.luaEndDrag = self:CreateAction("OnEndDrag")
	UCursorInput.onCursorPosChange = self:CreateAction("OnCursorPosChange")
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
end

M.OnClickSelectBtn = function(self)
	if not self.gamepadMode then
		return
	end

	if not self.selectedItem then
		self.OnRealBeginDrag(self)
	elseif self.selectedItem then
		self.OnRealEndDrag(self)
	end
end

M.OnClickFakeSelectBtn = function(self)
	if not self.gamepadMode then
		return
	end

	if self.selectedItem then
		self.OnRealEndDrag(self, true)
	else
		self.OnRealBeginDrag(self)
	end
end

M.OnClickPadCancelBtn = function(self)
	if not self.gamepadMode then
		return
	end

	if self.selectedItem then
		self.OnRealEndDrag(self, true)
	end
end

M.ResetCursorPosition = function(self)
	self.currentCursorPos = Vector3.New(Screen.width / 2, Screen.height / 2, 0)

	UCursorInput.ResetCursorPos()
end

M.InitGameState = function(self)
	self.hasGameEnded = false
	self.selectedItem = nil
	self.enterDrag = false
	self.canShowUI = true
	self.beginDragPos = nil

	if self.bindData.mousePos then
		self.bindData.mousePos.gameObject:SetActive(true)
	end

	self.ResetCursorPosition(self)
end

M.OnBeginDrag = function(self, eventPointer)
	if self.gamepadMode then
		return
	end

	self.OnRealBeginDrag(self)
end

M.OnDrag = function(self, eventPointer)
	if self.gamepadMode then
		return
	end

	self.OnRealDrag(self)
end

M.OnEndDrag = function(self, eventPointer)
	if self.gamepadMode then
		return
	end

	self.OnRealEndDrag(self)
end

M.OnCursorPosChange = function(self, position)
	local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height
	local worldPos = rect.parent:TransformPoint(Vector3.New(position.x - width / 2, position.y - height / 2, 0))
	local pos = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
	self.currentCursorPos = Vector3.New(pos.x, pos.y, 0)

	if self.gamepadMode and self.selectedItem then
		self.OnRealDrag(self)
	end
end

M.OnRealBeginDrag = function(self)
	if self.hasGameEnded then
		return
	end

	local mainCamera = gCS.CameraDataMgr.Instance.MainCamera

	if not mainCamera then
		return
	end

	local ray = mainCamera.ScreenPointToRay(mainCamera, self.pos)

	print_debug("OnRealBeginDrag", self.pos)
	print_debug("OnRealBeginDrag", ray)

	local hits = gCS.LuaUtils.RaycastAll(ray.origin, ray.direction, 2, bit.lshift(1, LX6.Constants.LayerConstants._Decoration), false)
	local bestTf, bestDist = nil

	if hits then
		for i = 0, hits.Length - 1 do
			local hit = hits[i]
			local tf = hit.transform

			if tf then
				local d = hit.distance

				if not bestDist or d >= bestDist then
					bestDist = d
					bestTf = tf
				end
			end
		end
	end

	if bestTf then
		if bestTf.name ~= self.targetItemName then
			self.OnTargetFound(self, bestTf.gameObject)

			return
		end

		self.selectedItem = bestTf.gameObject
		self.enterDrag = true
		self.bindData.holdCtrl = 1
		self.beginDragPos = self.pos

		self.bindData.PadCancelBtn:SetActive(true)

		self.rb = self.selectedItem:GetComponent(typeof(Rigidbody))

		if self.rb then
			self.rbDragSaved = self.rb.drag
			self.rbAngularDragSaved = self.rb.angularDrag
			self.rbConstraintsSaved = self.rb.constraints
			self.rb.drag = 0
			self.rb.angularDrag = 0.05
			self.rb.constraints = FREEZE_ROTATION
			self.rb.useGravity = false
			self.dragTargetPos = self.rb.position

			self.RegisterFixedDrag(self)
		end
	else
		self.selectedItem = nil
	end
end

M.OnRealDrag = function(self)
	if not self.enterDrag or not self.selectedItem then
		return
	end

	local itemScreenPos = self.camera:WorldToScreenPoint(self.selectedItem.transform.position)
	local screenSpace = Vector3.New(self.pos.x, self.pos.y, itemScreenPos.z)
	local cursorWorldPos = self.camera:ScreenToWorldPoint(screenSpace)
	cursorWorldPos.y = self.dragTargetY
	self.dragTargetPos = cursorWorldPos
end

M.RegisterFixedDrag = function(self)
	if not self.fixedDragHandler then
		self.fixedDragHandler = FixedUpdateBeat:CreateListener(self.FixedDragUpdate, self)

		FixedUpdateBeat:AddListener(self.fixedDragHandler)
	end
end

M.UnregisterFixedDrag = function(self)
	if self.fixedDragHandler then
		FixedUpdateBeat:RemoveListener(self.fixedDragHandler)

		self.fixedDragHandler = nil
	end
end

M.FixedDragUpdate = function(self)
	if not self.rb or not self.dragTargetPos then
		return
	end

	local toTarget = self.dragTargetPos - self.rb.position
	local vel = toTarget / Time.fixedDeltaTime
	local maxSpeed = self.dragMaxSpeed

	if maxSpeed >= vel.magnitude then
		vel = vel.normalized * maxSpeed
	end

	self.rb.velocity = vel
end

M.OnRealEndDrag = function(self, isConfirmExit)
	if not self.enterDrag then
		return
	end

	self.bindData.PadCancelBtn:SetActive(false)

	self.bindData.holdCtrl = 0

	self:ReleaseItem()
end

M.ReleaseItem = function(self)
	self.UnregisterFixedDrag(self)

	if self.selectedItem then
		local rb = self.selectedItem:GetComponent(typeof(Rigidbody))

		if rb then
			rb.velocity = Vector3.zero
			rb.useGravity = true

			if self.rbConstraintsSaved == nil then
				rb.constraints = self.rbConstraintsSaved
			end

			if self.rbDragSaved == nil then
				rb.drag = self.rbDragSaved
			end

			if self.rbAngularDragSaved == nil then
				rb.angularDrag = self.rbAngularDragSaved
			end
		end

		self.rbDragSaved = nil
		self.rbAngularDragSaved = nil
		self.rbConstraintsSaved = nil
		self.selectedItem = nil
	end

	self.rb = nil
	self.dragTargetPos = nil
	self.enterDrag = false
	self.beginDragPos = nil
end

M.OnTargetFound = function(self, targetGo)
	if self.hasGameEnded then
		return
	end

	self.hasGameEnded = true
	self.canShowUI = false

	self:ReleaseItem()
	UCursorInput.Inst.SetCursorDisplay(false)
	UCursorInput.StopCursorSnap()
	self.bindData.PadCancelBtn:SetActive(false)

	self.bindData.leftControlActive = false
	self.bindData.fakeSelectBtnActive = false

	self.bindData.SelectBtn.gameObject:SetActive(false)

	if self.bindData.mousePos then
		self.bindData.mousePos.gameObject:SetActive(false)
	end

	if not targetGo then
		self.OnTargetFlyFinished(self)

		return
	end

	local rb = targetGo.GetComponent(targetGo, typeof(Rigidbody))

	if rb then
		rb.velocity = Vector3.zero
		rb.useGravity = false
		rb.isKinematic = false
		rb.constraints = FREEZE_ROTATION
	end

	self.flyRb = rb
	local cam = self.camera or gCS.CameraDataMgr.Instance.MainCamera
	self.flyItem = targetGo
	self.flyFromPos = targetGo.transform.position
	self.flyLiftPos = Vector3.New(self.flyFromPos.x, self.dragTargetY - self.targetFlyLiftYOffset, self.flyFromPos.z)
	local centerScreen = Vector3.New(Screen.width / 2, Screen.height / 2, self.targetFlyDistance)
	local center = cam:ScreenToWorldPoint(centerScreen)
	self.flyToPos = Vector3.New(center.x, center.y, center.z)
	self.flyTimer = 0
	self.flyHoldTimer = 0
	self.flyLiftDuration = self.targetFlyLiftDuration
	self.flyMoveDuration = self.targetFlyDuration

	self:RegisterTargetFly()
end

M.RegisterTargetFly = function(self)
	if not self.targetFlyHandler then
		self.targetFlyHandler = FixedUpdateBeat:CreateListener(self.TargetFlyUpdate, self)

		FixedUpdateBeat:AddListener(self.targetFlyHandler)
	end
end

M.UnregisterTargetFly = function(self)
	if self.targetFlyHandler then
		FixedUpdateBeat:RemoveListener(self.targetFlyHandler)

		self.targetFlyHandler = nil
	end
end

M.TargetFlyUpdate = function(self)
	if not self.flyItem or not self.flyRb then
		self.UnregisterTargetFly(self)

		return
	end

	self.flyTimer = self.flyTimer + Time.fixedDeltaTime
	local targetPos = nil

	if self.flyTimer < self.flyLiftDuration then
		local t = self.flyTimer / self.flyLiftDuration
		local smoothT = t * t * (3 - 2 * t)
		targetPos = Vector3.Lerp(self.flyFromPos, self.flyLiftPos, smoothT)
	else
		local t = (self.flyTimer - self.flyLiftDuration) / self.flyMoveDuration

		if t <= 1 then
			t = 1
		end

		local smoothT = t * t * (3 - 2 * t)
		targetPos = Vector3.Lerp(self.flyLiftPos, self.flyToPos, smoothT)

		if t > 1 then
			self.flyHoldTimer = self.flyHoldTimer + Time.fixedDeltaTime

			if self.targetFlyHoldDuration < self.flyHoldTimer then
				self.OnTargetFlyFinished(self)

				return
			end
		end
	end

	local vel = (targetPos - self.flyRb.position) / Time.fixedDeltaTime

	if self.targetFlySpeed >= vel.magnitude then
		vel = vel.normalized * self.targetFlySpeed
	end

	self.flyRb.velocity = vel
end

M.OnTargetFlyFinished = function(self)
	self.UnregisterTargetFly(self)

	if self.flyRb and not gCS.LuaUtils.IsNull(self.flyRb) then
		self.flyRb.velocity = Vector3.zero
	end

	self.flyRb = nil

	if self.flyItem then
		self.flyItem:SetActive(false)
	end

	self.flyItem = nil

	gSpoonClientMgr:TryCallInnerSignal(self.instanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, "TargetItemFound")
end

M.SetItemsPhysics = function(self, enable)
	if enable and self.slotEntity and self.slotEntity.gameObject then
		self.m_ItemRigidbodies = self.slotEntity.gameObject:GetComponentsInChildren(typeof(Rigidbody), true):ToTable()
	end

	if not self.m_ItemRigidbodies then
		return
	end

	for _, rb in ipairs(self.m_ItemRigidbodies) do
		if not gCS.LuaUtils.IsNull(rb) then
			rb.isKinematic = not enable
		end
	end
end

M.OnUpdate = function(self)
	if self.hasGameEnded then
		return
	end

	if self.canShowUI then
		self.bindData.leftControlActive = true
		self.bindData.fakeSelectBtnActive = true

		self.bindData.SelectBtn.gameObject:SetActive(true)
	else
		self.bindData.leftControlActive = false
		self.bindData.fakeSelectBtnActive = false
	end

	if not self.gamepadMode then
		self.pos = Input.mousePosition
	else
		self.pos = self.currentCursorPos
	end

	local toVec2 = function(pos)
		return Vector2.New(pos and pos.x or 0, pos and pos.y or 0)
	end

	local screenPos = gCS.LuaUtils.ScreenPointUI(self.bindData.snapTargetTemp, toVec2(self.pos))

	self.bindData.mousePos:SetLocalPositionXY(screenPos.x, screenPos.y)
end
