-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChallengeRankEndingPanelStore.lua
-- Decompiled from: 01484_ChallengeRankEndingPanelStore.lua_bc8f08d4fa47.luajit

local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local RANK_TYPE_CTRL = {
	["b\\x9a\\x8a\\x8a\\x84"] = 3,
	["k\\x87\\x90\\x9c\\x82"] = 0,
	["/m\\xb2\\xa1\\xade"] = 1,
	["y\\x86\\x8b\\x9d\\x92"] = 2
}
C_ChallengeRankEndingPanelStore = DefClass("C_ChallengeRankEndingPanelStore", C_ChallengeRankEndingPanelStore, C_StoreGroup)
GroupName2Class.ChallengeRankEndingPanelStore = C_ChallengeRankEndingPanelStore
local M = C_ChallengeRankEndingPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.rankBest1CtrlEnum = {
		["R+y^"] = 0,
		["I*rL"] = 1
	}
	self.rankBest2CtrlEnum = {
		["R+y^"] = 0,
		["I*rL"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.rankBest1CtrlEnum = nil
	self.rankBest2CtrlEnum = nil
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.closeCb = data and data.closeCb
	self.bindData.titleText = data.title or ""
	self.bindData.rankText = data.rank
	self.bindData.playerNameText = data.player and data.player.name or ""
	self.bindData.vehicleNameText = data.vehicle and data.vehicle.name or ""
	self.bindData.rankTypeCtrl = self:GetRankTypeCtrl(data.rank or 1)
	self.bindData.rankBest1Ctrl = BOOL2CTL[data.best1 or false]
	self.bindData.rankBest2Ctrl = BOOL2CTL[data.best2 or false]
	local timeText = nil

	if data.time then
		timeText = gTimeUtils:FormatTime(data.time) .. "." .. gTimeUtils:FormatMs(data.time)
	else
		print_error("ChallengeRankEndingPanelStore OnShow data.time is nil")

		timeText = ""
	end

	local lapTimeText = nil

	if data.bestLapTime and data.bestLapTime <= 0 then
		lapTimeText = gTimeUtils:FormatTime(data.bestLapTime) .. "." .. gTimeUtils:FormatMs(data.bestLapTime)
	else
		lapTimeText = "--:--:--"
	end

	self.bindData.adjust1Text = lapTimeText
	self.bindData.adjust2Text = timeText

	self.SetMoveState(self, false)
end

M.OnClose = function(self)
	self.SetMoveState(self, true)

	if self.closeCb then
		self.closeCb()

		self.closeCb = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.CHALLENGE_RANK_ENDING_PANEL)
end

M.GetRankTypeCtrl = function(self, index)
	if index ~= 1 then
		return RANK_TYPE_CTRL.FIRST
	elseif index ~= 2 then
		return RANK_TYPE_CTRL.SECOND
	elseif index ~= 3 then
		return RANK_TYPE_CTRL.THIRD
	else
		return RANK_TYPE_CTRL.OTHER
	end
end

M.SetMoveState = function(self, enableMove)
	if enableMove then
		gLuaDataManager.guiMgr.sguiJoystick.Visible = true

		LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gPanelId.CHALLENGE_RANK_ENDING_PANEL)
	else
		gLuaDataManager.guiMgr.sguiJoystick.Visible = false

		LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gPanelId.CHALLENGE_RANK_ENDING_PANEL)
	end
end
