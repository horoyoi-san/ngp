-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\DialogControlPanelStore.lua
-- Decompiled from: 01204_DialogControlPanelStore.lua_b8d1e6de2e2a.luajit

C_DialogControlPanelStore = DefClass("C_DialogControlPanelStore", C_DialogControlPanelStore, C_StoreGroup)
GroupName2Class.DialogControlPanelStore = C_DialogControlPanelStore
local M = C_DialogControlPanelStore

M.OnAwake = function(self)
	self.mode = 0

	if not self.EventHandler then
		self.EventHandler = {
			[gEventConstants.DIALOG_REFRESH_CONTROLLER] = function (eventId, param)
				self:SetBtnStateByCS(param)
			end
		}
	end
end

M.OnUpdate = function(self)
	if self.mode ~= 0 then
		return
	end

	if gDialogManager:IsBranchShowing() then
		self.bindData.DialogControl:SetActive(false)
	else
		self.bindData.DialogControl:SetActive(true)
	end
end

M.OnShow = function(self, panelId, data)
	local store = self.GetDialogComponentStore(self, self.bindData.DialogControl)
	self.store = store
	store.btnSpeed0.luaClick = self.CreateAction(self, "OnSpeedClick")
	store.btnSpeed1.luaClick = self.CreateAction(self, "OnSpeedClick")
	store.btnSpeed125.luaClick = self.CreateAction(self, "OnSpeedClick")
	store.btnSpeed2.luaClick = self.CreateAction(self, "OnSpeedClick")
	store.btnSpeed3.luaClick = self.CreateAction(self, "OnSpeedClick")
	store.btnSkip.luaClick = self.CreateAction(self, "OnJumpDialogClick")
	store.btnPause.luaClick = self.CreateAction(self, "OnPauseClick")
	store.btnResume.luaClick = self.CreateAction(self, "OnPauseClick")

	self.SetBtnStateByCS(self, data)
end

M.OnEnable = function(self)
	self.BindListener(self)
end

M.OnDisable = function(self)
	self.UnbindListener(self)
end

M.OnClose = function(self)
	self.mode = 0
end

M.BindListener = function(self)
	if not self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		self.IsBindListener = true
	end
end

M.UnbindListener = function(self)
	if self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:RemoveMessageListener(i, v)
		end

		self.IsBindListener = false
	end
end

M.GetDialogComponentStore = function(self, widget)
	return gStoreManager:GetStoreGroup("S_DialogComponentStore"):GetStoreByWidget(widget)
end

M.SetBtnStateByCS = function(self, data)
	local param = data.ToTable(data)

	self.SetBtnState(self, param.mode, param.showSpeed, param.speedIndex, param.showSkip, param.showPause, param.pauseState)
end

M.SetBtnState = function(self, mode, showSpeed, speedIndex, showSkip, showPause, pauseState)
	if not self.store then
		return
	end

	self.mode = mode

	if mode ~= 0 then
		self.ShowSkip(self, false)
		self.ShowSpeed(self, false)
		self.ShowPause(self, false)
	elseif mode ~= 1 then
		self.ShowSkip(self, showSkip)
		self.ShowSpeed(self, showSpeed, speedIndex)
		self.ShowPause(self, false)
	elseif mode ~= 2 then
		self.ShowSkip(self, showSkip)
		self.ShowSpeed(self, showSpeed, speedIndex)
		self.ShowPause(self, showPause)

		if showPause then
			self.SetPauseState(self, pauseState)
		end
	elseif mode ~= 3 then
		self.ShowSkip(self, false)
		self.ShowSpeed(self, false)
		self.ShowPause(self, false)
	end
end

M.SetPauseState = function(self, pause)
	if pause then
		self.bindData.pauseState = 0
	else
		self.bindData.pauseState = 1
	end
end

M.ShowPause = function(self, enable)
	if not self.store.btnPauseRoot then
		return
	end

	self.store.btnPauseRoot:SetActive(enable)
end

M.ShowSkip = function(self, enable)
	if not self.store.btnSkip then
		return
	end

	self.store.btnSkip:SetActive(enable)
end

M.ShowSpeed = function(self, enable, speedIndex)
	if not self.store.btnSpeedRoot then
		return
	end

	self.store.btnSpeedRoot:SetActive(enable)

	if enable then
		self.store.autoSpeed = speedIndex
	end
end

M.OnJumpDialogClick = function(self)
	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		["n;m^"] = 3,
		dialogId = self.dialogId
	})
end

M.OnSpeedClick = function(self)
	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		["n;m^"] = 4,
		dialogId = self.dialogId
	})
end

M.OnPauseClick = function(self)
	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		["n;m^"] = 2,
		dialogId = self.dialogId
	})
end
