C_DartGamePanelStore = DefClass("C_DartGamePanelStore", C_DartGamePanelStore, C_StoreGroup)
GroupName2Class.DartGamePanelStore = C_DartGamePanelStore
local M = C_DartGamePanelStore
local Input = UnityEngine.Input
local PoiGameDartConfig = LTConfig.PoiGameDartConfig
local PoiGameDartAIConfig = LTConfig.PoiGameDartAIConfig
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local PoiGameConfig = LTConfig.PoiGameConfig
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local UCursorInput = SGUI.UCursorInput
local Screen = UnityEngine.Screen
local GameInputManager = LX6.Manager.GameInputManager
local GameMode = {
	HighScore = 1,
	TargetScore = 2
}
local FanshapedScore = {
	20,
	1,
	18,
	4,
	13,
	6,
	10,
	15,
	2,
	17,
	3,
	19,
	7,
	16,
	8,
	11,
	14,
	9,
	12,
	5
}
local RingRangeMulti = {
	0,
	0,
	1,
	3,
	1,
	2
}
local RingRangeAdd = {
	50,
	25,
	0,
	0,
	0,
	0
}
local PointGotWay = {}
local RingRange = {
	0.02668,
	0.0692,
	0.3928,
	0.4518,
	0.663,
	0.72
}

function M:GetRealSizeScale()
	return 2
end

local InitData = {
	qteRange = 184,
	missLevel = 0,
	swayFrequency = 1,
	flyTime = 0.5,
	qteOkRange = 0.4,
	flyStartTime = 0,
	currentSimulateIndex = 1,
	targetScore = 0,
	hasClickTip = false,
	shotCD = 3,
	getScoreRange = 0.25,
	tempStopUpdateProgress = false,
	qtePerfectRange = 0.2,
	inCursorVisibleAnim = false,
	playMode = 1,
	cursorSize = 208,
	dropMix = 0.5,
	qteSpeed = 2,
	lastShotTime = 0,
	currentUsingDartId = 1,
	cursorPerfectScale = 0.5,
	swayRange = 50,
	currentTruePosition = Vector3.New(0, 0, 0),
	missRange = {}
}

function M:RegisterEvents()
	self.changePlayerHandler = self:CreateAction("OnChangePlayer")
	self.msgEvents = {
		[gEventConstants.ON_PANEL_REFRESH_CURRENT_PLAYER] = self.changePlayerHandler,
		[gEventConstants.ON_BEFORE_DISPLAY_ACHIEVEMENT] = self:CreateAction("OnBeforeDisplayAchievement"),
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = self:CreateAction("OnActionDeviceChanged")
	}
	self.bindData.BtnShotFull.luaClick = self:CreateAction("OnShootKeyDown")
	self.bindData.BtnShot.luaClick = self:CreateAction("OnShootKeyDown")

	self:RegisterMessageEvents(self.msgEvents)

	self.currentInputDevice = InputActionBind.activeGameDevice
	UCursorInput.onCursorPosChange = self:CreateAction("onCursorPosChange")
	self.bindData.joyStick.luaValueChanged = self:CreateAction(self.OnJoyStickValueChanged)
	local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height
	self.currentCursorPos = Vector2.New(width / 2, height / 2, 0)
	self.curVelocity = Vector2.New(0, 0)
end

function M:OnJoyStickValueChanged(x, y, intensity)
	self.curVelocity = Vector2.New(x, y) * intensity * 20
end

function M:RefreshDartPos(deltaTime)
	self.currentCursorPos = self.currentCursorPos + self.curVelocity * deltaTime
end

function M:OnBtnDragBegin(eventPointer)
	return
end

function M:OnBtnDrag(eventPointer)
	self.currentCursorPos = self.currentCursorPos + eventPointer.delta
end

function M:OnBtnDragEnd(eventPointer)
	return
end

function M:OnActionDeviceChanged()
	self.currentInputDevice = InputActionBind.activeGameDevice
end

function M:RefreshMobileBtn(isShow)
	self.bindData.joyStick.gameObject:SetActive(isShow)
	self.bindData.BtnShot.gameObject:SetActive(isShow)
end

function M:onCursorPosChange(position)
	local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height
	local worldPos = rect.parent:TransformPoint(Vector3.New(position.x - width / 2, position.y - height / 2, 0))
	local pos = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
	self.currentCursorPos = Vector3.New(pos.x, pos.y, 0)
end

