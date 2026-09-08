-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangRankWindowPanelStore.lua
-- Decompiled from: 01218_MajiangRankWindowPanelStore.lua_0eddac5a33c1.luajit

local RedDotMgr = SGUI.RedDotMgr
C_MajiangRankWindowPanelStore = DefClass("C_MajiangRankWindowPanelStore", C_MajiangRankWindowPanelStore, C_StoreGroup)
GroupName2Class.MajiangRankWindowPanelStore = C_MajiangRankWindowPanelStore
local M = C_MajiangRankWindowPanelStore

M.OnAwake = function(self)
	self.bindData.showRewardBtn.luaClick = self.CreateAction(self, "OnShowRewardBtnClick")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnExit")
	self.bindData.startBtn.luaClick = self.CreateAction(self, "OnStartBtnClick")
	self.bindData.rankBtn.luaClick = self.CreateAction(self, "OnRankBtnClick")
	self.bindData.helpBtn.luaClick = self.CreateAction(self, "OnHelpBtnClick")
end

M.OnShow = function(self, panelId, data)
	self.bindData.ruleDescription = LTConfig.MahjongConfig.MahjongDivisionModeDescription

	self.RefreshData(self)
end

M.OnRefresh = function(self, mahjongInfo)
	local myScore = mahjongInfo and mahjongInfo.Score or 0
	self.bindData.score = gString.Format("%d", myScore)
	self.bindData.rankingName, self.bindData.iconId = gMaJiangManager:GetRankingNameAndIcon(myScore)

	self:RefreshRedDot()
end

M.OnExit = function(self)
	gPanelManager:Close(gPanelId.S_MA_JIANG_RANK_WINDOW_PANEL)
end

M.OnShowRewardBtnClick = function(self)
	gMaJiangManager:OpenRewardPanel()
end

M.OnStartBtnClick = function(self)
	gMaJiangManager:AskStartPveGame(self:CreateAction("OnExit"))
end

M.OnRankBtnClick = function(self)
	gMaJiangManager:OpenRankListPanel()
end

M.RefreshData = function(self)
	gMaJiangManager:RequestMahjongInfo(self:CreateAction("OnRefresh"), self:CreateAction("OnExit"))
end

M.RefreshRedDot = function(self)
	RedDotMgr.LuaSetRedDot(gMaJiangManager:CheckRedPoint(), "MajiangRankWindowPanelStore.Reward")
end

M.OnHelpBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_TEACH_PANEL)
end
