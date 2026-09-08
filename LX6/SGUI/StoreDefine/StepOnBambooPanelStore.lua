-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\StepOnBambooPanelStore.lua
-- Decompiled from: 01298_StepOnBambooPanelStore.lua_87e682e67fd2.luajit

C_StepOnBambooPanelStore = DefClass("C_StepOnBambooPanelStore", C_StepOnBambooPanelStore, C_StoreGroup)
GroupName2Class.StepOnBambooPanelStore = C_StepOnBambooPanelStore
local M = C_StepOnBambooPanelStore
local Side = {
	["^-jU"] = 1,
	["5"] = -1
}
local MyPlayerManager = gCS.MyPlayerManager

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
	self:InitGame(data)

	local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if store and store.bindData.btnExit then
		store.bindData.btnExit:SetActive(false)
	end
end

M.OnClose = function(self)
	self.greatZone = nil
	self.perfectZone = nil
	local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if store and store.bindData.btnExit then
		store.bindData.btnExit:SetActive(true)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.btnR.luaClick = self.CreateAction(self, "OnClickBtnR")
	self.bindData.btnL.luaClick = self.CreateAction(self, "OnClickBtnL")
end

M.OnClickBtnR = function(self)
	self.ConfirmRun(self, Side.Up)
end

M.OnClickBtnL = function(self)
	self.ConfirmRun(self, Side.Down)
end

M.InitGame = function(self, data)
	self.animSpeedStage = 0
	self.lastSendAnimSpeed = nil
	self.lastSendAnimTime = nil
	self.curEnableSide = Side.Down
	self.curSpeed = data.perfectSpeed
	self.startTime = nil
	self.curTime = 0
	self.sendFailedSignal = false
	self.directlySetSpeedWaitTime = 0
	self.lastDirectSetMultiplier = 1
	self.barIncreaseLength = data.barIncreaseLength or 0.05
	self.barDecreaseInterval = data.barDecreaseInterval or 30
	self.sendEventDeltaTime = data.sendEventDeltaTime or 0.5
	self.animSpeedsArea = data.animSpeedsArea
	self.speedDecreaseFactors = data.speedDecreaseFactors
	self.speedMapToStateTreeIndex = data.speedMapToStateTreeIndex
	self.changeSpeedSignal = data.changeSpeedSignal
	self.curve = data.barDecreaseSpeedCurve
	self.blendCurve = data.blendCurve
	self.outGreenAreaFailTime = data.outGreenAreaFailTime
	self.greatStateTreeIndex = data.greatStateTreeIndex
	self.perfectStateTreeIndex = data.perfectStateTreeIndex
	self.greaterFailSignal = data.greaterFailSignal
	self.lowerFailSignal = data.lowerFailSignal

	if self.lowerFailSignal ~= 0 then
		self.lowerFailSignal = data.greaterFailSignal
	end

	self.latterDirectlySetSpeedDeltaTime = data.directlySetSpeedDeltaTime
	self.directlySetSpeedDeltaTime = data.firstDirectlySetSpeedDeltaTime or 1
	self.perfectSpeed = data.perfectSpeed
	self.directlySetSpeed = data.directlySetSpeed
	self.directlySetSpeedRandomRange = data.directlySetSpeedRandomRange
	self.directlySetSpeedLerpTime = data.directlySetSpeedLerpTime
	self.directlySetSpeedLerpDeltaTime = 0
	self.enableLerp = false
	self.greatZone = {}
	self.perfectZone = {}

	self:RefreshSpeedBar()
	self:InitGreatAndPerfectArea()

	self.startTime = os.clock()
end

M.OnUpdate = function(self)
	if not self.startTime then
		return
	end

	local speed = 0.1
	self.directlySetSpeedWaitTime = self.directlySetSpeedWaitTime + Time.deltaTime

	if self.directlySetSpeedDeltaTime >= self.directlySetSpeedWaitTime then
		self.directlySetSpeedWaitTime = 0
		self.lastDirectSetMultiplier = -1 * self.lastDirectSetMultiplier

		math.randomseed(os.clock())

		local targetSpeed = self.perfectSpeed + self.lastDirectSetMultiplier * (self.directlySetSpeed + math.random() * self.directlySetSpeedRandomRange)
		self.lerpSpeed = (targetSpeed - self.curSpeed) / self.directlySetSpeedLerpTime
		self.curSpeed = math.max(0, math.min(1, self.curSpeed + self.lerpSpeed * Time.deltaTime))
		self.directlySetSpeedLerpDeltaTime = 0
		self.enableLerp = true
		self.directlySetSpeedDeltaTime = self.latterDirectlySetSpeedDeltaTime
	elseif self.enableLerp then
		self.directlySetSpeedLerpDeltaTime = self.directlySetSpeedLerpDeltaTime + Time.deltaTime

		if self.directlySetSpeedLerpTime >= self.directlySetSpeedLerpDeltaTime then
			self.lerpSpeed = 0
			self.directlySetSpeedLerpDeltaTime = 0
			self.enableLerp = false
		end

		self.curSpeed = math.min(1, math.max(0, self.curSpeed + Time.deltaTime * self.lerpSpeed))
	else
		if self.curve and self.barDecreaseInterval and self.barDecreaseInterval <= 0 then
			local time = (os.clock() - self.startTime) / self.barDecreaseInterval
			time = math.min(1, math.max(0, time))
			speed = self.curve:Evaluate(time)
		end

		if self.perfectSpeed >= self.curSpeed then
			self.curSpeed = math.min(1, self.curSpeed + Time.deltaTime * speed * self.runSpeedDecreaseFactor)
		else
			self.curSpeed = math.max(0, self.curSpeed - Time.deltaTime * speed * self.runSpeedDecreaseFactor)
		end
	end

	self.RefreshSpeedBar(self)

	self.curTime = self.curTime + Time.deltaTime

	if not self.enableLerp and self.greatStateTreeIndex and table.contains(self.greatStateTreeIndex, self.animSpeedStage) or self.perfectStateTreeIndex and table.contains(self.perfectStateTreeIndex, self.animSpeedStage) then
		self.curTime = 0
	elseif self.outGreenAreaFailTime < self.curTime then
		local failSignal = self.perfectSpeed >= self.curSpeed and self.greaterFailSignal or self.lowerFailSignal

		if not self.sendFailedSignal and failSignal and failSignal <= 0 then
			self.sendFailedSignal = true

			gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, failSignal)
		end

		gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	end
