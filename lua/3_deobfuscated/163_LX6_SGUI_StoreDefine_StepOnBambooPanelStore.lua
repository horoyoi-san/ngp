C_StepOnBambooPanelStore = DefClass("C_StepOnBambooPanelStore", C_StepOnBambooPanelStore, C_StoreGroup)
GroupName2Class.StepOnBambooPanelStore = C_StepOnBambooPanelStore
local M = C_StepOnBambooPanelStore
local Side = {
	Left = 1,
	Right = 2
}
local Stage = {
	Two = 2,
	One = 1
}
local MyPlayerManager = gCS.MyPlayerManager

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
	self:InitGame(data)

	local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if store and store.bindData.btnExit then
		store.bindData.btnExit:SetActive(false)
	end
end

function M:OnClose()
	self.greatZone = nil
	self.perfectZone = nil
	local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if store and store.bindData.btnExit then
		store.bindData.btnExit:SetActive(true)
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.btnR.luaClick = self:CreateAction("OnClickBtnR")
	self.bindData.btnL.luaClick = self:CreateAction("OnClickBtnL")
end

function M:OnClickBtnR()
	self:ConfirmRun(Side.Right)
end

function M:OnClickBtnL()
	self:ConfirmRun(Side.Left)
end

function M:InitGame(data)
	self.animSpeedStage = 0
	self.lastSendAnimSpeed = nil
	self.lastSendAnimTime = nil
	self.sideCheck = false
	self.curEnableSide = Side.Left
	self.curSpeed = 0
	self.startTime = nil
	self.curStage = Stage.One
	self.curTime = 0
	self.sendFailedSignal = false
	self.barIncreaseLength = data.barIncreaseLength or 0.05
	self.barDecreaseInterval = data.barDecreaseInterval or 30
	self.sendEventDeltaTime = data.sendEventDeltaTime or 0.5
	self.stageOneAnimSpeedsArea = data.animSpeedsArea
	self.animSpeedsArea = data.animSpeedsArea
	self.stageTwoAnimSpeedsArea = data.stageTwoAnimSpeedsArea
	self.speedDecreaseFactors = data.speedDecreaseFactors
	self.speedMapToStateTreeIndex = data.speedMapToStateTreeIndex
	self.changeSpeedSignal = data.changeSpeedSignal
	self.curve = data.barDecreaseSpeedCurve
	self.stageTwoDelay = data.stageTwoDelay
	self.outGreenAreaFailTime = data.outGreenAreaFailTime
	self.greatStateTreeIndex = data.greatStateTreeIndex
	self.perfectStateTreeIndex = data.perfectStateTreeIndex
	self.failSignal = data.failSignal
	self.greatZone = {}
	self.perfectZone = {}

	self:RefreshSpeedBar()
	self:InitGreatAndPerfectArea()

	self.startTime = os.clock()
end

function M:OnUpdate()
	if not self.startTime then
		return
	end

	local speed = 0.2

	if self.curve and self.barDecreaseInterval and self.barDecreaseInterval > 0 then
		local time = (os.clock() - self.startTime) / self.barDecreaseInterval
		time = math.min(1, math.max(0, time))
		speed = self.curve:Evaluate(time)
	end

	self.curSpeed = math.max(0, self.curSpeed - Time.deltaTime * speed * self.runSpeedDecreaseFactor)

	self:RefreshSpeedBar()

	self.curTime = self.curTime + Time.deltaTime

	if self.curStage == Stage.One then
		if self.stageTwoDelay < self.curTime then
			self.curStage = Stage.Two
			self.curTime = 0
			self.animSpeedsArea = self.stageTwoAnimSpeedsArea

			self:InitGreatAndPerfectArea()
		end
	elseif self.curStage == Stage.Two then
		if table.contains(self.greatStateTreeIndex, self.animSpeedStage) or table.contains(self.perfectStateTreeIndex, self.animSpeedStage) then
			self.curTime = 0
		elseif self.outGreenAreaFailTime <= self.curTime then
			if not self.sendFailedSignal and self.failSignal and self.failSignal > 0 then
				self.sendFailedSignal = true

				gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.failSignal)
			end

			gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
		end
	end
end

function M:ConfirmRun(curSide)
	if curSide ~= self.curEnableSide and self.sideCheck then
		return
	end

	self.sideCheck = true
	self.curSpeed = math.min(1, self.curSpeed + self.barIncreaseLength)

	if not self.startTime then
		self.startTime = os.clock()
	end

	self:ShowRunBtn(curSide, true)
	self:RefreshSpeedBar()
end

