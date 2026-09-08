-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerFingerprintPanelStore.lua
-- Decompiled from: 01687_HackerFingerprintPanelStore.lua_6c4348a301a6.luajit

local ComputerConfig = LTConfig.ComputerConfig
local ComputerAppConfig = LTConfig.ComputerAppConfig
local PoiGameConfig = LTConfig.PoiGameConfig
local PoiGameHackMinigameConfig = LTConfig.PoiGameHackMinigameConfig
local UCursorInput = SGUI.UCursorInput
local StateType = {
	["/M\\x85\\x9a\\x8fD"] = 6,
	["\\xf6\\xdd*\\xf4"] = 3,
	["\\#tW"] = 4,
	["\\xeb\\xce*\\xf6"] = 2,
	["\\xab\\xa3\\xab\\xaf"] = 1,
	["\\xea\\xce7\\xe2"] = 5
}
local TransitionType = {
	["\\s\\xb8c@\\xb7\\xcduo{zU"] = 11,
	["0\\xe6^(\\xef.\\xa3O\\xaf_\\xbe\\xb1"] = 1,
	["Տ\\xe2\\xe1$ٍ\\xf9\\x96,-"] = 10,
	["]c\\xa2yE\\xbc\\xf5xL{w@"] = 4,
	["Iw\\xa5{s\\x80\\xe7IdspK"] = 6,
	["\\xb95)3G\\xaeD\\xcd#\\xa6\\xbc"] = 7,
	["?.\\xeaz\\x96\\xf0\\x87)\\xe0\\xfe\\xefz\\xfe"] = 2,
	["-\\xe5Y \\xde\\x89s\\xa4W\\xb4\\xaf"] = 3,
	["ԏ\\xef\\xf5$ٍ\\xf9\\x96,-"] = 9,
	["?.\\xeaz\\x96\\xf0\\x9b:\\xe5\\xf1\\xe3g\\xe8"] = 5,
	["?#\\xe7v\\x8b\\xe4\\x9a:\\xe8\\xfc\\xefz\\xfc"] = 8
}
local FINGER_MAX_INDEX = 4
local DEFAULT_LEVEL_NUM = 1
local DEFAULT_LIFE = 5
local DEFAULT_GAME_TIME = 300
local DEFAULT_HACK_SKILL_CD = 0
local DEFAULT_MISSING_COUNT_PARTS_COUNT = 3
local DEFAULT_DUPLICATE_PARTS_COUNT = 1
local fingerprintPrefix = "S_img_fgp0"
local texturePath = "Assets/Res/SGUIWorld/Texture/HackerArcadeFingerPrint/"
C_HackerFingerprintPanelStore = DefClass("C_HackerFingerprintPanelStore", C_HackerFingerprintPanelStore, C_StoreGroup)
GroupName2Class.HackerFingerprintPanelStore = C_HackerFingerprintPanelStore
local M = C_HackerFingerprintPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.entityId = 0
	self.gameFSM = nil
	self.levelNum = DEFAULT_LEVEL_NUM
	self.gameTime = DEFAULT_GAME_TIME
	self.hackSkillCD = DEFAULT_HACK_SKILL_CD
	self.nowLevel = 0
	self.nowLife = 0
	self.maxLife = DEFAULT_LIFE
	self.missingPartsCount = DEFAULT_MISSING_COUNT_PARTS_COUNT
	self.duplicatePartsCount = DEFAULT_DUPLICATE_PARTS_COUNT
	self.answerIndex = 1
	self.answerLackGroup = nil
	self.answerListData = {}
	self.showListData = {}
	self.draggingItem = nil
	self.showListBtn = {}
	self.isSettleSuccess = false
	self.isAnimBlocking = false
	self.isCountDownPlaying = false
	self.hackSkillTimer = nil
	self.settleCloseTimer = nil
	self.isInSkill = false
	self.closeWithComputer = false
	self.closeWithAppOpen = nil
	self.canExitDirectly = false
	self.isDestroy = false
	self.bgStore = nil
	self.overStore = nil
	self.guideId = 0
	self.isInGuide = false
	self.skillHackId = 0
	self.levelsList = {}
	self.canRestart = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.successCtrlEnum = {
		["\\xea\\xce7\\xe2"] = 1,
		[":I\\x98\\x82\\x86E"] = 2,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.canSkillCtrlEnum = {
		["I\\x9f\\x80\\x8cU"] = 1,
		["\\x8dih"] = 0
	}
	self.isDraggingCtrlEnum = {
		["\\x97mu"] = 1,
		[""] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.successCtrlEnum = nil
	self.canSkillCtrlEnum = nil
	self.isDraggingCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.InitFSM(self)
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

M.ShowPanel = function(self, computerId, entityId)
	self.entityId = entityId
	local skillText = nil

	if computerId then
		local computerConfig = ComputerConfig.GetConfig(computerId)
		local gameAppCfg = computerConfig.AppToHackGame
		local gameConfigId = nil

		if table.isNilOrEmpty(gameAppCfg) then
			gameConfigId = computerConfig.HackGame
		else
			for i = 1, #gameAppCfg do
				if gameAppCfg[i].appId ~= ComputerAppConfig.hacker4 then
					gameConfigId = gameAppCfg[i].hackgameId

					break
				end
			end
		end

		local gameConfig = PoiGameHackMinigameConfig.GetConfig(gameConfigId)

		if gameConfig then
			self.levelNum = gameConfig.PlayCount
			self.gameTime = gameConfig.Time
			self.maxLife = gameConfig.Hp
			self.hackSkillCD = DEFAULT_HACK_SKILL_CD
			skillText = PoiGameConfig.FingerprintCrack_SkillText
			self.missingPartsCount = gameConfig.MissingPartsCount
			self.duplicatePartsCount = gameConfig.DuplicatePartsCount
			self.canRestart = gameConfig.CanRestart
		end

		self.closeWithComputer = computerConfig.HackGameExit
		self.closeWithAppOpen = computerConfig.HackOpenApp
		self.canExitDirectly = computerConfig.HackGameCanESC
		self.guideId = computerConfig.GuideId
		self.skillHackId = PoiGameConfig.FingerprintCrack_SkillCost
	end

	if not self.canExitDirectly then
		gMessageManager:SendMessage(gEventConstants.COMPUTER_ALLOW_EXIT, false)
	else
		gMessageManager:SendMessage(gEventConstants.COMPUTER_ALLOW_EXIT, true)
	end

	StartCoroutine(function ()
		WaitForEndOfFrame()
		self.gameFSM:SetInitState(StateType.Ready)

		self.skillStore = gStoreManager:GetStoreGroup("HackerArcadeSkillStore")

		if self.skillStore then
			self.skillStore:RegisterSkill(skillText, self:CreateAction("OnClickHackSkillBtn"), 0, self.skillHackId)
		end

		local bgGroup = gStoreManager:GetStoreGroup("HackerArcadeBgTemplate")

		for _, store in pairs(bgGroup.storeDic) do
			self.bgStore = store
		end

		local overGroup = gStoreManager:GetStoreGroup("HackerArcadeOverTemplate")

		for _, store in pairs(overGroup.storeDic) do
			self.overStore = store
		end

		if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.outerNavi
		end
	end)
end

M.OnClose = function(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.HACKER_GAME_FINISH_GUIDE] = function ()
			if not self.isInGuide then
				return
			end

			self.isInGuide = false

			self.gameFSM:SendSignal(TransitionType.Ready_Running)
		end,
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = function ()
			if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.outerNavi
			end

			self.bindData.isDraggingCtrl = 0
			self.draggingItem = nil
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.returnNaviBtn.luaClick = function()
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.outerNavi
		self.draggingItem = nil
		self.bindData.isDraggingCtrl = 0
	end

	self.bindData.showList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderShowListItem")
	self.bindData.resultList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderResultListItem")
	self.bindData.levelList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderLevelListItem")
	self.bindData.countDown.luaFinished = self.CreateAction(self, "OnCountDownFinish")
end

M.OnSimpleRenderShowListItem = function(self, btn, index)
	local data = self.showListData[index + 1]
	local identifier = data.fingerprintId * 10 + data.positionId
	self.showListBtn[identifier] = btn
	local id = btn.gameObject:GetInstanceID()

	if data.isFinished then
		btn.interactable = false
	else
		btn.interactable = true
	end

	local store = gStoreManager:GetStoreGroup("HackerFingerprintTemplate"):GetStoreById(id)

	if store then
		store.showPicUrl = data.url
		store.dropWidget.luaEndDrag = self.CreateActionWithArgs(self, "OnDrop", btn)
		store.dropWidget.luaBeginDrag = self.CreateActionWithArgs(self, "OnBeginDrag", {
			index,
			store.dropWidget
		})
		store.dropWidget.luaEnterDropWidget = self.CreateActionWithArgs(self, "OnDragEnter", store.dropWidget)
		store.dropWidget.luaExitDropWidget = self.CreateActionWithArgs(self, "OnDragExit", store.dropWidget)
		btn.luaClick = self.CreateActionWithArgs(self, "OnShowBtnClick", {
			index,
			store.dropWidget
		})
	end
end

M.OnSimpleRenderResultListItem = function(self, btn, index)
	local data = self.answerListData[index + 1]
	local id = btn.gameObject:GetInstanceID()
	btn.luaClick = self:CreateActionWithArgs("OnResultBtnClick", index)
	local store = gStoreManager:GetStoreGroup("HackerFingerprintLargeTemplate"):GetStoreById(id)

	if store then
		store.showPicUrl = data.url

		if data.isLack then
			if data.isFinished then
				store.colorCtrl = 1
				btn.interactable = false
			else
				store.colorCtrl = 2
				btn.interactable = true
			end
		else
			store.colorCtrl = 0
			btn.interactable = false
		end

		data.insId = id

		if gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse then
			return
		end

		if self.draggingItem then
			store.hintPicUrl = self.draggingItem.url
		end
	end
end

M.OnRenderLevelListItem = function(self, btn, index)
	local data = self.levelsList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("FingerprintLevelTemplate"):GetStoreById(id)

	if store then
		store.stageCtrl = data.isFinish and 1 or 0
	end
end

M.OnCountDownFinish = function(self)
	self.isSettleSuccess = false

	self.gameFSM:SendSignal(TransitionType.Running_Settle)
end

M.OnBeginDrag = function(self, data)
	self.bindData.isDraggingCtrl = 1

	UCursorInput.BlockCursorSubmitAction(true)

	local index = data[1]
	local dragWidget = data[2]
	self.draggingItem = self.showListData[index + 1]

	dragWidget.transform:SetLocalScale(2)
end

M.OnDrop = function(self, btn, widget)
	UCursorInput.BlockCursorSubmitAction(false)
	btn.transform:SetLocalScale(1)

	self.bindData.isDraggingCtrl = 0

	if widget ~= nil then
		self.draggingItem = nil

		return
	end

	local dropInsId = widget.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("HackerFingerprintLargeTemplate"):GetStoreById(dropInsId)

	if store then
		store.hoverCtrl = 0
	end

	for _, data in ipairs(self.answerListData) do
		if data.insId ~= dropInsId and data.isLack then
			if data.fingerprintId ~= self.draggingItem.fingerprintId and data.positionId ~= self.draggingItem.positionId then
				data.isFinished = true
				self.draggingItem.isFinished = true

				self.bindData.resultList:RefreshList()
				self.bindData.showList:RefreshList()
				self:CheckFinished()
				gSoundMgr:PlaySoundByTid(70601385)

				break
			else
				gSoundMgr:PlaySoundByTid(70601386)
				self.gameFSM:SendSignal(TransitionType.Running_Fail)
			end
		end
	end

	self.draggingItem = nil
end

M.OnShowBtnClick = function(self, data)
	if gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse then
		return
	end

	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.innerNavi
	self.bindData.isDraggingCtrl = 1
	local index = data[1]
	self.draggingItem = self.showListData[index + 1]

	self.bindData.resultList:RefreshList()
end

M.OnResultBtnClick = function(self, index)
	if gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse then
		return
	end

	local data = self.answerListData[index + 1]

	if data.isLack then
		if data.fingerprintId ~= self.draggingItem.fingerprintId and data.positionId ~= self.draggingItem.positionId then
			data.isFinished = true
			self.draggingItem.isFinished = true

			self.bindData.resultList:RefreshList()
			self.bindData.showList:RefreshList()

			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.outerNavi

			self:CheckFinished()
			gSoundMgr:PlaySoundByTid(70601385)
		else
			gSoundMgr:PlaySoundByTid(70601386)
			self.gameFSM:SendSignal(TransitionType.Running_Fail)
		end
	end
end

M.OnDragEnter = function(self, dragWidget, widget)
	UCursorInput.BlockCursorSubmitAction(false)

	local id = widget.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("HackerFingerprintLargeTemplate"):GetStoreById(id)

	if store then
		if store.colorCtrl ~= 0 then
			return
		end

		store.hoverCtrl = 1
	end
end

M.OnDragExit = function(self, dragWidget, widget)
	UCursorInput.BlockCursorSubmitAction(true)

	local id = widget.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("HackerFingerprintLargeTemplate"):GetStoreById(id)

	if store then
		store.hoverCtrl = 0
	end
end

M.CheckFinished = function(self)
	local isAllFinished = true

	for _, data in ipairs(self.answerListData) do
		if data.isLack and not data.isFinished then
			isAllFinished = false

			break
		end
	end

	if isAllFinished then
		self.gameFSM:SendSignal(TransitionType.Running_Success)
	end
end

M.OnClickHackSkillBtn = function(self)
	if self.gameFSM:GetCurrentState() == StateType.Running then
		return
	end

	for i = 1, #self.showListData do
		if self.showListData[i].isLack and not self.showListData[i].isFinished then
			for _, data in ipairs(self.answerListData) do
				if data.isLack and data.fingerprintId ~= self.showListData[i].fingerprintId and data.positionId ~= self.showListData[i].positionId then
					data.isFinished = true
					self.showListData[i].isFinished = true

					self.bindData.resultList:RefreshList()
					self.bindData.showList:RefreshList()
					self:CheckFinished()

					return
				end
			end
		end
	end
end

M.SetShowListDraggable = function(self, enable)
	for _, btn in pairs(self.showListBtn) do
		if btn then
			btn.draggable = enable
		end
	end
end

M.TryClose = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
		["@KczK->"] = true
	})