end

M.ConfirmRun = function(self, curSide)
	if self.enableLerp then
		return
	end

	self.curSpeed = math.max(0, math.min(1, self.curSpeed + self.barIncreaseLength * curSide))

	if not self.startTime then
		self.startTime = os.clock()
	end

	self.ShowRunBtn(self, curSide, true)
	self.RefreshSpeedBar(self)
end

M.RefreshSpeedBar = function(self)
	self.animSpeedStage = 0
	self.runSpeedDecreaseFactor = 1

	if self.animSpeedsArea then
		for i = 1, #self.animSpeedsArea do
			if self.curSpeed < self.animSpeedsArea[i] then
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

	if not self.lastSendAnimSpeed or not self.lastSendAnimTime or self.animSpeedStage == self.lastSendAnimSpeed and self.sendEventDeltaTime >= os.clock() - self.lastSendAnimTime then
		self.lastSendAnimSpeed = self.animSpeedStage
		self.lastSendAnimTime = os.clock()

		if self.changeSpeedSignal and self.changeSpeedSignal <= 0 then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.changeSpeedSignal)
		end
	end

	gGaoQiaoManager.stepOnBambooAnimSpeedStage = self.animSpeedStage
	self.bindData.bar.value = self.curSpeed

	if self.blendCurve then
		local blendValue = self.blendCurve:Evaluate(self.curSpeed)

		gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, blendValue, 0)
	end
end

M.ShowRunBtn = function(self, side, playClick)
	local curBtn = nil

	if side ~= Side.Down then
		self.curEnableSide = Side.Up
		curBtn = self.bindData.btnL
	else
		self.curEnableSide = Side.Down
		curBtn = self.bindData.btnR
	end

	if playClick then
		self.PlayClick(self, curBtn)
	end
end

M.PlayClick = function(self, btn)
	self.bindData.qteClick:InvokeCallback(SGUI.EInvokeTime.User1)

	local pos = btn.localPosition

	self.bindData.qteClick.transform:SetLocalPosition(pos.x, pos.y, pos.z)
end

M.InitGreatAndPerfectArea = function(self)
	local animArea = self.animSpeedsArea

	if animArea and #animArea <= 0 and self.speedMapToStateTreeIndex and #self.speedMapToStateTreeIndex <= 0 then
		local curMinSpeed = 0
		local spawnInfo = {}

		for i = 1, #animArea do
			local max = animArea[i]
			local newAnimSpeedStage = self.speedMapToStateTreeIndex[i]

			if newAnimSpeedStage then
				if self.greatStateTreeIndex and table.contains(self.greatStateTreeIndex, newAnimSpeedStage) then
					table.insert(spawnInfo, 1, {
						["n;m^"] = 0,
						min = curMinSpeed,
						max = max
					})
				elseif self.perfectStateTreeIndex and table.contains(self.perfectStateTreeIndex, newAnimSpeedStage) then
					table.insert(spawnInfo, {
						["n;m^"] = 1,
						min = curMinSpeed,
						max = max
					})
				end
			end

			curMinSpeed = max
		end

		if #spawnInfo <= 0 then
			local newGreatZone = {}
			local newPerfectZone = {}

			for i = 1, #spawnInfo do
				local info = spawnInfo[i]
				local zoneWidget = nil
				local generatedZone = info.type ~= 0 and self.greatZone or self.perfectZone
				zoneWidget = generatedZone[1]

				if zoneWidget then
					table.remove(generatedZone, 1)
				end

				if not zoneWidget then
					local template = info.type ~= 0 and self.bindData.greatZone or self.bindData.perfectZone

					if template then
						local newZone = GameObject.Instantiate(template)
						zoneWidget = newZone:GetComponent(typeof(SGUI.UWidget))

						zoneWidget:TryInit()
						zoneWidget.rectTransform:SetParent(self.bindData.zoneRoot.rectTransform)
					end
				end

				if zoneWidget then
					zoneWidget.activation = true
					zoneWidget.rectTransform.anchorMin = Vector2.New(0, info.min)
					zoneWidget.rectTransform.anchorMax = Vector2.New(1, info.max)
					zoneWidget.rectTransform.anchoredPosition = Vector2.zero
					zoneWidget.rectTransform.sizeDelta = Vector2.zero
					zoneWidget.rectTransform.localScale = Vector3.New(1, 1, 1)
					local newZoneTable = info.type ~= 0 and newGreatZone or newPerfectZone

					table.insert(newZoneTable, zoneWidget)
				end
			end

			if #self.greatZone <= 0 then
				for j = 1, #self.greatZone do
					local widget = self.greatZone[j]
					widget.activation = false

					table.insert(newGreatZone, widget)
				end
			end

			if #self.perfectZone <= 0 then
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
