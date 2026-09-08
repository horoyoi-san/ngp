-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChineseChess\ChineseChessFinalPanelStore.lua
-- Decompiled from: 01273_ChineseChessFinalPanelStore.lua_21def67e664b.luajit

C_ChineseChessFinalPanelStore = DefClass("C_ChineseChessFinalPanelStore", C_ChineseChessFinalPanelStore, C_StoreGroup)
GroupName2Class.ChineseChessFinalPanelStore = C_ChineseChessFinalPanelStore
local M = C_ChineseChessFinalPanelStore

M.DefineAllEnumsAutoGen = function(self)
	self.winCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.playAgainBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.winCtrlEnum = nil
	self.playAgainBtnCtrlEnum = nil
end

M.OnAwake = function(self)
	self.RegisterWidget(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	self.bindData.playAgainBtn.luaClick = self.CreateAction(self, self.OnPlayAgainBtnClick)
	self.bindData.nextLevelBtn.luaClick = self.CreateAction(self, self.OnNextLevelBtnClick)
end

M.OnShow = function(self, panelId, data)
	self.bindData.winCtrl = data.isWin and self.winCtrlEnum._true or self.winCtrlEnum._false
	local player1IsRed = gChineseChessMgr.Player1.PlayerInfo.IsRed
	local redPlayer = player1IsRed and gChineseChessMgr.Player1.PlayerInfo or gChineseChessMgr.Player2.PlayerInfo
	local blackPlayer = player1IsRed and gChineseChessMgr.Player2.PlayerInfo or gChineseChessMgr.Player1.PlayerInfo
	self.bindData.redName = redPlayer.Name
	self.bindData.blackName = blackPlayer.Name
	local mode = gChineseChessMgr._gameMode or gChineseChessMode.Chess

	if mode ~= gChineseChessMode.Late then
		if data.isWin then
			local cfg = LTConfig.PoiGameChineseChessEndGameConfig.GetConfig(gChineseChessMgr.CurrentEndGameId)
			local hasNext = cfg == nil and cfg.NextEndGame >= 0
			self.bindData.playAgainBtnCtrl = self.playAgainBtnCtrlEnum._true

			self.bindData.nextLevelBtn:SetActive(hasNext)
		else
			self.bindData.playAgainBtnCtrl = self.playAgainBtnCtrlEnum._false
		end
	else
		self.bindData.playAgainBtnCtrl = self.playAgainBtnCtrlEnum._false
	end
end

M.OnExitBtnClick = function(self)
	gChineseChessMgr:ExitAfterGameEnd()
end

M.OnPlayAgainBtnClick = function(self)
	self.bindData.playAgainBtn.interactable = false

	if gChineseChessMgr._gameMode ~= gChineseChessMode.Late then
		gChineseChessMgr:RetryEndGame()
	else
		gChineseChessMgr:PlayAgainChess()
	end
end

M.OnNextLevelBtnClick = function(self)
	self.bindData.nextLevelBtn.interactable = false

	gChineseChessMgr:NextEndGame()
end

M.ResetPlayAgainBtn = function(self)
	if self.STATE_EnableOnce then
		self.bindData.playAgainBtn.interactable = true
		self.bindData.nextLevelBtn.interactable = true
	end
end
