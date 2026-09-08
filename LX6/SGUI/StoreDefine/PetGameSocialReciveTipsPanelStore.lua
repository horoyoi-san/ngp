-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameSocialReciveTipsPanelStore.lua
-- Decompiled from: 00831_PetGameSocialReciveTipsPanelStore.lua_b13b9860a5e6.luajit

local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local Net_GameMode = PetGameEnum.Net_GameMode
C_PetGameSocialReciveTipsPanelStore = DefClass("C_PetGameSocialReciveTipsPanelStore", C_PetGameSocialReciveTipsPanelStore, C_StoreGroup)
GroupName2Class.PetGameSocialReciveTipsPanelStore = C_PetGameSocialReciveTipsPanelStore
local M = C_PetGameSocialReciveTipsPanelStore
local receiveBtn = {
	["\\x97mu"] = 1,
	[""] = 2
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
	data = data or {}
	self.panelId = panelId
	self.parentPanel = data.parent
	self.roomData = data.roomData
	self.bindData.tipsYesBtn.luaClick = self:CreateAction(self.OnYesBtnClick, self)
	self.bindData.tipsNoBtn.luaClick = self:CreateAction(self.OnNoBtnClick, self)

	self:UpdateBtnSelectedState(receiveBtn.yes)
	self:ShowInviteTips()
	self:BindSystemBtn()
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)

	self.roomData = nil
	self.parentPanel = nil
end

M.UpdateBtnSelectedState = function(self, selectedIndex)
	local buttons = {
		[receiveBtn.yes] = self.bindData.tipsYesBtn,
		[receiveBtn.no] = self.bindData.tipsNoBtn
	}

	for index, btn in pairs(buttons) do
		if btn and btn.SetSelected then
			btn:SetSelected(index ~= selectedIndex)
		end
	end

	self.selectedIndex = selectedIndex
end

M.IsBtnSelected = function(self, index)
	if self.selectedIndex == index then
		self.UpdateBtnSelectedState(self, index)

		return false
	end

	return true
end

M.ShowInviteTips = function(self)
	if not self.bindData.tipsText or not self.roomData then
		return
	end

	local tipsId = 400543

	if self.roomData.GameMode ~= Net_GameMode.Gift then
		tipsId = 400544
	elseif self.roomData.GameMode ~= Net_GameMode.Marriage then
		tipsId = 400545
	end

	local tips = gPetGameMultilingual:GetText(tipsId)
	local hostName = self.roomData.HostName

	if hostName and hostName == "" then
		tips = string.format(tips, hostName)
	end

	self.bindData.tipsText.text = tips
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
	local nextIndex = self.selectedIndex ~= receiveBtn.yes and receiveBtn.no or receiveBtn.yes

	self:UpdateBtnSelectedState(nextIndex)
end

M.OnConfirmBtnClick = function(self)
	if self.selectedIndex ~= receiveBtn.yes then
		self.OnYesBtnClick(self)
	else
		self.OnNoBtnClick(self)
	end
end

M.OnCancleBtnClick = function(self)
	self.OnNoBtnClick(self)
end

M.OnYesBtnClick = function(self)
	if not self.IsBtnSelected(self, receiveBtn.yes) then
		return
	end

	local roomId = self.roomData and self.roomData.RoomId

	if not roomId or not gPetGameSocialPlayManager then
		print_error("PetGameSocialReciveTipsPanelStore：邀请数据或社交管理器为空")
		self.CloseSelf(self)

		return
	end

	local currentGame = gPetGameManager.currentGame
	local pet = currentGame and currentGame:GetPetEnity()
	local petId = pet and pet:GetPetId() or nil

	if not gPetGameSocialPlayManager:AcceptPlayInvite(roomId, 10002, petId, "玩家") then
		print_error("PetGameSocialReciveTipsPanelStore：社交网络启动失败")

		return
	end

	self.parentPanel:OpenChildPanel(gPanelId.MINI_GAMES_PET_GAME_SOCIAL_TIPS)
end

M.OnNoBtnClick = function(self)
	if not self.IsBtnSelected(self, receiveBtn.no) then
		return
	end

	local roomId = self.roomData and self.roomData.RoomId

	if roomId and gPetGameSocialPlayManager then
		gPetGameSocialPlayManager:RejectPlayInvite(roomId)
	end

	self.CloseSelf(self)
end

M.CloseSelf = function(self)
	if self.parentPanel then
		self.parentPanel:CloseChildPanel(self.panelId)
	end
end
