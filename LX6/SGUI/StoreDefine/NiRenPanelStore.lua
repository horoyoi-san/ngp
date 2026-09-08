-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NiRenPanelStore.lua
-- Decompiled from: 00932_NiRenPanelStore.lua_eb81a8b52b2c.luajit

C_NiRenPanelStore = DefClass("C_NiRenPanelStore", C_NiRenPanelStore, C_StoreGroup)
GroupName2Class.NiRenPanelStore = C_NiRenPanelStore
local M = C_NiRenPanelStore
local Input = UnityEngine.Input
local UCursorInput = SGUI.UCursorInput
local Screen = UnityEngine.Screen
local PinHaoBanDefine = LX6.Share.PinhaobanDefine
local PHBSlot = LX6.Share.PHBSlot
local Rigidbody = UnityEngine.Rigidbody
local GameInputManager = LX6.Manager.GameInputManager
local BodyType = {
	["\\xbeaa"] = 1,
	["1G\\x9f\\x85\\x86X"] = 0
}
local PartIndex = {
	["e\\xaf\\xac\\xab\\xba"] = 1,
	["e\\xaf\\xac\\xab\\xa4"] = 2,
	["R'|_"] = 0,
	["V'zH"] = 3
}
local PARTS_PER_BODY = 4

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.ClearEffects = function(self)
	if self.preHoverUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preHoverUUID)

		self.preHoverUUID = nil
	end

	if self.preSelectedItemUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedItemUUID)

		self.preSelectedItemUUID = nil
	end

	if self.hoverLoopSoundId then
		gSoundMgr:StopSoundByNid(self.hoverLoopSoundId)

		self.hoverLoopSoundId = nil
	end

	self.preHover = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.isMobilePlatform = not gCS.LuaUtils.IsNonMobileAdaptive()

	if gCS.CameraDataMgr.MainCamera then
		self.camera = gCS.CameraDataMgr.MainCamera
	end

	self.hoverAnimName = {
		"\\x9d3%\\xb7\\xaa\\xf1\\xe0Ҧ\\xe5\\xe6\\xdbr\\xe8\\xf9\\xb9\\x8c'\\xbb+\\x94\\xa9\\xd1ì\\xe9",
		"0ّ=/\\xfeT,\\xb1\\x8a&A\\xb3w\\xb2r%\\xaa&\\xf2\\x93*\\x9f",
		"0ّ=/\\xfeT,\\xb1\\x8a&A\\xb3w\\xb2r%\\xaa&\\xf2\\x93*\\x9c",
		"0ّ=/\\xfeT,\\xb1\\x8a&A\\xb3w\\xb2r%\\xaa&\\xf2\\x93*\\x9d"
	}
	local clip = self.bindData.hoverAnim0:GetClip(self.hoverAnimName[1])
	self.openDuration = clip and clip.length or 0.5
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	local taskId = gTaskNodeManager:GetNowDoingTask()

	if taskId == 0 then
		self.curTaskInfo, self.taskTargetList, self.nowTargetIndex = gTaskNodeManager:GetTaskCounterInfo(taskId)

		if self.curTaskInfo ~= nil then
			self.bindData.taskDes = ""
		else
			self.bindData.taskDes = self.curTaskInfo.WorkDescription
		end
	else
		self.bindData.taskDes = ""
	end

	GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay, true, UnityEngine.CursorLockMode.Confined)

	if data and data.sceneNode then
		self.sceneNode = data.sceneNode
	end

	self.instanceId = data.instanceId

	self:InitGameState()
	self:ResetCursorPosition()
	self.bindData.PadCancelBtn:SetActive(false)
end

