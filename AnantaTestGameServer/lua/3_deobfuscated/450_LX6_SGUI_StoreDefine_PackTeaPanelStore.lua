C_PackTeaPanelStore = DefClass("C_PackTeaPanelStore", C_PackTeaPanelStore, C_StoreGroup)
GroupName2Class.PackTeaPanelStore = C_PackTeaPanelStore
local M = C_PackTeaPanelStore
local Input = UnityEngine.Input
local SimulatorPart = L50.SimulatorGame.SimulatorPart
local SimulatorParticle = L50.SimulatorGame.SimulatorParticle

function M:Init()
	self.usedPackCnt = 0
	self.usedTeaCnt = 0
	self.isDragging = false
	self.teaSplashStartY = 0
	self.packs = {}
	self.selectedDragPart = nil
	self.currentSelectedPart = nil
	self.curTeaCount = 0
	self.teaCountPerPack = 0
	self.clickedPile = {}
	self.startRayCast = true
	self.canDragFullPack = false
	self.packCnt = 0
	self.fullPackCnt = 0
	self.onePack = nil
	self.oneSticker = nil
	self.areaTriggerGo = nil
	self.canDragOnePack = true
	self.canDragSticker = false
	self.curCompound = nil
	self.curSplashY = 0
	self.curSlashFinish = false
	self.hasTea = false
	self.packHasTea = false
	self.isEnterSplashingArea = false
	self.splashTeaProgress = 0
	self.splashTeaIncrement = 0.01
	self.enterRotate = false
	self.enterRotate = false
	self.totalFullPackCnt = 0
end

function M:ctor()
	self:Init()

	self.partStateDefine = {
		clickState = {
			None = -1,
			Clicked = 1,
			type = 0
		},
		PackState = {
			FullPack = 2,
			OnePack = 1,
			None = -1,
			type = 1
		},
		SplashTea = {
			None = -1,
			NotFull = 1,
			Full = 2,
			type = 2
		}
	}
end

function M:OnAwake()
	self.msgEvents = {
		[gEventConstants.ON_SIMULATOR_GAME_PANEL_AREA_TRIGGER] = self:CreateAction("OnAreaTriggerEvent")
	}

	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.interactBtn.luaBeginDrag = self:CreateAction("OnBeginDrag")
	self.bindData.interactBtn.luaDrag = self:CreateAction("OnDrag")
	self.bindData.interactBtn.luaEndDrag = self:CreateAction("OnEndDrag")
	self.bindData.interactBtn.luaClick = self:CreateAction("OnClick")
	self.bindData.upBtn.luaPress = self:CreateActionWithArgs("OnBtnPress", -1)
	self.bindData.upBtn.luaRelease = self:CreateActionWithArgs("OnBtnRelease", -1)
	self.bindData.downBtn.luaPress = self:CreateActionWithArgs("OnBtnPress", 1)
	self.bindData.downBtn.luaRelease = self:CreateActionWithArgs("OnBtnRelease", 1)
end

function M:OnBtnPress(dir)
	if not self.isDragging then
		return
	end

	self.rotateDir = dir
	self.enterRotate = true
	self.rotateSpeed = 50
end

function M:OnBtnRelease(dir)
	if not self.isDragging then
		return
	end

	self.enterRotate = false
end

function M:ResetPart()
	if self.simulatorStartPos then
		self.simulatorInitTransform = self.simulatorStartPos.gameObject.transform

		self.simulator.gameObject:GetComponent(typeof(SimulatorPart)):SetInitTransform(self.simulatorInitTransform)
		self.simulator.gameObject:GetComponent(typeof(SimulatorPart)):ReturnToInitialTransform()
	end

	if self.splashTea then
		self:ResetSplashTea()
	end
end

