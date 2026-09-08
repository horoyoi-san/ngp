-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerCodeTracingPanelStore.lua
-- Decompiled from: 01699_HackerCodeTracingPanelStore.lua_36d8c8beed46.luajit

local ComputerConfig = LTConfig.ComputerConfig
local ComputerAppConfig = LTConfig.ComputerAppConfig
local PoiGameConfig = LTConfig.PoiGameConfig
local PoiGameHackMinigameConfig = LTConfig.PoiGameHackMinigameConfig
local CodeTrackConfig = LTConfig.PoiGameCodeTrackConfig
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
local DEFAULT_SPEED = 1
local DEFAULT_LEVEL_NUM = 1
local DEFAULT_LIFE = 5
local DEFAULT_GAME_TIME = 300
local DEFAULT_CODE_INTERVAL_DOWN = 4
local DEFAULT_CODE_INTERVAL_UP = 5
local DEFAULT_SKILL_EXCLUDE_COUNT = 3
local DEFAULT_SKILL_DURATION_TIME = 20
local DEFAULT_HACK_SKILL_CD = 3
local DEFAULT_HACK_SKILL_HINT_DOWN = 1
local DEFAULT_HACK_SKILL_HINT_UP = 2
C_HackerCodeTracingPanelStore = DefClass("C_HackerCodeTracingPanelStore", C_HackerCodeTracingPanelStore, C_StoreGroup)
GroupName2Class.HackerCodeTracingPanelStore = C_HackerCodeTracingPanelStore
local M = C_HackerCodeTracingPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.entityId = 0
	self.gameFSM = nil
	self.speed = DEFAULT_SPEED
	self.speeds = nil
	self.levelNum = DEFAULT_LEVEL_NUM
	self.gameTime = DEFAULT_GAME_TIME
	self.codeIntervalDown = DEFAULT_CODE_INTERVAL_DOWN
	self.codeIntervalUp = DEFAULT_CODE_INTERVAL_UP
	self.hackSkillHackExcludeCount = DEFAULT_SKILL_EXCLUDE_COUNT
	self.hackSkillTime = DEFAULT_SKILL_DURATION_TIME
	self.hackSkillCD = DEFAULT_HACK_SKILL_CD
	self.hackSkillHintDown = DEFAULT_HACK_SKILL_HINT_DOWN
	self.hackSkillHintUp = DEFAULT_HACK_SKILL_HINT_UP
	self.genCodeNum = 0
	self.genSkillNum = 0
	self.nowRandomCodeInterval = 0
	self.nowRandomSkillInterval = 0
	self.targetCode = nil
	self.nowLevel = 0
	self.nowTrackCount = 0
	self.nowLife = 0
	self.maxLife = DEFAULT_LIFE
	self.rollPos = 0
	self.contentHeight = 0
	self.isSettleSuccess = false
	self.isAnimBlocking = false
	self.gameRandomData = nil
	self.isCountDownPlaying = false
	self.hackSkillTimer = nil
	self.failPhaseTimer = nil
	self.settleCloseTimer = nil
	self.hackSkillTween = nil
	self.isInSkill = false
	self.closeWithComputer = false
	self.closeWithAppOpen = nil
	self.canExitDirectly = false
	self.alreadyShowBtn = {}
	self.isDestroy = false
	self.bgStore = nil
	self.overStore = nil
	self.guideId = 0
	self.isInGuide = false
	self.skillHackId = 0
	self.levelsList = {}
	self.canRestart = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.InitFSM(self)
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
				if gameAppCfg[i].appId ~= ComputerAppConfig.hacker3 then
					gameConfigId = gameAppCfg[i].hackgameId

					break
				end
			end
		end

		local gameConfig = PoiGameHackMinigameConfig.GetConfig(gameConfigId)

		if gameConfig then
			self.speeds = gameConfig.CodeListScrollSpeed
			self.levelNum = gameConfig.PlayCount
			self.gameTime = gameConfig.Time
			self.maxLife = gameConfig.Hp
			self.codeIntervalDown = gameConfig.RightCodeInterval[1]
			self.codeIntervalUp = gameConfig.RightCodeInterval[2]
			self.hackSkillHackExcludeCount = PoiGameConfig.CodeTrack_HackSkill[2]
			self.hackSkillTime = PoiGameConfig.CodeTrack_HackSkill[1]
			self.hackSkillCD = PoiGameConfig.CodeTrack_HackSkill[5]
			self.hackSkillHintDown = PoiGameConfig.CodeTrack_HackSkill[3]
			self.hackSkillHintUp = PoiGameConfig.CodeTrack_HackSkill[4]
			skillText = PoiGameConfig.CodeTrack_SkillText
			self.canRestart = gameConfig.CanRestart
		end

		self.closeWithComputer = computerConfig.HackGameExit
		self.closeWithAppOpen = computerConfig.HackOpenApp
		self.canExitDirectly = computerConfig.HackGameCanESC
		self.guideId = computerConfig.GuideId
		self.skillHackId = PoiGameConfig.CodeTrack_SkillCost
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
			self.skillStore:RegisterSkill(skillText, self:CreateAction("OnClickHackSkillBtn"), self.hackSkillTime, self.skillHackId)
		end

		local bgGroup = gStoreManager:GetStoreGroup("HackerArcadeBgTemplate")

		for _, store in pairs(bgGroup.storeDic) do
			self.bgStore = store
		end

		local overGroup = gStoreManager:GetStoreGroup("HackerArcadeOverTemplate")

		for _, store in pairs(overGroup.storeDic) do
			self.overStore = store
		end
	end)
