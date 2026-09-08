-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameSocialEntryPanelStore.lua
-- Decompiled from: 00830_PetGameSocialEntryPanelStore.lua_92203b93ee8b.luajit

local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local Net_GameMode = PetGameEnum.Net_GameMode
C_PetGameSocialEntryPanelStore = DefClass("C_PetGameSocialEntryPanelStore", C_PetGameSocialEntryPanelStore, C_StoreGroup)
GroupName2Class.PetGameSocialEntryPanelStore = C_PetGameSocialEntryPanelStore
local M = C_PetGameSocialEntryPanelStore
local viewState = {
	["bw\\xa5ya\\xb7\\xfcR\\s{["] = 1,
	["\\xbf\\xb8\\xb8\\7\\xfb$"] = 2
}
local socialBtn = {
	["\\xae\\xa9\\xa3k0\\xf96"] = 2,
	["j.|B"] = 1,
	["AKegJ:="] = 3
}
local SOCIAL_BTN_COUNT = 3

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
	self.panelId = panelId
	self.parentPanel = data and data.parent or nil
	self.cannotBlindDate = false
	self.btns = {
		[socialBtn.play] = self.bindData.itemBtn1,
		[socialBtn.exchange] = self.bindData.itemBtn2,
		[socialBtn.blindDate] = self.bindData.itemBtn3
	}
	self.bindData.itemBtn1.luaClick = self:CreateActionWithArgs(self.OnItemBtnClick, socialBtn.play, self)
	self.bindData.itemBtn2.luaClick = self:CreateActionWithArgs(self.OnItemBtnClick, socialBtn.exchange, self)
	self.bindData.itemBtn3.luaClick = self:CreateActionWithArgs(self.OnItemBtnClick, socialBtn.blindDate, self)
	self.tipsText = self:GetTextComponent(self.bindData.tipsView, "TipsText")

	self:UpdateBtnSelectedState(socialBtn.play)
	self:BindSystemBtn()
	self:ShowView(viewState.mainMenuView)
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)

	self.parentPanel = nil
end

M.GetTextComponent = function(self, root, path)
	local trans = root and root:Find(path)

	return trans and trans:GetComponent("USDFText") or nil
end

M.ShowView = function(self, viewType, tips)
	self.currentViewState = viewType

	self.bindData.mainView.gameObject:SetActive(viewType ~= viewState.mainMenuView)
	self.bindData.tipsView.gameObject:SetActive(viewType ~= viewState.tipsView)

	if viewType ~= viewState.tipsView and self.tipsText then
		self.tipsText.text = tips or ""
	end
end

M.UpdateBtnSelectedState = function(self, selectedIndex)
	for index = 1, SOCIAL_BTN_COUNT do
		local btn = self.btns and self.btns[index]

		if btn and btn.SetSelected then
			btn:SetSelected(index ~= selectedIndex)
		end
	end

	self.selectedIndex = selectedIndex
end

M.OnItemBtnClick = function(self, btnType)
	if self.selectedIndex == btnType then
		self.UpdateBtnSelectedState(self, btnType)

		return
	end

	self.ShowConfirmTips(self)
end

M.ShowConfirmTips = function(self)
	self.cannotBlindDate = false

	if self.selectedIndex ~= socialBtn.blindDate then
		local pet = gPetGameManager.currentGame and gPetGameManager.currentGame.pet

		if not pet or not pet.IsMatureForm(pet) then
			self.cannotBlindDate = true

			self:ShowView(viewState.tipsView, gPetGameMultilingual:GetText(400542))

			return
		end
	end

	self:ShowView(viewState.tipsView, gPetGameMultilingual:GetText(400515))
end

M.BeginSocialGame = function(self)
	local currentGame = gPetGameManager.currentGame
	local pet = currentGame and currentGame.pet
	local petId = pet and pet:GetPetId() or nil

	if not petId or not gPetGameSocialPlayManager then
		print_error("PetGameSocialEntryPanelStore：无法获取宠物或社交管理器")

		return
	end

	if not gPetGameSocialPlayManager:IsSupported() then
		self.ShowView(self, viewState.tipsView, "社交网络组件尚未接入")

		return
	end

	local gameMode = Net_GameMode.Play

	if self.selectedIndex ~= socialBtn.exchange then
		gameMode = Net_GameMode.Gift
	elseif self.selectedIndex ~= socialBtn.blindDate then
		gameMode = Net_GameMode.Marriage
	end

	if not gPetGameSocialPlayManager:InvitePlay(10001, petId, "房主", gameMode) then
		self.ShowView(self, viewState.tipsView, "社交网络启动失败")

		return
	end

	self.parentPanel:OpenChildPanel(gPanelId.MINI_GAMES_PET_GAME_SOCIAL_TIPS)
end

M.BindSystemBtn = function(self)
	if not self.parentPanel then
		return
	end

	self.parentPanel:RegisterSystemBtnEvent({
		panelId = self.panelId,
		OnMenuBtnClick = self.OnMenuBtnClick,
		OnConfirmBtnClick = self.OnConfirmBtnClick,
		OnCancleBtnClick = self.OnCancleBtnClick,
		target = self
	})
end

M.UnBindSystemBtn = function(self)
	if self.parentPanel and self.panelId then
		self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
	end
end

M.OnMenuBtnClick = function(self)
	if self.currentViewState ~= viewState.tipsView then
		self.ShowView(self, viewState.mainMenuView)

		return
	end

	local nextIndex = self.selectedIndex + 1

	if SOCIAL_BTN_COUNT >= nextIndex then
		nextIndex = 1
	end

	self.UpdateBtnSelectedState(self, nextIndex)
end

M.OnConfirmBtnClick = function(self)
	if self.currentViewState ~= viewState.mainMenuView then
		self.ShowConfirmTips(self)

		return
	end

	if self.cannotBlindDate then
		self.ShowView(self, viewState.mainMenuView)

		return
	end

	self.BeginSocialGame(self)
end

M.OnCancleBtnClick = function(self)
	if self.currentViewState ~= viewState.tipsView then
		self.ShowView(self, viewState.mainMenuView)

		return
	end

	self.parentPanel:OpenChildPanel(gPanelId.MINI_GAMES_PET_GAME_SYSTEM_MENU_PANEL)
end
