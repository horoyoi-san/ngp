-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FishingGameMainPanelStore.lua
-- Decompiled from: 01858_FishingGameMainPanelStore.lua_e9a94d2ec2f8.luajit

C_FishingGameMainPanelStore = DefClass("C_FishingGameMainPanelStore", C_FishingGameMainPanelStore, C_StoreGroup)
GroupName2Class.FishingGameMainPanelStore = C_FishingGameMainPanelStore
local M = C_FishingGameMainPanelStore
local GameInputManager = LX6.Manager.GameInputManager
local QTE_KEYS = nil
local QTE_TIMEOUT = 2.5
local GAMEPAD_LEFT_STICK_ID = 102
local QTE_SWIPE_DIR = {
	[gFishingGameConst.FishingGameQteKey.W] = "top",
	[gFishingGameConst.FishingGameQteKey.A] = "left",
	[gFishingGameConst.FishingGameQteKey.S] = "bottom",
	[gFishingGameConst.FishingGameQteKey.D] = "right"
}

local GetQteIconId = function(info)
	local device = gCS.LuaUtils.GetActiveDevice()

	if SGUI.GameDevice.KeyboardMouse >= device then
		local gamepadCfg = LTConfig.InputSGUIGamepadConfig.GetConfig(GAMEPAD_LEFT_STICK_ID)

		if gamepadCfg then
			local iconList = nil

			if device ~= SGUI.GameDevice.PlayStation then
				iconList = gamepadCfg.PSButtonIcon
			else
				iconList = gamepadCfg.XBoxButtonIcon
			end

			if iconList and #iconList <= 0 then
				return iconList[1]
			end
		end
	end

	if info.pcKeyCfg and #info.pcKeyCfg.ButtonIcon <= 0 then
		return info.pcKeyCfg.ButtonIcon[1]
	end

	return nil
end

local GetQteKeys = function()
	if not QTE_KEYS then
		local pcKeyIds = {
			11,
			12,
			13,
			14
		}
		local qteKeyEnums = {
			gFishingGameConst.FishingGameQteKey.W,
			gFishingGameConst.FishingGameQteKey.A,
			gFishingGameConst.FishingGameQteKey.S,
			gFishingGameConst.FishingGameQteKey.D
		}
		QTE_KEYS = {}

		for i, pcKeyId in ipairs(pcKeyIds) do
			local pcKeyCfg = LTConfig.InputSGUIPCKeyConfig.GetConfig(pcKeyId)

			if pcKeyCfg then
				table.insert(QTE_KEYS, {
					qteKey = qteKeyEnums[i],
					pcKeyId = pcKeyCfg.Id,
					label = pcKeyCfg.ButtonName,
					pcKeyCfg = pcKeyCfg
				})
			end
		end
	end

	return QTE_KEYS
end

M.GetBtnStore = function(self, widget)
	if not widget then
		return nil
	end

	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end

M.OnAwake = function(self)
	self.system = C_FishingGameSystem.new()
end

M.OnStart = function(self)
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	self.BindAction(self)
	self.InitAnimation(self)
end

M.OnShow = function(self, panelId, data)
	self.showData = data
end

M.NotifyLoaded = function(self)
	if self.showData ~= nil then
		return
	end

	if not self.system then
		self.system = C_FishingGameSystem.new()
	end

	local data = self.showData
	self.showData = nil
	self.isQuestMode = data and data.isQuestMode or false
	self.entityInstanceId = data and data.entityInstanceId or 0
	self.spotId = data and data.spotId or 0
	self.maxFailCount = data and data.maxFailCount or 0

	if self.bindData.SwipePanel then
		self.bindData.SwipePanel.gameObject:SetActive(false)
	end

	slot2 = gPanelManager

	slot2:Close(gPanelId.TIMELINE_SWIPE_PANEL)

	slot2 = self.system.character

	slot2:Init()

	slot2 = self.system.character

	slot2:LoadModel(function ()
		slot0 = self

		slot0:SetData()

		self.startCoroutine = coroutine.start(function ()
			coroutine.wait(0.5)

			if self.system.cmRegister:GetVcamByName("VCamera_Start") then
				self.system.cmRegister:EnableVCamera("VCamera_Start", 11)
			end

			coroutine.wait(0.33)
			self.system:SetVCamera(gFishingGameConst.FishingGameVCamera.FollowCharacter)
			coroutine.wait(0.7)
			self:StartFishing()
		end)
	end)
