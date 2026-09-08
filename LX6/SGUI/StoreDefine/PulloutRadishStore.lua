-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PulloutRadishStore.lua
-- Decompiled from: 00801_PulloutRadishStore.lua_ef0143b8b2ff.luajit

C_PulloutRadishStore = DefClass("C_PulloutRadishStore", C_PulloutRadishStore, C_StoreGroup)
GroupName2Class.PulloutRadishStore = C_PulloutRadishStore
local M = C_PulloutRadishStore
local GameplaySignalInwardConfig = LTConfig.GameplaySignalInwardConfig
local FarmConfig = LTConfig.FarmConfig
local Screen = UnityEngine.Screen
local Input = UnityEngine.Input

M.ctor = function(self)
	self.curCorp = nil
	self.isPress = false
	self.enterWash = false
	self.curSeconds = 0
	self.isLeftPress = false
	self.isRightPress = false
	self.curGo = nil
	self.curLeftHandRotParam = 0
	self.rightHandX = 0
	self.rightHandY = 0.5
	self.lastMousePosY = nil
	self.lastSliderValue = nil
	self.dirtList = {}
	self.dissolvedDirtCount = 0
	self.DISSOLVE_TIME = 2
	self.DISSOLVE_TARGET_COUNT = 3
	self.isShooting = false
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.processEnum = {
		["m#nS"] = 1,
		["\\xc9\\xce1\\xe5"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.processEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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
	self.lastMousePosY = nil
	self.lastSliderValue = nil
	self.bindData.clickBtn.interactable = true
	self.enterWash = false
	self.isPress = false
	self.isLeftPress = false
	self.isRightPress = false
	self.curSeconds = 0
	self.bodyCollider = nil
	self.bindData.process = self.processEnum.pullout
	self.bindData.fillmount = 0
	self.curLeftHandRotParam = 0
	self.LEFT_HAND_ROT_OUT_MAX = FarmConfig.LHandRotLimit[1]
	self.LEFT_HAND_ROT_IN_MAX = FarmConfig.LHandRotLimit[2]
	self.curCorp = gCS.FarmFunctionUtils.GetCurrentInteractCorpGo()

	self:InitDirtData()

	self.dissolvedDirtCount = 0

	self.bindData.returnBtn:SetActive(true)

	self.isShooting = false

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.fullBtn:SetActive(false)

		self.bindData.slider.value = 0.5
	end
end

M.SetWashBtnEnable = function(self, enable)
	self.bindData.returnBtn.interactable = enable
	self.bindData.turnLeftBtn.interactable = enable
	self.bindData.turnRightBtn.interactable = enable

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.fullBtn.interactable = enable
	end
end

M.OnUpdate = function(self)
	if self.isPress then
		self.curSeconds = self.curSeconds + Time.deltaTime
		self.curSeconds = math.min(self.curSeconds, FarmConfig.PullOutPressTime)
		local totalTime = FarmConfig.PullOutPressTime
		self.bindData.fillmount = self.curSeconds / totalTime

		if FarmConfig.PullOutPressTime < self.curSeconds then
			self.isPress = false
			self.bindData.clickBtn.interactable = false

			self.bindData.returnBtn:SetActive(false)
			gCS.FarmFunctionUtils.SetCorpGoToHandl(self.curCorp)
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, GameplaySignalInwardConfig.CorpPullOut)
		end
	elseif not self.enterWash then
		self.bindData.fillmount = 0
		self.curSeconds = 0
	end

	if self.enterWash then
		self.UpdateLeftHandRotation(self)
		self.UpdateRightHandMove(self)
		self.UpdateWaterGunDetect(self)
	end
end

M.InitDirtData = function(self)
	self.dirtList = {}

	if not self.curCorp or gCS.LuaUtils.IsNull(self.curCorp) then
		print_error("[PulloutRadish]当前作物为空，无法初始化泥土数据")

		return
	end

	local dirtRoot = self.curCorp.transform:Find("Stage4/DirtRoot")
	self.bodyCollider = self.curCorp.transform:Find("Stage4/BodyCollider")

	if not dirtRoot or gCS.LuaUtils.IsNull(dirtRoot) or not self.bodyCollider or gCS.LuaUtils.IsNull(self.bodyCollider) then
		print_error("[PulloutRadish]作物上未找到泥土根节点DirtRoot")

		return
	end

	local allDirtGOs = {}
	local dirtChildCount = dirtRoot.childCount

	for i = 0, dirtChildCount - 1 do
		local dirtTrans = dirtRoot.GetChild(dirtRoot, i)
		local dirtGO = dirtTrans.gameObject

		if dirtGO and not gCS.LuaUtils.IsNull(dirtGO) then
			table.insert(allDirtGOs, dirtGO)
		end
	end

	if #allDirtGOs ~= 0 then
		print_error("[PulloutRadish] DirtRoot下无泥土子节点")

		return
	end

	local soilCntRange = FarmConfig.SoilCntRange or {
		2,
		5
	}
	local low = soilCntRange[1] or 2
	local high = soilCntRange[2] or 5
	local randomShowCount = math.floor(UnityEngine.Random.Range(low, high + 1))

	if randomShowCount <= #allDirtGOs then
		randomShowCount = #allDirtGOs
	end

	local selectedIndexes = {}
	local totalDirt = #allDirtGOs

	while randomShowCount <= #selectedIndexes do
		local randomIdx = math.floor(UnityEngine.Random.Range(1, totalDirt + 1))
		local isDuplicate = false

		for _, idx in ipairs(selectedIndexes) do
			if idx ~= randomIdx then
				isDuplicate = true

				break
			end
		end

		if not isDuplicate then
			table.insert(selectedIndexes, randomIdx)
		end
	end

	for i = 1, totalDirt do
		local dirtGO = allDirtGOs[i]
		local isShow = false

		for _, selectedIdx in ipairs(selectedIndexes) do
			if i ~= selectedIdx then
				isShow = true

				break
			end
		end

		dirtGO.SetActive(dirtGO, isShow)
	end

	for i, dirtGO in ipairs(allDirtGOs) do
		local isShow = dirtGO.activeSelf

		if isShow then
			local dirtModel = dirtGO.transform:Find("dirt")

			table.insert(self.dirtList, {
				["k\\xbfdC\\xbe\\xe4B^ssI"] = 0,
				["\\x96'6k\\x8eN\\xd5!\\xaf\\xbd"] = false,
				go = dirtGO,
				isShow = isShow,
				dirtModel = dirtModel,
				initScale = dirtModel.gameObject.transform:GetLocalScaleX()
			})
		end
	end
end

M.UpdateWaterGunDetect = function(self)
	if not self.isShooting then
		return
	end

	local dirtGOs = {}

	for _, dirt in ipairs(self.dirtList) do
		table.insert(dirtGOs, dirt.go)
	end

	local isPixelSuccess = gCS.FarmFunctionUtils.CheckWashProgressFinish()
	local hitIndexes = gCS.FarmFunctionUtils.DetectHitDirtIndexes(dirtGOs, FarmConfig.SoilDetectRadius, self.bodyCollider.gameObject)
	local isHitAnyValidDirt = false
	hitIndexes = hitIndexes.ToTable(hitIndexes)

	for _, idx in ipairs(hitIndexes) do
		local dirt = self.dirtList[idx + 1]

		if dirt and dirt.isShow and not dirt.isDissolved then
			dirt.dissolveTime = dirt.dissolveTime + Time.deltaTime
			isHitAnyValidDirt = true
			local remainingRatio = 1 - dirt.dissolveTime / FarmConfig.SoilDissolveTime
			remainingRatio = math.max(remainingRatio, 0)
			local scale = remainingRatio * dirt.initScale

			dirt.dirtModel.transform:SetLocalScale(scale)

			if FarmConfig.SoilDissolveTime < dirt.dissolveTime then
				self.OnDirtDissolve(self, idx + 1)
			end
		end
	end

	if self.dissolvedDirtCount > #self.dirtList and isPixelSuccess then
		self.GameEnd(self, true)
	end
end

M.OnDirtDissolve = function(self, dirtIndex)
	local dirt = self.dirtList[dirtIndex]

	if not dirt or dirt.isDissolved then
		return
	end

	dirt.isDissolved = true

	dirt.go:SetActive(false)

	self.dissolvedDirtCount = self.dissolvedDirtCount + 1
end

M.UpdateLeftHandRotation = function(self)
	if not self.enterWash then
		return
	end

	local delta = Time.deltaTime * FarmConfig.LeftHandRotSpeed

	if self.isLeftPress and not self.isRightPress then
		self.curLeftHandRotParam = math.min(self.curLeftHandRotParam + delta, self.LEFT_HAND_ROT_OUT_MAX)
	elseif self.isRightPress and not self.isLeftPress then
		self.curLeftHandRotParam = math.max(self.curLeftHandRotParam - delta, self.LEFT_HAND_ROT_IN_MAX)
	end

	self.UpdateLeftHandAnimatorParam(self)
end

M.UpdateRightHandMove = function(self)
	if not self.enterWash then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local currentMousePos = UnityEngine.Input.mousePosition
		local currentMouseY = currentMousePos.y

		if self.lastMousePosY ~= nil then
			self.lastMousePosY = currentMouseY

			return
		end

		local deltaY = currentMouseY - self.lastMousePosY
		self.lastMousePosY = currentMouseY

		if deltaY ~= 0 then
			return
		end

		self.rightHandY = Mathf.Clamp01(self.rightHandY + deltaY / Screen.height)

		gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, self.rightHandY, 18)
	end