function M:InitSetting()
	local settingComp = gDartsGameManager.currentDartsGame.SettingComp
	self.targetCenterTransform = gDartsGameManager.currentDartsGame.targetCenterTransform
	local tid = gBattleSpiritMgr.currentSpiritTemplateId
	local attr = gSpiritManager:GetUrbanAttr(tid)
	local cfg = PoiGameDartConfig.GetConfig(gDartsGameManager.currentDartsGame.currentUsingDartId)
	self.mobileSpeed = PoiGameConfig.DartNpc_Challenge_Mobile_speed
	local mePid = gCS.MyPlayerManager.PlayerUnit.Pid
	local isZeroSway = gBuffUtils.HasBuff(mePid, 52900013)
	local ytDartTwo2Three = gBuffUtils.HasBuff(mePid, 52900016)
	local carrotDartTwo2Three = gBuffUtils.HasBuff(mePid, 52900017)
	self.isTwo2Three = ytDartTwo2Three and gDartsGameManager.currentDartsGame.currentUsingDartId == 13 or carrotDartTwo2Three and gDartsGameManager.currentDartsGame.currentUsingDartId == 8

	if settingComp then
		self.flyTime = settingComp.DartFlyTime
		self.dropMix = settingComp.DartDropMix
		self.cursorSize = settingComp.DartCursorSize
		self.cursorOffsetScale = settingComp.DartCursorPerfectOffset
		self.qteSpeed = settingComp.DartQTETime
		self.qtePerfectRange = settingComp.DartQTEPerfectRange
		self.qteOkRange = settingComp.DartQTEOkRange
		self.swayRange = settingComp.CursorSwayRange
		self.swayFrequency = settingComp.CursorSwayFrequency
	else
		self.qtePerfectRange = cfg.PerfectRange
		self.qteOkRange = cfg.OkRange
		self.swayRange = cfg.ShakeAmp
		local frequencyMax = 5
		local frequencyMin = 1
		self.swayFrequency = (100 - cfg.ShakeFreq) / 100 * (frequencyMax - frequencyMin) + frequencyMin
		self.qteSpeed = PoiGameConfig.Dart_BarSpeed
	end

	self.swayRange = self.swayRange * Formula_cs:CalDartsShakeAmpSensitivity(attr)

	if isZeroSway then
		self.swayRange = 0
	end

	self.swayFrequency = self.swayFrequency * Formula_cs:CalDartsShakeFreqSensitivity(attr)
	self.qteOkRange = self.qteOkRange * Formula_cs:CalDartsOkRangeSensitivity(attr)
	self.qtePerfectRange = self.qtePerfectRange * Formula_cs:CalDartsPerfectRangeSensitivity(attr)
end

function M:InitPointGotWay()
	if self.PointGotWay == nil then
		self.PointGotWay = {}
	end

	for i = 1, #FanshapedScore do
		for j = 3, #RingRangeMulti do
			local point = FanshapedScore[i] * RingRangeMulti[j]

			if self.PointGotWay[point] == nil then
				self.PointGotWay[point] = {}
			end

			table.insert(self.PointGotWay[point], {
				fanIndex = i,
				ringIndex = j,
				mul = RingRangeMulti[j]
			})
		end
	end

	if self.PointGotWay[25] == nil then
		self.PointGotWay[25] = {}
	end

	table.insert(self.PointGotWay[25], {
		mul = 1,
		ringIndex = 2,
		fanIndex = 0
	})

	if self.PointGotWay[50] == nil then
		self.PointGotWay[50] = {}
	end

	table.insert(self.PointGotWay[50], {
		mul = 2,
		ringIndex = 1,
		fanIndex = 0
	})

	if self.CanGotPoint == nil then
		self.CanGotPoint = {}
	end

	for i, v in pairs(self.PointGotWay) do
		table.insert(self.CanGotPoint, i)
	end
end

function M:OnAwake()
	for i, v in pairs(InitData) do
		self[i] = v
	end

	self:RegisterEvents()
	self:InitSetting()
	self:InitPointGotWay()

	self.playMode = gDartsGameManager.currentDartsGame.playMode

	if gDartsGameManager.currentDartsGame.playMode == 2 then
		self.targetScore = gDartsGameManager.currentDartsGame.targetScore
		self.scoreList = self:SimulateTargetPointAction()
	end

	function gDartsGameManager.currentDartsGame.doStartFlyFunc(darts, isEnd)
		self:DoFireFunc(darts, isEnd)
	end

	self.bindData.CanInput = false
	self.bindData.BtnShotFull.interactable = false
	self.bindData.BtnShot.interactable = false
	self.bindData.leftStickBtn.interactable = false

	self:GetParent():RegisterBtnBackCallback(self:CreateAction("Close"))
	self:GetParent():SetRayBoxState(true)
end

function M:GetParent()
	return gStoreManager:GetStoreGroup("GameplayHudPanelStore")
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnStart()
	self.tempStopUpdateProgress = true
end

function M:RegisterBindGroup()
	local id = self.bindData.MeInfoUI.gameObject:GetInstanceID()
	self.MeInfo = self:GetStoreById(id)
	id = self.bindData.OtherInfoUI.gameObject:GetInstanceID()
	self.OtherInfo = self:GetStoreById(id)
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self:RegisterBindGroup()
	self:InitView()
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, true)
	SGUI.UCursorInput.Inst.SetCursorDisplay(false)
	SGUI.UCursorInput.StopCursorSnap()
	GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay, false, UnityEngine.CursorLockMode.None)

	if not gCS.LuaUtils.IsNonMobileAdaptive() and not self.hasClickTip then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.mobileTipAnim, "S_vx_NormalTips")
	end