end

M.OnUpdate = function(self)
	if not self.system then
		return
	end

	self.CheckLineBar(self)
	self.SetHpBar(self)
	self.SetDurability(self)
	self.UpdateQteTimer(self)
	self.UpdateButtonVisibility(self)
end

M.OnActiveDeviceChange = function(self, device)
	if not self.qteRunning or not self.currentQteInfo then
		return
	end

	local store = self.GetBtnStore(self, self.bindData.ClickBtn)

	if not store then
		return
	end

	local iconId = GetQteIconId(self.currentQteInfo)

	if iconId then
		store.pcKeyMode = 2
		store.btnIcon = iconId
	else
		store.pcKeyMode = 3
		store.btnText = self.currentQteInfo.label
	end
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)

	self.startCoroutine = coroutine.stop(self.startCoroutine)
	self.qteStatusCoroutine = coroutine.stop(self.qteStatusCoroutine)

	self.HideQte(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	if self.moveAction then
		GameInputManager.UnregisterInputCallback(gInputActionId.MOVEMENT_MOVE, self.moveAction)

		self.moveAction = nil
	end

	if self.bindData.Joystick then
		self.bindData.Joystick.luaValueChanged = nil
	end

	if self.isMobile and self.onSwipeQte then
		gMessageManager:RemoveMessageListener(gEventConstants.TIMELINE_QTE_TRIGGER, self.onSwipeQte)

		self.onSwipeQte = nil
	end

	if self.system then
		self.system:Destroy()

		self.system = nil
	end
end

M.BindAction = function(self)
	self.bindData.ThrowButton.luaClick = self.CreateAction(self, self.StartFishing)
	self.bindData.BackButton.luaClick = self.CreateAction(self, self.OnMouse1Up)
	self.bindData.LineButton.luaPress = self.CreateAction(self, self.OnDownSpace)
	self.bindData.LineButton.luaRelease = self.CreateAction(self, self.OnUpSpace)

	if self.isMobile then
		if self.bindData.Joystick then
			self.bindData.Joystick.luaValueChanged = self.CreateAction(self, self.OnJoystickValueChange)
		end
	else
		self.moveAction = self.CreateAction(self, self.OnWASDChange)

		GameInputManager.RegisterInputCallback(gInputActionId.MOVEMENT_MOVE, self.moveAction)
	end

	self.bindData.BackBtnWhite.luaLongPress = self.CreateAction(self, self.ExitFishing)

	if self.isMobile then
		self.bindData.BackBtnWhite.luaClick = self.CreateAction(self, self.ExitFishing)
	end

	self.onSetFish = self:CreateAction(self.SetFish, self)

	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_FISHING_GAME_MAIN_SETFISH, self.onSetFish)

	if self.isMobile then
		self.onSwipeQte = self:CreateAction(self.OnSwipeQteTrigger)

		gMessageManager:AddMessageListener(gEventConstants.TIMELINE_QTE_TRIGGER, self.onSwipeQte)
	end
end

M.InitAnimation = function(self)
	self.lineScaleTF = self.bindData.lineScale.transform

	self.bindData.ButtonLeft:SetPCKeyInfoWithOutTip(12)
	self.bindData.ButtonRight:SetPCKeyInfoWithOutTip(14)
end

