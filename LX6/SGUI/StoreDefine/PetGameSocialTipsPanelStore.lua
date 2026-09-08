-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameSocialTipsPanelStore.lua
-- Decompiled from: 00832_PetGameSocialTipsPanelStore.lua_ff278945f402.luajit

C_PetGameSocialTipsPanelStore = DefClass("C_PetGameSocialTipsPanelStore", C_PetGameSocialTipsPanelStore, C_StoreGroup)
GroupName2Class.PetGameSocialTipsPanelStore = C_PetGameSocialTipsPanelStore
local M = C_PetGameSocialTipsPanelStore

M.OnAwake = function(self)
	self.gameStartHandler = self:CreateAction(self.OnGameStart, self)

	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_PET_GAME_SOCIAL_PLAY_SYNC_STARTED, self.gameStartHandler)
end

M.OnDestroy = function(self)
	self.ClearTimer(self)

	if self.gameStartHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_PET_GAME_SOCIAL_PLAY_SYNC_STARTED, self.gameStartHandler)

		self.gameStartHandler = nil
	end
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.parentPanel = data and data.parent or nil
	self.panelId = panelId
	self.totalTime = 60
	self.enterTime = os.time()
	self.dotIndex = 0
	local root = self.bindData.slider and self.bindData.slider.transform.parent
	local tipsTrans = root and root:Find("tips")
	self.tipsText = tipsTrans and tipsTrans:GetComponent("USDFText") or nil

	self:ClearTimer()

	self.updateTimer = Timer.New(function ()
		self:UpdateInfo()
	end, 0.2, -1)

	self.updateTimer:Start()
end

M.OnClose = function(self)
	self.ClearTimer(self)

	self.parentPanel = nil
end

M.UpdateInfo = function(self)
	local interval = os.time() - self.enterTime

	if self.totalTime < interval then
		self.OnTimeOut(self)

		return
	end

	if self.bindData.slider then
		self.bindData.slider.mValue = interval / self.totalTime
	end

	if self.tipsText then
		self.dotIndex = self.dotIndex % 3 + 1
		self.tipsText.text = gPetGameMultilingual:GetText(400516) .. string.rep(".", self.dotIndex)
	end
end

M.ClearTimer = function(self)
	if self.updateTimer then
		self.updateTimer:Stop()

		self.updateTimer = nil
	end
end

M.OnTimeOut = function(self)
	self.ClearTimer(self)

	if gPetGameSocialPlayManager then
		gPetGameSocialPlayManager:StopPlayInvite()
	end

	if self.parentPanel then
		self.parentPanel:CloseChildPanel(self.panelId)
	end
end

M.OnGameStart = function(self)
	self.ClearTimer(self)

	if self.parentPanel then
		self.parentPanel:CloseChildPanel(self.panelId)
	end
end
