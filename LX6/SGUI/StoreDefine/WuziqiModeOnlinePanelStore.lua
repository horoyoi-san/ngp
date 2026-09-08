-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WuziqiModeOnlinePanelStore.lua
-- Decompiled from: 01243_WuziqiModeOnlinePanelStore.lua_9ca2bc9de07e.luajit

C_WuziqiModeOnlinePanelStore = DefClass("C_WuziqiModeOnlinePanelStore", C_WuziqiModeOnlinePanelStore, C_StoreGroup)
GroupName2Class.WuziqiModeOnlinePanelStore = C_WuziqiModeOnlinePanelStore
local M = C_WuziqiModeOnlinePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.playerInfoCache = {}
	self.turnCountDownDelayTimer = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.roundEnum = {
		["b\\xba\\xaa\\xaa\\xa4"] = 1,
		["I'q]"] = 0
	}
	self.colorEnum = {
		["Z\\xa6\\xab\\xbb\\xb3"] = 1,
		["O\\xa2\\xa3\\xac\\xbd"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.roundEnum = nil
	self.colorEnum = nil
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
	gLuaTimeMgrUtils.CancelUnitDelay(self.turnCountDownDelayTimer)

	self.turnCountDownDelayTimer = nil

	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.OnGomokuRoundTurnChange(self, nil, data)

	if data and data.ToTable then
		data = data.ToTable(data)
	end

	local opponentPid = data.opponentPid
	self.opponentPid = opponentPid
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	local headIconId = spiritCfg and spiritCfg.SHeadIconID or 0
	self.bindData.leftHeadIconId = headIconId
	self.bindData.leftName.text = gPlayerManager.infoLogin.bindData.playerName

	self:RequestPlayerInfo({
		opponentPid
	})
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.GOMOKU_ROUND_TURN_CHANGE] = self.CreateAction(self, self.OnGomokuRoundTurnChange)
	}
end

M.RegisterWidget = function(self)
end

M.RequestPlayerInfo = function(self, pidList)
	if table.isNilOrEmpty(pidList) then
		return
	end

	slot2 = gFriendManager

	slot2:GetSimplePlayerInfoByPidList(pidList, function (datas)
		if table.isNilOrEmpty(datas) then
			return
		end

		for i = 1, #datas do
			self.playerInfoCache[datas[i].Pid] = datas[i]
		end

		self:RefreshPlayerInfoUI()
	end)
end

M.RefreshPlayerInfoUI = function(self)
	local opponentInfo = self.playerInfoCache[self.opponentPid]

	if opponentInfo then
		self.bindData.rightName.text = gSocialFriendManager:GetPlayerDisplayName(self.opponentPid, opponentInfo.Name or "")
		local headIcon = 0
		local headId = gClientUtils.GetLinkHeadId(opponentInfo)

		if headId == 0 then
			headIcon = gHunLunManager:GetHeadIconAndName(headId)
		end

		self.bindData.rightHeadIconId = headIcon
	end
end

M.OnGomokuRoundTurnChange = function(self, _, data)
	if data and data.ToTable then
		data = data:ToTable()
		self.currentRound = data.currentRound
		self.currentTurn = data.currentTurn
		local delay = LTConfig.PoiGameConfig.GomokuTurnCountDownDelay or 0

		gLuaTimeMgrUtils.CancelUnitDelay(self.turnCountDownDelayTimer)

		self.turnCountDownDelayTimer = nil
		local mySeatIndex = L50.L50App.Scene.GomokuManager.MySeatIndex

		if mySeatIndex ~= self.currentTurn and delay <= 0 then
			self.StopTurnCountDown(self)

			self.turnCountDownDelayTimer = gLuaTimeMgrUtils.Delay(function ()
				self.turnCountDownDelayTimer = nil

				self:ApplyTurnChange(delay)
			end, delay)
		else
			self.ApplyTurnChange(self, 0)
		end
	end
end

M.ApplyTurnChange = function(self, deductedTime)
	local mySeatIndex = L50.L50App.Scene.GomokuManager.MySeatIndex

	if mySeatIndex ~= self.currentTurn then
		self.bindData.round = self.roundEnum.Self
	else
		self.bindData.round = self.roundEnum.Other
	end

	self.bindData.color = self.currentTurn

	self.PlayTurnCountDown(self, deductedTime)
end

M.StopTurnCountDown = function(self)
	local countDown = self.bindData.time

	if not countDown then
		return
	end

	countDown.luaFinished = nil

	countDown.Stop(countDown)
end

M.PlayTurnCountDown = function(self, deductedTime)
	local countDown = self.bindData.time

	if not countDown then
		return
	end

	countDown:Play(LTConfig.PoiGameConfig.GomokuTurnCountDown - (deductedTime or 0))

	countDown.luaFinished = function()
		L50.L50App.Scene.GomokuManager:LeaveGomoku(true)
	end
end