end

M.UpdateLeftHandAnimatorParam = function(self)
	if not self.enterWash then
		return
	end

	if self.isLeftPress or self.isRightPress then
		local animX = (self.curLeftHandRotParam - self.LEFT_HAND_ROT_IN_MAX) / (self.LEFT_HAND_ROT_OUT_MAX - self.LEFT_HAND_ROT_IN_MAX)

		gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, animX, 17)
	end
end

M.GameEnd = function(self, isSuccess)
	if isSuccess then
		self.SetWashBtnEnable(self, false)
		gCS.FarmFunctionUtils.HarvestCurrentInteractCorpGo()
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, GameplaySignalInwardConfig.CorpWashFinish)
	else
		gCS.FarmFunctionUtils.SetCorpGoReturn()
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, GameplaySignalInwardConfig.CorpPauseFinish)
	end

	gPanelManager:Close(self.m_Id)
end

M.OnClose = function(self)
	self.lastMousePosY = nil
	self.lastSliderValue = nil
	self.dirtList = {}
	self.dissolvedDirtCount = 0
	self.curCorp = nil

	gCS.FarmFunctionUtils.DisableCheckStippleAlpha(false)
	gCS.CameraDataMgr.cinemachineManager:EnableFixCamera(false, Vector3.zero, Vector3.zero, 0, 0)
	gCS.CameraDataMgr.cinemachineManager:EnableFixCamera2(false, Vector3.zero, Vector3.zero, 0, 0)

	self.isPress = false
	self.isLeftPress = false
	self.isRightPress = false
	self.bindData.fillmount = 0
	self.curSeconds = 0
	self.curGo = nil
	self.enterWash = false
	self.curLeftHandRotParam = 0
	self.bindData.process = self.processEnum.pullout
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CORP_WATER_GUN_READY] = self.CreateAction(self, "OnWaterGunReady"),
		[gEventConstants.CORP_DO_FLIP_OVER] = self.CreateAction(self, "CorpDoFlipOver")
	}
