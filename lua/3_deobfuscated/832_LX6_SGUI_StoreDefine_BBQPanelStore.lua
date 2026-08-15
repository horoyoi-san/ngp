C_BBQPanelStore = DefClass("C_BBQPanelStore", C_BBQPanelStore, C_StoreGroup)
GroupName2Class.BBQPanelStore = C_BBQPanelStore
local M = C_BBQPanelStore
local GameInputManager = LX6.Manager.GameInputManager
local Input = UnityEngine.Input

function M:ctor()
	self.isPrepare = false
	self.totalTime = 0
	self.prepareTime = 0
	self.isStart = false
	self.playerScoreDic = {}
	self.rankListData = {}
	self.saucePos = {}
	self.isPressing = false
	self.startPressPos = Vector2.zero
	self.hasTriggeredDrag = false
	self.pressPosThreshold = 1
end

function M:DefineAllVariables()
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
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:Init()
	self.bindData.prepareRoot:SetActive(true)
	self.bindData.FullBtn:SetActive(false)
	self.bindData.endPanel:SetActive(false)

	self.bindData.myScore = 0
	self.isPrepare = true
	self.bindData.timeProgress.value = self.bindData.timeProgress.maxValue
	self.isStart = true

	self.bindData.MeFeedback.gameObject:SetActive(false)
	self.bindData.P1Feedback.gameObject:SetActive(false)
	self.bindData.P2Feedback.gameObject:SetActive(false)
	self.bindData.P3Feedback.gameObject:SetActive(false)

	self.playerScoreDic = {
		[0] = 0,
		0,
		0,
		0
	}
	self.rankListData = {}
	self.isPressing = false
	self.startPressPos = Vector2.zero
	self.hasTriggeredDrag = false
	self.bindData.myName = gPlayerManager.infoLogin.bindData.name

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.BBQ_PANEL_STORE, true)
	GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay, false, UnityEngine.CursorLockMode.None)
end

function M:OnShow(panelId, data)
	self.prepareTime = data.prepareTime
	self.totalTime = data.seconds
	self.saucePos = data.saucePos:ToTable()

	self:Init()
end

function M:OnClose()
	self.isStart = false
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ON_SIMULATOR_GAME_TIMER_UP] = self:CreateAction("OnTimerUp"),
		[gEventConstants.SEND_BBQ_PLAYER_SINGLE_SCORE] = self:CreateAction("OnAddPlayerSingleScore"),
		[gEventConstants.ON_SIMULATOR_RESTART_GAME] = self:CreateAction("OnRestart"),
		[gEventConstants.ON_SIMULATOR_PREPARE_TIME] = self:CreateAction("OnEndPrepare")
	}
end

function M:OnRestart()
	self:Init()
end

function M:OnEndPrepare(eventId, data)
	self.bindData.prepareRoot:SetActive(false)
	self.bindData.FullBtn:SetActive(true)

	self.isPrepare = false
end