function M:OnShow(panelId, data)
	for i, v in pairs(data.data) do
		self[i] = v
	end

	self:ResetPart()
	self:Init()

	self.areaTriggerGo = self.StackTea.transform.parent.gameObject
	self.teaCntPerPile = self.teaCntPerPile
	self.teaCntPerPack = self.teaCntPerPack
	self.teaPileDecreaseAmount = 1 / self.teaCntPerPile

	self:InitializeTiltSystem()
	self:InitializeParticle()
	self:ResetSplashTea()
	self.TeaPile.gameObject:SetActive(false)
	gCS.SimulatorGameUtils.SetEnterTriggerCount(self.sceneNode.gameObject.transform:Find("StackTeaTrigger").gameObject, self.teaCntPerPile)
	gCS.SimulatorGameUtils.SetEnterTriggerCount(self.sceneNode.gameObject.transform:Find("ContainerTrigger").gameObject, self.teaCntPerPile)
	gCS.SimulatorGameUtils.ResetTriggerState(self.sceneNode.gameObject.transform:Find("StackTeaTrigger").gameObject)
	gCS.SimulatorGameUtils.ResetTriggerState(self.sceneNode.gameObject.transform:Find("ContainerTrigger").gameObject)

	self.splashPerPackProgress = 1 / self.teaCntPerPack
	self.packTrigger = self.sceneNode.gameObject.transform:Find("PackTrigger"):GetComponent(typeof(UnityEngine.Collider))
	self.packTrigger.isTrigger = true
	self.instanceId = self.instanceId
	self.FakeWraps = self.sceneNode.gameObject.transform:Find("FakeWraps").gameObject
	self.playerPackCnt = gCommonItemManager:GetItemNum(36786102)
	self.playerTeaCnt = gCommonItemManager:GetItemNum(36786106)

	if self.playerTeaCnt <= 5 then
		self.StackTea.gameObject.transform:SetLocalScaleY(self.playerTeaCnt / 5)
	else
		self.StackTea.gameObject.transform:SetLocalScaleY(1)
	end
end

function M:OnUpdate()
	self:UpdateInput()
	self:UpdateRotation()
	self:UpdateCheckRotation()
end

function M:UpdateRotation()
	if not self.enterRotate then
		return
	end

	if gCS.LuaUtils.IsNull(self.selectedDragPart) or gCS.SimulatorGameUtils.GetPartType(self.selectedDragPart.gameObject) ~= 0 then
		return
	end

	local partTrans = self.selectedDragPart.gameObject.transform
	local deltaRotation = self.rotateSpeed * self.rotateDir * Time.deltaTime

	partTrans:Rotate(deltaRotation, 0, 0)
end

function M:UpdateCheckRotation()
	if not self:CheckCanUpdateSplashTea() then
		self:SetParticle(false)

		return
	end

	if not self.hasTea then
		return
	end

	if not gCS.LuaUtils.IsNull(self.selectedDragPart) and gCS.SimulatorGameUtils.GetPartType(self.selectedDragPart.gameObject) == 0 then
		self:SetParticle(true)
	end
end

function M:InitializeTiltSystem()
	self:ResetSplashTea()

	self.isEnterSplashingArea = false
	self.tiltStartTime = 0
end

function M:OnAreaTriggerEvent(eventId, data)
	data = data:ToTable()

	if data[2] == 0 then
		if data[1] == 5 and self.StackTea and not self.hasTea and self.usedTeaCnt < math.min(self.playerTeaCnt, self.teaCntPerPile) then
			self.usedTeaCnt = self.usedTeaCnt + 1
			local currentScale = self.StackTea.gameObject:GetLocalScaleY()

			self.TeaPile.gameObject:SetActive(true)
			self.StackTea.transform:SetLocalScaleY(currentScale - self.teaPileDecreaseAmount)
			gCS.SimulatorGameUtils.SetTriggerEnable(self.areaTriggerGo, false)

			self.hasTea = true

			self.simulator.gameObject.transform:SetLocalRotation(Quaternion.identity)
		end

		if data[1] == 7 then
			self.canDragOnePack = true
			self.fullPackCnt = self.fullPackCnt + 1

			gSpoonClientMgr:ReleaseContextEvent(self.instanceId, gSpoonEventType.OnReceiveSignal, {
				signalKey = "AddFullPack"
			})

			if self.fullPackCnt == math.min(self.playerTeaCnt, self.teaCntPerPile) or self.fullPackCnt == self.playerPackCnt then
				self:GameEnd()
			end
		end
	end

	if data[1] == 6 then
		if self.hasTea and data[2] == 0 and self.curCompound and not self.packHasTea then
			self.isEnterSplashingArea = true
			self.tiltStartTime = Time.time
		end

		if data[2] == 1 and self.isEnterSplashingArea then
			self.isEnterSplashingArea = false
		end
	end