M.SetData = function(self)
	local clearFishing = self:CreateAction(self.ClearFishing, self)
	local setKeyboard = self:CreateAction(self.SetKeyboard, self)
	local setQte = self:CreateAction(self.SetQte, self)
	local hideLineBar = self:CreateAction(self.HideLineBar, self)
	local setGuide = self:CreateAction(self.SetGuide, self)
	local lineDisconnect = self:CreateAction(self.LineDisconnect, self)
	local setInteractable = self:CreateAction(self.SetInteractable, self)

	self.system:SetData(clearFishing, setKeyboard, setQte, hideLineBar, setGuide, lineDisconnect, setInteractable, self.isQuestMode, self.entityInstanceId, self.spotId, self.maxFailCount)
	self:SetKeyboard(false, false, false, false, false)
	self:UpdateButtonVisibility()
	self.bindData.HpSlider.gameObject:SetActive(false)
	self:HideQte()
	self:HideLineBar()
	self:SetGuide(gFishingGameConst.FishingGameGuideType.None)

	self.bindData.FishingLineBarText.text = FishingGameConfig.GetLanguageContent(200304)
	self.bindData.DurabilityTitle.text = FishingGameConfig.GetLanguageContent(200101)
	self.bindData.DurabilityLine.text = FishingGameConfig.GetLanguageContent(200301)
end

M.SetFish = function(self)
	if self.system.fish ~= nil then
		return
	end

	self.bindData.HpSlider.gameObject:SetActive(true)
end

M.SetHpBar = function(self)
	if self.system.fish ~= nil then
		return
	end

	local fishData = self.system.fish.data

	if fishData.maxHp < 0 then
		return
	end

	self.bindData.HpSlider.value = fishData.hp / fishData.maxHp
end

M.SetDurability = function(self)
	if self.system.maxDurability < 0 then
		return
	end

	self.bindData.DurabilityNum.text = string.format("%d/%d", math.ceil(self.system.durability), self.system.maxDurability)
	self.bindData.DurabilitySlider.value = self.system.durability / self.system.maxDurability
end

M.ShowQte = function(self, qteKey)
	local info = nil

	for _, v in ipairs(GetQteKeys()) do
		if v.qteKey ~= qteKey then
			info = v

			break
		end
	end

	if not info then
		return
	end

	self.qteTimer = QTE_TIMEOUT
	self.qteRunning = true
	self.currentQteInfo = info

	if self.isMobile then
		local direction = QTE_SWIPE_DIR[qteKey] or "top"
		local swipeData = {
			["\\x8a\\xb5\\xbb~7\\xe86"] = 2,
			["d\\xa3p^\\xb7\\xe1T^cnI"] = 1,
			direction = direction,
			duration = QTE_TIMEOUT,
			ToTable = function (self)
				return self
			end
		}

		if self.bindData.SwipePanel then
			self.bindData.SwipePanel.gameObject:SetActive(false)
		end

		gPanelManager:CheckShow(gPanelId.TIMELINE_SWIPE_PANEL, swipeData)
	else
		local store = self.GetBtnStore(self, self.bindData.ClickBtn)

		if not store then
			return
		end

		store.clickBtn:SetPCKeyInfoWithOutTip(info.pcKeyId)

		store.pcKeyMode = 2
		local iconId = GetQteIconId(info)

		if iconId then
			store.btnIcon = iconId
		else
			store.pcKeyMode = 3
			store.btnText = info.label
		end

		store.progressType = 1

		if store.outCircleRT then
			store.outCircleRT.localScale = Vector3.New(1, 1, 1)
		end

		self.bindData.ClickBtn.gameObject:SetActive(true)

		local arrowCtrlMap = {
			[gFishingGameConst.FishingGameQteKey.W] = 0,
			[gFishingGameConst.FishingGameQteKey.A] = 1,
			[gFishingGameConst.FishingGameQteKey.S] = 2,
			[gFishingGameConst.FishingGameQteKey.D] = 3
		}
		self.bindData.ArrowCtrl = arrowCtrlMap[qteKey] or 0

		self.bindData.Arrow.gameObject:SetActive(true)
	end
end

M.UpdateQteTimer = function(self)
	if not self.qteRunning then
		return
	end

	self.qteTimer = self.qteTimer - gLogicTime.deltaTime

	if not self.isMobile then
		local progress = 1 - Mathf.Clamp01(self.qteTimer / QTE_TIMEOUT)
		local store = self.GetBtnStore(self, self.bindData.ClickBtn)

		if store and store.outCircleRT then
			local innerW = store.innerCircleRT.rect.width
			local outerW = store.outCircleRT.rect.width
			store.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerW / outerW, innerW / outerW, 1), progress)
		end
	end

	if self.qteTimer < 0 then
		self.qteRunning = false
		self.currentQteInfo = nil

		self.OnQteFail(self)

		return
	end
