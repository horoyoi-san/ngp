-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameSettingPanelStore.lua
-- Decompiled from: 00824_PetGameSettingPanelStore.lua_ac333e1e724a.luajit

C_PetGameSettingPanelStore = DefClass("C_PetGameSettingPanelStore", C_PetGameSettingPanelStore, C_StoreGroup)
GroupName2Class.PetGameSettingPanelStore = C_PetGameSettingPanelStore
local M = C_PetGameSettingPanelStore

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
	self:ShowPetState()
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.ShowPetState = function(self)
	if not self.petEntity then
		print_error("找不到宠物")

		return
	end

	local petData = self.petEntity:GetPetData()
	self.bindData.hungerValSlider.value = petData.hungerValue / 20
	self.bindData.happinessValSlider.value = petData.moodValue / 6
	local money = self.petEntity:GetMoney()
	self.bindData.MoneyText.text = tostring(money)
end

M.BindSystemBtn = function(self)
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
	self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
end

M.OnMenuBtnClick = function(self)
end

M.OnConfirmBtnClick = function(self)
end

M.OnCancleBtnClick = function(self)
	self.parentPanel:CloseChildPanel(self.panelId)
end
