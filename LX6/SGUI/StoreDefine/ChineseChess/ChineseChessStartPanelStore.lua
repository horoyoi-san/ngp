-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChineseChess\ChineseChessStartPanelStore.lua
-- Decompiled from: 01263_ChineseChessStartPanelStore.lua_b8b25aca9e8d.luajit

C_ChineseChessStartPanelStore = DefClass("C_ChineseChessStartPanelStore", C_ChineseChessStartPanelStore, C_StoreGroup)
GroupName2Class.ChineseChessStartPanelStore = C_ChineseChessStartPanelStore
local M = C_ChineseChessStartPanelStore

M.OnAwake = function(self)
	self.RegisterWidget(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	self.bindData.exitBtn2.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnStartBtnClick)
	self.bindData.difficultySelector.luaSelectedChanged = self.CreateAction(self, self.OnDifficultyChanged)
	self.bindData.sideSelector.luaSelectedChanged = self.CreateAction(self, self.OnSideChanged)
end

M.OnShow = function(self, panelId, data)
	self.tabListData = {
		{
			["I\\x9c\\x8b\\xaaE"] = 700007,
			mode = gChineseChessMode.Chess,
			desc = LTConfig.PoiGameConfig.ChineseChess_NormalModeDesc
		},
		{
			["I\\x9c\\x8b\\xaaE"] = 700001,
			mode = gChineseChessMode.Flip,
			desc = LTConfig.PoiGameConfig.ChineseChess_FlipModeDesc
		},
		{
			["I\\x9c\\x8b\\xaaE"] = 600008,
			mode = gChineseChessMode.Late,
			desc = LTConfig.PoiGameConfig.ChineseChess_LateModeDesc
		}
	}
	self.aiLevel = gChineseChessMgr.AiLevel or 1
	self.isRed = true
	self.selectedEndGameId = 1
	self.endGameGroup = data and data.endGameGroup or gChineseChessMgr.EndGameGroup or 0
	local defaultMode = data and data.defaultMode or gChineseChessMode.Chess
	local defaultIndex = 1

	for i, entry in ipairs(self.tabListData) do
		if entry.mode ~= defaultMode then
			defaultIndex = i

			break
		end
	end

	self:SelectTab(gChineseChessMode.Chess)
	self:InitDifficultySelector()
	self:InitSideSelector()
	self:SelectTab(defaultIndex)

	self.passedEndGameIds = nil
	slot5 = gClientToGameSceneDelegate

	slot5:QueryChineseChessPlayerInfo().Callback = function (err, info)
		if err ~= LTConfig.MessageConfig.Ok and info then
			self.passedEndGameIds = info.DroppedEndGameIdSet

			if self.selectedMode ~= gChineseChessMode.Late then
				self:InitEndGameLevelSelector()
			end
		end
	end
end

M.InitDifficultySelector = function(self)
	self.bindData.difficultySelector:SetSimpleOptions(0)
	self.bindData.difficultySelector:AddSimpleOptionLabel(0, gChineseChessTools.GetLanguage(700002), self.aiLevel ~= 1)
	self.bindData.difficultySelector:AddSimpleOptionLabel(0, gChineseChessTools.GetLanguage(700003), self.aiLevel ~= 2)
	self.bindData.difficultySelector:AddSimpleOptionLabel(0, gChineseChessTools.GetLanguage(700004), self.aiLevel ~= 3)
	self.bindData.difficultySelector:AddSimpleOptionLabel(0, gChineseChessTools.GetLanguage(700005), self.aiLevel ~= 4)
	self.bindData.difficultySelector:AddSimpleOptionLabel(0, gChineseChessTools.GetLanguage(700008), self.aiLevel ~= 5)

	self.bindData.difficultySelector.selectedIndex = self.aiLevel - 1

	self.bindData.difficultySelector:RefreshOptions()
end