end

M.OnWaterGunReady = function(self)
	self.bindData.process = self.processEnum.wash
	self.enterWash = true
end

M.CorpDoFlipOver = function(self, eventId, data)
	if data then
		self.SetWashBtnEnable(self, false)
	else
		self.SetWashBtnEnable(self, true)
	end
end

M.RegisterWidget = function(self)
	self.bindData.clickBtn.luaPress = self.CreateAction(self, "OnClickBtnPress")
	self.bindData.clickBtn.luaRelease = self.CreateAction(self, "OnClickBtnRelease")
	self.bindData.turnLeftBtn.luaPress = self.CreateAction(self, "OnTurnLeftPress")
	self.bindData.turnLeftBtn.luaRelease = self.CreateAction(self, "OnTurnLeftRelease")
	self.bindData.turnRightBtn.luaPress = self.CreateAction(self, "OnTurnRightPress")
	self.bindData.turnRightBtn.luaRelease = self.CreateAction(self, "OnTurnRightRelease")
	self.bindData.turnOverBtn.luaClick = self.CreateAction(self, "OnTurnOverClick")
	self.bindData.returnBtn.luaClick = self.CreateAction(self, "OnClickReturn")
	self.bindData.slider.luaValueChanged = self.CreateAction(self, "OnSliderValueChange")
	self.bindData.slider.luaPress = self.CreateAction(self, "OnPressSlider")
	self.bindData.slider.luaRelease = self.CreateAction(self, "OnReleaseSlider")
	self.bindData.fullBtn.luaPress = self.CreateAction(self, "OnPressFullBtn")
	self.bindData.fullBtn.luaRelease = self.CreateAction(self, "OnReleaseFullBtn")
end

M.OnPressSlider = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not self.enterWash then
		return
	end

	self.isShooting = true

	gCS.FarmFunctionUtils.PlayEffectToCurWaterGun(true)
end

M.OnReleaseSlider = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not self.enterWash then
		return
	end

	self.isShooting = false

	gCS.FarmFunctionUtils.PlayEffectToCurWaterGun(false)
end

M.OnSliderValueChange = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not self.enterWash then
		return
	end

	if self.lastSliderValue ~= nil then
		self.lastSliderValue = self.bindData.slider.value

		return
	end

	local deltaY = self.bindData.slider.value - self.lastSliderValue
	self.lastSliderValue = self.bindData.slider.value

	if deltaY ~= 0 then
		return
	end

	self.rightHandY = Mathf.Clamp01(self.rightHandY + deltaY / self.bindData.slider.maxValue)

	gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, self.rightHandY, 18)
end

M.OnClickReturn = function(self)
	self.GameEnd(self, false)
end

M.OnClickBtnPress = function(self)
	self.isPress = true
end

M.OnClickBtnRelease = function(self)
	self.isPress = false
end

M.OnTurnLeftPress = function(self)
	self.isLeftPress = true
end

M.OnTurnLeftRelease = function(self)
	self.isLeftPress = false
end

M.OnTurnRightPress = function(self)
	self.isRightPress = true
end

M.OnTurnRightRelease = function(self)
	self.isRightPress = false
end

M.OnTurnOverClick = function(self)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, GameplaySignalInwardConfig.CorpFlipOver)
end

M.OnPressFullBtn = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not self.enterWash then
		return
	end

	self.isShooting = true

	gCS.FarmFunctionUtils.PlayEffectToCurWaterGun(true)
end

M.OnReleaseFullBtn = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not self.enterWash then
		return
	end

	self.isShooting = false

	gCS.FarmFunctionUtils.PlayEffectToCurWaterGun(false)
end
