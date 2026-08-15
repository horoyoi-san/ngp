local DOTween = DOTween
local Ease = DG.Tweening.Ease
local ComputerConfig = LTConfig.ComputerConfig
local ComputerAppConfig = LTConfig.ComputerAppConfig
local PoiGameConfig = LTConfig.PoiGameConfig
local PoiGameHackMinigameConfig = LTConfig.PoiGameHackMinigameConfig
local StateType = {
	Settle = 7,
	Offline = 4,
	Fail = 5,
	Success = 6,
	Ready = 1,
	Running = 3,
	Show = 2
}
local TransitionType = {
	Settle_Ready = 12,
	Running_Fail = 3,
	Show_Settle = 11,
	Running_Settle = 10,
	Fail_Running = 5,
	Fail_Settle = 6,
	Success_Show = 9,
	Show_Running = 2,
	Success_Settle = 8,
	Ready_Show = 1,
	Running_Success = 4,
	Success_Running = 7
}
local EMPTY_TABLE = {}
local DEFAULT_COL_NUM = 6
local DEFAULT_ROW_NUM = 5
local MAX_COL_NUM = 6
local MAX_ROW_NUM = 5
local DEFAULT_SPEED = 5
local DEFAULT_LEVEL_NUM = 4
local DEFAULT_LIFE = 6
local DEFAULT_GAME_TIME = 300
local INVALID_PLACEHOLDER = -1
local WRONG_PLACEHOLDER = 0
local CORRECT_PLACEHOLDER = 1
local DEFAULT_HACK_SKILL_CUE_INTERVAL = 2
local DEFAULT_SKILL_DURATION_TIME = 6
local DEFAULT_HACK_SKILL_CD = 10
local DEFAULT_TWINKLE_TIMES = 3
local DEFAULT_TWINKLE_SHOW_TIME = 0.5
local DEFAULT_TWINKLE_HIDE_TIME = 0.1

local function GET_INDEX_ROW_NUM(n)
	return math.floor((n - 1) / MAX_COL_NUM) + 1
end

local function GET_INDEX_COL_NUM(n)
	return (n - 1) % MAX_COL_NUM + 1
end

local function IS_INDEX_OUT_OF_GAME_RANGE(col, row, index)
	local realCol = GET_INDEX_COL_NUM(index)
	local realRow = GET_INDEX_ROW_NUM(index)

	return col < realCol or row < realRow
end