end

M.OnDestroy = function(self)
	self.isDestroy = true

	if self.gameFSM then
		self.gameFSM:Dispose()

		self.gameFSM = nil
	end

	if not self.canExitDirectly then
		gMessageManager:SendMessage(gEventConstants.COMPUTER_ALLOW_EXIT, true)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.HACKER_GAME_FINISH_GUIDE] = function ()
			if not self.isInGuide then
				return
			end

			self.isInGuide = false

			self.gameFSM:SendSignal(TransitionType.Ready_Running)
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.loopList.luaSimpleRenderItem = self:CreateAction("OnRenderLoopListItem")

	self.bindData.loopList:RegisterToSetToPoolEvent(function (index, _)
		self.alreadyShowBtn[index + 1] = nil
	end)

	self.bindData.lifeList.luaSimpleRenderItem = self:CreateAction("OnRenderLifeListItem")
	self.bindData.countDown.luaFinished = self:CreateAction("OnCountDownFinish")
end

M.OnRenderLoopListItem = function(self, btn, index)
	index = index + 1
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("CodeTracingTemplate"):GetStoreById(id)
	local data = self.gameRandomData[index]
	data.lId = self:GenNextCodeId()
	data.rId = self:GenNextCodeId()

	if store then
		self.alreadyShowBtn[index] = btn
		local lBtn = store.leftBtn
		local rBtn = store.rightBtn

		if not lBtn.luaPress then
			lBtn.luaPress = self.CreateActionWithArgs(self, "OnCodeClick", {
				["[\\xbd\\x8b\\x85U"] = true,
				widget = btn
			})
		end

		if not rBtn.luaPress then
			rBtn.luaPress = self.CreateActionWithArgs(self, "OnCodeClick", {
				["[\\xbd\\x8b\\x85U"] = false,
				widget = btn
			})
		end

		store.leftCodeText = CodeTrackConfig.GetConfig(data.lId).Snippet
		store.rightCodeText = CodeTrackConfig.GetConfig(data.rId).Snippet
		store.lModeCtrl = 0
		store.rModeCtrl = 0

		if self.isInSkill then
			self.GenNextHint(self, store, data)
		end
	end
end

