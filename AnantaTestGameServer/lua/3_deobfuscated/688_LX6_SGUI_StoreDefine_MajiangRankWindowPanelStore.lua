local RedDotMgr = SGUI.RedDotMgr
C_MajiangRankWindowPanelStore = DefClass("C_MajiangRankWindowPanelStore", C_MajiangRankWindowPanelStore, C_StoreGroup)
GroupName2Class.MajiangRankWindowPanelStore = C_MajiangRankWindowPanelStore
local M = C_MajiangRankWindowPanelStore

function M:ctor()
	self.msgEvents = {}
end

function M:OnAwake()
	self.bindData.showRewardBtn.luaClick = self:CreateAction("OnShowRewardBtnClick")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnExit")
	self.bindData.startBtn.luaClick = self:CreateAction("OnStartBtnClick")
	self.bindData.rankBtn.luaClick = self:CreateAction("OnRankBtnClick")
	self.bindData.helpBtn.luaClick = self:CreateAction("OnHelpBtnClick")
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.bindData.ruleDescription = LTConfig.MahjongConfig.MahjongDivisionModeDescription

	self:RefreshData()
end

function M:OnClose()
	return
end

function M:OnRefresh(mahjongInfo)
	local myScore = mahjongInfo and mahjongInfo.Score or 0
	self.bindData.score = gString.Format("%d", myScore)
	self.bindData.rankingName, self.bindData.iconId = gMaJiangManager:GetRankingNameAndIcon(myScore)

	self:RefreshRedDot()
end

function M:OnExit()
	gPanelManager:Close(gPanelId.S_MA_JIANG_RANK_WINDOW_PANEL)
end

function M:OnShowRewardBtnClick()
	gMaJiangManager:OpenRewardPanel()
end

function M:OnStartBtnClick()
	gMaJiangManager:AskStartPveGame(self:CreateAction("OnExit"))
end

function M:OnRankBtnClick()
	gMaJiangManager:OpenRankListPanel()
end

function M:RefreshData()
	gMaJiangManager:RequestMahjongInfo(self:CreateAction("OnRefresh"), self:CreateAction("OnExit"))
end

function M:RefreshRedDot()
	RedDotMgr.LuaSetRedDot(gMaJiangManager:CheckRedPoint(), "MajiangRankWindowPanelStore.Reward")
end

function M:OnHelpBtnClick()
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_TEACH_PANEL)
end