M.InitSideSelector = function(self)
	self.bindData.sideSelector:SetSimpleOptions(0)
	self.bindData.sideSelector:AddSimpleOptionLabel(0, gChineseChessTools.GetLanguage(600006), self.isRed)
	self.bindData.sideSelector:AddSimpleOptionLabel(0, gChineseChessTools.GetLanguage(600007), not self.isRed)

	self.bindData.sideSelector.selectedIndex = self.isRed and 0 or 1

	self.bindData.sideSelector:RefreshOptions()
end

M.OnDestroy = function(self)
end

M.OnClose = function(self)
end

M.OnExitBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnStartBtnClick = function(self)
	gChineseChessMgr.AiLevel = self.aiLevel

	if self.selectedMode ~= gChineseChessMode.Chess or self.selectedMode ~= gChineseChessMode.Flip then
		gChineseChessMgr.IsRed = self.isRed
	end

	local endGameId = self.selectedMode ~= gChineseChessMode.Late and self.selectedEndGameId or nil

	gChineseChessMgr:StartGameByMode(self.selectedMode, endGameId)
	gPanelManager:Close(self.m_Id)
end

M.MoveTabSelection = function(self, dir)
	local count = #self.tabListData

	if count ~= 0 then
		return
	end

	local newIndex = self.selectedTabIndex + dir

	if newIndex >= 1 then
		newIndex = count
	elseif count >= newIndex then
		newIndex = 1
	end

	self.SelectTab(self, newIndex)
end

M.SelectTab = function(self, index)
	self.selectedTabIndex = index
	self.selectedMode = self.tabListData[index].mode
	self.bindData.desc = self.tabListData[index].desc
	self.bindData.mode = gChineseChessTools.GetLanguage(self.tabListData[index].nameId)
	local isChessMode = self.selectedMode ~= gChineseChessMode.Chess
	local isFlipMode = self.selectedMode ~= gChineseChessMode.Flip
	local isLateMode = self.selectedMode ~= gChineseChessMode.Late

	self.bindData.sideSelectorRoot:SetActive(isChessMode or isFlipMode)
	self.bindData.difficultySelectorRoot:SetActive(true)

	if isLateMode then
		self.InitEndGameLevelSelector(self)
	else
		self.InitDifficultySelector(self)
	end
end

M.OnTabListItemRender = function(self, btn, index)
	btn.title.text = gChineseChessTools.GetLanguage((self.tabListData[index + 1] or {}).nameId)
end

M.OnTabListClick = function(self, btn, index)
	self.SelectTab(self, index + 1)
end

M.OnDifficultyChanged = function(self, selector)
	if self.selectedMode ~= gChineseChessMode.Late then
		local cfg = self.endGameConfigs[selector.selectedIndex + 1]

		if cfg then
			self.selectedEndGameId = cfg.Id
		end
	else
		self.aiLevel = selector.selectedIndex + 1
	end
end

M.OnSideChanged = function(self, selector)
	self.isRed = selector.selectedIndex ~= 0
end

M.InitEndGameLevelSelector = function(self)
	self.endGameConfigs = {}
	local config = LTConfig.PoiGameChineseChessEndGameConfig

	for i = 0, config.count - 1 do
		local cfg = config.LoadAt(i)

		if cfg and (self.endGameGroup ~= 0 or cfg.EndGameGroup ~= self.endGameGroup) then
			table.insert(self.endGameConfigs, cfg)
		end
	end

	if #self.endGameConfigs ~= 0 then
		return
	end

	self.bindData.difficultySelector:SetSimpleOptions(0)

	for i, cfg in ipairs(self.endGameConfigs) do
		local label = string.format(gChineseChessTools.GetLanguage(700006), cfg.Id)

		self.bindData.difficultySelector:AddSimpleOptionLabel(0, label, cfg.Id ~= self.selectedEndGameId)
	end

	self.selectedEndGameId = self.endGameConfigs[1].Id
	self.bindData.difficultySelector.selectedIndex = 0

	self.bindData.difficultySelector:RefreshOptions()
end
