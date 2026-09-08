-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FridgeHomePanelStore.lua
-- Decompiled from: 01841_FridgeHomePanelStore.lua_195efbb90368.luajit

local MessageConfig = LTConfig.MessageConfig
local FridgeHomeTextInfos = {
	FullyLoaded = {
		["N'pK"] = "\\x83\\xe7chBJmqh#\\xbaG\\xafC"
	}
}
C_FridgeHomePanelStore = DefClass("C_FridgeHomePanelStore", C_FridgeHomePanelStore, C_StoreGroup)
GroupName2Class.FridgeHomePanelStore = C_FridgeHomePanelStore
local M = C_FridgeHomePanelStore

M.DefineAllVariables = function(self)
	self.isClosed = false
	self.loadTimeTimer = nil
	self._loadRemainSeconds = 0
	self.eventHandle = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.RegisterWidget = function(self)
	self.bindData.autoCollectBtn.luaClick = self.CreateAction(self, "OnAutoCollectClick")
	self.bindData.matchGameBtn.luaClick = self.CreateAction(self, "OnMatchGameClick")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseClick")
end

M.OnGroupEnable = function(self)
	self.isClosed = false

	self.RefreshAll(self)
	self.RegisterEvent(self)
end

M.OnEnable = function(self)
	self.RefreshMatchGameBtn(self)
end

M.OnGroupDisable = function(self)
	self.isClosed = true

	self.StopLoadTimeTimer(self)
	self.UnregisterEvent(self)
end

M.OnShow = function(self)
	self.RefreshAll(self)
end

M.OnClose = function(self)
	self.isClosed = true

	self.StopLoadTimeTimer(self)
end

M.RegisterEvent = function(self)
	self.eventHandle = {
		[gEventConstants.UPDATE_MATCH_GAME_REMAIN_TIMES] = function ()
			self:RefreshMatchGameBtn()
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandle)
end

M.UnregisterEvent = function(self)
	if not self.eventHandle then
		return
	end

	gMessageManager:UnregisterEventHandlers(self.eventHandle)

	self.eventHandle = nil
end

M.RefreshAll = function(self)
	self.RefreshMatchGameBtn(self)
	self.RefreshLoadTips(self)
end

M.OnAutoCollectClick = function(self)
	local now = os.time()

	if self._lastAutoCollectTime and now - self._lastAutoCollectTime >= 1 then
		return
	end

	self._lastAutoCollectTime = now
	slot2 = gFactorMachineManager

	slot2:EnterFactorPanel(function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gPanelManager:CheckShow(gPanelId.S_FRIDGE_AUTO_COLLECT)
	end)
end

M.OnMatchGameClick = function(self)
	gPanelManager:CheckShow(gPanelId.S_MATCH_GAME_PANEL)
end

M.OnCloseClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.RefreshMatchGameBtn = function(self)
	local remainingTimes = gFactorMachineManager:GetRemainingGameTimes()

	if self.isClosed then
		return
	end

	local T = gFactorMachineManager:GetGameConfigTable()
	local totalTimes = gFactorMachineManager:GetConstant(T.PlayTime)
	self.bindData.matchGameTimesText = string.format("%d/%d", remainingTimes, totalTimes)
end

M.RefreshLoadTips = function(self)
	slot1 = gFactorMachineManager

	slot1:AskGetLoadTimeRemaining(function (err, remainingSeconds)
		if err == MessageConfig.Ok then
			return
		end

		if self.isClosed then
			return
		end

		if remainingSeconds < 0 then
			self.bindData.loadTipsText = gFactorMachineManager:GetText(FridgeHomeTextInfos.FullyLoaded)

			self:StopLoadTimeTimer()
		else
			self._loadRemainSeconds = remainingSeconds

			self:_updateLoadTimeText(remainingSeconds)
			self:StartLoadTimeTimer()
		end
	end)
end

M.StartLoadTimeTimer = function(self)
	self:StopLoadTimeTimer()

	self.loadTimeTimer = Timer.New(function ()
		if self.isClosed then
			return
		end

		self._loadRemainSeconds = self._loadRemainSeconds - 1

		if self._loadRemainSeconds < 0 then
			self.bindData.loadTipsText = gFactorMachineManager:GetText(FridgeHomeTextInfos.FullyLoaded)

			self:StopLoadTimeTimer()

			return
		end

		self:_updateLoadTimeText(self._loadRemainSeconds)
	end, 1, -1):Start()
end

M._updateLoadTimeText = function(self, seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor(seconds % 3600 / 60)
	local s = seconds % 60
	self.bindData.loadTipsText = string.format("%02d:%02d:%02d", h, m, s)
end

M.StopLoadTimeTimer = function(self)
	if self.loadTimeTimer then
		self.loadTimeTimer:Stop()

		self.loadTimeTimer = nil
	end
end