end

local GET_FINGERPRINT_URL_BY_INDEX = function(index)
	return string.format("%s%s%d.png", texturePath, fingerprintPrefix, index)
end

local GET_FINGERPRINT_PIECE_URL_BY_INDEX = function(belong, index)
	return string.format("%s%s%d_0%d.png", texturePath, fingerprintPrefix, belong, index)
end

local GEN_RANDOM_FINGERPRINT_INDEX = function()
	math.randomseed(os.time())

	return math.random(1, FINGER_MAX_INDEX)
end

local GEN_RANDOM_ANSWER_LACK = function(num, result)
	for i = 1, 9 do
		result[i] = i
	end

	for i = 1, num do
		local j = math.random(i, 9)
		result[j] = result[i]
		result[i] = result[j]
	end

	for i = num + 1, 9 do
		result[i] = nil
	end
end

M.ResetGameState = function(self)
	self.nowLevel = 1
	self.nowLife = self.maxLife
	self.bindData.lifeText = string.format("%d/%d", self.maxLife - self.nowLife, self.maxLife)

	if not gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, 52606169) then
		self.bindData.canSkillCtrl = self.canSkillCtrlEnum.cannot
	else
		self.bindData.canSkillCtrl = self.canSkillCtrlEnum.can
	end
end

M.RefreshLevel = function(self)
	if table.count(self.levelsList) < 0 then
		self.levelsList = {}

		for i = 1, self.levelNum do
			local level = {}

			if i >= self.nowLevel then
				level.isFinish = true
			else
				level.isFinish = false
			end

			table.insert(self.levelsList, level)
		end

		self.bindData.levelList:SetSimpleList(#self.levelsList)
	else
		for i = 1, self.levelNum do
			local level = self.levelsList[i]

			if i >= self.nowLevel then
				level.isFinish = true
			else
				level.isFinish = false
			end
		end

		self.bindData.levelList:RefreshList()
	end
end

M.GenGameData = function(self)
	self.answerIndex = GEN_RANDOM_FINGERPRINT_INDEX()
	self.bindData.answerPicUrl = GET_FINGERPRINT_URL_BY_INDEX(self.answerIndex)
	self.answerLackGroup = {}

	GEN_RANDOM_ANSWER_LACK(self.missingPartsCount, self.answerLackGroup)
	self.GenAnswerFingerprint(self)
	self.GenShowPiecesData(self)
end

M.GenAnswerFingerprint = function(self)
	table.clear(self.answerListData)

	for i = 1, 9 do
		local data = {
			url = GET_FINGERPRINT_PIECE_URL_BY_INDEX(self.answerIndex, i),
			fingerprintId = self.answerIndex,
			positionId = i,
			isLack = false
		}

		table.insert(self.answerListData, data)
	end

	for _, index in ipairs(self.answerLackGroup) do
		self.answerListData[index].isLack = true
	end

	self.bindData.resultList:SetSimpleList(#self.answerListData)
end

M.GenShowPiecesData = function(self)
	table.clear(self.showListData)
	table.clear(self.showListBtn)

	local resultCount = 0

	for i = 1, #self.answerLackGroup do
		resultCount = resultCount + 1
		local data = {
			fingerprintId = self.answerIndex,
			positionId = self.answerLackGroup[i]
		}
		data.url = GET_FINGERPRINT_PIECE_URL_BY_INDEX(data.fingerprintId, data.positionId)
		data.isLack = true

		table.insert(self.showListData, data)
	end

	local added = 0

	for i = 1, #self.answerLackGroup do
		if self.duplicatePartsCount < added then
			break
		end

		local onceAdd = 0

		while added >= 1 do
			local fingerprintId = math.random(1, 4)

			if fingerprintId == self.answerIndex then
				local data = {
					fingerprintId = fingerprintId,
					positionId = self.answerLackGroup[i]
				}
				data.url = GET_FINGERPRINT_PIECE_URL_BY_INDEX(data.fingerprintId, data.positionId)
				data.isLack = false

				table.insert(self.showListData, data)

				added = added + 1
				onceAdd = onceAdd + 1
				resultCount = resultCount + 1
			end
		end
	end

	while resultCount >= 9 do
		local fId = math.random(1, 4)
		local pId = math.random(1, 9)
		local skip = false

		for i = 1, #self.answerLackGroup do
			if self.answerLackGroup[i] ~= pId then
				skip = true

				break
			end
		end

		if not skip then
			for i = 1, resultCount do
				if self.showListData[i].fingerprintId ~= fId and self.showListData[i].positionId ~= pId then
					skip = true

					break
				end
			end
		end

		if not skip then
			local data = {
				fingerprintId = fId,
				positionId = pId
			}
			data.url = GET_FINGERPRINT_PIECE_URL_BY_INDEX(data.fingerprintId, data.positionId)
			data.isLack = false

			table.insert(self.showListData, data)

			resultCount = resultCount + 1
		end
	end

	for i = 9, 2, -1 do
		local j = math.random(1, i)
		self.showListData[j] = self.showListData[i]
		self.showListData[i] = self.showListData[j]
	end

	self.bindData.showList:SetSimpleList(#self.showListData)
end

M.InitFSM = function(self)
	self.gameFSM = gFSMManager:GetFSM(self)

	self.gameFSM:AddStates(StateType)
	self.gameFSM:AddTransitions(StateType, TransitionType)
end

M.OnReadyEnter = function(self)
	self.ResetGameState(self)
	self.RefreshLevel(self)
	self.GenGameData(self)

	if self.guideId == 0 and gNewGuideMgr.activeGuideBT and gNewGuideMgr.activeGuideBT.guideId ~= self.guideId or gPanelManager:IsPanelShowing(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS) then
		self.isInGuide = true

		return
	end

	self.gameFSM:SendSignal(TransitionType.Ready_Running)
end

M.OnRunningEnter = function(self)
	self.SetShowListDraggable(self, true)

	if not self.isCountDownPlaying then
		self.bindData.countDown:Play(self.gameTime)

		self.isCountDownPlaying = true
	end
end

M.OnRunningExit = function(self)
	self.SetShowListDraggable(self, false)
end

M.OnFailEnter = function(self)
	self.nowLife = self.nowLife - 1
	self.bindData.lifeText = string.format("%d/%d", self.maxLife - self.nowLife, self.maxLife)
	slot1 = self.bindData.ani

	slot1:Play("S_Vx_HackerArcadeBgTemplate_Error")

	slot1 = gSoundMgr

	slot1:PlaySoundByTid(70503077)
	gLuaTimeMgrUtils.Delay(function ()
		if self.nowLife < 0 then
			self.isSettleSuccess = false

			self.gameFSM:SendSignal(TransitionType.Fail_Settle)

			return
		end

		self.gameFSM:SendSignal(TransitionType.Fail_Running)
	end, 0.77)
end

M.OnSuccessEnter = function(self)
	if self.levelNum < self.nowLevel then
		slot1 = self.bindData.ani

		slot1:Play("S_Vx_HackerArcadeBgTemplate_success02")

		self.isSettleSuccess = true
		self.nowLevel = self.nowLevel + 1

		self:RefreshLevel()
		gLuaTimeMgrUtils.Delay(function ()
			self.gameFSM:SendSignal(TransitionType.Success_Settle)
		end, 1.1)

		return
	end

	slot1 = self.bindData.ani

	slot1:Play("S_Vx_HackerArcadeBgTemplate_success01")

	self.nowLevel = self.nowLevel + 1

	self:RefreshLevel()
	gLuaTimeMgrUtils.Delay(function ()
		self:GenGameData()
	end, 0.5)
	gLuaTimeMgrUtils.Delay(function ()
		self.gameFSM:SendSignal(TransitionType.Success_Running)
	end, 1.5)
end

M.OnSettleEnter = function(self)
	self.isCountDownPlaying = false

	self.bindData.countDown:Stop()

	if self.isSettleSuccess then
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = self.successCtrlEnum.Success

			if self.overStore and self.overStore.ani then
				self.overStore.ani:Play("S_Vx_HackerArcadeOver_open")

				self.overStore.replayCtrl = 0
			end

			self.settleCloseTimer = gLuaTimeMgrUtils.Delay(function ()
				gMessageManager:SendMessage(gEventConstants.HACKER_GAME_SUCCESS, {
					["\\xac\\xb0\\xae^'\\xee6"] = 4,
					entityId = self.entityId
				})
				gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
					closeSelf = self.closeWithComputer,
					closeWithAppOpen = self.closeWithAppOpen
				})
			end, PoiGameConfig.FingerprintCrack_EndTime)
		end, PoiGameConfig.FingerprintCrack_EndDelay)
	elseif self.canRestart then
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = self.successCtrlEnum.Failed

			if self.overStore then
				slot0 = self.overStore.ani
				local clip = slot0:GetClip("S_Vx_HackerArcadeOver_open")
				slot1 = self.overStore.ani

				slot1:Play("S_Vx_HackerArcadeOver_open")
				gLuaTimeMgrUtils.Delay(function ()
					self.overStore.replayCtrl = 1
				end, clip.length)

				self.overStore.replayBtn.luaClick = function()
					self.bindData.successCtrl = self.successCtrlEnum.Normal

					self.gameFSM:SendSignal(TransitionType.Settle_Ready)
				end
			end
		end, PoiGameConfig.FingerprintCrack_EndDelay)
	else
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = self.successCtrlEnum.Failed

			if self.overStore and self.overStore.ani then
				self.overStore.ani:Play("S_Vx_HackerArcadeOver_open")
			end

			self.settleCloseTimer = gLuaTimeMgrUtils.Delay(function ()
				gMessageManager:SendMessage(gEventConstants.HACKER_GAME_FAIL, {
					["\\xac\\xb0\\xae^'\\xee6"] = 4,
					entityId = self.entityId
				})
				gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
					closeSelf = self.closeWithComputer or self.closeWithAppOpen == ComputerConfig.HackOpenAppType.none
				})
			end, PoiGameConfig.FingerprintCrack_EndTime)
		end, PoiGameConfig.FingerprintCrack_EndDelay)
	end
end

M.GMPass = function(self)
	gMessageManager:SendMessage(gEventConstants.HACKER_GAME_SUCCESS, {
		["\\xac\\xb0\\xae^'\\xee6"] = 4,
		entityId = self.entityId
	})
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
		closeSelf = self.closeWithComputer,
		closeWithAppOpen = self.closeWithAppOpen
	})
end