C_HackerSignalMappingPanelStore = DefClass("C_HackerSignalMappingPanelStore", C_HackerSignalMappingPanelStore, C_StoreGroup)
GroupName2Class.HackerSignalMappingPanelStore = C_HackerSignalMappingPanelStore
local M = C_HackerSignalMappingPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.entityId = 0
	self.isCheckShow = true
	self.isCountDownPlaying = false
	self.colNum = DEFAULT_COL_NUM
	self.colNums = nil
	self.rowNum = DEFAULT_ROW_NUM
	self.rowNums = nil
	self.speed = DEFAULT_SPEED
	self.levelNum = DEFAULT_LEVEL_NUM
	self.gameTime = DEFAULT_GAME_TIME
	self.hackSkillCueInterval = DEFAULT_HACK_SKILL_CUE_INTERVAL
	self.keyword = INVALID_PLACEHOLDER
	self.twinkleTimes = DEFAULT_TWINKLE_TIMES
	self.twinkleShowTime = DEFAULT_TWINKLE_SHOW_TIME
	self.twinkleHideTime = DEFAULT_TWINKLE_HIDE_TIME
	self.finishCol = {}
	self.nowLevel = 0
	self.nowLife = 0
	self.maxLife = DEFAULT_LIFE
	self.selectedIndex = 0
	self.gameRandomData = {}
	self.gameExpandData = {}
	self.signalStore = {}
	self.correctPos = {}
	self.isInSkill = false
	self.demonstrateTween = nil
	self.hackSkillBtnTween = nil
	self.hackSkillTween = nil
	self.successTransferTimer = nil
	self.settleCloseTimer = nil
	self.closeWithComputer = false
	self.closeWithAppOpen = nil
	self.canExitDirectly = false
	self.listRowSpacing = 10
	self.listColSpacing = 10
	self.isDestroy = false
	self.bgStore = nil
	self.overStore = nil
	self.guideId = 0
	self.isInGuide = false
	self.skillHackId = 0
	self.levelDatas = {}
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
	self.colNums = data.cols
	self.rowNums = data.rows
	self.speed = data.speed or DEFAULT_SPEED
	self.levelNum = data.levelNum or DEFAULT_LEVEL_NUM
	self.gameTime = data.gameTime or DEFAULT_GAME_TIME
	self.maxLife = data.hp or DEFAULT_LIFE
	self.keyword = data.keyword or INVALID_PLACEHOLDER
	self.hackSkillCueInterval = data.hackSkillCueInterval or DEFAULT_HACK_SKILL_CUE_INTERVAL
	self.hackSkillTime = data.hackSkillTime or DEFAULT_SKILL_DURATION_TIME
	self.hackSkillCD = data.hackSkillCD or DEFAULT_HACK_SKILL_CD
	self.twinkleTimes = data.twinkleTimes or DEFAULT_TWINKLE_TIMES
	self.twinkleShowTime = data.twinkleShowTime or DEFAULT_TWINKLE_SHOW_TIME
	self.twinkleHideTime = data.twinkleHideTime or DEFAULT_TWINKLE_HIDE_TIME
	self.skillHackId = PoiGameConfig.SigCrack_SkillCost
	self.listRowSpacing = self.bindData.gameList.rowSpacing
	self.listRowSpacing = self.bindData.gameList.colSpacing

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
				if gameAppCfg[i].appId == ComputerAppConfig.hacker2 then
					gameConfigId = gameAppCfg[i].hackgameId

					break
				end
			end
		end

		local gameConfig = PoiGameHackMinigameConfig.GetConfig(gameConfigId)
		data = {
			rows = gameConfig.Row,
			cols = gameConfig.Column,
			speed = gameConfig.MemoryTime,
			levelNum = gameConfig.PlayCount,
			keywords = gameConfig.Password,
			gameTime = gameConfig.Time,
			hp = gameConfig.Hp,
			hackSkillTime = PoiGameConfig.SigCrack_HackSkill[1],
			hackSkillCueInterval = PoiGameConfig.SigCrack_HackSkill[2],
			hackSkillCD = PoiGameConfig.SigCrack_HackSkill[3],
			twinkleHideTime = gameConfig.BlinkHideDuration,
			twinkleShowTime = gameConfig.BlinkShowDuration,
			twinkleTimes = gameConfig.BlinkCount
		}
		skillText = PoiGameConfig.SigCrack_SkillText
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
			self.skillStore:RegisterSkillWithTimeGet(skillText, self:CreateAction("OnClickHackSkillBtn"), self:CreateAction("GetReDemonstrateTime"), self.skillHackId)
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
	self.isDestroy = true

	if self.gameFSM then
		self.gameFSM:Dispose()

		self.gameFSM = nil
	end

	gLuaTimeMgrUtils.CancelUnitDelay(self.settleCloseTimer)
	gLuaTimeMgrUtils.CancelUnitDelay(self.successShowTimer)
	gLuaTimeMgrUtils.CancelUnitDelay(self.successTransferTimer)

	self.settleCloseTimer = nil
	self.successShowTimer = nil
	self.successTransferTimer = nil

	if self.demonstrateTween then
		self.demonstrateTween:Kill()

		self.demonstrateTween = nil
	end

	if self.hackSkillTween then
		self.hackSkillTween:Kill()

		self.hackSkillTween = nil
	end

	if self.hackSkillBtnTween then
		self.hackSkillBtnTween:Kill()

		self.hackSkillBtnTween = nil
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

			self.gameFSM:SendSignal(TransitionType.Ready_Show)
		end
	}
end