M.OnClose = function(self)
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay)
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device

	if not self.gamepadMode then
		self.bindData.selectBtnActive = true
	else
		self.bindData.selectBtnActive = false
	end

	if self.selectedItem then
		self.ItemBackToInitPos(self)

		self.currentSelectedRealGo = nil
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.SelectBtn.luaClick = self.CreateAction(self, self.OnClickSelectBtn)
	self.bindData.ConfirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.FakeSelectBtn.luaClick = self.CreateAction(self, self.OnClickFakeSelectBtn)
	self.bindData.PadCancelBtn.luaClick = self.CreateAction(self, self.OnClickPadCancelBtn)
	self.bindData.SelectBtn.luaBeginDrag = self.CreateAction(self, "OnBeginDrag")
	self.bindData.SelectBtn.luaDrag = self.CreateAction(self, "OnDrag")
	self.bindData.SelectBtn.luaEndDrag = self.CreateAction(self, "OnEndDrag")

	for i = 0, 7 do
		self.bindData["slotHover" .. i].luaHover = self.CreateActionWithArgs(self, "OnHover", i)
		self.bindData["slotHover" .. i].luaUnhover = self.CreateActionWithArgs(self, "OnUnHover", i)
		self.bindData["slotHover" .. i].luaClick = self.CreateAction(self, "OnHoverSelect")
		self.bindData["slotHover" .. i].luaFocus = self.CreateActionWithArgs(self, "OnHover", i)
		self.bindData["slotHover" .. i].luaBlur = self.CreateActionWithArgs(self, "OnUnHover", i)
	end

	UCursorInput.onCursorPosChange = self:CreateAction("OnCursorPosChange")
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
end

M.OnClickSelectBtn = function(self)
	if not self.gamepadMode then
		return
	end

	if not self.selectedItem then
		self.OnRealBeginDrag(self)
	elseif self.selectedItem and self.isOnHover then
		self.OnRealEndDrag(self)
	end
end

M.OnClickConfirmBtn = function(self)
end

M.OnClickFakeSelectBtn = function(self)
	if not self.gamepadMode then
		return
	end

	if not self.selectedItem then
		self.OnRealBeginDrag(self)
	elseif self.selectedItem and self.isOnHover then
		self.OnRealEndDrag(self)
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
	self.currentSelectedRealGo = nil
	self.enterDrag = false
	self.curHoverSlotIndex = nil
	self.isOnHover = false
	self.canHover = true
	self.canShowUI = true
	self.slotHovering = {}
	self.slotHoverTimers = {}
	self.slotHoverBegun = {}
	self.hoverLoopSoundId = nil

	self.bindData.rotateImg.gameObject:SetActive(false)
	self.bindData.ConfirmBtn.gameObject:SetActive(false)
	self.bindData.WKey.gameObject:SetActive(false)
	self.bindData.AKey.gameObject:SetActive(false)
	self.bindData.SKey.gameObject:SetActive(false)
	self.bindData.DKey.gameObject:SetActive(false)

	slot1 = self.bindData.controllerImgs

	slot1:SetActive(false)

	self.monkeySlots = {
		[PartIndex.Head] = -1,
		[PartIndex.Handl] = -1,
		[PartIndex.Handr] = -1,
		[PartIndex.Legs] = -1
	}
	self.monkeySlotCount = 0
	self.monkeySlotPartTypes = {}
	self.pigSlots = {
		[PartIndex.Head] = -1,
		[PartIndex.Handl] = -1,
		[PartIndex.Handr] = -1,
		[PartIndex.Legs] = -1
	}
	self.pigSlotCount = 0
	self.pigSlotPartTypes = {}
	self.allParts = {}
	self.partInitData = {}
	self.allSlots = {}

	if self.sceneNode then
		local parts = self.sceneNode:GetComponentsInChildren(typeof(PinHaoBanDefine)):ToTable()

		for i, part in ipairs(parts) do
			table.insert(self.allParts, part)

			part.installedSlotIndex = -1

			part:SetTrigger(true)

			part.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = false
			self.partInitData[part] = {
				parent = part.transform.parent,
				position = part.transform.position,
				rotation = part.transform.rotation
			}
		end

		local slots = self.sceneNode:GetComponentsInChildren(typeof(PHBSlot)):ToTable()

		for _, slot in ipairs(slots) do
			self.allSlots[slot.slotIndex] = slot
		end
	end

	self.canHover = false
	self.canShowUI = false
	self.hoverPosReady = false

	Timer.New(function ()
		for i = 0, 7 do
			local slot = self.allSlots[i]

			if slot then
				local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(slot.transform.position, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
				local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.RootRect, Vector3.New(x, y, 0))

				self.bindData["rectHover" .. i]:SetLocalPosition(UIPos)
			end
		end

		self.hoverPosReady = true
		self.canHover = true
		self.canShowUI = true
	end, 1.5):Start()
	self:ResetCursorPosition()
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
	if self.hasGameEnded or not self.hoverPosReady then
		return
	end

	if self.currentSelectedRealGo and not gCS.LuaUtils.IsNull(self.currentSelectedRealGo) then
		self.selectedItem = self.currentSelectedRealGo

		if self.selectedItem.installedSlotIndex == -1 then
			self.UninstallPart(self, self.selectedItem)
		end

		self.canHover = false
		self.enterDrag = true

		self.bindData.PadCancelBtn:SetActive(true)

		for _, part in ipairs(self.allParts) do
			if part ~= self.selectedItem then
				part:SetTrigger(false)

				part.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = false
			else
				part.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true
			end
		end

		if self.preSelectedItemUUID then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedItemUUID)
		end

		self.preSelectedItemUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610836, LX6.Effect.EffectPlayTag.Gameplay, "NiRenGameSelect_" .. tostring(self.selectedItem.type) .. "_" .. tostring(self.selectedItem.index), self.selectedItem.gameObject)

		if self.preHoverUUID then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preHoverUUID)

			self.preHoverUUID = nil
		end

		self.preHover = nil
	end