end

M.OnQteSuccess = function(self)
	if not self.qteRunning then
		return
	end

	self.qteRunning = false
	self.currentQteInfo = nil
end

M.HideQte = function(self)
	self.qteRunning = false
	self.currentQteInfo = nil

	self.bindData.ClickBtn.gameObject:SetActive(false)

	if self.bindData.Arrow then
		self.bindData.Arrow.gameObject:SetActive(false)
	end

	if self.bindData.SwipePanel then
		self.bindData.SwipePanel.gameObject:SetActive(false)
	end

	gPanelManager:Close(gPanelId.TIMELINE_SWIPE_PANEL)
end

M.SetQte = function(self, type)
	if type ~= gFishingGameConst.FishingGameQte.Show then
		self.SetKeyboard(self, false, false, false, false, false)
		self.ShowQte(self, self.system.needQte)
	elseif type ~= gFishingGameConst.FishingGameQte.Success then
		self.HideQte(self)
		self.ShowQteResult(self, true)
	elseif type ~= gFishingGameConst.FishingGameQte.Fail then
		self.HideQte(self)
		self.ShowQteResult(self, false)
	else
		self.HideQte(self)
	end
end

M.ShowQteResult = function(self, isSuccess)
	local guide = self.bindData.TrainingGuide

	if not guide then
		return
	end

	guide.gameObject:SetActive(true)

	if self.bindData.GuideText then
		self.bindData.GuideText.text = FishingGameConfig.GetLanguageContent(isSuccess and 200302 or 200303)
	end

	self.qteStatusCoroutine = coroutine.stop(self.qteStatusCoroutine)
	self.qteStatusCoroutine = coroutine.start(function ()
		coroutine.wait(1.5)
		guide.gameObject:SetActive(false)
	end)
end

M.ShowLineBar = function(self)
	self.bindData.Line.gameObject:SetActive(true)
	self.bindData.LayoutBox.gameObject:SetActive(true)

	self.bindData.LayoutBox.renderOpacity = 1
	self.bindData.LineCtrl = 0
	self.lastLineLevel = 0

	if self.bindData.FishingLineBarText then
		self.bindData.FishingLineBarText.color = UnityEngine.Color.white
	end

	local icon = self.bindData.LayoutBox.transform:Find("Icon")

	if icon then
		local img = icon.GetComponent(icon, "UImage")

		if img then
			img.color = UnityEngine.Color.white
		end
	end
end

M.HideLineBar = function(self)
	self.lineBarReadyTime = nil

	self.bindData.Line.gameObject:SetActive(false)
	self.bindData.HpSlider.gameObject:SetActive(false)
end

M.CheckLineBar = function(self)
	if self.system.fishingStep == gFishingGameConst.FishingGameStep.SlipFish then
		return
	end

	if not self.lineBarReadyTime then
		self.lineBarReadyTime = Time.time + 1.5
	end

	if Time.time >= self.lineBarReadyTime then
		return
	end

	if self.lineBarReadyTime <= 0 then
		self.lineBarReadyTime = 0

		self.ShowLineBar(self)
	end

	local num = self.system.lineLoad / self.system.maxLineLoad
	local level, speed, width = nil

	if num < 0.2 then
		level = 1
		speed = 0
		width = 400
	elseif num < 0.4 then
		level = 1
		speed = 0.6
		width = 400
	elseif num < 0.6 then
		level = 2
		speed = 1.2
		width = 800
	elseif num < 0.8 then
		level = 3
		speed = 2
		width = 1100
	else
		level = 4
		speed = 3
		width = 1400
	end

	self.bindData.Line.gameObject:SetActive(true)

	local scaleX = width / 1400
	self.lineScaleTF.localScale = Vector3.New(scaleX, 1, 1)

	if level == self.lastLineLevel then
		if level ~= 1 then
			self.bindData.LineCtrl = 0
		else
			self.bindData.LineCtrl = 1
		end

		self.lastLineLevel = level
	end
