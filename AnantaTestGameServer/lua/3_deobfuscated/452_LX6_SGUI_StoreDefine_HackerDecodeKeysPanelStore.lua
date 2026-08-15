local DOTween = DOTween
local Ease = DG.Tweening.Ease
local ComputerConfig = LTConfig.ComputerConfig
local ComputerAppConfig = LTConfig.ComputerAppConfig
local PoiGameConfig = LTConfig.PoiGameConfig
local PoiGameHackMinigameConfig = LTConfig.PoiGameHackMinigameConfig
local StateType = {
	Settle = 6,
	Offline = 3,
	Fail = 4,
	Running = 2,
	Ready = 1,
	Success = 5
}
local TransitionType = {
	Settle_Ready = 11,
	Ready_Running = 1,
	Running_Settle = 10,
	Running_Fail = 4,
	Fail_Running = 6,
	Fail_Settle = 7,
	Running_Offline = 2,
	Offline_Ready = 3,
	Success_Settle = 9,
	Running_Success = 5,
	Success_Running = 8
}
local EMPTY_TABLE = {}
local COL_NUM = 8
local ROW_NUM = 7
local DEFAULT_NUM_PER_COL = 15
local DEFAULT_SPEED = 10
local DEFAULT_LEVEL_NUM = 4
local DEFAULT_LIFE = 5
local DEFAULT_GAME_TIME = 300
local INVALID_PLACEHOLDER = -1
local DEFAULT_HACK_SKILL_ADD_KEY_NUM = 3
local DEFAULT_SKILL_DURATION_TIME = 5
local DEFAULT_HACK_SKILL_CD = 10
C_HackerDecodeKeysPanelStore = DefClass("C_HackerDecodeKeysPanelStore", C_HackerDecodeKeysPanelStore, C_StoreGroup)
GroupName2Class.HackerDecodeKeysPanelStore = C_HackerDecodeKeysPanelStore
local M = C_HackerDecodeKeysPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.entityId = 0
	self.gameFSM = nil
	self.numPerCol = DEFAULT_NUM_PER_COL
	self.numPerCols = nil
	self.speed = DEFAULT_SPEED
	self.speeds = nil
	self.levelNum = DEFAULT_LEVEL_NUM
	self.gameTime = DEFAULT_GAME_TIME
	self.hackSkillHackNum = DEFAULT_HACK_SKILL_ADD_KEY_NUM
	self.hackSkillTime = DEFAULT_SKILL_DURATION_TIME
	self.hackSkillCD = DEFAULT_HACK_SKILL_CD
	self.keywords = nil
	self.nowKeyword = {}
	self.nowLevel = 0
	self.nowLife = 0
	self.maxLife = DEFAULT_LIFE
	self.rollPos = {}
	self.contentHeight = 0
	self.nowSelectCol = 1
	self.underCtrlColList = nil
	self.skillStore = nil
	self.isSettleSuccess = false
	self.isAnimBlocking = false
	self.gameRandomData = {}
	self.finishCol = {}
	self.autoRollingCol = {}
	self.isCountDownPlaying = false
	self.needRecoverCol = {}
	self.isInSkill = false
	self.hackSkillTimer = nil
	self.failPhaseTimer = nil
	self.settleCloseTimer = nil
	self.hackSkillTween = nil
	self.isCheckShow = true
	self.closeWithComputer = false
	self.closeWithAppOpen = nil
	self.canExitDirectly = false
	self.bgStore = nil
	self.overStore = nil
	self.guideId = 0
	self.isInGuide = false
	self.skillHackId = 0
	self.levelsList = {}
	self.canRestart = false
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:InitFSM()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	data = data or EMPTY_TABLE
	self.numPerCols = data.numPerCols
	self.speeds = data.speeds
	self.levelNum = data.levelNum or DEFAULT_LEVEL_NUM
	self.gameTime = data.gameTime or DEFAULT_GAME_TIME
	self.maxLife = data.hp or DEFAULT_LIFE
	self.hackSkillHackNum = data.hackSkillHackNum or DEFAULT_HACK_SKILL_ADD_KEY_NUM
	self.hackSkillTime = data.hackSkillTime or DEFAULT_SKILL_DURATION_TIME
	self.hackSkillCD = data.hackSkillCD or DEFAULT_HACK_SKILL_CD
	self.skillHackId = PoiGameConfig.KeyCrack_SkillCost
	self.keywords = self:GetOrGenKeywords(data)

	self.gameFSM:SetInitState(StateType.Ready)