end

function M:StartTilting(enabled, callback)
	if callback then
		callback()
	end
end

function M:ResetSplashTea()
	local splashTea = self.splashTea

	if splashTea then
		self.packHasTea = false

		splashTea.gameObject:SetActive(false)

		splashTea.transform.localScale = Vector3.New(1, 0, 1)
	end
end

function M:SetParticle(enable)
	if self.particle then
		self.particle.gameObject:SetActive(enable)
	end
end

function M:UpdateInput()
	self.pos = Input.mousePosition

	if self.startRayCast then
		local hitInfo = gCS.LuaUtils.PinHaoBanGetUIToCameraHit(self.pos)

		if not hitInfo then
			self.currentSelectedPart = nil
		elseif hitInfo.collider ~= nil then
			local hitGo = hitInfo.collider.gameObject

			if hitGo ~= nil then
				local type = self:IsRealGos(hitGo)

				if type ~= -1 then
					self.currentSelectedPart = hitGo.gameObject
				else
					self.currentSelectedPart = nil
				end
			end
		end
	end
end

function M:UpdateSplashTea()
	local splashTea = self.splashTea

	if not splashTea then
		return
	end

	if self.curTeaCount < self.teaCntPerPack then
		splashTea.gameObject:SetActive(true)

		self.splashTeaProgress = math.min(self.teaSplashStartY + self.splashPerPackProgress, self.splashTeaProgress + self.splashTeaIncrement)

		splashTea.transform:SetLocalScaleY(self.splashTeaProgress)

		if self.splashTeaProgress >= self.teaSplashStartY + self.splashPerPackProgress then
			self:SplashTeaFinish()
		end
	end
end

function M:CheckCanUpdateSplashTea()
	if gCS.LuaUtils.IsNull(self.selectedDragPart) or gCS.SimulatorGameUtils.GetPartType(self.selectedDragPart.gameObject) ~= 0 then
		return false
	end

	local goUp = Quaternion.Euler(self.selectedDragPart.gameObject.transform.localEulerAngles) * Vector3.up
	local signedAngle = self:SignedAngle(goUp, Vector3.up, Vector3.right)

	if math.abs(signedAngle + 180) <= 0.1 then
		return false
	end

	return signedAngle < 0
end

function M:SplashTeaFinish()
	self.teaSplashStartY = self.splashTeaProgress

	if self.teaSplashStartY >= 1 then
		self.teaSplashStartY = 0
	end

	self.hasTea = false

	self.TeaPile.gameObject:SetActive(false)

	self.curTeaCount = self.curTeaCount + 1

	if self.curTeaCount == self.teaCntPerPack then
		gCS.SimulatorGameUtils.SetCompoundPartEnableMerge(self.curCompound, false)

		self.packHasTea = true
		self.curTeaCount = 0
		self.splashTeaProgress = 0
		self.packTrigger.isTrigger = true
	end

	self:SetParticle(false)
end

function M:InitializeParticle()
	local particle = self.simulator.gameObject.transform:Find("Pipe/Cylinder/Particle")
	self.particle = particle:GetComponent(typeof(SimulatorParticle))

	function self.particle.onParticleHit()
		self:UpdateSplashTea()
	end

	self:SetParticle(false)
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnClick()
	if not gCS.LuaUtils.IsNull(self.currentSelectedPart) then
		if self.packCnt >= 4 then
			return
		end

		local curState = gCS.SimulatorGameUtils.GetPartState(self.currentSelectedPart, self.partStateDefine.clickState.type)

		if gCS.SimulatorGameUtils.GetPartType(self.currentSelectedPart) == 4 and curState == self.partStateDefine.clickState.None then
			gCS.SimulatorGameUtils.SetPartState(self.currentSelectedPart, self.partStateDefine.clickState.type, self.partStateDefine.clickState.Clicked)
			gCS.SimulatorGameUtils.PartPlayTween(self.currentSelectedPart.gameObject, function ()
				self.packCnt = self.packCnt + 1

				if self.packCnt == 4 then
					self.canDragSticker = true

					self:ResetSplashTea()
					gCS.SimulatorGameUtils.SetCompoundPartEnableMerge(self.curCompound, true)

					if self.packCnt == self.teaCntPerPile then
						-- Nothing
					end
				end
			end)
		end
	end