function M:RefreshSpeedBar()
	self.animSpeedStage = 0
	self.runSpeedDecreaseFactor = 1

	if self.animSpeedsArea then
		for i = 1, #self.animSpeedsArea do
			if self.curSpeed <= self.animSpeedsArea[i] then
				local decreaseFactor = self.speedDecreaseFactors and self.speedDecreaseFactors[i]

				if decreaseFactor then
					self.runSpeedDecreaseFactor = decreaseFactor
				end

				local newAnimSpeedStage = self.speedMapToStateTreeIndex and self.speedMapToStateTreeIndex[i]

				if newAnimSpeedStage then
					self.animSpeedStage = newAnimSpeedStage
				end

				break
			end
		end
	end

	if not self.lastSendAnimSpeed or not self.lastSendAnimTime or self.animSpeedStage ~= self.lastSendAnimSpeed and self.sendEventDeltaTime < os.clock() - self.lastSendAnimTime then
		self.lastSendAnimSpeed = self.animSpeedStage
		self.lastSendAnimTime = os.clock()

		if self.changeSpeedSignal and self.changeSpeedSignal > 0 then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.changeSpeedSignal)
		end
	end

	gGaoQiaoManager.stepOnBambooAnimSpeedStage = self.animSpeedStage
	self.bindData.bar.value = self.curSpeed
end

function M:ShowRunBtn(side, playClick)
	local curBtn, anotherBtn = nil

	if side == Side.Left then
		self.curEnableSide = Side.Right
		curBtn = self.bindData.btnL
		anotherBtn = self.bindData.btnR
	else
		self.curEnableSide = Side.Left
		curBtn = self.bindData.btnR
		anotherBtn = self.bindData.btnL
	end

	curBtn.activation = false
	anotherBtn.activation = true
	anotherBtn.transform.localScale = Vector3.one

	if playClick then
		self:PlayClick(curBtn)
	end
end

function M:PlayClick(btn)
	self.bindData.qteClick:InvokeCallback(SGUI.EInvokeTime.User1)

	local pos = btn.localPosition

	self.bindData.qteClick.transform:SetLocalPosition(pos.x, pos.y, pos.z)
end

function M:InitGreatAndPerfectArea()
	local animArea = self.stageOneAnimSpeedsArea

	if self.curStage == Stage.Two then
		animArea = self.stageTwoAnimSpeedsArea
	end

	if animArea and #animArea > 0 and self.speedMapToStateTreeIndex and #self.speedMapToStateTreeIndex > 0 then
		local curMinSpeed = 0
		local spawnInfo = {}

		for i = 1, #animArea do
			local max = animArea[i]
			local newAnimSpeedStage = self.speedMapToStateTreeIndex[i]

			if newAnimSpeedStage then
				if table.contains(self.greatStateTreeIndex, newAnimSpeedStage) then
					table.insert(spawnInfo, 1, {
						type = 0,
						min = curMinSpeed,
						max = max
					})
				elseif table.contains(self.perfectStateTreeIndex, newAnimSpeedStage) then
					table.insert(spawnInfo, {
						type = 1,
						min = curMinSpeed,
						max = max
					})
				end
			end

			curMinSpeed = max
		end

		if #spawnInfo > 0 then
			local newGreatZone = {}
			local newPerfectZone = {}

			for i = 1, #spawnInfo do
				local info = spawnInfo[i]
				local zoneWidget = nil
				local generatedZone = info.type == 0 and self.greatZone or self.perfectZone
				zoneWidget = generatedZone[1]

				if zoneWidget then
					table.remove(generatedZone, 1)
				end

				if not zoneWidget then
					local template = info.type == 0 and self.bindData.greatZone or self.bindData.perfectZone

					if template then
						local newZone = GameObject.Instantiate(template)
						zoneWidget = newZone:GetComponent(typeof(SGUI.UWidget))

						zoneWidget:TryInit()
						zoneWidget.rectTransform:SetParent(self.bindData.zoneRoot.rectTransform)
					end
				end

				if zoneWidget then
					zoneWidget.activation = true
					zoneWidget.rectTransform.anchorMin = Vector2.New(info.min, 0)
					zoneWidget.rectTransform.anchorMax = Vector2.New(info.max, 1)
					zoneWidget.rectTransform.anchoredPosition = Vector2.zero
					zoneWidget.rectTransform.sizeDelta = Vector2.zero
					zoneWidget.rectTransform.localScale = Vector3.New(1, 1, 1)
					local newZoneTable = info.type == 0 and newGreatZone or newPerfectZone

					table.insert(newZoneTable, zoneWidget)
				end
			end

			if #self.greatZone > 0 then
				for j = 1, #self.greatZone do
					local widget = self.greatZone[j]
					widget.activation = false

					table.insert(newGreatZone, widget)
				end
			end

			if #self.perfectZone > 0 then
				for j = 1, #self.perfectZone do
					local widget = self.perfectZone[j]
					widget.activation = false

					table.insert(newPerfectZone, widget)
				end
			end

			self.greatZone = newGreatZone
			self.perfectZone = newPerfectZone
		end
	end
end