end

M.OnRealDrag = function(self)
	if not self.enterDrag or not self.selectedItem then
		return
	end

	self.itemScreenPos = self.camera:WorldToScreenPoint(self.selectedItem.transform.position)
	local screenSpace = Vector3.New(self.pos.x, self.pos.y, self.itemScreenPos.z)
	local cursorWorldPos = self.camera:ScreenToWorldPoint(screenSpace)
	self.selectedItem.m_EnterDrag = true
	self.selectedItem.cursorWorldPos = cursorWorldPos
end

M.OnRealEndDrag = function(self, isConfirmExit)
	if not self.enterDrag then
		return
	end

	self.bindData.PadCancelBtn:SetActive(false)

	if self.selectedItem then
		self.selectedItem.m_EnterDrag = false
	end

	if self.curHoverSlotIndex and self.isOnHover and not isConfirmExit then
		self.TryInstall(self)
	else
		self.ItemBackToInitPos(self)
	end

	self.currentSelectedRealGo = nil
end

M.ItemBackToInitPos = function(self)
	if not self.selectedItem then
		return
	end

	local initData = self.partInitData[self.selectedItem]
	self.selectedItem.installedSlotIndex = -1
	self.selectedItem.m_EnterDrag = false
	self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).velocity = Vector3.zero

	if initData then
		self.selectedItem.transform:SetParent(initData.parent)

		self.selectedItem.transform.position = initData.position
		self.selectedItem.transform.rotation = initData.rotation
	end

	self.selectedItem = nil
	self.enterDrag = false
	self.canHover = true

	for _, part in ipairs(self.allParts) do
		part:SetTrigger(true)

		part.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = false
	end

	self.ClearEffects(self)
end

