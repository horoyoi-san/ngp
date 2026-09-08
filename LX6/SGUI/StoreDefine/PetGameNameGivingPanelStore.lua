-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameNameGivingPanelStore.lua
-- Decompiled from: 00821_PetGameNameGivingPanelStore.lua_99980503573b.luajit

C_PetGameNameGivingPanelStore = DefClass("C_PetGameNameGivingPanelStore", C_PetGameNameGivingPanelStore, C_StoreGroup)
GroupName2Class.PetGameNameGivingPanelStore = C_PetGameNameGivingPanelStore
local M = C_PetGameNameGivingPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
	self.UnBindSystemBtn(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.UnBindSystemBtn(self)
end

M.OnShow = function(self, panelId, data)
	self.parentPanel = data.parent
	self.panelId = panelId
	self.petEntity = gPetGameManager.currentGame and gPetGameManager.currentGame.pet

	self:BindSystemBtn()

	self.bindData.confirmBtn.luaClick = self:CreateAction(self.OnNameConfirm, self)
	self.bindData.nameInput.text = ""
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.OnNameConfirm = function(self)
	local name = self.bindData.nameInput.text

	if not name or name ~= "" then
		return
	end

	self.petEntity:SetCustomName(name)
	self.parentPanel:CloseChildPanel(self.panelId)
end

M.BindSystemBtn = function(self)
	if not self.parentPanel then
		return
	end

	self.isMenuBtnPressed = false
	local eventHandler = {
		panelId = self.panelId,
		OnMenuBtnClick = self.OnMenuBtnClick,
		OnConfirmBtnClick = self.OnConfirmBtnClick,
		OnCancleBtnClick = self.OnCancleBtnClick,
		target = self
	}

	self.parentPanel:RegisterSystemBtnEvent(eventHandler)
end

M.UnBindSystemBtn = function(self)
	if self.parentPanel and self.panelId then
		self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
	end
end

M.OnMenuBtnClick = function(self)
end

M.OnConfirmBtnClick = function(self)
	self.OnNameConfirm(self)
end

M.OnCancleBtnClick = function(self)
	self.parentPanel:CloseChildPanel(self.panelId)
end
