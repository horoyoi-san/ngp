-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ArtistHomePanelStore.lua
-- Decompiled from: 01910_ArtistHomePanelStore.lua_d758fe0f5d19.luajit

C_ArtistHomePanelStore = DefClass("C_ArtistHomePanelStore", C_ArtistHomePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.ArtistHomePanelStore = C_ArtistHomePanelStore
local M = C_ArtistHomePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showLevelCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showLevelCtrlEnum = nil
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
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.drawBtn.luaClick = self.CreateAction(self, self.OnClickDrawBtn)
	self.bindData.musicalBtn.luaClick = self.CreateAction(self, self.OnClickMusicalBtn)
end

M.OnClickDrawBtn = function(self)
	gBeggarManager:OpenBeggarHudPanel(4, 4, false)
	gMainPhoneUtils.CloseMainPhonePanel()
end

M.OnClickMusicalBtn = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_BEGGAR_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.BEGGAR_APP_SHOW_TYPE.TYPE
	})
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshPanelView(self)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_BEGGAR_APP_CONTENT_CLOSE)
end

M.RefreshPanelView = function(self)
	local currentJobInfo, levelCfg, cfg = gBeggarManager:GetBeggarJobInfo()

	if currentJobInfo then
		self.bindData.showLevelCtrl = 1
		local progress = currentJobInfo.Exp / levelCfg.Exp

		self.bindData.levelProgress:ProgressToValue(progress)

		local level = levelCfg and levelCfg.Level or 1
		self.bindData.level = string.format("Lv.%d", level or 1)
		self.bindData.curExp = currentJobInfo.Exp
		self.bindData.maxExp = levelCfg.Exp
		self.bindData.levelText = cfg.Name
	else
		self.bindData.showLevelCtrl = 0
	end
end

M.ClearData = function(self)
	if not gBeggarManager.isInBeggar then
		LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, gBanId.Beggar)
	end

	gBeggarManager:CheckNeedEndBeggar()
end