M.UninstallPart = function(self, part)
	local slotIdx = part.installedSlotIndex

	if slotIdx ~= -1 then
		return
	end

	local slotBodyType = slotIdx >= 4 and BodyType.Monkey or BodyType.Pig
	local slotPartIndex = slotIdx % 4

	if slotBodyType ~= BodyType.Monkey then
		self.monkeySlots[slotPartIndex] = -1
		self.monkeySlotPartTypes[slotPartIndex] = nil
		self.monkeySlotCount = self.monkeySlotCount - 1
	else
		self.pigSlots[slotPartIndex] = -1
		self.pigSlotPartTypes[slotPartIndex] = nil
		self.pigSlotCount = self.pigSlotCount - 1
	end

	local initData = self.partInitData[part]

	if initData then
		part.transform:SetParent(initData.parent)
	end

	part.installedSlotIndex = -1

	self.bindData["slotHover" .. slotIdx].gameObject:SetActive(true)
end

M.TryInstall = function(self)
	if not self.selectedItem then
		return
	end

	local partIndex = self.selectedItem.index
	local slotBodyType = self.curHoverSlotIndex >= 4 and BodyType.Monkey or BodyType.Pig
	local slotPartIndex = self.curHoverSlotIndex % 4

	if partIndex == slotPartIndex then
		self.ItemBackToInitPos(self)

		return
	end

	local partId = self.selectedItem.type * 4 + self.selectedItem.index

	if slotBodyType ~= BodyType.Monkey then
		if self.monkeySlots[slotPartIndex] == -1 then
			self.ItemBackToInitPos(self)

			return
		end

		self.monkeySlots[slotPartIndex] = slotPartIndex
		self.monkeySlotPartTypes[slotPartIndex] = partId
		self.monkeySlotCount = self.monkeySlotCount + 1
	elseif slotBodyType ~= BodyType.Pig then
		if self.pigSlots[slotPartIndex] == -1 then
			self.ItemBackToInitPos(self)

			return
		end

		self.pigSlots[slotPartIndex] = slotPartIndex
		self.pigSlotPartTypes[slotPartIndex] = partId
		self.pigSlotCount = self.pigSlotCount + 1
	end

	self.selectedItem:SetTrigger(true)

	self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true
	self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).velocity = Vector3.zero
	self.selectedItem.installedSlotIndex = self.curHoverSlotIndex
	local slot = self.allSlots[self.curHoverSlotIndex]

	if slot then
		self.selectedItem.transform:SetParent(slot.transform)
		self.selectedItem.transform:SetLocalPosition(0, 0, 0)

		self.selectedItem.transform.localRotation = Quaternion.identity
	end

	self.bindData["slotHover" .. self.curHoverSlotIndex].gameObject:SetActive(false)

	self.isOnHover = false
	self.enterDrag = false
	self.selectedItem = nil
	self.curHoverSlotIndex = nil
	self.canHover = true

	for _, part in ipairs(self.allParts) do
		if part.installedSlotIndex ~= -1 then
			part:SetTrigger(true)

			part.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = false
		end
	end

	self.ClearEffects(self)
	self.CheckGameEnd(self)
end

M.CheckGameEnd = function(self)
	if PARTS_PER_BODY < self.monkeySlotCount then
		self.OnGameEnd(self, BodyType.Monkey)
	elseif PARTS_PER_BODY < self.pigSlotCount then
		self.OnGameEnd(self, BodyType.Pig)
	end
end

M.OnGameEnd = function(self, winnerBodyType)
	self.hasGameEnded = true
	self.canHover = false
	self.canShowUI = false
	local slotPartTypes = winnerBodyType ~= BodyType.Monkey and self.monkeySlotPartTypes or self.pigSlotPartTypes

	gMiniGameDataManager:SetNiRenGameResult({
		winnerBodyType = winnerBodyType,
		parts = {
			[PartIndex.Head] = slotPartTypes[PartIndex.Head],
			[PartIndex.Handl] = slotPartTypes[PartIndex.Handl],
			[PartIndex.Handr] = slotPartTypes[PartIndex.Handr],
			[PartIndex.Legs] = slotPartTypes[PartIndex.Legs]
		}
	})
	gSpoonClientMgr:ReleaseContextEvent(self.instanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnNiRenFinish)
	gPanelManager:Close(gPanelId.S_NIREN_PANEL)
