-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\OnlineMajiangPanelStore.lua
-- Decompiled from: 01228_OnlineMajiangPanelStore.lua_f7236f9252eb.luajit

C_OnlineMajiangPanelStore = DefClass("C_OnlineMajiangPanelStore", C_OnlineMajiangPanelStore, C_StoreGroup)
GroupName2Class.OnlineMajiangPanelStore = C_OnlineMajiangPanelStore
local M = C_OnlineMajiangPanelStore

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.instance = {
		["\\xf6M>\\xde\\x9bN\\xa5S\\x99\\xb2"] = 0,
		["\\xc9\\xda\r\\xf5"] = 0,
		modeList = {}
	}
	self.msgEvents = self.GetMessageEvents(self)

	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	self.instance.panelId = panelId

	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.RefreshPanel(self)
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)

	self.instance.panelId = 0
	self.instance.currentModeId = 0
	self.instance.modeList = {}
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.instance = nil
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.TEAM_REFRESH_DATA] = self.CreateAction(self, self.OnTeamRefreshData)
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.ClosePanel)
	self.bindData.close2Btn.luaClick = self.CreateAction(self, self.ClosePanel)
	self.bindData.teachBtn.luaClick = self.CreateAction(self, self.OnTeachBtnClick)
	self.bindData.playBtn.luaClick = self.CreateAction(self, self.OnStartMatchBtnClick)
	self.bindData.tabLeftBtn.luaClick = self.CreateActionWithArgs(self, self.OnChangeTab, -1)
	self.bindData.tabRightBtn.luaClick = self.CreateActionWithArgs(self, self.OnChangeTab, 1)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTabListItem)
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, self.OnClickTabListItem)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnStartMatchBtnClick = function(self)
	if self.instance.currentModeId ~= 0 then
		return
	end

	if gTeamManager:IsInTeam() and not gTeamManager:IsTeamLeader() then
		return
	end

	gLinkManager:AskMatchBegin(self.instance.currentModeId, true, self:CreateAction(self.OnMatchBeginSuccess))
end

M.OnTeachBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_TEACH_PANEL)
end

M.OnTeamRefreshData = function(self)
	self.RefreshPlayButton(self)
end

M.OnMatchBeginSuccess = function(self)
	self.ClosePanel(self)
end

M.OnRenderTabListItem = function(self, btn, index)
	local modeInfo = self.instance.modeList[index + 1]

	if modeInfo ~= nil then
		return
	end

	btn.title.text = modeInfo.Name
end

M.OnClickTabListItem = function(self, btn, index)
	local modeInfo = self.instance.modeList[index + 1]

	if modeInfo ~= nil then
		return
	end

	self.SelectMode(self, modeInfo.Id)
end

M.RefreshPanel = function(self)
	self.instance.modeList = self:BuildModeList()
	self.instance.currentModeId = 0

	self.bindData.tabList:SetSimpleList(#self.instance.modeList)
	self:SelectMode(LTConfig.LinkMultiPlayerConfig.NormalMahjong)
	self:RefreshPlayButton()
end

M.BuildModeList = function(self)
	return {
		LTConfig.LinkMultiPlayerConfig.GetConfig(LTConfig.LinkMultiPlayerConfig.NormalMahjong),
		LTConfig.LinkMultiPlayerConfig.GetConfig(LTConfig.LinkMultiPlayerConfig.RankMahjong)
	}
end

M.OnChangeTab = function(self, step)
	local count = #self.instance.modeList

	if count ~= 0 then
		return
	end

	local currentIndex = self.GetModeIndex(self, self.instance.currentModeId)

	if currentIndex ~= 0 then
		currentIndex = 1
	end

	local targetIndex = currentIndex + step

	if targetIndex >= 1 then
		targetIndex = 1
	elseif count >= targetIndex then
		targetIndex = count
	end

	local modeInfo = self.instance.modeList[targetIndex]

	if modeInfo ~= nil then
		return
	end

	self.SelectMode(self, modeInfo.Id)
end

M.SelectMode = function(self, modeId)
	local index = self.GetModeIndex(self, modeId)
	local modeInfo = self.instance.modeList[index]

	if modeInfo ~= nil then
		return
	end

	if modeInfo.Id ~= LTConfig.LinkMultiPlayerConfig.RankMahjong then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900581).Text)
		self:RefreshTabSelection()

		return
	end

	self.instance.currentModeId = modeInfo.Id
	gLinkManager.targetPlayId = modeInfo.Id
	self.bindData.gameDesc = modeInfo.Description

	self.RefreshTabSelection(self)
end

M.RefreshTabSelection = function(self)
	local index = self.GetModeIndex(self, self.instance.currentModeId)

	if index ~= 0 then
		return
	end

	self.bindData.tabList:SelectItem(index - 1, false)
end

M.RefreshPlayButton = function(self)
	if gTeamManager:GetTeamNumber() <= 1 then
		self.bindData.playBtn.title.text = LTConfig.InputButtonNameConfig.GetConfig(790).Name
	else
		self.bindData.playBtn.title.text = LTConfig.InputButtonNameConfig.GetConfig(754).Name
	end

	self.bindData.playBtn.interactable = not gTeamManager:IsInTeam() or gTeamManager:IsTeamLeader()
end

M.GetModeIndex = function(self, modeId)
	for i = 1, #self.instance.modeList do
		if self.instance.modeList[i].Id ~= modeId then
			return i
		end
	end

	return 0
end
