-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameGetPetPanelStore.lua
-- Decompiled from: 00926_PetGameGetPetPanelStore.lua_0778ca677826.luajit

C_PetGameGetPetPanelStore = DefClass("C_PetGameGetPetPanelStore", C_PetGameGetPetPanelStore, C_StoreGroup)
GroupName2Class.PetGameGetPetPanelStore = C_PetGameGetPetPanelStore
local M = C_PetGameGetPetPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
	self.UnBindSystemBtn(self)
end

M.OnStart = function(self)
	self.bindData.Item.luaClick = self.CreateAction(self, self.OnItemClick, self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.UnBindSystemBtn(self)
end

M.OnShow = function(self, panelId, data)
	self.parentPanel = data.parent

	self.BindSystemBtn(self)
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.BindSystemBtn = function(self)
	self.isMenuBtnPressed = false
	local eventHandler = {
		panelId = gPanelId.MINI_GAMES_PET_GAME_GET_PET_PANEL,
		OnMenuBtnPressed = self.OnMenuBtnPressed,
		OnConfirmBtnClick = self.OnConfirmBtnClick,
		target = self
	}

	self.parentPanel:RegisterSystemBtnEvent(eventHandler)
end

M.UnBindSystemBtn = function(self)
	self.parentPanel:UnregisterSystemBtnEvent(gPanelId.MINI_GAMES_PET_GAME_GET_PET_PANEL)
end

M.OnMenuBtnPressed = function(self, isPressed)
	if isPressed then
		self.isMenuBtnPressed = isPressed
	end

	if self.isMenuBtnPressed and not isPressed then
		self.OnItemClick(self)
	end
end

M.OnConfirmBtnClick = function(self)
	self.OnItemClick(self)
end

M.OnItemClick = function(self)
	self.parentPanel:OpenChildPanel(gPanelId.MINI_GAMES_PET_GAME_CHOOSE_REGION)
end