end

M.OnHover = function(self, slotIndex)
	if not self.selectedItem then
		if not self:GetHoverAnim(slotIndex):IsPlaying(self.hoverAnimName[4]) then
			gCS.LuaUtils.PlayAnimationByName(self.GetHoverAnim(self, slotIndex), self.hoverAnimName[4])
		end

		self.slotHovering[slotIndex] = true

		if not self.hoverLoopSoundId then
			self.hoverLoopSoundId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)
		end

		return
	end

	if self.curHoverSlotIndex == slotIndex then
		self.curHoverSlotIndex = slotIndex

		if self.hoverLoopSoundId then
			gSoundMgr:StopSoundByNid(self.hoverLoopSoundId)

			self.hoverLoopSoundId = nil
		end

		if not self.hoverLoopSoundId then
			self.hoverLoopSoundId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)
		end

		self.isOnHover = true
	end

	self.bindData["slotHover" .. slotIndex].gameObject:SetActive(true)

	if not self:GetHoverAnim(slotIndex):IsPlaying(self.hoverAnimName[4]) then
		gCS.LuaUtils.PlayAnimationByName(self.GetHoverAnim(self, slotIndex), self.hoverAnimName[4])
	end
end

M.OnUnHover = function(self, slotIndex)
	if self.curHoverSlotIndex and self.curHoverSlotIndex ~= slotIndex then
		self.curHoverSlotIndex = nil
		self.isOnHover = false

		if self.hoverLoopSoundId then
			gSoundMgr:StopSoundByNid(self.hoverLoopSoundId)

			self.hoverLoopSoundId = nil
		end
	end

	self.slotHovering[slotIndex] = nil

	self:ClearSlotHoverState(slotIndex)
	self:GetHoverAnim(slotIndex):Stop()
end

M.OnHoverSelect = function(self)
	if self.gamepadMode and self.selectedItem and self.isOnHover then
		self.OnRealEndDrag(self)
	end
end

M.GetHoverAnim = function(self, index)
	return self.bindData["hoverAnim" .. index]
end

M.HideOrShowHover = function(self, isActive)
	local dragPartIndex = self.selectedItem and self.selectedItem.index or nil

	for i = 0, 7 do
		local slotBodyType = i >= 4 and BodyType.Monkey or BodyType.Pig
		local slotPartIndex = i % 4
		local isOccupied = false

		if slotBodyType ~= BodyType.Monkey then
			isOccupied = self.monkeySlots[slotPartIndex] == -1
		else
			isOccupied = self.pigSlots[slotPartIndex] == -1
		end

		local isPartMatch = dragPartIndex ~= nil or slotPartIndex ~= dragPartIndex

		if isOccupied or not isActive or not isPartMatch then
			self.bindData["slotHover" .. i].gameObject:SetActive(false)
			self.bindData["rectHover" .. i].gameObject:SetActive(false)
			self:ClearSlotHoverState(i)
		elseif self.selectedItem then
			self.bindData["slotHover" .. i].gameObject:SetActive(true)
			self.bindData["rectHover" .. i].gameObject:SetActive(true)

			if not self:GetHoverAnim(i):IsPlaying(self.hoverAnimName[3]) then
				gCS.LuaUtils.PlayAnimationByName(self.GetHoverAnim(self, i), self.hoverAnimName[3])
			end
		else
			local slot = self.allSlots[i]

			if slot and self.pos then
				local slotScreenPos = self.camera:WorldToScreenPoint(slot.transform.position)
				local dx = self.pos.x - slotScreenPos.x
				local dy = self.pos.y - slotScreenPos.y
				local dis = math.sqrt(dx * dx + dy * dy)

				if dis <= 200 then
					self.bindData["slotHover" .. i].gameObject:SetActive(false)
					self.bindData["rectHover" .. i].gameObject:SetActive(false)
					self:ClearSlotHoverState(i)
				else
					self.bindData["slotHover" .. i].gameObject:SetActive(true)
					self.bindData["rectHover" .. i].gameObject:SetActive(true)

					if not self.slotHovering[i] and not self.slotHoverTimers[i] then
						if not self.slotHoverBegun[i] then
							gCS.LuaUtils.PlayAnimationByName(self.GetHoverAnim(self, i), self.hoverAnimName[1])

							self.slotHoverBegun[i] = true
						end

						local timer = Timer.New(function ()
							self.slotHoverTimers[i] = nil

							gCS.LuaUtils.PlayAnimationByName(self:GetHoverAnim(i), self.hoverAnimName[2])
						end, self.openDuration):Start()
						self.slotHoverTimers[i] = timer
					end
				end
			end
		end
	end