end

M.LineDisconnect = function(self)
	self:SetKeyboard(false, false, false, false, false, false)
	self.bindData.HpSlider.gameObject:SetActive(false)

	self.bindData.LineCtrl = 2
end

M.SetKeyboard = function(self, isW, isA, isS, isD, isSpace, isAni)
	self.bindData.ButtonLeft.gameObject:SetActive(isA)
	self.bindData.ButtonRight.gameObject:SetActive(isD)

	if self.isMobile then
		if isA and self.bindData.ButtonLeft.SetPCKeyInfoWithOutTip then
			self.bindData.ButtonLeft:SetPCKeyInfoWithOutTip(0)
		end

		if isD and self.bindData.ButtonRight.SetPCKeyInfoWithOutTip then
			self.bindData.ButtonRight:SetPCKeyInfoWithOutTip(0)
		end
	end
end

M.StartFishing = function(self)
	local fishingStep = self.system.fishingStep

	if fishingStep ~= gFishingGameConst.FishingGameStep.None then
		gPanelManager:Close(gPanelId.MINI_GAMES_FISHING_RESULT_PANEL)
		self:SetGuide(gFishingGameConst.FishingGameGuideType.None)
		self.system:SelectFloatPos()
	elseif fishingStep ~= gFishingGameConst.FishingGameStep.SelectFloat then
		self:SetKeyboard(false, false, false, false, false)

		slot2 = self.system

		slot2:CastFloat(function ()
		end)
	end
end

M.ClearFishing = function(self)
	self.system:Clear()
	self:SetKeyboard(false, false, false, false, false)
	self.bindData.HpSlider.gameObject:SetActive(false)
	self:HideLineBar()
	self:HideQte()

	self.fishingStep = gFishingGameConst.FishingGameStep.None

	self:SetGuide(gFishingGameConst.FishingGameGuideType.None)
	self:StartFishing()
end

M.SetInteractable = function(self, enabled)
	if self.rootWidget then
		self.rootWidget.gameObject:SetActive(enabled)
	end

	if not enabled then
		self.bindData.HpSlider.gameObject:SetActive(false)
	end
end

M.SetGuide = function(self, type)
	local guide = self.bindData.TrainingGuide

	if not guide then
		return
	end

	if type ~= gFishingGameConst.FishingGameGuideType.None then
		guide.gameObject:SetActive(false)
	else
		guide.gameObject:SetActive(true)

		local textMap = {
			[gFishingGameConst.FishingGameGuideType.FloatPos] = FishingGameConfig.GetLanguageContent(200302),
			[gFishingGameConst.FishingGameGuideType.AttractFish] = FishingGameConfig.GetLanguageContent(200303),
			[gFishingGameConst.FishingGameGuideType.SlipFish] = FishingGameConfig.GetLanguageContent(200302)
		}

		if self.bindData.GuideText then
			self.bindData.GuideText.text = textMap[type] or ""
		end
	end
end

M.ExitFishing = function(self)
	if not self.system then
		return
	end

	if not self.system:CanExit() then
		return
	end

	self.system:Destroy()

	self.system = nil

	gFishingGameManager:DestroyGame()
	gPanelManager:Close(gPanelId.MINI_GAMES_FISHING_GAME_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_FISHING_RESULT_PANEL)
end

M.OnMouse1Up = function(self)
	if not self.system then
		return
	end

	local fishingStep = self.system.fishingStep

	if fishingStep ~= gFishingGameConst.FishingGameStep.AttractFish or fishingStep ~= gFishingGameConst.FishingGameStep.FishBite then
		self.ClearFishing(self)
	end
end

M.OnDownSpace = function(self)
	local fishingStep = self.system.fishingStep

	if fishingStep ~= gFishingGameConst.FishingGameStep.AttractFish or fishingStep ~= gFishingGameConst.FishingGameStep.FishBite then
		self.system:AttractFishReelin(true)
	elseif fishingStep ~= gFishingGameConst.FishingGameStep.SlipFish then
		self.system:SlipFishReelin(true)
	end
end