function M:OnTimerUp(eventId, data)
	self.isStart = false
	self.rankListData = {}
	local scoreArray = {}

	for playerId, score in pairs(self.playerScoreDic) do
		table.insert(scoreArray, {
			playerId = playerId,
			score = score
		})
	end

	table.sort(scoreArray, function (a, b)
		if a.score ~= b.score then
			return b.score < a.score
		else
			return a.playerId < b.playerId
		end
	end)

	for rank, info in ipairs(scoreArray) do
		info.rank = rank

		table.insert(self.rankListData, info)
	end

	self.bindData.endPanel:SetActive(true)
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.BBQ_PANEL_STORE, false)
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay)
	self.bindData.rankList:SetSimpleList(#self.rankListData)
end

function M:OnAddPlayerSingleScore(eventId, data)
	if self.playerScoreDic[data.playerId] == nil then
		self.playerScoreDic[data.playerId] = 0
	end

	self:ShowFeedback(data.playerId, data.singleScore)

	self.playerScoreDic[data.playerId] = self.playerScoreDic[data.playerId] + data.singleScore
	self.bindData.myScore = self.playerScoreDic[0] or 0
end

function M:ShowFeedback(playerId, score)
	local widget = self:GetFeedbackWidget(playerId)

	widget.gameObject:SetActive(true)

	local store = self:GetStoreByWidget(widget)
	store.score = score

	if score > 0 then
		store.feedback = 4
	else
		store.feedback = 0
	end

	Timer.New(function ()
		if not gCS.LuaUtils.IsNull(widget) then
			widget.gameObject:SetActive(false)
		end
	end, 1):Start()
end

function M:GetFeedbackWidget(playerId)
	if playerId == 0 then
		return self.bindData.MeFeedback
	elseif playerId == 1 then
		return self.bindData.P1Feedback
	elseif playerId == 2 then
		return self.bindData.P2Feedback
	else
		return self.bindData.P3Feedback
	end

	return null
end

function M:OnUpdate()
	if not self.isStart then
		return
	end

	if self.isPrepare then
		self.bindData.prepareTime = math.ceil(gCS.SimulatorGameUtils.GetGamePrepareTime())

		return
	end

	self.bindData.timeProgress.value = (self.totalTime - gCS.SimulatorGameUtils.GetGameCurrentTime()) / self.totalTime * (self.bindData.timeProgress.maxValue - self.bindData.timeProgress.minValue)
	local playerInputPos = gCS.SimulatorGameUtils.GetBBQPlayerInputPositions():ToTable()
	local mePos = gCS.LuaUtils.ScreenPointUI(self.bindData.RootRect, playerInputPos[1])

	self.bindData.selfMousePos:SetLocalPositionXY(mePos.x, mePos.y)

	local p1Pos = gCS.LuaUtils.ScreenPointUI(self.bindData.RootRect, playerInputPos[2])

	self.bindData.p1Mouse:SetLocalPositionXY(p1Pos.x, p1Pos.y)

	local p2Pos = gCS.LuaUtils.ScreenPointUI(self.bindData.RootRect, playerInputPos[3])

	self.bindData.p2Mouse:SetLocalPositionXY(p2Pos.x, p2Pos.y)

	local p3Pos = gCS.LuaUtils.ScreenPointUI(self.bindData.RootRect, playerInputPos[4])

	self.bindData.p3Mouse:SetLocalPositionXY(p3Pos.x, p3Pos.y)
end

function M:RegisterWidget()
	self.bindData.FullBtn.luaClick = self:CreateAction("OnClickFullBtn")
	self.bindData.FullBtn.luaBeginDrag = self:CreateAction("OnBeginDragFullBtn")
	self.bindData.FullBtn.luaEndDrag = self:CreateAction("OnEndDragFullBtn")
	self.bindData.FullBtn.luaPress = self:CreateAction("OnPressFullBtn")
	self.bindData.FullBtn.luaRelease = self:CreateAction("OnReleaseFullBtn")
	self.bindData.rankList.luaSimpleRenderItem = self:CreateAction("OnRenderRankItem")
	self.bindData.exitBtn.luaClick = self:CreateAction("ExitGame")
	self.bindData.restartBtn.luaClick = self:CreateAction("RestartGame")
end

function M:ExitGame()
	gMessageManager:SendMessage(gEventConstants.ON_SIMULATOR_UI_END, 0)
end

function M:RestartGame()
	self.bindData.endPanel:SetActive(false)
	gMessageManager:SendMessage(gEventConstants.ON_SIMULATOR_UI_END, 1)
end

function M:OnClickFullBtn()
	gMessageManager:SendMessage(gEventConstants.ON_SIMULATOR_GAME_PANEL_CLICK)
end

function M:OnBeginDragFullBtn()
	gMessageManager:SendMessage(gEventConstants.ON_SIMULATOR_GAME_PANEL_BEGIN_DRAG)
end

function M:OnEndDragFullBtn()
	gMessageManager:SendMessage(gEventConstants.ON_SIMULATOR_GAME_PANEL_END_DRAG)
end

function M:OnPressFullBtn()
	self.bindData.myCtrlState = 1
end

function M:OnReleaseFullBtn()
	self.bindData.myCtrlState = 0
end

function M:OnRenderRankItem(btn, index)
	local data = self.rankListData[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		if data.playerId == 0 then
			store.playerName = gPlayerManager.infoLogin.bindData.name
		else
			store.playerName = "Player" .. data.playerId
		end

		store.score = data.score
		store.rank = index + 1
	end
end
