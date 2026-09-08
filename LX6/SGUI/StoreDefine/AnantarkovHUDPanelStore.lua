-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovHUDPanelStore.lua
-- Decompiled from: 01615_AnantarkovHUDPanelStore.lua_02a600f76ae6.luajit

local ExtractionShooterConfig = LTConfig.ExtractionShooterConfig
C_AnantarkovHUDPanelStore = DefClass("C_AnantarkovHUDPanelStore", C_AnantarkovHUDPanelStore, C_StoreGroup)
GroupName2Class.AnantarkovHUDPanelStore = C_AnantarkovHUDPanelStore
local M = C_AnantarkovHUDPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.listenProgressIds = {}
	self.currentRoomIds = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.timeWarningCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.escapeTypeEnum = {
		["Nu\\xb8~Z\\xb7\\xc5FxspK"] = 2,
		["=K\\x85\\x87\\x95D"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.countDownVisibleCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.timeWarningCtrlEnum = nil
	self.escapeTypeEnum = nil
	self.countDownVisibleCtrlEnum = nil
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.InitModel(self)
	self.InitView(self)
end

M.InitModel = function(self)
	local targetPlayId = gLinkManager.targetPlayId
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(targetPlayId)
	local extractionShooterId = multiPlayerCfg and multiPlayerCfg.ExtractionSettings
	local extractionShooterCfg = LTConfig.ExtractionShooterConfig.GetConfig(extractionShooterId)
	self.globalCountdownTime = extractionShooterCfg and extractionShooterCfg.GlobalCountTime
end

M.InitView = function(self)
	self.RefreshCountTimeView(self)
end

M.OnClose = function(self)
	self.currentRoomIds = {}
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PLAYER_ENTER_ROOM] = self.CreateAction(self, self.OnPlayerEnterRoom),
		[gEventConstants.PLAYER_LEAVE_ROOM] = self.CreateAction(self, self.OnPlayerExitRoom),
		[gEventConstants.PROGRESS_STATE_CHANGE] = self.CreateAction(self, self.RefreshCurrentProgress),
		[gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE] = self.CreateAction(self, self.RefreshProgressInfo)
	}
end

M.OnPlayerEnterRoom = function(self, _, roomId)
	self.currentRoomIds[roomId] = true

	self.RefreshEscapeState(self)
end

M.OnPlayerExitRoom = function(self, _, roomId)
	self.currentRoomIds[roomId] = nil

	self.RefreshEscapeState(self)
end

M.RefreshEscapeState = function(self)
	local isInInner = false
	local isInOuter = false

	for id, _ in pairs(self.currentRoomIds) do
		if gExtractionShooterManager:CheckInInnerExPoint(id) then
			isInInner = true
		elseif gExtractionShooterManager:CheckInOuterExPoint(id) then
			isInOuter = true
		end
	end

	if isInInner then
		self.bindData.escapeType = self.escapeTypeEnum.Active
		self.bindData.countDownLabel = ExtractionShooterConfig.EnterEvacuationPlaceCountDownLabel
		self.bindData.countDownVisibleCtrl = self.countDownVisibleCtrlEnum._true
	elseif isInOuter then
		self.bindData.escapeType = self.escapeTypeEnum.ActiveWaring
		self.bindData.countDownLabel = ExtractionShooterConfig.NotEnterEvacuationPlaceCountDownLabel
		self.bindData.countDownVisibleCtrl = self.countDownVisibleCtrlEnum._true
	else
		self.bindData.escapeType = self.escapeTypeEnum.Normal
		self.bindData.countDownLabel = ""
		self.bindData.countDownVisibleCtrl = self.countDownVisibleCtrlEnum._false
	end
end

M.RefreshProgressInfo = function(self, _, data)
	if data.uiId ~= self.m_Id then
		self.tempalteId = data.templateId
		self.listenProgressIds = gNewGamePlayProgressMgr:GetProgressDictByTemplateIds({
			self.tempalteId
		})

		self:GetProgressInfo()
	end
end

M.RefreshCurrentProgress = function(self, _, progressId)
	if self.listenProgressIds[progressId] then
		self.GetProgressInfo(self)
	end
end

M.GetProgressInfo = function(self)
	self.countDownStore = gStoreManager:GetStoreGroup(self.bindData.countdownWid.Store):GetStoreByWidget(self.bindData.countdownWid)
	self.progressId = gNewGamePlayProgressMgr:RenderSingleProgressTemplate(self.countDownStore, self.tempalteId)

	self:RefreshEscapeState()
end

M.RegisterWidget = function(self)
	self.bindData.openButton.luaClick = self.CreateAction(self, "OnClickOpenButton")
end

M.OnUpdate = function(self)
	self.RefreshCountTimeView(self)
end

M.RefreshCountTimeView = function(self)
	if self.globalCountdownTime and gLinkManager.gameStartTime and gLinkManager.gameStartTime <= 0 then
		local diffTime = gLuaDataManager.serverTime - gLinkManager.gameStartTime
		local leftTime = self.globalCountdownTime - diffTime
		leftTime = math.max(leftTime, 0)
		self.bindData.timeWarningCtrl = leftTime < LTConfig.ExtractionShooterConfig.CountdownTimeWarn and self.timeWarningCtrlEnum.active or self.timeWarningCtrlEnum.normal
		local minute = leftTime / gClientConst.SECONDS_PER_MINUTE
		local second = leftTime % gClientConst.SECONDS_PER_MINUTE
		self.bindData.countdown = ("%02d:%02d"):format(minute, second)
	end
end

M.OnClickOpenButton = function(self)
	gPanelManager:CheckShow(gPanelId.ANANTARKOV_BAG_PANEL)
end