M.OnUpSpace = function(self)
	local fishingStep = self.system.fishingStep

	if fishingStep ~= gFishingGameConst.FishingGameStep.AttractFish or fishingStep ~= gFishingGameConst.FishingGameStep.FishBite then
		self.system:AttractFishReelin(false)
	elseif fishingStep ~= gFishingGameConst.FishingGameStep.SlipFish then
		self.system:SlipFishReelin(false)
	end
end

M.OnDownA = function(self)
	local fishingStep = self.system.fishingStep

	if fishingStep ~= gFishingGameConst.FishingGameStep.PullFish or fishingStep ~= gFishingGameConst.FishingGameStep.Finish or fishingStep ~= gFishingGameConst.FishingGameStep.Fail then
		return
	end

	self.system:SetKey(gFishingGameConst.FishingGameQteKey.A, true)
end

M.OnUpA = function(self)
	self.system:SetKey(gFishingGameConst.FishingGameQteKey.A, false)
end

M.OnDownD = function(self)
	local fishingStep = self.system.fishingStep

	if fishingStep ~= gFishingGameConst.FishingGameStep.PullFish or fishingStep ~= gFishingGameConst.FishingGameStep.Finish or fishingStep ~= gFishingGameConst.FishingGameStep.Fail then
		return
	end

	self.system:SetKey(gFishingGameConst.FishingGameQteKey.D, true)
end

M.OnUpD = function(self)
	self.system:SetKey(gFishingGameConst.FishingGameQteKey.D, false)
end

M.OnWASDChange = function(self, context)
	if context.performed or context.started then
		local v = context:ReadValueVector2()

		self.system:SetKey(gFishingGameConst.FishingGameQteKey.W, v.y >= 0.5)
		self.system:SetKey(gFishingGameConst.FishingGameQteKey.S, v.y <= -0.5)
		self.system:SetKey(gFishingGameConst.FishingGameQteKey.A, v.x <= -0.5)
		self.system:SetKey(gFishingGameConst.FishingGameQteKey.D, v.x >= 0.5)
	elseif context.canceled then
		self.system:SetKey(gFishingGameConst.FishingGameQteKey.W, false)
		self.system:SetKey(gFishingGameConst.FishingGameQteKey.S, false)
		self.system:SetKey(gFishingGameConst.FishingGameQteKey.A, false)
		self.system:SetKey(gFishingGameConst.FishingGameQteKey.D, false)
	end
end

M.OnJoystickValueChange = function(self, x, y, size)
	if not self.system then
		return
	end

	self.system:SetKey(gFishingGameConst.FishingGameQteKey.A, x <= -0.5)
	self.system:SetKey(gFishingGameConst.FishingGameQteKey.D, x >= 0.5)
	self.system:SetKey(gFishingGameConst.FishingGameQteKey.W, y >= 0.5)
	self.system:SetKey(gFishingGameConst.FishingGameQteKey.S, y <= -0.5)
end

M.UpdateButtonVisibility = function(self)
	local step = self.system.fishingStep
	local G = gFishingGameConst.FishingGameStep

	self.bindData.ThrowButton.gameObject:SetActive(step ~= G.SelectFloat)
	self.bindData.MoveRespond.gameObject:SetActive(step ~= G.SelectFloat)

	if self.bindData.MoveButton2 then
		self.bindData.MoveButton2.gameObject:SetActive(step ~= G.AttractFish)
	end

	self.bindData.BackButton.gameObject:SetActive(step ~= G.AttractFish or step ~= G.FishBite or step ~= G.BiteQte)
	self.bindData.LineButton.gameObject:SetActive(step ~= G.AttractFish or step ~= G.FishBite or step ~= G.SlipFish)

	if self.bindData.BackBtnWhite then
		local showExit = step ~= G.SelectFloat

		if self.isQuestMode then
			showExit = showExit and self.system.maxFailCount > self.system.failCount
		end

		self.bindData.BackBtnWhite.gameObject:SetActive(showExit)
	end
end

M.OnSwipeQteTrigger = function(self, value)
	if not self.qteRunning or not self.currentQteInfo then
		return
	end

	self.system.wasdMap[self.currentQteInfo.qteKey] = Time.time
end
