-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameSleepPanelStore.lua
-- Decompiled from: 00829_PetGameSleepPanelStore.lua_6da332aba37e.luajit

C_PetGameSleepPanelStore = DefClass("C_PetGameSleepPanelStore", C_PetGameSleepPanelStore, C_StoreGroup)
GroupName2Class.PetGameSleepPanelStore = C_PetGameSleepPanelStore
local M = C_PetGameSleepPanelStore
local sleepTipsBtn = {
	["M\\x82\\xac\\x97O"] = 1,
	["C\\xa1\\x80\\xbb\\xb8"] = 2
}
local SleepMode = {
	["+I\\x9a\\x8b\\xb6Q"] = 2,
	["vTڸ\\x96;\\xb4\\xcc\\xf8"] = 1
}

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
	if not data then
		return
	end

	self.parentPanel = data.parent
	self.panelId = panelId
	self.petEntity = gPetGameManager.currentGame and gPetGameManager.currentGame.pet
	self.mode = self:GetMode(panelId)

	self:BindSystemBtn()

	self.bindData.tipsYesBtn.luaClick = self:CreateAction(self.OnYesBtnClick, self)
	self.bindData.tipsNoBtn.luaClick = self:CreateAction(self.OnNoBtnClick, self)
	self.btns = {
		[sleepTipsBtn.yesBtn] = self.bindData.tipsYesBtn,
		[sleepTipsBtn.noBtn] = self.bindData.tipsNoBtn
	}
	self.btnSelectedState = {}

	self:ReSetBtnSlectedState(self.btnSelectedState, self.btns, sleepTipsBtn.yesBtn)

	if self.mode ~= SleepMode.WakeUp then
		self.bindData.pageCtrl = 1
		self.bindData.tipsText.text = gPetGameMultilingual:GetText(400507)
	else
		self.bindData.pageCtrl = 0
		self.bindData.tipsText.text = gPetGameMultilingual:GetText(400506)
	end
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.GetMode = function(self, panelId)
	if panelId ~= gPanelId.MINI_GAMES_PET_GAME_WAKE_UP then
		return SleepMode.WakeUp
	end

	return SleepMode.EnterSleep
end

M.ReSetBtnSlectedState = function(self, btnSelectedState, btns, defaultBtnType)
	for k, _ in pairs(btns) do
		btnSelectedState[k] = false
	end

	self.UpdateBtnSlectedState(self, defaultBtnType, btnSelectedState, btns)
end

M.UpdateBtnSlectedState = function(self, selectedBtnType, btnSelectedState, btns)
	for k, btn in pairs(btns) do
		local active = k ~= selectedBtnType
		btnSelectedState[k] = active

		if btn and btn.SetSelected then
			btn.SetSelected(btn, active)
		end
	end

	self.selectedIndex = selectedBtnType
end

M.isBtnSelected = function(self, selectedBtnType, btnSelectedState, btns)
	if not btnSelectedState[selectedBtnType] then
		self.UpdateBtnSlectedState(self, selectedBtnType, btnSelectedState, btns)

		return false
	end

	return true
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
	if self.parentPanel and self.panelId then
		self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
	end
end

M.OnMenuBtnClick = function(self)
	local maxIndex = #self.btns
	self.selectedIndex = (self.selectedIndex or 0) + 1

	if maxIndex >= self.selectedIndex then
		self.selectedIndex = 1
	end

	self.UpdateBtnSlectedState(self, self.selectedIndex, self.btnSelectedState, self.btns)
end

M.OnConfirmBtnClick = function(self)
	if self.selectedIndex ~= sleepTipsBtn.yesBtn then
		self.OnYesBtnClick(self)
	else
		self.OnNoBtnClick(self)
	end
end

M.OnCancleBtnClick = function(self)
	self.parentPanel:CloseChildPanel(self.panelId)
end

M.OnYesBtnClick = function(self)
	if not self.isBtnSelected(self, sleepTipsBtn.yesBtn, self.btnSelectedState, self.btns) then
		return
	end

	self.parentPanel:CloseChildPanel(self.panelId)

	local pet = gPetGameManager.currentGame and gPetGameManager.currentGame.pet

	if not pet then
		return
	end

	if self.mode ~= SleepMode.WakeUp then
		pet.AheadOfWakeUp(pet)
	else
		pet.AheadOfGo2Sleep(pet)
	end
end

M.OnNoBtnClick = function(self)
	if not self.isBtnSelected(self, sleepTipsBtn.noBtn, self.btnSelectedState, self.btns) then
		return
	end

	self.parentPanel:CloseChildPanel(self.panelId)

	if self.mode ~= SleepMode.EnterSleep then
		self.parentPanel:ShowSystemMenu()
	end
end
