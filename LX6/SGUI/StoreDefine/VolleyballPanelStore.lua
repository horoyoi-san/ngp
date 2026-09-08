-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\VolleyballPanelStore.lua
-- Decompiled from: 01146_VolleyballPanelStore.lua_f7e05d3b7bf9.luajit

C_VolleyballPanelStore = DefClass("C_VolleyballPanelStore", C_VolleyballPanelStore, C_StoreGroup)
GroupName2Class.VolleyballPanelStore = C_VolleyballPanelStore
local M = C_VolleyballPanelStore

M.OnAwake = function(self)
	self.playerController = nil
	self.luaPlayerController = nil
	self.inputX = 0
	self.inputY = 0
	self.input = Vector2.New(0, 0)
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.btnA.luaClick = self.CreateAction(self, "OnClickButtonA")
	self.bindData.btnB.luaClick = self.CreateAction(self, "OnClickButtonB")

	if data.playerController then
		self.playerController = data.playerController

		self.playerController:SetUITakeOverMove(false)

		self.playerController.StoreTable = self
	end

	if data.luaPlayerController then
		self.luaPlayerController = data.luaPlayerController
		self.luaPlayerController.gamePanel = self
	end

	if data.finishCb then
		data.finishCb()
	end
end

M.OnClose = function(self)
end

M.ChangeButtonState = function(self, hideCtrl, imageACtrl, imageBCtrl)
	self.bindData.HideCtrl = hideCtrl
	self.bindData.imageACtrl = imageACtrl
	self.bindData.imageBCtrl = imageBCtrl
end

M.ChangeButtonInteractable = function(self, interactable)
	self.bindData.btnA.interactable = interactable
	self.bindData.btnB.interactable = interactable
end

M.OnClickButtonA = function(self, btn, index, data)
	if self.playerController then
		self.playerController:ClickA()
	end

	if self.luaPlayerController then
		self.luaPlayerController:ClickMouse(true)
	end
end

M.OnClickButtonB = function(self, btn, index, data)
	if self.playerController then
		self.playerController:ClickB()
	end

	if self.luaPlayerController then
		self.luaPlayerController:ClickMouse(false)
	end
end

M.OnJoyStickValueChange = function(self, x, y, value)
	self.input.x = x
	self.input.y = y

	self.playerController:InputByUI(self.input)
end