function M:RegisterWidget()
	self.bindData.levelList.luaSimpleRenderItem = self:CreateAction("OnRenderLevelListItem")
	self.bindData.gameList.luaSimpleRenderItem = self:CreateAction("OnRenderGameListItem")
	self.bindData.gameList.luaSimpleClick = self:CreateAction("OnClickGameList")
	self.bindData.countDown.luaFinished = self:CreateAction("OnCountDownFinish")
end

function M:OnClickHackSkillBtn()
	if self.gameFSM:GetCurrentState() ~= StateType.Running then
		return
	end

	math.randomseed(os.time())
	self:SignalReDemonstrate()
end

function M:OnRenderLevelListItem(btn, index)
	local data = self.levelDatas[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SignalMappingLevelTemplate"):GetStoreById(id)

	if store then
		local level = data.level

		if level < self.nowLevel then
			store.levelStageCtrl = 1
		else
			store.levelStageCtrl = 0
		end

		store.levelText = data.char
	end
end

function M:OnRenderGameListItem(btn, index)
	local data = self.gameExpandData[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SignalMappingTemplate"):GetStoreById(id)

	if store then
		if data.content == INVALID_PLACEHOLDER then
			store.signalCtrl = 4
			btn.interactable = false
		else
			store.signalCtrl = 0
			btn.interactable = true
		end

		store:EnableImmediatelyCommit(true)

		self.signalStore[data.pos] = store
		local width = store.twinkleBtn:GetTargetWidth()
		local col = index % MAX_COL_NUM + 1
		local row = math.floor(index / MAX_COL_NUM) + 1
		local x1 = -(col - (MAX_COL_NUM + 1) / 2) * (width + self.listColSpacing) * 0.1
		local y1 = (row - (MAX_ROW_NUM + 1) / 2) * (width + self.listRowSpacing) * 0.1

		store.child1Btn.gameObject.transform:SetLocalPositionXY(x1, y1)

		local x2 = -(col - (MAX_COL_NUM + 1) / 2) * (width + self.listColSpacing) * 0.2
		local y2 = (row - (MAX_ROW_NUM + 1) / 2) * (width + self.listRowSpacing) * 0.2

		store.child2Btn.gameObject.transform:SetLocalPositionXY(x2, y2)
	end
end

function M:OnClickGameList(btn, index)
	local data = self.gameExpandData[index + 1]

	if self.gameFSM:GetCurrentState() ~= StateType.Running then
		return
	end

	if self.isInSkill then
		return
	end

	local pos = data.pos

	if self.signalStore[data.pos].signalCtrl == 4 or self.signalStore[data.pos].signalCtrl == 3 then
		return
	end

	if self.gameRandomData[pos] == INVALID_PLACEHOLDER then
		return
	elseif self.gameRandomData[pos] == WRONG_PLACEHOLDER then
		if self.bgStore then
			self.bgStore.ani:Play("S_Vx_HackerArcadeBgTemplate_Error")
		end

		self.selectedIndex = pos

		self.gameFSM:SendSignal(TransitionType.Running_Fail)
		gSoundMgr:PlaySoundByTid(70601385)

		return
	elseif self.gameRandomData[pos] == CORRECT_PLACEHOLDER then
		self.selectedIndex = pos

		self.gameFSM:SendSignal(TransitionType.Running_Success)
		gSoundMgr:PlaySoundByTid(70601386)

		return
	end
end

function M:OnCountDownFinish()
	self.isSettleSuccess = false

	self.gameFSM:SendSignal(TransitionType.Running_Settle)
end

function M:ResetGameState()
	table.clear(self.finishCol)

	for i = 1, self.colNum do
		self.finishCol[i] = false
	end

	self.nowLevel = 1
	self.nowLife = self.maxLife
	self.bindData.lifeText = string.format("%d/%d", self.maxLife - self.nowLife, self.maxLife)

	if not gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, 52606114) then
		self.bindData.canSkillCtrl = 1
	else
		self.bindData.canSkillCtrl = 0
	end
end

local function CHECK_KEYWORD_DECIMALS(s)
	return s == "0" and 1 or #s
end

local function GEN_RANDOM_KEYWORD(decimals)
	if type(decimals) ~= "number" or decimals < 1 then
		return "0"
	end

	local digits = ""

	for i = 1, decimals do
		digits = digits .. tostring(math.random(0, 9))
	end

	return digits
end

function M:RefreshLevel()
	if not self.levelNum or self.levelNum < 0 then
		print_error("关卡数异常,需要修改!levelNum = ", self.levelNum)

		return
	end

	if self.keyword ~= INVALID_PLACEHOLDER and CHECK_KEYWORD_DECIMALS(self.keyword) ~= self.levelNum then
		print_error("关卡数和密码位数不符,需要修改!")

		return
	end

	if self.keyword == INVALID_PLACEHOLDER then
		math.randomseed(os.time())

		self.keyword = GEN_RANDOM_KEYWORD(self.levelNum)
	end

	self.levelDatas = {}

	for i = 1, self.levelNum do
		local char = self.keyword:sub(i, i)
		local data = {
			char = char,
			level = i
		}

		table.insert(self.levelDatas, data)
	end

	self.bindData.levelList:SetSimpleList(#self.levelDatas)

	self.colNum = self.colNums and self.colNums[self.nowLevel] or DEFAULT_COL_NUM
	self.rowNum = self.rowNums and self.rowNums[self.nowLevel] or DEFAULT_ROW_NUM
end

local function GEN_RANDOM_SIGNAL_POS(col, row, result)
	for i = 1, col do
		local rrow = math.random(1, row)
		local position = (rrow - 1) * MAX_COL_NUM + i
		result[position] = true
	end

	return result
end

function M:GenGameRandomData()
	math.randomseed(os.time())

	local totalNum = MAX_COL_NUM * MAX_ROW_NUM

	table.clear(self.gameExpandData)
	table.clear(self.correctPos)
	GEN_RANDOM_SIGNAL_POS(self.colNum, self.rowNum, self.gameExpandData)

	for i = 1, totalNum do
		if not IS_INDEX_OUT_OF_GAME_RANGE(self.colNum, self.rowNum, i) then
			if self.gameExpandData[i] then
				table.insert(self.correctPos, i)

				self.gameRandomData[i] = CORRECT_PLACEHOLDER
			else
				self.gameRandomData[i] = WRONG_PLACEHOLDER
			end
		else
			self.gameRandomData[i] = INVALID_PLACEHOLDER
		end
	end

	table.clear(self.gameExpandData)
	table.sort(self.correctPos, function (a, b)
		return GET_INDEX_COL_NUM(a) < GET_INDEX_COL_NUM(b)
	end)

	for i, v in ipairs(self.gameRandomData) do
		local data = {
			content = v,
			pos = i
		}

		table.insert(self.gameExpandData, data)
	end

	self.bindData.gameList:SetSimpleList(#self.gameExpandData)
end

function M:GetReDemonstrateTime()
	local perShowTime = self.hackSkillCueInterval
	local needReshine = 0
	local needShineDic = {}

	for i = 1, self.colNum do
		if not self.finishCol[i] then
			needReshine = needReshine + 1
			needShineDic[i] = true
		end
	end

	self.isInSkill = true
	local totalTime = needReshine * perShowTime

	return totalTime
end

function M:StartSignalDemonstrate()
	local perShowTime = self.speed / self.colNum
	local showCol = 1
	self.demonstrateTween = DOTween.To(function ()
		return 0
	end, function (value)
		if value >= (showCol - 1) * perShowTime then
			if showCol <= self.colNum then
				self.signalStore[self.correctPos[showCol]].signalCtrl = 1
			end

			showCol = showCol + 1
		end
	end, self.speed, self.speed):SetEase(Ease.Linear):OnComplete(function ()
		for i = 1, self.colNum do
			self.signalStore[self.correctPos[i]].twinkleBtn.renderOpacity = 0
		end

		self:DoSignalTwinkle()
	end)
end

function M:DoSignalTwinkle()
	local totalTime = self.twinkleTimes * (self.twinkleShowTime + self.twinkleHideTime)

	for i = 1, self.colNum do
		for j = 1, self.twinkleTimes do
			self:DoSingleTwinkle(self.signalStore[self.correctPos[i]], j)
		end
	end

	gLuaTimeMgrUtils.Delay(function ()
		if self.isDestroy then
			return
		end

		for i = 1, self.colNum do
			self.signalStore[self.correctPos[i]].signalCtrl = 0
			self.signalStore[self.correctPos[i]].twinkleBtn.renderOpacity = 1
		end

		if self.gameFSM then
			self.gameFSM:SendSignal(TransitionType.Show_Running)
		end
	end, totalTime + 0.01)
end

function M:DoSingleTwinkle(store, times)
	gLuaTimeMgrUtils.Delay(function ()
		if self.isDestroy then
			return
		end

		store.twinkleBtn.renderOpacity = 1

		gLuaTimeMgrUtils.Delay(function ()
			if self.isDestroy then
				return
			end

			if times ~= self.twinkleTimes then
				store.twinkleBtn.renderOpacity = 0
			end
		end, self.twinkleShowTime)
	end, self.twinkleHideTime * times + self.twinkleShowTime * (times - 1))
end

function M:DoSuccessTransferInterval(signal)
	self.successShowTimer = gLuaTimeMgrUtils.Delay(function ()
		if signal == TransitionType.Success_Show then
			self:GenGameRandomData()
			table.clear(self.finishCol)
		end
	end, 1)
	self.successTransferTimer = gLuaTimeMgrUtils.Delay(function ()
		self.gameFSM:SendSignal(signal)
	end, 2)
end

local tmpTable = {}

function M:ExcludeOneIncorrect()
	table.clear(tmpTable)

	local selectCol = self.colNum + 1

	for i = 1, self.colNum do
		if not self.finishCol[i] then
			selectCol = i

			break
		end
	end

	local function rFun()
		table.clear(tmpTable)

		for i = 1, self.rowNum do
			local pos = selectCol + (i - 1) * MAX_COL_NUM

			if self.signalStore[pos].signalCtrl == 0 and self.gameRandomData[pos] == WRONG_PLACEHOLDER then
				table.insert(tmpTable, pos)
			end
		end
	end

	while #tmpTable == 0 and selectCol <= self.colNum do
		rFun()

		if #tmpTable == 0 then
			selectCol = selectCol + 1

			while self.finishCol[selectCol] and selectCol <= self.colNum do
				selectCol = selectCol + 1
			end
		end
	end

	if #tmpTable > 0 then
		local select = math.random(#tmpTable)
		self.signalStore[tmpTable[select]].signalCtrl = 3
	end
end

function M:SignalReDemonstrate()
	local perShowTime = self.hackSkillCueInterval
	local needReshine = 0
	local needShineDic = {}

	for i = 1, self.colNum do
		if not self.finishCol[i] then
			needReshine = needReshine + 1
			needShineDic[i] = true
		end
	end

	self.isInSkill = true
	local totalTime = needReshine * perShowTime
	local showColNum = 1
	local lastCol = 0
	self.SkillReshineTween = DOTween.To(function ()
		return 0
	end, function (value)
		if value >= (showColNum - 1) * perShowTime then
			if needReshine < showColNum then
				self.signalStore[self.correctPos[lastCol]].signalCtrl = 0
			else
				if lastCol ~= 0 then
					self.signalStore[self.correctPos[lastCol]].signalCtrl = 0
				end

				local col = nil

				while true do
					col = math.random(1, self.colNum)

					if needShineDic[col] then
						break
					end
				end

				self.signalStore[self.correctPos[col]].signalCtrl = 1
				needShineDic[col] = false
				lastCol = col
				showColNum = showColNum + 1
			end
		end
	end, totalTime, totalTime):SetEase(Ease.Linear):OnComplete(function ()
		self.isInSkill = false
		self.signalStore[self.correctPos[lastCol]].signalCtrl = 0
	end)
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
	self:GenGameRandomData()

	if self.guideId ~= 0 and gNewGuideMgr.activeGuideBT and gNewGuideMgr.activeGuideBT.guideId == self.guideId or gPanelManager:IsPanelShowing(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS) then
		self.isInGuide = true

		return
	end

	self.gameFSM:SendSignal(TransitionType.Ready_Show)
end

function M:OnReadyExit()
	if not self.isCountDownPlaying then
		self.bindData.countDown:Play(self.gameTime)

		self.isCountDownPlaying = true
	end
end

function M:OnShowEnter()
	if self.skillStore then
		self.skillStore:SetSkillCanUse(false)
	end

	self:StartSignalDemonstrate()
end

function M:OnRunningEnter()
	if self.skillStore then
		self.skillStore:SetSkillCanUse(true)
	end
end

function M:OnFailEnter()
	self.signalStore[self.selectedIndex].signalCtrl = 3
	self.nowLife = self.nowLife - 1
	self.bindData.lifeText = string.format("%d/%d", self.maxLife - self.nowLife, self.maxLife)

	if self.nowLife <= 0 then
		self.isSettleSuccess = false

		self.gameFSM:SendSignal(TransitionType.Fail_Settle)

		return
	end

	self.gameFSM:SendSignal(TransitionType.Fail_Running)
end

function M:OnSuccessEnter()
	self.signalStore[self.selectedIndex].signalCtrl = 2
	local col = GET_INDEX_COL_NUM(self.selectedIndex)
	self.finishCol[col] = true
	local isAllFinish = true

	for i = 1, self.colNum do
		if not self.finishCol[i] then
			isAllFinish = false
		end
	end

	if isAllFinish then
		if self.levelNum <= self.nowLevel then
			self.nowLevel = self.nowLevel + 1

			self.bindData.levelList:RefreshList()

			self.isSettleSuccess = true

			self:DoSuccessTransferInterval(TransitionType.Success_Settle)

			return
		else
			self.nowLevel = self.nowLevel + 1

			self.bindData.levelList:RefreshList()

			self.colNum = self.colNums and self.colNums[self.nowLevel] or DEFAULT_COL_NUM
			self.rowNum = self.rowNums and self.rowNums[self.nowLevel] or DEFAULT_ROW_NUM

			if self.skillStore then
				self.skillStore:SetSkillCanUse(false)
			end

			self:DoSuccessTransferInterval(TransitionType.Success_Show)
		end
	else
		self.gameFSM:SendSignal(TransitionType.Success_Running)
	end
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
					gameType = 2,
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
			end, PoiGameConfig.SigCrack_EndTime)
		end, PoiGameConfig.SigCrack_EndDelay)
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
		end, PoiGameConfig.SigCrack_EndDelay)
	else
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.successCtrl = 2

			if self.overStore then
				self.overStore.ani:Play("S_Vx_HackerArcadeOver_open")
			end

			self.settleCloseTimer = gLuaTimeMgrUtils.Delay(function ()
				gMessageManager:SendMessage(gEventConstants.HACKER_GAME_FAIL, {
					gameType = 2,
					entityId = self.entityId
				})

				if self.isCheckShow then
					gPanelManager:Close(self.m_Id)
				else
					gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
						closeSelf = self.closeWithComputer or self.closeWithAppOpen ~= ComputerConfig.HackOpenAppType.none
					})
				end
			end, PoiGameConfig.SigCrack_EndTime)
		end, PoiGameConfig.SigCrack_EndDelay)
	end
end

function M:GMPass()
	gMessageManager:SendMessage(gEventConstants.HACKER_GAME_SUCCESS, {
		gameType = 2,
		entityId = self.entityId
	})
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE, {
		closeSelf = self.closeWithComputer,
		closeWithAppOpen = self.closeWithAppOpen
	})
end