M.OnCodeClick = function(self, param)
	if self.gameFSM:GetCurrentState() == StateType.Running then
		return
	end

	local btn = param.widget
	local isLeft = param.isLeft
	local index = self.bindData.loopList:GetChildIndex(btn)
	local data = self.gameRandomData[index + 1]
	local widgetId = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("CodeTracingTemplate"):GetStoreById(widgetId)
	local id = nil

	if isLeft then
		id = data.lId

		if store.lModeCtrl == 0 then
			return
		end
	else
		id = data.rId

		if store.rModeCtrl == 0 then
			return
		end
	end

	if id ~= self.targetCode then
		if isLeft then
			store.lModeCtrl = 1
		else
			store.rModeCtrl = 1
		end

		self.gameFSM:SendSignal(TransitionType.Running_Success)
		gSoundMgr:PlaySoundByTid(70601386)
	else
		if isLeft then
			store.lModeCtrl = 2
		else
			store.rModeCtrl = 2
		end

		if self.bgStore then
			self.bgStore.ani:Play("S_Vx_HackerArcadeBgTemplate_Error")
		end

		self.gameFSM:SendSignal(TransitionType.Running_Fail)
		gSoundMgr:PlaySoundByTid(70601385)
	end
end

M.OnRenderLifeListItem = function(self, btn, index)
	local data = self.levelsList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("CodeTracingCheckTemplate"):GetStoreById(id)

	if store then
		store.checkCtrl = data.isFinish and 1 or 0
	end
end

M.OnCountDownFinish = function(self)
	self.isSettleSuccess = false

	self.gameFSM:SendSignal(TransitionType.Running_Settle)
end

M.ResetGameState = function(self)
	self.targetCode = nil
	self.genCodeNum = 0
	self.nowLevel = 1
	self.nowSelectCol = 1
	self.nowLife = self.maxLife
	self.bindData.lifeText = string.format("%d/%d", self.maxLife - self.nowLife, self.maxLife)

	if not gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, 52606146) then
		self.bindData.canSkillCtrl = 1
	else
		self.bindData.canSkillCtrl = 0
	end
end

M.RefreshLevel = function(self)
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

	self.bindData.lifeList:SetSimpleList(#self.levelsList)

	self.speed = self.speeds and self.speeds[self.nowLevel] or DEFAULT_SPEED
end

M.SetLoopListData = function(self)
	local listData = {}

	for i = 1, 7 do
		local data = {
			index = i
		}

		table.insert(listData, data)
	end

	self.gameRandomData = listData

	self.bindData.loopList:SetSimpleList(#self.gameRandomData)

	self.contentHeight = self.bindData.loopList:GetContentHeight()
end

M.GenTargetCode = function(self)
	local count = CodeTrackConfig.count
	local targetText = nil

	math.randomseed(os.time())

	local index = math.random(0, count - 1)

	for i = 0, count - 1 do
		if i ~= index then
			local cfg = CodeTrackConfig.LoadAt(i)

			if self.targetCode == nil and self.targetCode ~= cfg.Id then
				if i ~= count - 1 then
					cfg = CodeTrackConfig.LoadAt(i - 1)
				else
					cfg = CodeTrackConfig.LoadAt(i + 1)
				end
			end

			self.targetCode = cfg.Id
			targetText = cfg.Snippet
		end
	end

	self.bindData.targetCodeText = targetText
end

local GEN_ONE_RANDOM_CODE_ID = function()
	local count = CodeTrackConfig.count
	local index = math.random(0, count - 1)

	for i = 0, count - 1 do
		if i ~= index then
			local cfg = CodeTrackConfig.LoadAt(i)

			return cfg.Id
		end
	end
end

M.GenNextCodeId = function(self)
	if self.nowRandomCodeInterval ~= 0 then
		math.randomseed(os.time())

		self.nowRandomCodeInterval = math.random(self.codeIntervalDown, self.codeIntervalUp)
	end

	if self.nowRandomCodeInterval < self.genCodeNum then
		self.genCodeNum = 0
		self.nowRandomCodeInterval = 0

		return self.targetCode
	end

	local codeId = nil

	while true do
		local id = GEN_ONE_RANDOM_CODE_ID()

		if id == self.targetCode then
			codeId = id

			break
		end
	end

	self.genCodeNum = self.genCodeNum + 1

	return codeId
end

local SHARED_POS = Vector2.New(0, 0)

M.HandleAutoLoopRolling = function(self)
	self.rollPos = self.rollPos + self.speed * Time.deltaTime
	SHARED_POS.y = self.rollPos

	self.bindData.loopList:GoToPos(SHARED_POS, true)
end

M.TryClose = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
		["@KczK->"] = true
	})