end

function M:Close()
	if gDartsGameManager._dartNpcCfg then
		gSpoonClientMgr:ReleaseContextEvent(gDartsGameManager._dart_gadgetId, gSpoonEventType.OnDartInterrupt, {
			npcId = gDartsGameManager._dartNpcCfg.Id,
			gadgetId = gDartsGameManager._dart_gadgetId
		})
	end

	self:GetParent():SetRayBoxState(false)
	gDartsGameManager:DestroyGame()
end

function M:FindAnotherPoint(gotPoint)
	local tryPoint = 0

	for i = 1, 60 do
		tryPoint = gotPoint - i

		if tryPoint >= 1 and table.contains(self.CanGotPoint, tryPoint) then
			return tryPoint
		end

		tryPoint = gotPoint + i

		if tryPoint <= 60 and table.contains(self.CanGotPoint, tryPoint) then
			return tryPoint
		end
	end
end

function M:GetCanGotRandomUnderPoint(gotPoint)
	local canClearPoint = {}

	for i = 1, gotPoint do
		local tryGot = gotPoint - i

		if table.contains(self.CanGotPoint, tryGot) then
			table.insert(canClearPoint, tryGot)
		end
	end

	local index = math.random(1, #canClearPoint)

	return canClearPoint[index]
end

function M:GetTwoDartCanGotPoint()
	local canClearPoint = {}

	for i = 1, #self.CanGotPoint do
		for j = 1, #self.CanGotPoint do
			if not table.contains(canClearPoint, self.CanGotPoint[i] + self.CanGotPoint[j]) then
				table.insert(canClearPoint, self.CanGotPoint[i] + self.CanGotPoint[j])
			end
		end
	end

	return canClearPoint
end

local PERFECT_ORDERS = {
	[301] = {
		{
			60,
			60,
			60,
			60,
			60,
			1
		},
		{
			60,
			60,
			57,
			60,
			60,
			4
		},
		{
			60,
			60,
			54,
			60,
			60,
			7
		},
		{
			60,
			60,
			51,
			60,
			60,
			10
		}
	},
	[501] = {
		{
			60,
			60,
			60,
			60,
			60,
			60,
			60,
			60,
			21
		},
		{
			60,
			60,
			60,
			60,
			60,
			57,
			60,
			60,
			24
		},
		{
			60,
			60,
			60,
			60,
			60,
			54,
			60,
			60,
			27
		},
		{
			60,
			60,
			60,
			60,
			60,
			51,
			60,
			60,
			30
		},
		{
			60,
			60,
			60,
			60,
			60,
			48,
			60,
			60,
			33
		}
	}
}

function M:SimulateTargetPointAction()
	local targetScore = self.targetScore
	local aiConfigId = gDartsGameManager.currentDartsGame.aiConfigId

	if not aiConfigId or aiConfigId <= 0 then
		aiConfigId = 100
	end

	local aiConfig = PoiGameDartAIConfig.GetConfig(aiConfigId)
	local scoreList = {}

	math.randomseed(os.time())

	local isRatePerfect = aiConfig.IsRatePerfect

	if isRatePerfect then
		local orders = PERFECT_ORDERS[targetScore]

		if orders then
			local ordersCount = #orders
			local randomIndex = math.random(1, ordersCount)
			local order = orders[randomIndex]

			for _, data in ipairs(order) do
				table.insert(scoreList, data)
			end

			return scoreList
		end
	end

	local randomTurns = aiConfig.BustCount
	local tryScoreList = {}
	local oneTurnShots = {}
	local oneTurnTotalPoint = 0
	local currentScore = 0
	local currentBustTurn = 0
	local selfShotGotPoint = nil
	local whileCost = 10000

	while #scoreList < 500 do
		whileCost = whileCost - 1

		if whileCost < 0 then
			print_error("循环次数过多")

			break
		end

		if #oneTurnShots >= 3 then
			for i = 1, #oneTurnShots do
				table.insert(scoreList, oneTurnShots[i])
			end

			table.clear(oneTurnShots)

			currentScore = currentScore + oneTurnTotalPoint
			oneTurnTotalPoint = 0
		end

		if currentScore == targetScore then
			break
		end

		self.getScoreRange = aiConfig.ScoreRateRange
		selfShotGotPoint = math.floor(aiConfig.ScoreRateCountUp * (1 + math.random() * 2 * self.getScoreRange - self.getScoreRange))

		if table.contains(self.CanGotPoint, selfShotGotPoint) then
			table.insert(tryScoreList, selfShotGotPoint)

			local nextScore = currentScore + oneTurnTotalPoint + selfShotGotPoint

			if nextScore == targetScore and currentBustTurn < randomTurns then
				selfShotGotPoint = self:FindAnotherPoint(selfShotGotPoint)

				table.insert(oneTurnShots, selfShotGotPoint)

				oneTurnTotalPoint = oneTurnTotalPoint + selfShotGotPoint

				if targetScore < currentScore + oneTurnTotalPoint then
					for i = 1, #oneTurnShots do
						table.insert(scoreList, oneTurnShots[i])
					end

					table.clear(oneTurnShots)

					oneTurnTotalPoint = 0
					currentBustTurn = currentBustTurn + 1
				end
			elseif randomTurns <= currentBustTurn and targetScore - nextScore <= 60 and #oneTurnShots <= 1 then
				local lastShotLeftPoint = 0

				if targetScore - nextScore > 0 then
					if #oneTurnShots == 1 then
						if table.contains(self.CanGotPoint, targetScore - nextScore) then
							for i = 1, #oneTurnShots do
								table.insert(scoreList, oneTurnShots[i])
							end

							table.insert(scoreList, selfShotGotPoint)
							table.insert(scoreList, targetScore - nextScore)
							table.clear(oneTurnShots)

							oneTurnTotalPoint = 0

							break
						else
							table.clear(oneTurnShots)

							oneTurnTotalPoint = 0
							lastShotLeftPoint = targetScore - currentScore
						end
					else
						table.insert(scoreList, selfShotGotPoint)
						table.insert(oneTurnShots, selfShotGotPoint)

						oneTurnTotalPoint = oneTurnTotalPoint + selfShotGotPoint
						lastShotLeftPoint = targetScore - nextScore
					end
				else
					lastShotLeftPoint = targetScore - currentScore
				end

				if table.contains(self.CanGotPoint, lastShotLeftPoint) then
					table.insert(scoreList, lastShotLeftPoint)

					currentScore = targetScore

					break
				else
					local canClearPoint = {}

					for i = 1, #self.CanGotPoint do
						local tryGot = self.CanGotPoint[i]

						if tryGot < lastShotLeftPoint and table.contains(self.CanGotPoint, lastShotLeftPoint - tryGot) then
							table.insert(canClearPoint, tryGot)
						end
					end

					if #canClearPoint ~= 0 then
						local index = math.random(1, #canClearPoint)

						table.insert(scoreList, canClearPoint[index])
						table.insert(scoreList, lastShotLeftPoint - canClearPoint[index])

						currentScore = targetScore

						break
					end
				end
			elseif targetScore < nextScore then
				if randomTurns <= currentBustTurn then
					local newScore = self.GetCanGotRandomUnderPoint(targetScore - currentScore - oneTurnTotalPoint)

					table.insert(oneTurnShots, newScore)

					oneTurnTotalPoint = oneTurnTotalPoint + newScore
				else
					table.insert(oneTurnShots, selfShotGotPoint)

					oneTurnTotalPoint = oneTurnTotalPoint + selfShotGotPoint

					for i = 1, #oneTurnShots do
						table.insert(scoreList, oneTurnShots[i])
					end

					table.clear(oneTurnShots)

					oneTurnTotalPoint = 0
					currentBustTurn = currentBustTurn + 1
				end
			else
				table.insert(oneTurnShots, selfShotGotPoint)

				oneTurnTotalPoint = oneTurnTotalPoint + selfShotGotPoint
			end
		end
	end

	return scoreList
end

function M:CulPoint(hitPosition)
	local scale = self.GetRealSizeScale()
	local dir = hitPosition - self.targetCenterTransform.position
	dir = Vector3.ProjectOnPlane(dir, self.targetCenterTransform.forward)
	local dis = dir:Magnitude()
	local ringIndex = -1

	for i = 1, #RingRange do
		if RingRange[i] >= dis * scale then
			ringIndex = i

			break
		end
	end

	if ringIndex < 0 then
		return 0
	end

	local angleUp = Vector3.Angle(self.targetCenterTransform.up, dir)
	local angleRight = Vector3.Angle(self.targetCenterTransform.right, dir)
	local realAngle = 0

	if angleRight <= 90 then
		realAngle = angleUp
	else
		realAngle = -angleUp + 360
	end

	local areaIndex = math.ceil((realAngle + 9) % 360 / 18)
	local centerPoint = RingRangeAdd[ringIndex]
	local singlePoint = FanshapedScore[areaIndex]
	local multiple = RingRangeMulti[ringIndex]

	if gDartsGameManager.currentDartsGame:IsMyTurn() and self.isTwo2Three and multiple == 2 then
		multiple = 3
	end

	local point = centerPoint + multiple * singlePoint

	return point, areaIndex, ringIndex
end

function M:OnChangePlayer()
	if self.STATE_EnableOnce == false then
		return
	end

	self:InitView()
	self:RefreshCursorCanInput()

	if gDartsGameManager.currentDartsGame:IsMyTurn() then
		self.bindData.BtnShot.interactable = false
		self.bindData.BtnShotFull.interactable = false
		self.bindData.leftStickBtn.interactable = false
	end
end

function M:OnBeforeDisplayAchievement()
	if gDartsGameManager.currentDartsGame:IsMyTurn() then
		self:RefreshMobileBtn(false)
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.BgDecoAnim, "S_vx_DartGamePanel_BgDeco_Close")
end

function M:CloseBgDeco()
	gCS.LuaUtils.PlayAnimationByName(self.bindData.BgDecoAnim, "S_vx_DartGamePanel_BgDeco_Close")
end

local ButtonEvents = {
	Close = 1,
	ShootKeyDown = 1000
}

function M:DoShotPosition(position, targetPoint)
	if gDartsGameManager.currentDartsGame:IsMyTurn() then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.DoShootAnim, "S_vx_DartGamePanel_CrosshairShoot")
	end

	self.targetPosition = position
	self.targetPoint = targetPoint
	local preCul = self:CulPoint(position)

	if targetPoint ~= nil and preCul ~= targetPoint then
		preCul = targetPoint
	end

	self.waitFly = true

	gDartsGameManager.currentDartsGame:FireOneDartTimeline(preCul, position)

	self.lastShotTime = gLogicTime.time
	self.tempStopUpdateProgress = true
