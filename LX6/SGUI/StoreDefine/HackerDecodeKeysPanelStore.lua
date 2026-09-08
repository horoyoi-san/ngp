-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerDecodeKeysPanelStore.lua
-- Decompiled from: 01700_HackerDecodeKeysPanelStore.lua_fe6bb98f90a8.luajit

local DOTween = DOTween
local Ease = DG.Tweening.Ease
local ComputerConfig = LTConfig.ComputerConfig
local ComputerAppConfig = LTConfig.ComputerAppConfig
local PoiGameConfig = LTConfig.PoiGameConfig
local PoiGameHackMinigameConfig = LTConfig.PoiGameHackMinigameConfig
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

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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

M.OnShow = function(self, panelId, data)
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

M.ShowPanel = function(self, computerId, entityId)
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
				if gameAppCfg[i].appId ~= ComputerAppConfig.hacker1 then
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

M.OnClose = function(self)
	self.gameFSM:Dispose()

	self.gameFSM = nil
end

M.OnDestroy = function(self)
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
	self.bindData.hackBtn.luaClick = self.CreateAction(self, "OnClickHackBtn")
	self.bindData.levelList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderLevelListItem")

	for i = 1, COL_NUM do
		self.bindData["gameList" .. i].luaSimpleRenderItem = self.CreateActionWithArgs(self, "OnRenderGameListItem", i)
	end

	self.bindData.countDown.luaFinished = self.CreateAction(self, "OnCountDownFinish")
end

M.OnClickHackBtn = function(self)
	if self.isAnimBlocking then
		return
	end

	if self.gameFSM:GetCurrentState() == StateType.Running then
		return
	end

	self.autoRollingCol[self.nowSelectCol] = false
	local btn = self.underCtrlColList:GetCurNearestCenterItem()
	local index = self.underCtrlColList:GetChildIndex(btn)
	local offset = self.underCtrlColList:GetItemToCenterOffset(btn)
	local extraIndex = offset >= 0 and (index - 1) % self.numPerCol or (index + 1) % self.numPerCol
	local nowData = self.gameRandomData[self.nowSelectCol][index + 1][1]

	if nowData == self.nowKeyword[self.nowSelectCol] then
		local extraData = self.gameRandomData[self.nowSelectCol][extraIndex + 1][1]

		if extraData ~= self.nowKeyword[self.nowSelectCol] then
			btn = self.underCtrlColList:GetChildAt(extraIndex)
		end
	elseif offset <= 0 then
		local extraData = self.gameRandomData[self.nowSelectCol][extraIndex + 1][1]

		if extraData ~= self.nowKeyword[self.nowSelectCol] then
			btn = self.underCtrlColList:GetChildAt(extraIndex)
		end
	end

	self.HandleSelectAnim(self, btn)
end

