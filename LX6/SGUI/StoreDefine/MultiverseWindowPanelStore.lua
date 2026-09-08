-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MultiverseWindowPanelStore.lua
-- Decompiled from: 01048_MultiverseWindowPanelStore.lua_bb654dcca792.luajit

local ClientConsts = gClientConst
C_MultiverseWindowPanelStore = DefClass("C_MultiverseWindowPanelStore", C_MultiverseWindowPanelStore, C_StoreGroup)
GroupName2Class.MultiverseWindowPanelStore = C_MultiverseWindowPanelStore
local M = C_MultiverseWindowPanelStore

M.ctor = function(self)
	self.mgr = gMultiverseMgr
end

M.DefineAllVariables = function(self)
	self.verseList = {}
	self.selectedCfg = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.windowTypeEnum = {
		["3F\\x9d\\x87\\x8dD"] = 1,
		["/A\\x9f\\x89\\x8fD"] = 0
	}
	self.isCurrentVerseEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isLastEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isReadyEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isPlayingEnum = {
		["\\xbc!2-}\\x93U\\xe9;\\xab\\xa0"] = 1,
		["\\x87\\xb0\\xbfZ2\\xff*"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.windowTypeEnum = nil
	self.isCurrentVerseEnum = nil
	self.isLastEnum = nil
	self.isReadyEnum = nil
	self.isPlayingEnum = nil
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
	self.verseList = data and data.verseList or {}
	self.selectedCfg = nil

	if #self.verseList ~= 0 then
		self.OnClickBackBtn(self)

		return
	end

	self.bindData.loopList:SetSimpleList(#self.verseList)
	self.bindData.loopList:SelectItem(0)
end

M.OnClose = function(self)
	self.verseList = {}
	self.selectedCfg = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.loopList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderLoopList)
	self.bindData.loopList.luaSelectedChanged = self.CreateAction(self, self.OnLoopListSelectedChanged)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.tipsBtn.luaClick = self.CreateAction(self, self.OnClickTipsBtn)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnRenderLoopList = function(self, btn, index, data)
	local cfg = self.verseList[index + 1]

	if not cfg then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.titleLabel = cfg.Name
	store.descLabel = cfg.Des
	store.background = cfg.Image
	store.isReady = ClientConsts.BOOL2CTL[self.mgr:CheckVerse(cfg.Id)]
	store.isLast = ClientConsts.BOOL2CTL[cfg.Id ~= self.mgr.lastVerse]
	store.isPlaying = ClientConsts.BOOL2CTL[cfg.Id ~= self.mgr.curVerse]
	btn.interactable = self.mgr:CheckVerse(cfg.Id)
end

M.OnLoopListSelectedChanged = function(self, uList)
	local index = uList.selectedIndex + 1
	local cfg = self.verseList[index]

	if not cfg then
		return
	end

	self.bindData.descLabel = cfg.Des
	self.selectedCfg = cfg
	self.bindData.isCurrentVerse = ClientConsts.BOOL2CTL[cfg.Id ~= self.mgr.curVerse]
end

M.OnClickConfirmBtn = function(self)
	if self.selectedCfg then
		if self.selectedCfg.Id ~= self.mgr.curVerse then
			self:OnClickBackBtn()
			gPanelManager:Close(gPanelId.MULTIVERSE_INITIAL_PANEL)

			return
		end

		if gLoginManager:CheckIsOnlineTest() then
			gLinkManager:OnChangeLinkMode(self.selectedCfg.LinkMode)
			gLoginManager:OnLogin()
		else
			self.mgr:AskEnterMultiverse(self.selectedCfg.Id, self.selectedCfg.LinkMode)
		end
	end

	self.OnClickBackBtn(self)
end

M.OnClickTipsBtn = function(self)
	gDisplayMessageMgr:ShowMessExplainSub(LTConfig.MessageExplainConfig.MultiverseOnlineModeExplain)
end
