C_VolleyballPanelStore = DefClass("C_VolleyballPanelStore", C_VolleyballPanelStore, C_StoreGroup)
GroupName2Class.VolleyballPanelStore = C_VolleyballPanelStore
local M = C_VolleyballPanelStore

function M:OnAwake()
	self.playerController = nil
	self.luaPlayerController = nil
	self.inputX = 0
	self.inputY = 0
	self.input = Vector2.New(0, 0)
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.bindData.btnA.luaClick = self:CreateAction("OnClickButtonA")
	self.bindData.btnB.luaClick = self:CreateAction("OnClickButtonB")

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

function M:OnClose()
	return
end

function M:ChangeButtonState(hideCtrl, imageACtrl, imageBCtrl)
	self.bindData.HideCtrl = hideCtrl
	self.bindData.imageACtrl = imageACtrl
	self.bindData.imageBCtrl = imageBCtrl
end

function M:ChangeButtonInteractable(interactable)
	self.bindData.btnA.interactable = interactable
	self.bindData.btnB.interactable = interactable
end

function M:OnClickButtonA(btn, index, data)
	if self.playerController then
		self.playerController:ClickA()
	end

	if self.luaPlayerController then
		self.luaPlayerController:ClickMouse(true)
	end
end

function M:OnClickButtonB(btn, index, data)
	if self.playerController then
		self.playerController:ClickB()
	end

	if self.luaPlayerController then
		self.luaPlayerController:ClickMouse(false)
	end
end

function M:OnJoyStickValueChange(x, y, value)
	self.input.x = x
	self.input.y = y

	self.playerController:InputByUI(self.input)
end