end

function M:ClosePanel()
	self.FakeWraps:SetActive(true)
	self:ClearMessageEvents()
	self:ResetSplashTea()
	self:SetParticle(false)
	gCS.GuiUtils.CutSceneShowMyUnit(gCS.MyPlayerManager.PlayerUnit, true)
	gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.S_FARM_PANEL)

	if not gCS.LuaUtils.IsNull(self.selectedDragPart) then
		self.selectedDragPart.enablePhysicsMove = false

		self.selectedDragPart:ReturnToInitialTransform()
	end

	self.TeaPile.gameObject:SetActive(false)
	self.StackTea.gameObject.transform:SetLocalScaleY(1)

	if self.packs then
		for i, v in ipairs(self.packs) do
			GameObject.Destroy(v)
		end
	end

	self.particle.onParticleHit = nil
end

function M:OnBeginDrag()
	self.isDragging = true

	if not gCS.LuaUtils.IsNull(self.currentSelectedPart) then
		if gCS.SimulatorGameUtils.GetPartType(self.currentSelectedPart) == 0 then
			self.selectedDragPart = self.currentSelectedPart.transform:GetComponent(typeof(SimulatorPart))

			self.selectedDragPart:SetPartTrigger(false)
			self.selectedDragPart:SetPartGravity(false)
			gCS.SimulatorGameUtils.SetPartEnablePhysicsMove(self.selectedDragPart, true)

			self.startRayCast = false
		elseif gCS.SimulatorGameUtils.GetPartType(self.currentSelectedPart) == 1 and self.usedPackCnt < self.playerPackCnt then
			if self.canDragOnePack then
				if self.onePack then
					self.onePack = nil
				end

				self.onePack = UnityEngine.GameObject.Instantiate(self.singlePack.transform, self.sceneNode.transform)
				local dragPart = self.onePack.transform:GetComponent(typeof(SimulatorPart))

				table.insert(self.packs, dragPart.gameObject)

				self.selectedDragPart = dragPart
				local curPackState = gCS.SimulatorGameUtils.GetPartState(self.selectedDragPart.gameObject, self.partStateDefine.PackState.type)

				if curPackState == self.partStateDefine.PackState.None then
					gCS.SimulatorGameUtils.SetPartState(self.selectedDragPart.gameObject, self.partStateDefine.PackState.type, self.partStateDefine.PackState.OnePack)
				end

				self.selectedDragPart.gameObject.transform.position = self.currentSelectedPart.gameObject.transform.position + Vector3.New(0, 0.3, 0)

				self.selectedDragPart.gameObject:SetActive(true)
				self.selectedDragPart:SetInitTransform(self.packInitPosition.gameObject.transform)
				self.selectedDragPart:SetPartTrigger(true)
				gCS.SimulatorGameUtils.SetPartEnablePhysicsMove(self.selectedDragPart, true)

				self.startRayCast = false
			end
		elseif gCS.SimulatorGameUtils.GetPartType(self.currentSelectedPart) == 2 then
			if not self.canDragSticker then
				return
			end

			if not self.oneSticker then
				self.oneSticker = UnityEngine.GameObject.Instantiate(self.singleSticker.transform, self.sceneNode.transform)
			end

			self.selectedDragPart = self.oneSticker.transform:GetComponent(typeof(SimulatorPart))
			self.selectedDragPart.gameObject.transform.position = self.currentSelectedPart.gameObject.transform.position + Vector3.New(0, 0.3, 0)

			self.selectedDragPart.gameObject:SetActive(true)
			self.selectedDragPart:SetInitTransform(self.singleStickerPos.gameObject.transform)
			self.selectedDragPart:SetPartTrigger(true)
			gCS.SimulatorGameUtils.SetPartEnablePhysicsMove(self.selectedDragPart, true)

			self.startRayCast = false
		elseif gCS.SimulatorGameUtils.GetPartType(self.currentSelectedPart) == 3 then
			local curState = gCS.SimulatorGameUtils.GetPartState(self.currentSelectedPart, self.partStateDefine.PackState.type)

			if curState == self.partStateDefine.PackState.OnePack and self.canDragOnePack then
				self.selectedDragPart = self.currentSelectedPart.transform:GetComponent(typeof(SimulatorPart))

				self.selectedDragPart:SetInitTransform(self.packInitPosition.gameObject.transform)
				self.selectedDragPart:SetPartTrigger(false)
				gCS.SimulatorGameUtils.SetPartEnablePhysicsMove(self.selectedDragPart, true)

				self.startRayCast = false
			end

			if curState == self.partStateDefine.PackState.FullPack then
				self.selectedDragPart = self.currentSelectedPart.transform:GetComponent(typeof(SimulatorPart))
				self.selectedDragPart.gameObject.transform.position = self.currentSelectedPart.gameObject.transform.position + Vector3.New(0, 0.3, 0)

				self.selectedDragPart:SetInitTransform(self.sceneNode.gameObject.transform)
				self.selectedDragPart:SetPartTrigger(false)
				gCS.SimulatorGameUtils.SetPartEnablePhysicsMove(self.selectedDragPart, true)

				self.startRayCast = false
			end
		end
	end