M.OnClickHackSkillBtn = function(self)
	if self.gameFSM:GetCurrentState() == StateType.Running then
		return
	end

	self.isInSkill = true

	table.clear(self.needRecoverCol)

	for i = self.nowSelectCol, COL_NUM do
		self.needRecoverCol[i] = true

		self.ChangeRandomDataToKey(self, self.nowKeyword[i], self.hackSkillHackNum, self.gameRandomData[i])
	end

	self.hackSkillTimer = gLuaTimeMgrUtils.Delay(function ()
		if self.gameFSM:GetCurrentState() == StateType.Running then
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

M.OnRenderLevelListItem = function(self, btn, index)
	local data = self.levelsList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("DecodeKeyLevelTemplate"):GetStoreById(id)

	if store then
		store.levelStageCtrl = data.isFinish and 1 or 0
	end
end

M.OnRenderGameListItem = function(self, col, btn, index)
	local data = self.gameRandomData[col][index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("DecodeKeyTemplate"):GetStoreById(id)

	if store then
		local colKey = self.nowKeyword[col]
		local key = data[1]

		if key ~= colKey then
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

M.OnCountDownFinish = function(self)
	self.isSettleSuccess = false

	self.gameFSM:SendSignal(TransitionType.Running_Settle)
end

local IS_VALID_UPPERCASE_WORD = function(word)
	return type(word) ~= "string" and #word ~= 8 and word:match("^[A-Z]+$") == nil
end

local GEN_RANDOM_KEYWORD = function()
	local keywordsPool = PoiGameConfig.KeyCrack_CodePool

	return keywordsPool[math.random(#keywordsPool)]
end

M.GetOrGenKeywords = function(self, data)
	math.randomseed(os.time())

	local result = {}
	local levelNum = self.levelNum
	local keywords = data.keywords

	if not keywords then
		for i = 1, levelNum do
			table.insert(result, GEN_RANDOM_KEYWORD())
		end
	elseif #keywords == levelNum then
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

M.ResetGameState = function(self)
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

	self.bindData.levelList:SetSimpleList(#self.levelsList)

	self.numPerCol = self.numPerCols and self.numPerCols[self.nowLevel] or DEFAULT_NUM_PER_COL
	self.speed = self.speeds and self.speeds[self.nowLevel] or DEFAULT_SPEED
end

M.RefreshNowKeyword = function(self)
	table.clear(self.nowKeyword)

	local nowKeyword = self.keywords[self.nowLevel]

	for i = 1, #nowKeyword do
		self.nowKeyword[i] = nowKeyword.sub(nowKeyword, i, i)
	end
end

local reusableTable = {}

local SELECT_RANDOM_FROM_CONTINUOUS_SET = function(x, y, result)
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

local FILL_UNIQUE_LETTERS = function(array, thisColKey)
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
		if thisColKey ~= letterSet[pointer] then
			pointer = pointer + 1
		end

		if v ~= INVALID_PLACEHOLDER then
			array[i] = {
				letterSet[pointer]
			}
		elseif v[1] ~= INVALID_PLACEHOLDER then
			array[i][1] = letterSet[pointer]
		end

		pointer = pointer + 1
	end
end

local COL_NEED_SHOW_SET = {}

M.GenGameRandomData = function(self)
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
		if COL_NEED_SHOW_SET[i] ~= i then
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

M.SetLoopListData = function(self)
	for i = 1, COL_NUM do
		self.bindData["gameList" .. i]:SetSimpleList(#self.gameRandomData[i])

		self.autoRollingCol[i] = true
		self.rollPos[i] = 0
	end

	self.contentHeight = self.bindData.gameList1:GetContentHeight()
end

M.GoToNextLevel = function(self)
	table.clear(self.finishCol)

	self.nowLevel = self.nowLevel + 1
	self.nowSelectCol = 1
end

M.ChangeRandomDataToKey = function(self, key, num, data)
	local length = #data
	local counter = 1

	while num > counter do
		local pos = math.random(length)

		if data[pos][1] == key then
			data[pos][1] = key
			counter = counter + 1
		end
	end
end

M.ReGenOneListData = function(self, data, key)
	local pos = math.random(#data)

	for i = 1, self.numPerCol do
		data[i][1] = INVALID_PLACEHOLDER
	end

	data[pos][1] = key

	FILL_UNIQUE_LETTERS(data, key)
end

local SHARED_POS = Vector2.New(0, 0)

M.HandleAutoLoopRolling = function(self)
	for i = 1, COL_NUM do
		if self.autoRollingCol[i] then
			self.rollPos[i] = (self.rollPos[i] + self.speed * Time.deltaTime) % self.contentHeight
			SHARED_POS.y = self.rollPos[i]

			self.bindData["gameList" .. i]:GoToPos(SHARED_POS, true)
		end
	end
end

M.RefreshNowSelectCol = function(self)
	self.underCtrlColList = self.bindData["gameList" .. self.nowSelectCol]

	self.bindData.colHintTrans:SetPosition(self.underCtrlColList.transform.position.x, self.underCtrlColList.transform.position.y, self.underCtrlColList.transform.position.z)
end

M.GetNowListCenterKey = function(self)
end

M.HandleSelectAnim = function(self, btn)
	self.isCountDownPlaying = false
	slot2 = self.bindData.countDown

	slot2:Stop()

	slot2 = self.underCtrlColList
	local offset = slot2:GetItemToCenterOffset(btn)
	local originalPos = self.rollPos[self.nowSelectCol]
	self.rollPos[self.nowSelectCol] = self.rollPos[self.nowSelectCol] - offset
	self.isAnimBlocking = true
	slot4 = DOTween.To(function ()
		return originalPos
	end, function (value)
		originalPos = value
		SHARED_POS.y = originalPos

		if not gClientUtils.IsNil(self.underCtrlColList) then
			self.underCtrlColList:GoToPos(SHARED_POS, true)
		end
	end, self.rollPos[self.nowSelectCol], 0.2)
	slot4 = slot4:SetEase(Ease.Linear)

	slot4:OnComplete(function ()
		self:HandleSelectResult(btn)
	end)
end

M.HandleSelectResult = function(self, btn)
	if self.gameFSM:GetCurrentState() == StateType.Running then
		self.isAnimBlocking = false

		return
	end

	local index = self.underCtrlColList:GetChildIndex(btn)
	local key = self.gameRandomData[self.nowSelectCol][index + 1][1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("DecodeKeyTemplate"):GetStoreById(id)

	if store then
		if key == self.nowKeyword[self.nowSelectCol] then
			store.keyStatusCtrl = 1

			if self.bgStore then
				self.bgStore.ani:Play("S_Vx_HackerArcadeBgTemplate_Error")
			end

			self.failPhaseTimer = gLuaTimeMgrUtils.Delay(function ()
				self.isAnimBlocking = false
				store.keyStatusCtrl = 0

				if self.gameFSM:GetCurrentState() == StateType.Running then
					return
				end

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

M.TryClose = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
		["@KczK->"] = true
	})
end

M.GetFSMStateInitParams = function(self, name)
	return StateType[name], self[string.format("On%sEnter", name)], self[string.format("On%sExit", name)], self[string.format("On%sUpdate", name)]
end

local result = {}

M.GetFSMTransitionInitParams = function(self, name)
	table.clear(result)

	for word in string.gmatch(name, "([^_]+)") do
		table.insert(result, word)
	end

	return StateType[result[1]], StateType[result[2]], TransitionType[name], self[string.format("On%sTo%sCheck", result[1], result[2])], self[string.format("On%sTo%sTransition", result[1], result[2])]
end

M.InitFSM = function(self)
	self.gameFSM = gFSMManager:GetFSM(self)

	for name, _ in pairs(StateType) do
		self.gameFSM:AddState(self:GetFSMStateInitParams(name))
	end

	for name, _ in pairs(TransitionType) do
		self.gameFSM:AddTransition(self:GetFSMTransitionInitParams(name))
	end
end

M.OnReadyEnter = function(self)
	self.ResetGameState(self)
	self.RefreshLevel(self)
	self.RefreshNowKeyword(self)
	self.RefreshNowSelectCol(self)
	self.GenGameRandomData(self)
	self.SetLoopListData(self)

	if self.guideId == 0 and gNewGuideMgr.activeGuideBT and gNewGuideMgr.activeGuideBT.guideId ~= self.guideId or gPanelManager:IsPanelShowing(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS) then
		self.isInGuide = true

		return
	end

	self.gameFSM:SendSignal(TransitionType.Ready_Running)
end

M.OnRunningEnter = function(self)
	if not self.isCountDownPlaying then
		local currentSecond = self.bindData.countDown.currentSecond

		if currentSecond ~= 0 then
			self.bindData.countDown:Play(self.gameTime)
		else
			self.bindData.countDown:Play(currentSecond, self.gameTime)
		end

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

	self.autoRollingCol[self.nowSelectCol] = true

	self.RefreshNowSelectCol(self)

	self.finishCol[self.nowSelectCol] = false
	self.autoRollingCol[self.nowSelectCol] = true

	self.ReGenOneListData(self, self.gameRandomData[self.nowSelectCol], self.nowKeyword[self.nowSelectCol])

	if self.isInSkill then
		self.ChangeRandomDataToKey(self, self.nowKeyword[self.nowSelectCol], self.hackSkillHackNum, self.gameRandomData[self.nowSelectCol])
	else
		self.needRecoverCol[self.nowSelectCol] = false
	end

	self.underCtrlColList:SetSimpleList(#self.gameRandomData[self.nowSelectCol])
	self:HandleAutoLoopRolling()
	self.gameFSM:SendSignal(TransitionType.Fail_Running)
end

M.OnSuccessEnter = function(self)
	self.finishCol[self.nowSelectCol] = true

	if self.nowSelectCol >= COL_NUM then
		self.nowSelectCol = self.nowSelectCol + 1
	elseif self.levelNum < self.nowLevel then
		self.isSettleSuccess = true

		self.gameFSM:SendSignal(TransitionType.Success_Settle)

		return
	else
		self.GoToNextLevel(self)
		self.RefreshLevel(self)
		self.RefreshNowKeyword(self)
		self.GenGameRandomData(self)
		self.SetLoopListData(self)
	end

	self:RefreshNowSelectCol()
	self:HandleAutoLoopRolling()
	self.gameFSM:SendSignal(TransitionType.Success_Running)
end

M.OnSettleEnter = function(self)
	self.isCountDownPlaying = false

	self.bindData.countDown:Stop()

	if self.isSettleSuccess then
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = 1

			if self.overStore then
				self.overStore.ani:Play("S_Vx_HackerArcadeOver_open")

				self.overStore.replayCtrl = 0
			end

			self.settleCloseTimer = gLuaTimeMgrUtils.Delay(function ()
				gMessageManager:SendMessage(gEventConstants.HACKER_GAME_SUCCESS, {
					["\\xac\\xb0\\xae^'\\xee6"] = 1,
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
					["\\xac\\xb0\\xae^'\\xee6"] = 1,
					entityId = self.entityId
				})

				if self.isCheckShow then
					gPanelManager:Close(self.m_Id)
				else
					slot0 = gMessageManager
					slot2 = slot0
					slot0 = slot0.SendMessage
					slot3 = gEventConstants.ON_COMPUTER_APP_CLOSE
					slot4 = {}
					slot5 = self.closeWithComputer or self.closeWithAppOpen == ComputerConfig.HackOpenAppType.none
					slot4.closeSelf = slot5

					slot0(slot2, slot3, slot4)
				end
			end, PoiGameConfig.KeyCrack_EndTime)
		end, PoiGameConfig.KeyCrack_EndDelay)
	end
end

M.GMPass = function(self)
	gMessageManager:SendMessage(gEventConstants.HACKER_GAME_SUCCESS, {
		["\\xac\\xb0\\xae^'\\xee6"] = 1,
		entityId = self.entityId
	})
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
		closeSelf = self.closeWithComputer,
		closeWithAppOpen = self.closeWithAppOpen
	})
end