end

M.ClearSlotHoverState = function(self, index)
	if self.slotHoverTimers[index] then
		self.slotHoverTimers[index]:Stop()

		self.slotHoverTimers[index] = nil
	end

	self.slotHovering[index] = nil
	self.slotHoverBegun[index] = nil
end

M.OnUpdate = function(self)
	if self.hasGameEnded then
		return
	end

	if self.canShowUI then
		self.bindData.leftControlActive = true
		self.bindData.fakeSelectBtnActive = true

		self.bindData.SelectBtn.gameObject:SetActive(true)
		self:HideOrShowHover(true)
	else
		self.bindData.leftControlActive = false
		self.bindData.fakeSelectBtnActive = false

		self.HideOrShowHover(self, false)
	end

	if not self.gamepadMode then
		self.pos = Input.mousePosition
	else
		self.pos = self.currentCursorPos
	end

	if self.pos and self.enterDrag then
		return
	end

	if self.canHover and not self.hasGameEnded and not self.enterDrag then
		local hitInfo = gCS.LuaUtils.PinHaoBanGetUIToCameraHit(self.pos)

		if hitInfo and hitInfo.collider == nil then
			local hitGo = hitInfo.collider.transform

			if hitGo == nil then
				local hitRealGo = self.IsAimGos(self, hitGo)

				if not hitRealGo then
					self.ClearHoverEffect(self)
					self.ClearEffects(self)

					self.currentSelectedRealGo = nil

					return
				end

				self.currentSelectedRealGo = hitRealGo
			else
				self.ClearHoverEffect(self)
				self.ClearEffects(self)

				self.currentSelectedRealGo = nil
			end
		else
			self.ClearHoverEffect(self)
			self.ClearEffects(self)

			self.currentSelectedRealGo = nil
		end
	end
end

M.ClearHoverEffect = function(self)
	if self.preHoverUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preHoverUUID)

		self.preHoverUUID = nil
	end

	self.preHover = nil
	self.currentSelectedRealGo = nil
end

M.IsAimGos = function(self, transform)
	if transform == nil then
		local item = transform.gameObject:GetComponentInParent(typeof(PinHaoBanDefine))

		if not item then
			if self.preHoverUUID then
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preHoverUUID)

				self.preHoverUUID = nil
			end

			self.preHover = nil

			return
		end

		if self.preHover == item then
			if self.preHoverUUID then
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preHoverUUID)

				self.preHoverUUID = nil
			end

			gSoundMgr:PlaySoundByExternalSource("ExHandle_click_03", LX6.Audio.ExternalSourceType.Motion_2D)

			self.preHoverUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, LX6.Effect.EffectPlayTag.Gameplay, "NiRenGameHover_" .. tostring(item.type) .. "_" .. tostring(item.index), item.gameObject)
			self.preHover = item
		end

		return item
	end

	if self.preHoverUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preHoverUUID)

		self.preHoverUUID = nil
	end

	self.preHover = nil
end