end

M.OnClickHackSkillBtn = function(self)
	self.genSkillNum = 0
	self.nowRandomSkillInterval = 0
	local nowTime = self.bindData.countDown.currentSecond
	local totalTime = self.bindData.countDown.totalSecond
	self.isInSkill = true
	slot3 = self.bindData.countDown

	slot3:Stop()
	self:HintAlreadyShowBtn(self.hackSkillHackExcludeCount)
	gLuaTimeMgrUtils.Delay(function ()
		if self.isDestroy then
			return
		end

		self.bindData.countDown:Play(nowTime, totalTime)

		self.isInSkill = false
	end, self.hackSkillTime)
end

local arr = {}

M.HintAlreadyShowBtn = function(self, n)
	math.randomseed(os.time())
	table.clear(arr)

	for _, btn in pairs(self.alreadyShowBtn) do
		local index = self.bindData.loopList:GetChildIndex(btn)

		if index == -1 then
			local data = self.gameRandomData[index + 1]
			local widgetId = btn.gameObject:GetInstanceID()
			local store = gStoreManager:GetStoreGroup("CodeTracingTemplate"):GetStoreById(widgetId)

			if data.lId == self.targetCode then
				table.insert(arr, {
					["[\\xbd\\x8b\\x85U"] = true,
					store = store
				})
			end

			if data.rId == self.targetCode then
				table.insert(arr, {
					["[\\xbd\\x8b\\x85U"] = false,
					store = store
				})
			end
		end
	end

	if n > #arr then
		return
	end

	for i = #arr, 2, -1 do
		local j = math.random(i)
		arr[j] = arr[i]
		arr[i] = arr[j]
	end

	local num = 0

	for i = 1, #arr do
		if n < num then
			return
		end

		local store = arr[i].store
		local isLeft = arr[i].isLeft

		if isLeft then
			store.lModeCtrl = 3
			num = num + 1
		else
			store.rModeCtrl = 3
			num = num + 1
		end
	end
end

M.GenNextHint = function(self, store, data)
	if self.nowRandomSkillInterval ~= 0 then
		math.randomseed(os.time())

		self.nowRandomSkillInterval = math.random(self.hackSkillHintDown, self.hackSkillHintUp)
	end

	if self.genSkillNum > self.nowRandomSkillInterval - 1 then
		if self.genSkillNum ~= self.nowRandomSkillInterval then
			if data.lId == self.targetCode then
				store.lModeCtrl = 3
				self.genSkillNum = 1
			elseif data.rId == self.targetCode then
				store.rModeCtrl = 3
				self.genSkillNum = 0
			else
				self.genSkillNum = self.genSkillNum + 2

				return
			end
		elseif data.rId == self.targetCode then
			store.rModeCtrl = 3
			self.genSkillNum = 0
		else
			self.genSkillNum = self.genSkillNum + 1

			return
		end

		self.nowRandomSkillInterval = 0

		return
	end

	self.genSkillNum = self.genSkillNum + 2
end

M.InitFSM = function(self)
	self.gameFSM = gFSMManager:GetFSM(self)

	self.gameFSM:AddStates(StateType)
	self.gameFSM:AddTransitions(StateType, TransitionType)
end

M.OnReadyEnter = function(self)
	self.ResetGameState(self)
	self.RefreshLevel(self)
	self.GenTargetCode(self)
	self.SetLoopListData(self)

	if self.guideId == 0 and gNewGuideMgr.activeGuideBT and gNewGuideMgr.activeGuideBT.guideId ~= self.guideId or gPanelManager:IsPanelShowing(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS) then
		self.isInGuide = true

		return
	end

	self.gameFSM:SendSignal(TransitionType.Ready_Running)
end

M.OnRunningEnter = function(self)
	if not self.isCountDownPlaying then
		self.bindData.countDown:Play(self.gameTime)

		self.isCountDownPlaying = true
	end