end

function M:ShowPanel(computerId, entityId)
	self.entityId = entityId
	local data, skillText = nil

	if computerId then
		local computerConfig = ComputerConfig.GetConfig(computerId)
		local gameAppCfg = computerConfig.AppToHackGame
		local gameConfigId = nil

		if table.isNilOrEmpty(gameAppCfg) then
			gameConfigId = computerConfig.HackGame
		else
			for i = 1, #gameAppCfg do
				if gameAppCfg[i].appId == ComputerAppConfig.hacker1 then
					gameConfigId = gameAppCfg[i].hackgameId

					break
				end
			end
		end

		local gameConfig = PoiGameHackMinigameConfig.GetConfig(gameConfigId)
		data = {
			numPerCols = gameConfig.CharCount,
			speeds = gameConfig.ScrollSpeed,
			levelNum = gameConfig.PlayCount,
			keywords = gameConfig.Password,
			gameTime = gameConfig.Time,
			hp = gameConfig.Hp,
			hackSkillTime = PoiGameConfig.KeyCrack_HackSkill[1],
			hackSkillHackNum = PoiGameConfig.KeyCrack_HackSkill[2],
			hackSkillCD = PoiGameConfig.KeyCrack_HackSkill[3]
		}
		skillText = PoiGameConfig.KeyCrack_SkillText
		self.closeWithComputer = computerConfig.HackGameExit
		self.closeWithAppOpen = computerConfig.HackOpenApp
		self.canExitDirectly = computerConfig.HackGameCanESC
		self.guideId = computerConfig.GuideId
		self.canRestart = gameConfig.CanRestart
	end

	if not self.canExitDirectly then
		gMessageManager:SendMessage(gEventConstants.COMPUTER_ALLOW_EXIT, false)
	else
		gMessageManager:SendMessage(gEventConstants.COMPUTER_ALLOW_EXIT, true)
	end

	self.isCheckShow = false

	StartCoroutine(function ()
		WaitForEndOfFrame()
		self:OnShow(0, data)

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

function M:OnClose()
	self.gameFSM:Dispose()

	self.gameFSM = nil
end

function M:OnDestroy()
	if self.gameFSM then
		self.gameFSM:Dispose()

		self.gameFSM = nil
	end

	gLuaTimeMgrUtils.CancelUnitDelay(self.hackSkillTimer)
	gLuaTimeMgrUtils.CancelUnitDelay(self.failPhaseTimer)
	gLuaTimeMgrUtils.CancelUnitDelay(self.settleCloseTimer)

	self.hackSkillTimer = nil
	self.failPhaseTimer = nil
	self.settleCloseTimer = nil

	if self.hackSkillTween then
		self.hackSkillTween:Kill()

		self.hackSkillTween = nil
	end

	if not self.canExitDirectly then
		gMessageManager:SendMessage(gEventConstants.COMPUTER_ALLOW_EXIT, true)
	end
end

function M:GenMessageEvents()
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

function M:RegisterWidget()
	self.bindData.hackBtn.luaClick = self:CreateAction("OnClickHackBtn")
	self.bindData.levelList.luaSimpleRenderItem = self:CreateAction("OnRenderLevelListItem")

	for i = 1, COL_NUM do
		self.bindData["gameList" .. i].luaRenderItem = self:CreateActionWithArgs("OnRenderGameListItem", i)
	end

	self.bindData.countDown.luaFinished = self:CreateAction("OnCountDownFinish")
end

function M:OnClickHackBtn()
	if self.isAnimBlocking then
		return
	end

	if self.gameFSM:GetCurrentState() ~= StateType.Running then
		return
	end

	self.autoRollingCol[self.nowSelectCol] = false
	local btn = self.underCtrlColList:GetCurNearestCenterItem()
	local index = self.underCtrlColList:GetChildIndex(btn)
	local offset = self.underCtrlColList:GetItemToCenterOffset(btn)
	local extraIndex = offset < 0 and (index - 1) % self.numPerCol or (index + 1) % self.numPerCol
	local nowData = self.gameRandomData[self.nowSelectCol][index + 1][1]

	if nowData ~= self.nowKeyword[self.nowSelectCol] then
		local extraData = self.gameRandomData[self.nowSelectCol][extraIndex + 1][1]

		if extraData == self.nowKeyword[self.nowSelectCol] then
			btn = self.underCtrlColList:GetChildAt(extraIndex)
		end
	elseif offset > 0 then
		local extraData = self.gameRandomData[self.nowSelectCol][extraIndex + 1][1]

		if extraData == self.nowKeyword[self.nowSelectCol] then
			btn = self.underCtrlColList:GetChildAt(extraIndex)
		end
	end

	self:HandleSelectAnim(btn)
end

function M:OnClickHackSkillBtn()
	if self.gameFSM:GetCurrentState() ~= StateType.Running then
		return
	end

	self.isInSkill = true

	table.clear(self.needRecoverCol)

	for i = self.nowSelectCol, COL_NUM do
		self.needRecoverCol[i] = true

		self:ChangeRandomDataToKey(self.nowKeyword[i], self.hackSkillHackNum, self.gameRandomData[i])
	end

	self.hackSkillTimer = gLuaTimeMgrUtils.Delay(function ()
		if self.gameFSM:GetCurrentState() ~= StateType.Running then
			return
		end

		for i = self.nowSelectCol, COL_NUM do
			if self.needRecoverCol[i] then
				self:ReGenOneListData(self.gameRandomData[i], self.nowKeyword[i])
			end
		end

		self.isInSkill = false
	end, self.hackSkillTime)
end

function M:OnRenderLevelListItem(btn, index)
	local data = self.levelsList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("DecodeKeyLevelTemplate"):GetStoreById(id)

	if store then
		store.levelStageCtrl = data.isFinish and 1 or 0
	end
end

function M:OnRenderGameListItem(col, btn, index)
	local data = self.gameRandomData[col][index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("DecodeKeyTemplate"):GetStoreById(id)

	if store then
		local colKey = self.nowKeyword[col]
		local key = data[1]

		if key == colKey then
			if self.finishCol[col] then
				store.keyStatusCtrl = 2
			else
				store.keyStatusCtrl = 3
			end
		else
			store.keyStatusCtrl = 0
		end

		store.keyText = key
	end
end

function M:OnCountDownFinish()
	self.isSettleSuccess = false

	self.gameFSM:SendSignal(TransitionType.Running_Settle)
end

local function IS_VALID_UPPERCASE_WORD(word)
	return type(word) == "string" and #word == 8 and word:match("^[A-Z]+$") ~= nil
end

local function GEN_RANDOM_KEYWORD()
	local keywordsPool = PoiGameConfig.KeyCrack_CodePool

	return keywordsPool[math.random(#keywordsPool)]
end

function M:GetOrGenKeywords(data)
	math.randomseed(os.time())

	local result = {}
	local levelNum = self.levelNum
	local keywords = data.keywords

	if not keywords then
		for i = 1, levelNum do
			table.insert(result, GEN_RANDOM_KEYWORD())
		end
	elseif #keywords ~= levelNum then
		for i = 1, levelNum do
			if keywords[i] and IS_VALID_UPPERCASE_WORD(keywords[i]) then
				table.insert(result, keywords[i])
			else
				table.insert(result, GEN_RANDOM_KEYWORD())
			end
		end
	else
		return keywords
	end

	return result
end

function M:ResetGameState()
	table.clear(self.finishCol)

	self.nowLevel = 1
	self.nowSelectCol = 1
	self.nowLife = self.maxLife
	self.bindData.lifeText = string.format("%d/%d", self.maxLife - self.nowLife, self.maxLife)

	if not gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, 52606113) then
		self.bindData.canSkillCtrl = 1
	else
		self.bindData.canSkillCtrl = 0
	end
end

function M:RefreshLevel()
	self.levelsList = {}

	for i = 1, self.levelNum do
		local level = {}

		if i < self.nowLevel then
			level.isFinish = true
		else
			level.isFinish = false
		end

		table.insert(self.levelsList, level)
	end

	self.bindData.levelList:SetSimpleList(#self.levelsList)

	self.numPerCol = self.numPerCols and self.numPerCols[self.nowLevel] or DEFAULT_NUM_PER_COL
	self.speed = self.speeds and self.speeds[self.nowLevel] or DEFAULT_SPEED
end

function M:RefreshNowKeyword()
	table.clear(self.nowKeyword)

	local nowKeyword = self.keywords[self.nowLevel]

	for i = 1, #nowKeyword do
		self.nowKeyword[i] = nowKeyword:sub(i, i)
	end
end

local reusableTable = {}

local function SELECT_RANDOM_FROM_CONTINUOUS_SET(x, y, result)
	table.clear(reusableTable)

	for i = 1, x do
		reusableTable[i] = i
	end

	for i = x, 2, -1 do
		local j = math.random(i)
		reusableTable[j] = reusableTable[i]
		reusableTable[i] = reusableTable[j]
	end

	for i = 1, y do
		result[reusableTable[i]] = reusableTable[i]
	end
end

local letterSet = {}

local function FILL_UNIQUE_LETTERS(array, thisColKey)
	if not next(letterSet) then
		for c = string.byte("A"), string.byte("Z") do
			local letter = string.char(c)

			table.insert(letterSet, letter)
		end
	end

	for i = #letterSet, 2, -1 do
		local j = math.random(i)
		letterSet[j] = letterSet[i]
		letterSet[i] = letterSet[j]
	end

	local pointer = 1

	for i, v in ipairs(array) do
		if thisColKey == letterSet[pointer] then
			pointer = pointer + 1
		end

		if v == INVALID_PLACEHOLDER then
			array[i] = {
				letterSet[pointer]
			}
		elseif v[1] == INVALID_PLACEHOLDER then
			array[i][1] = letterSet[pointer]
		end

		pointer = pointer + 1
	end
end

local COL_NEED_SHOW_SET = {}

function M:GenGameRandomData()
	table.clear(COL_NEED_SHOW_SET)
	math.randomseed(os.time())

	for i = 1, COL_NUM do
		self.gameRandomData[i] = self.gameRandomData[i] or {}

		for j = 1, self.numPerCol do
			self.gameRandomData[i][j] = INVALID_PLACEHOLDER
		end
	end

	local needShowColNum = math.random(COL_NUM)
	needShowColNum = math.max(needShowColNum, 2)

	SELECT_RANDOM_FROM_CONTINUOUS_SET(COL_NUM, needShowColNum, COL_NEED_SHOW_SET)

	for i = 1, COL_NUM do
		if COL_NEED_SHOW_SET[i] == i then
			local place = math.random(ROW_NUM)
			self.gameRandomData[i][place] = {
				self.nowKeyword[i]
			}
		else
			local place = math.random(ROW_NUM + 1, self.numPerCol)
			self.gameRandomData[i][place] = {
				self.nowKeyword[i]
			}
		end
	end

	for i = 1, COL_NUM do
		local thisColKey = self.nowKeyword[i]

		FILL_UNIQUE_LETTERS(self.gameRandomData[i], thisColKey)
	end
end

function M:SetLoopListData()
	for i = 1, COL_NUM do
		self.bindData["gameList" .. i]:SetList(self.gameRandomData[i])

		self.autoRollingCol[i] = true
		self.rollPos[i] = 0
	end

	self.contentHeight = self.bindData.gameList1:GetContentHeight()
end

function M:GoToNextLevel()
	table.clear(self.finishCol)

	self.nowLevel = self.nowLevel + 1
	self.nowSelectCol = 1
end

function M:ChangeRandomDataToKey(key, num, data)
	local length = #data
	local counter = 1

	while num >= counter do
		local pos = math.random(length)

		if data[pos][1] ~= key then
			data[pos][1] = key
			counter = counter + 1
		end
	end
end

function M:ReGenOneListData(data, key)
	local pos = math.random(#data)

	for i = 1, self.numPerCol do
		data[i][1] = INVALID_PLACEHOLDER
	end

	data[pos][1] = key

	FILL_UNIQUE_LETTERS(data, key)
end

local SHARED_POS = Vector2.New(0, 0)

function M:HandleAutoLoopRolling()
	for i = 1, COL_NUM do
		if self.autoRollingCol[i] then
			self.rollPos[i] = (self.rollPos[i] + self.speed) % self.contentHeight
			SHARED_POS.y = self.rollPos[i]

			self.bindData["gameList" .. i]:GoToPos(SHARED_POS, true)
		end
	end
end

function M:RefreshNowSelectCol()
	self.bindData.decodeColCtrl = self.nowSelectCol - 1
	self.underCtrlColList = self.bindData["gameList" .. self.nowSelectCol]
end

function M:GetNowListCenterKey()
	return
end

function M:HandleSelectAnim(btn)
	local offset = self.underCtrlColList:GetItemToCenterOffset(btn)
	local originalPos = self.rollPos[self.nowSelectCol]
	self.rollPos[self.nowSelectCol] = self.rollPos[self.nowSelectCol] - offset
	self.isAnimBlocking = true

	DOTween.To(function ()
		return originalPos
	end, function (value)
		originalPos = value
		SHARED_POS.y = originalPos

		if not gClientUtils.IsNil(self.underCtrlColList) then
			self.underCtrlColList:GoToPos(SHARED_POS, true)
		end
	end, self.rollPos[self.nowSelectCol], 0.2):SetEase(Ease.Linear):OnComplete(function ()
		self:HandleSelectResult(btn)
	end)
end

function M:HandleSelectResult(btn)
	local data = self.underCtrlColList:GetData(btn)
	local key = data[1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("DecodeKeyTemplate"):GetStoreById(id)

	if store then
		if key ~= self.nowKeyword[self.nowSelectCol] then
			store.keyStatusCtrl = 1

			if self.bgStore then
				self.bgStore.ani:Play("S_Vx_HackerArcadeBgTemplate_Error")
			end

			self.failPhaseTimer = gLuaTimeMgrUtils.Delay(function ()
				self.isAnimBlocking = false
				store.keyStatusCtrl = 0

				self.gameFSM:SendSignal(TransitionType.Running_Fail)
			end, 0.5)

			gSoundMgr:PlaySoundByTid(70601385)
		else
			self.isAnimBlocking = false
			store.keyStatusCtrl = 2

			self.gameFSM:SendSignal(TransitionType.Running_Success)
			gSoundMgr:PlaySoundByTid(70601386)
		end
	end
end

function M:TryClose()
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
		closeSelf = true
	})
end

function M:GetFSMStateInitParams(name)
	return StateType[name], self[string.format("On%sEnter", name)], self[string.format("On%sExit", name)], self[string.format("On%sUpdate", name)]
end

local result = {}

function M:GetFSMTransitionInitParams(name)
	table.clear(result)

	for word in string.gmatch(name, "([^_]+)") do
		table.insert(result, word)
	end

	return StateType[result[1]], StateType[result[2]], TransitionType[name], self[string.format("On%sTo%sCheck", result[1], result[2])], self[string.format("On%sTo%sTransition", result[1], result[2])]
end

function M:InitFSM()
	self.gameFSM = gFSMManager:GetFSM(self)

	for name, _ in pairs(StateType) do
		self.gameFSM:AddState(self:GetFSMStateInitParams(name))
	end

	for name, _ in pairs(TransitionType) do
		self.gameFSM:AddTransition(self:GetFSMTransitionInitParams(name))
	end
end

function M:OnReadyEnter()
	self:ResetGameState()
	self:RefreshLevel()
	self:RefreshNowKeyword()
	self:RefreshNowSelectCol()
	self:GenGameRandomData()
	self:SetLoopListData()

	if self.guideId ~= 0 and gNewGuideMgr.activeGuideBT and gNewGuideMgr.activeGuideBT.guideId == self.guideId or gPanelManager:IsPanelShowing(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS) then
		self.isInGuide = true

		return
	end

	self.gameFSM:SendSignal(TransitionType.Ready_Running)
end

function M:OnRunningEnter()
	if not self.isCountDownPlaying then
		self.bindData.countDown:Play(self.gameTime)

		self.isCountDownPlaying = true
	end
end

function M:OnRunningUpdate()
	self:HandleAutoLoopRolling()
end

function M:OnOfflineEnter()
	return
end

function M:OnOfflineExit()
	return
end

function M:OnFailEnter()
	self.nowLife = self.nowLife - 1
	self.bindData.lifeText = string.format("%d/%d", self.maxLife - self.nowLife, self.maxLife)

	if self.nowLife <= 0 then
		self.isSettleSuccess = false

		self.gameFSM:SendSignal(TransitionType.Fail_Settle)

		return
	end

	self.autoRollingCol[self.nowSelectCol] = true

	self:RefreshNowSelectCol()

	self.finishCol[self.nowSelectCol] = false
	self.autoRollingCol[self.nowSelectCol] = true

	self:ReGenOneListData(self.gameRandomData[self.nowSelectCol], self.nowKeyword[self.nowSelectCol])

	if self.isInSkill then
		self:ChangeRandomDataToKey(self.nowKeyword[self.nowSelectCol], self.hackSkillHackNum, self.gameRandomData[self.nowSelectCol])
	else
		self.needRecoverCol[self.nowSelectCol] = false
	end

	self.underCtrlColList:SetList(self.gameRandomData[self.nowSelectCol])
	self:HandleAutoLoopRolling()
	self.gameFSM:SendSignal(TransitionType.Fail_Running)
end

function M:OnSuccessEnter()
	self.finishCol[self.nowSelectCol] = true

	if self.nowSelectCol < COL_NUM then
		self.nowSelectCol = self.nowSelectCol + 1
	elseif self.levelNum <= self.nowLevel then
		self.isSettleSuccess = true

		self.gameFSM:SendSignal(TransitionType.Success_Settle)

		return
	else
		self:GoToNextLevel()
		self:RefreshLevel()
		self:RefreshNowKeyword()
		self:GenGameRandomData()
		self:SetLoopListData()
	end

	self:RefreshNowSelectCol()
	self:HandleAutoLoopRolling()
	self.gameFSM:SendSignal(TransitionType.Success_Running)
end

function M:OnSettleEnter()
	if self.isSettleSuccess then
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = 1

			if self.overStore then
				self.overStore.ani:Play("S_Vx_HackerArcadeOver_open")

				self.overStore.replayCtrl = 0
			end

			self.settleCloseTimer = gLuaTimeMgrUtils.Delay(function ()
				gMessageManager:SendMessage(gEventConstants.HACKER_GAME_SUCCESS, {
					gameType = 1,
					entityId = self.entityId
				})

				if self.isCheckShow then
					gPanelManager:Close(self.m_Id)
				else
					gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
						closeSelf = self.closeWithComputer,
						closeWithAppOpen = self.closeWithAppOpen
					})
				end
			end, PoiGameConfig.KeyCrack_EndTime)
		end, PoiGameConfig.KeyCrack_EndDelay)
	elseif self.canRestart then
		self.isCountDownPlaying = false

		self.bindData.countDown:Stop()
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = 2

			if self.overStore then
				local clip = self.overStore.ani:GetClip("S_Vx_HackerArcadeOver_open")

				self.overStore.ani:Play("S_Vx_HackerArcadeOver_open")
				gLuaTimeMgrUtils.Delay(function ()
					self.overStore.replayCtrl = 1
				end, clip.length)

				function self.overStore.replayBtn.luaClick()
					self.bindData.successCtrl = 0

					self.gameFSM:SendSignal(TransitionType.Settle_Ready)
				end
			end
		end, PoiGameConfig.KeyCrack_EndDelay)
	else
		self.overStore.replayCtrl = 0

		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = 2

			if self.overStore then
				self.overStore.ani:Play("S_Vx_HackerArcadeOver_open")
			end

			self.settleCloseTimer = gLuaTimeMgrUtils.Delay(function ()
				gMessageManager:SendMessage(gEventConstants.HACKER_GAME_FAIL, {
					gameType = 1,
					entityId = self.entityId
				})

				if self.isCheckShow then
					gPanelManager:Close(self.m_Id)
				else
					gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
						closeSelf = self.closeWithComputer or self.closeWithAppOpen ~= ComputerConfig.HackOpenAppType.none
					})
				end
			end, PoiGameConfig.KeyCrack_EndTime)
		end, PoiGameConfig.KeyCrack_EndDelay)
	end
end

function M:GMPass()
	gMessageManager:SendMessage(gEventConstants.HACKER_GAME_SUCCESS, {
		gameType = 1,
		entityId = self.entityId
	})
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
		closeSelf = self.closeWithComputer,
		closeWithAppOpen = self.closeWithAppOpen
	})
end