end

function M:DoFireFunc(darts, isEnd)
	self.flyStartTime = gLogicTime.time - gLogicTime.deltaTime
	self.flyingDarts = darts

	if isEnd then
		self.shotCD = -1
	end

	self.startPosition = self.flyingDarts.transform.position

	self:UpdateFlyDartToTargetPoint()

	self.waitFly = false
end

function M:GetRandomPointGotWay()
	local aiConfigId = gDartsGameManager.currentDartsGame.aiConfigId
	local aiConfig = PoiGameDartAIConfig.GetConfig(aiConfigId)
	local selfTurnGotPoint = 0
	local randomTime = 100

	while true do
		randomTime = randomTime - 1

		if randomTime < 0 then
			if self.CanGotPoint ~= nil and #self.CanGotPoint > 0 then
				selfTurnGotPoint = self.CanGotPoint[1]

				break
			end

			selfTurnGotPoint = 0

			break
		end

		self.getScoreRange = aiConfig.ScoreRateRange
		selfTurnGotPoint = math.floor(aiConfig.ScoreRateCountUp * (1 + math.random() * 2 * self.getScoreRange - self.getScoreRange))

		if table.contains(self.CanGotPoint, selfTurnGotPoint) then
			break
		end
	end

	local canGotPoint = Mathf.Clamp(selfTurnGotPoint, 1, 60)
	local getWayList = self.PointGotWay[canGotPoint]
	local randomIndex = math.random(1, #getWayList)

	return canGotPoint, getWayList[randomIndex]
end

function M:GetScoreWayByTargetPoint(point)
	if point == nil then
		print_error("触发了异常,getWayList为空的bug没修好")

		local getWayList = self.PointGotWay[10]
		local randomIndex = math.random(1, #getWayList)

		return 10, getWayList[randomIndex]
	end

	local getWayList = self.PointGotWay[point]
	local randomIndex = math.random(1, #getWayList)

	return point, getWayList[randomIndex]
end

function M:OnBtnClose()
	gDartsGameManager:DestroyGame()
end

function M:OnShootKeyDown()
	if self.inCursorVisibleAnim then
		return
	end

	if self.shotCD < 0 then
		return
	end

	if not self.bindData.CanInput then
		return
	end

	if gLogicTime.time - self.lastShotTime < self.shotCD then
		return
	end

	if self.waitFly then
		return
	end

	local factor = self.bindData.shootProgressFillAmount

	if factor > 0.5 - self.qtePerfectRange / 2 and factor < 0.5 + self.qtePerfectRange / 2 then
		self.missLevel = 0
	elseif factor > 0.5 - self.qteOkRange / 2 and factor < 0.5 + self.qteOkRange / 2 then
		self.missLevel = 1
	else
		self.missLevel = 2
	end

	if self.bindData.CursorPosition == nil then
		self:UpdateRandomMoveCursorOffset()
	end

	local screenPoint = self.bindData.CursorPosition

	if screenPoint == nil then
		screenPoint = Vector3.New(0, 0, 0)
	end

	local missDir = nil

	if self.missLevel > 0 then
		missDir = Vector3.Normalize(Vector3.New((0.5 - math.random()) * 2, (0.5 - math.random()) * 2, 0))
	end

	if self.missLevel == 1 then
		screenPoint = screenPoint + missDir * math.random() * self.cursorPerfectScale * self.cursorSize / 2
	elseif self.missLevel == 2 then
		screenPoint = screenPoint + missDir * (math.random() * (1 - self.cursorPerfectScale) + self.cursorPerfectScale) * self.cursorSize / 2
	end

	local worldPos = self.bindData.RootRect:TransformPoint(screenPoint)
	screenPoint = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
	local hitInfo = gCS.LuaUtils.GetUIToCameraHit(screenPoint)

	if not self.hasClickTip then
		gCS.LuaUtils.StopCurrentAnimation(self.bindData.mobileTipAnim)

		self.hasClickTip = true
	end

	self:DoShotPosition(hitInfo.point)
end

function M:OtherPlayerShoot(serverPoint, serverPos)
	if serverPoint and serverPoint >= 0 then
		print_debug("Dart: OtherPlayerShoot", serverPoint, serverPos)
		self:DoShotPosition(serverPos, serverPoint)

		return
	end

	local point, gotWay = nil

	if self.playMode == 1 then
		point, gotWay = self:GetRandomPointGotWay()
	else
		local targetPoint = self.scoreList[self.currentSimulateIndex]
		point, gotWay = self:GetScoreWayByTargetPoint(targetPoint)
		self.currentSimulateIndex = self.currentSimulateIndex + 1
	end

	local fanIndex = gotWay.fanIndex
	local ringIndex = gotWay.ringIndex
	local center = self.targetCenterTransform.position
	local randomDir = Vector3.one

	if fanIndex > 0 then
		local randomAngle = math.random() * 360 / 20 + (fanIndex - 1) * 360 / 20 - 9
		local rotation = Quaternion.AngleAxis(randomAngle, -self.targetCenterTransform.forward)
		randomDir = rotation:MulVec3(self.targetCenterTransform.up)
	else
		randomDir = Vector3.Normalize(Vector3.New((0.5 - math.random()) * 2, (0.5 - math.random()) * 2, 0))
	end

	local rangeMin = RingRange[ringIndex - 1] or 0
	local rangeMax = RingRange[ringIndex]
	local randomDis = math.random() * (rangeMax - rangeMin) + rangeMin
	local realDis = randomDis / self:GetRealSizeScale()
	local targetPosition = center + randomDir * realDis

	self:DoShotPosition(targetPosition, point)
end

function M:InitView()
	self.bindData.okRangeFillAmount = self.qteOkRange * 0.5
	self.bindData.okRotateZ = -90 + self.qteOkRange * 0.5 / 2 * 360
	self.bindData.perfectRangeFillAmount = self.qtePerfectRange * 0.5
	self.bindData.perfectRotateZ = -90 + self.qtePerfectRange * 0.5 / 2 * 360
	self.shotCD = 3
	self.lastShotTime = 0
	self.waitFly = false

	self:InitCurrentCursor()
	self:RefreshPoint()
	self:RefreshName()
	self:RefreshRounds()

	if gDartsGameManager.currentDartsGame.currentIndex == 1 then
		self.bindData.isMyTurn = true
	else
		self.bindData.isMyTurn = false
	end

	if not gDartsGameManager.currentDartsGame:IsMyTurn() then
		self.isNpcGame = true

		self.bindData.OtherShotNode.gameObject:SetActive(true)

		local targetViewTransform = gDartsGameManager.currentDartsGame.targetViewTransform
		self.bindData.ViewCamera.transform.position = targetViewTransform.position
		self.bindData.ViewCamera.transform.rotation = targetViewTransform.rotation

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			self:RefreshMobileBtn(false)
		end
	else
		self.bindData.OtherShotNode.gameObject:SetActive(false)

		self.isNpcGame = false
	end
end

function M:RefreshCursorCanInput()
	if gDartsGameManager.currentDartsGame == nil then
		return
	end

	if not gDartsGameManager.currentDartsGame:IsMyTurn() then
		self:SetCanInput(false)

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			self:RefreshMobileBtn(false)
		end
	elseif not gDartsGameManager.currentDartsGame.isRealCanShot then
		self:SetCanInput(false)

		self.shotCD = -1
	else
		self:SetCanInput(true)

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			self:RefreshMobileBtn(true)
		end
	end
end

local currentMoveOffsetProgress = 0
local currentMoveDir = Vector3.New(0, 1, 0)

function M:UpdateRandomMoveCursorOffset()
	local position = Vector3.New(0, 80, 0)
	currentMoveOffsetProgress = currentMoveOffsetProgress + Time.deltaTime / self.swayFrequency

	if currentMoveOffsetProgress >= 2 then
		currentMoveDir = Vector3.Normalize(Vector3.New((0.5 - math.random()) * 2, (0.5 - math.random()) * 2, 0))
		currentMoveOffsetProgress = currentMoveOffsetProgress % 2
	end

	local currentPosition = nil
	local currentScreenRealPoint = gCS.LuaUtils.ScreenPointUI(self.bindData.RootRect, self.currentTruePosition)

	if currentMoveOffsetProgress <= 1 then
		currentPosition = currentScreenRealPoint + currentMoveDir * currentMoveOffsetProgress * self.swayRange
	else
		currentPosition = currentScreenRealPoint + currentMoveDir * (2 - currentMoveOffsetProgress) * self.swayRange
	end

	self.bindData.CursorPosition = currentPosition

	if gDartsGameManager.currentDartsGame then
		local worldPos = self.bindData.RootRect:TransformPoint(currentScreenRealPoint)
		local screenPoint = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
		local dir = gCS.LuaUtils.GetScreenPointRayDir(screenPoint)

		gDartsGameManager.currentDartsGame:MoveCursorLookAt(dir)
	end
end

function M:ResetRandomPosition()
	if self.currentInputDevice == GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		LX6.Manager.GameInputManager.SetCursorPositionInPC(Screen.width / 2, Screen.height / 2)
	elseif self.currentInputDevice == GameDevice.PlayStation or self.currentInputDevice == GameDevice.Xbox then
		self.currentCursorPos = Vector3.New(Screen.width / 2, Screen.height / 2, 0)

		UCursorInput.ResetCursorPos()
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.currentCursorPos = Vector3.New(Screen.width / 2, Screen.height / 2, 0)
	end
end

function M:UpdateFlyDartToTargetPoint()
	local dartStartPosition = self.startPosition
	local dartTargetPosition = self.targetPosition
	local timeToReachTarget = self.flyTime
	local gravity = -9.81 * self.dropMix
	local initialVelocity = (dartTargetPosition - dartStartPosition) / timeToReachTarget - Vector3.New(0, 0.5 * gravity * timeToReachTarget, 0)
	local currentTime = gLogicTime.time
	local startTime = self.flyStartTime
	local deltaT = currentTime - startTime

	if self.flyTime < deltaT then
		deltaT = self.flyTime
	end

	local position = Vector3.New(dartStartPosition.x + deltaT * initialVelocity.x, dartStartPosition.y + initialVelocity.y * deltaT + 0.5 * gravity * deltaT * deltaT, dartStartPosition.z + deltaT * initialVelocity.z)

	if not gCS.LuaUtils.IsNull(self.flyingDarts) then
		if Vector3.Distance(self.flyingDarts.transform.position, position) > 0.01 then
			local dir = self.flyingDarts.transform.position - position
			self.flyingDarts.transform.up = Vector3.Normalize(dir)
		end

		self.flyingDarts.transform.position = position
	end
end

function M:InitCurrentCursor()
	return
end

function M:SetCanInput(isCanInput)
	if isCanInput and self.bindData.CanInput ~= isCanInput then
		self:ResetRandomPosition()

		self.tempStopUpdateProgress = false

		gCS.LuaUtils.PlayAnimationByName(self.bindData.DoShootAnim, "S_vx_DartGamePanel_CrosshairOpen")

		local delay = gCS.LuaUtils.GetAnimationTime(self.bindData.DoShootAnim, "S_vx_DartGamePanel_CrosshairOpen")
		self.inCursorVisibleAnim = false

		if delay > 0 then
			self.inCursorVisibleAnim = true

			Timer.New(function ()
				self.inCursorVisibleAnim = false
			end, delay):Start()
		end
	end

	self.bindData.CanInput = isCanInput
	self.bindData.BtnShotFull.interactable = isCanInput
	self.bindData.BtnShot.interactable = isCanInput
	self.bindData.leftStickBtn.interactable = isCanInput
end

function M:OnCursorMoveStart(value)
	self.isCursorMove = true
end

function M:OnCursorMoveEnd(value)
	self.isCursorMove = false
end

function M:OnCursorMove(value)
	if self.isCursorMove then
		self:DoCursorMove(value.x * 1000 * Time.unscaledDeltaTime, value.y * 1000 * Time.unscaledDeltaTime)
	end
end

function M:DoCursorMove(x, y)
	return
end

local shootProgressStartTime = 0

function M:UpdateShootProgressFill()
	if not self.bindData.CanInput then
		return
	end

	if self.tempStopUpdateProgress ~= nil and self.tempStopUpdateProgress then
		return
	end

	local progress = (shootProgressStartTime - gLogicTime.time) / self.qteSpeed % 2
	local amount = 0

	if progress <= 1 then
		amount = progress
		self.bindData.shootProgressFillAmount = amount
		self.bindData.perfectOverFillAmount = Mathf.Clamp(amount - (1 - self.qtePerfectRange) / 2, 0, self.qtePerfectRange)
	else
		amount = 2 - progress
		self.bindData.shootProgressFillAmount = amount
		self.bindData.perfectOverFillAmount = Mathf.Clamp(amount - (1 - self.qtePerfectRange) / 2, 0, self.qtePerfectRange)
	end

	self.bindData.progressHeadHintZ = 90 - amount * 180
end

function M:OnUpdate()
	self:UpdateShootProgressFill()

	if not self.inCursorVisibleAnim and self.shotCD >= 0 and self.bindData.CanInput and self.shotCD <= gLogicTime.time - self.lastShotTime and not self.waitFly then
		self.bindData.BtnShot.interactable = true
		self.bindData.BtnShotFull.interactable = true
		self.bindData.leftStickBtn.interactable = true
	else
		self.bindData.BtnShot.interactable = false
		self.bindData.BtnShotFull.interactable = false
		self.bindData.leftStickBtn.interactable = false
	end

	local pos = nil

	if self.currentInputDevice == GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		pos = Input.mousePosition

		if self.moveParam ~= nil and (self.moveParam.x ~= 0 or self.moveParam.y ~= 0) then
			self.currentCursorPos = self.currentCursorPos + self.moveParam
			pos = self.currentCursorPos
		end
	elseif self.currentInputDevice == GameDevice.PlayStation or self.currentInputDevice == GameDevice.Xbox then
		pos = self.currentCursorPos
	else
		self:RefreshDartPos(self.mobileSpeed)

		pos = self.currentCursorPos
	end

	if pos == nil then
		return
	end

	pos.x = Mathf.Clamp(pos.x, 0, Screen.width)
	pos.y = Mathf.Clamp(pos.y, 0, Screen.height)
	local delta = pos - self.currentTruePosition

	if math.abs(delta.x) > 0.01 or math.abs(delta.y) > 0.01 then
		if self.bindData.CanInput then
			self.currentTruePosition = pos
		end

		if not self.isCursorMove then
			self:OnCursorMoveStart()
		else
			self:OnCursorMove(delta)
		end
	elseif self.isCursorMove then
		self:OnCursorMoveEnd()
	end

	if self.bindData.CanInput and (self.tempStopUpdateProgress == nil or not self.tempStopUpdateProgress) then
		self:UpdateRandomMoveCursorOffset()
	end

	if gLogicTime.time < self.flyStartTime + self.flyTime then
		self:UpdateFlyDartToTargetPoint()
	elseif self.flyStartTime > 0 then
		self:EndDartsFly()
	end
end

function M:EndDartsFly()
	self:UpdateFlyDartToTargetPoint()

	self.flyStartTime = 0

	self:SetCanInput(false)

	local getPoint, areaIndex, ringIndex = self:CulPoint(self.targetPosition)

	if self.targetPoint ~= nil and self.targetPoint ~= getPoint then
		getPoint = self.targetPoint
	end

	self.targetPoint = nil

	if gDartsGameManager.currentDartsGame and gDartsGameManager.currentDartsGame:IsMyTurn() then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
	end

	self:PlayEffectAndGetPoint(getPoint, areaIndex, ringIndex)
end

function M:PlayEffectAndGetPoint(point, areaIndex, ringIndex)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:PlayHitEffect(areaIndex, ringIndex)
	end

	local canShotAgain = gDartsGameManager.currentDartsGame:CurrentPlayerGetPoint(point)

	self:RefreshPoint(canShotAgain)

	if not canShotAgain then
		if gDartsGameManager.currentDartsGame.isGameEnd then
			self.bindData.OtherShotNode.gameObject:SetActive(false)
		else
			gLuaTimeMgrUtils.Delay(function ()
				if not self.STATE_EnableOnce then
					return
				end

				self.bindData.OtherShotNode.gameObject:SetActive(false)
			end, 0.5)
		end

		self.shotCD = -1
	else
		gLuaTimeMgrUtils.Delay(function ()
			self:RefreshCursorCanInput()
		end, 0.5)
	end
end

function M:RefreshPoint(canShotAgain)
	if not self.STATE_EnableOnce then
		return
	end

	if gDartsGameManager.currentDartsGame == nil then
		return
	end

	local me = gDartsGameManager.currentDartsGame.playerList[1]

	if self.playMode == 2 then
		self.MeInfo.playerScore = self.targetScore - me.point
		self.MeInfo.playerThisTurnScore = me.point - me.roundStartPoint
	else
		self.MeInfo.playerScore = me.point
		self.MeInfo.playerThisTurnScore = me.point - me.roundStartPoint
	end

	local other = gDartsGameManager.currentDartsGame.playerList[2]

	if self.playMode == 2 then
		self.OtherInfo.playerScore = self.targetScore - other.point
		self.OtherInfo.playerThisTurnScore = other.point - other.roundStartPoint
	else
		self.OtherInfo.playerScore = other.point
		self.OtherInfo.playerThisTurnScore = other.point - other.roundStartPoint
	end

	if gDartsGameManager.currentDartsGame.currentIndex == 1 then
		if canShotAgain ~= nil then
			if not canShotAgain then
				gCS.LuaUtils.PlayAnimationByName(self.MeInfo.playerScoreAnim, "S_vx_DartGamePanel_playerScore")
			else
				gCS.LuaUtils.PlayAnimationByName(self.MeInfo.playerScoreAnim, "S_vx_DartGamePanel_playerCurrent")
			end
		end
	elseif canShotAgain ~= nil then
		if not canShotAgain then
			gCS.LuaUtils.PlayAnimationByName(self.OtherInfo.playerScoreAnim, "S_vx_DartGamePanel_NPCScore")
		else
			gCS.LuaUtils.PlayAnimationByName(self.OtherInfo.playerScoreAnim, "S_vx_DartGamePanel_NPCCurrent")
		end
	end
end

function M:RefreshName()
	local me = gDartsGameManager.currentDartsGame.playerList[1]
	self.MeInfo.playerName = me.playerName
	local other = gDartsGameManager.currentDartsGame.playerList[2]
	self.OtherInfo.playerName = other.playerName
end

function M:RefreshRounds()
	local player = gDartsGameManager.currentDartsGame.playerList[gDartsGameManager.currentDartsGame.currentIndex]
	self.bindData.roundIndex = player.roundIndex .. "/" .. gDartsGameManager.currentDartsGame.roundCount
end

function M:OnDestroy()
	UnityEngine.GameObject.Destroy(self.bindData.ViewCamera)
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, false)
	SGUI.UCursorInput.Inst.SetCursorDisplay(true)
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay)
end