end

M.OnRunningUpdate = function(self)
	self.HandleAutoLoopRolling(self)
end

M.OnOfflineEnter = function(self)
end

M.OnOfflineExit = function(self)
end

M.OnFailEnter = function(self)
	self.nowLife = self.nowLife - 1
	self.bindData.lifeText = string.format("%d/%d", self.maxLife - self.nowLife, self.maxLife)

	if self.nowLife < 0 then
		self.isSettleSuccess = false

		self.gameFSM:SendSignal(TransitionType.Fail_Settle)

		return
	end

	self.gameFSM:SendSignal(TransitionType.Fail_Running)
end

M.OnSuccessEnter = function(self)
	if self.levelNum < self.nowLevel then
		self.isSettleSuccess = true
		self.nowLevel = self.nowLevel + 1

		self:RefreshLevel()
		self.gameFSM:SendSignal(TransitionType.Success_Settle)

		return
	end

	slot1 = self.bindData.ani

	slot1:Play("S_Vx_HackerArcade03_PC_TL_template_refresh")
	gLuaTimeMgrUtils.Delay(function ()
		self:GenTargetCode()

		self.nowLevel = self.nowLevel + 1

		self:RefreshLevel()
		self.gameFSM:SendSignal(TransitionType.Success_Running)
	end, 0.2)
end

M.OnSettleEnter = function(self)
	self.isCountDownPlaying = false

	self.bindData.countDown:Stop()

	if self.isSettleSuccess then
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = 1

			if self.overStore and self.overStore.ani then
				self.overStore.ani:Play("S_Vx_HackerArcadeOver_open")

				self.overStore.replayCtrl = 0
			end

			self.settleCloseTimer = gLuaTimeMgrUtils.Delay(function ()
				gMessageManager:SendMessage(gEventConstants.HACKER_GAME_SUCCESS, {
					["\\xac\\xb0\\xae^'\\xee6"] = 3,
					entityId = self.entityId
				})
				gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
					closeSelf = self.closeWithComputer,
					closeWithAppOpen = self.closeWithAppOpen
				})
			end, PoiGameConfig.CodeTrack_EndTime)
		end, PoiGameConfig.CodeTrack_EndDelay)
	elseif self.canRestart then
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = 2

			if self.overStore then
				slot0 = self.overStore.ani
				local clip = slot0:GetClip("S_Vx_HackerArcadeOver_open")
				slot1 = self.overStore.ani

				slot1:Play("S_Vx_HackerArcadeOver_open")
				gLuaTimeMgrUtils.Delay(function ()
					self.overStore.replayCtrl = 1
				end, clip.length)

				self.overStore.replayBtn.luaClick = function()
					self.bindData.successCtrl = 0

					self.overStore.ani:Play("S_Vx_HackerArcadeOver_close")
					self.gameFSM:SendSignal(TransitionType.Settle_Ready)
				end
			end
		end, PoiGameConfig.CodeTrack_EndDelay)
	else
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = 2

			if self.overStore and self.overStore.ani then
				self.overStore.ani:Play("S_Vx_HackerArcadeOver_open")
			end

			self.settleCloseTimer = gLuaTimeMgrUtils.Delay(function ()
				gMessageManager:SendMessage(gEventConstants.HACKER_GAME_FAIL, {
					["\\xac\\xb0\\xae^'\\xee6"] = 3,
					entityId = self.entityId
				})
				gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
					closeSelf = self.closeWithComputer or self.closeWithAppOpen == ComputerConfig.HackOpenAppType.none
				})
			end, PoiGameConfig.CodeTrack_EndTime)
		end, PoiGameConfig.CodeTrack_EndDelay)
	end
end

M.GMPass = function(self)
	gMessageManager:SendMessage(gEventConstants.HACKER_GAME_SUCCESS, {
		["\\xac\\xb0\\xae^'\\xee6"] = 3,
		entityId = self.entityId
	})
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
		closeSelf = self.closeWithComputer,
		closeWithAppOpen = self.closeWithAppOpen
	})
end
