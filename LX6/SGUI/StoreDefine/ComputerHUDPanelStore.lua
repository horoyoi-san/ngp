-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComputerHUDPanelStore.lua
-- Decompiled from: 01548_ComputerHUDPanelStore.lua_73e78d6eeb03.luajit

C_ComputerHUDPanelStore = DefClass("C_ComputerHUDPanelStore", C_ComputerHUDPanelStore, C_StoreGroup)
GroupName2Class.ComputerHUDPanelStore = C_ComputerHUDPanelStore
local M = C_ComputerHUDPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")

	self.InitMessages(self)
end

M.InitMessages = function(self)
	local messageEvents = {
		[gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE] = self.CreateAction(self, "OnExitButtonStateChange")
	}

	self.RegisterMessageEvents(self, messageEvents)
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.exitCallback = args and args.exitCallback

	if args and args.hideExitBtnOnInit then
		self.bindData.exitButton:SetActive(not args.hideExitBtnOnInit)
	end
end

M.InitView = function(self, args)
	local navigationArea = args.navigationArea
	navigationArea.gamePadBar = self.bindData.gamePadBar

	navigationArea.RegisterGamePadBar(navigationArea)
	navigationArea.RefreshPCKeys(navigationArea)
	navigationArea.RefreshGamePadBar(navigationArea)
end

M.OnExitClick = function(self)
	if self.exitCallback then
		self.exitCallback()
	end
end

M.OnExitButtonStateChange = function(self, _, isActive)
	self.bindData.exitButton:SetActive(isActive)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end