end

function M:OnDrag()
	return
end

function M:OnEndDrag()
	self.isDragging = false

	if not gCS.LuaUtils.IsNull(self.selectedDragPart) then
		self.selectedDragPart:SetPartTrigger(true)
		gCS.SimulatorGameUtils.SetPartEnablePhysicsMove(self.selectedDragPart, false)

		if gCS.SimulatorGameUtils.GetPartType(self.selectedDragPart.gameObject) == 3 then
			local curState = gCS.SimulatorGameUtils.GetPartState(self.selectedDragPart.gameObject, self.partStateDefine.PackState.type)
			self.startRayCast = true

			if curState == self.partStateDefine.PackState.OnePack then
				self.usedPackCnt = self.usedPackCnt + 1

				if self.playerPackCnt <= self.usedPackCnt then
					self.FakeWraps:SetActive(false)
				end

				self.selectedDragPart:ReturnToInitialTransform(false)

				self.canDragOnePack = false
				self.packCnt = 0
				self.curCompound = self.selectedDragPart
				self.packTrigger.isTrigger = false
			end

			if curState == self.partStateDefine.PackState.FullPack then
				self.selectedDragPart:SetPartTrigger(false)
				self.selectedDragPart:SetPartGravity(true)

				local rb = self.selectedDragPart:GetComponent(typeof(UnityEngine.Rigidbody))

				if rb then
					rb:AddForce(Vector3.New(1, -1, 0), UnityEngine.ForceMode.Acceleration)
				end

				self.onePack = nil
			end

			self.selectedDragPart = nil
		elseif gCS.SimulatorGameUtils.GetPartType(self.selectedDragPart.gameObject) == 4 then
			self.selectedDragPart:ReturnToInitialTransform(true)
			self.selectedDragPart:SetColliderEnable(false)

			local packSticker = self.curCompound.gameObject.transform:Find("WrapSticker")

			packSticker.gameObject:SetActive(true)
			gCS.SimulatorGameUtils.SetCompoundPartEnableMerge(self.curCompound, true)
			gCS.SimulatorGameUtils.SetPartState(self.curCompound.gameObject, self.partStateDefine.PackState.type, self.partStateDefine.PackState.FullPack)

			self.totalFullPackCnt = self.totalFullPackCnt + 1
			self.canDragSticker = false
			self.selectedDragPart = nil
			self.startRayCast = true
		else
			self.selectedDragPart:SetPartTrigger(false)
			self.selectedDragPart:SetPartGravity(true)

			self.startRayCast = true
		end
	end
end

function M:IsRealGos(transform)
	local type = gCS.SimulatorGameUtils.GetPartType(transform.gameObject)

	return type
end

function M:GameEnd()
	self.needUpdate = false
	gStoreManager:GetStoreGroup("FarmPanelStore").bindData.btnBack.interactable = false

	Timer.New(function ()
		gStoreManager:GetStoreGroup("FarmPanelStore"):ClosePanel()
	end, 1):Start()
end

function M:SignedAngle(v1, v2, axis)
	local angle = Vector3.Angle(v1, v2)
	local sign = Mathf.Sign(Vector3.Dot(axis, Vector3.Cross(v1, v2)))

	return angle * sign
end
