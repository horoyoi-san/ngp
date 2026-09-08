-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneConfirmPanelStore.lua
-- Decompiled from: 02039_PhoneConfirmPanelStore.lua_833ea88435b5.luajit

C_PhoneConfirmPanelStore = DefClass("C_PhoneConfirmPanelStore", C_PhoneConfirmPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneConfirmPanelStore = C_PhoneConfirmPanelStore
local M = C_PhoneConfirmPanelStore

M.OnAwake = function(self)
	self.bindData.confirmButton.luaClick = self.CreateAction(self, self.OnConfirmClick)
	self.bindData.cancelButton.luaClick = self.CreateAction(self, self.OnCancelClick)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnCancelClick)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.onConfirmCallback = args.onConfirmCallback
	self.onCancelCallback = args.onCancelCallback
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self:RefreshPanelView(args)

	self.bindData.buttonState = args.buttonState or 0

	if args.autoCloseTime then
		self.StartAutoCloseCo(self, args.autoCloseTime)
	end
end

M.StartAutoCloseCo = function(self, delayTime)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(delayTime)
		self:ClosePanel()
	end)
end

M.RefreshPanelView = function(self, args)
	if args.title then
		self.bindData.title = args.title
	end

	if args.description then
		self.bindData.description = args.description
	end
end

M.OnConfirmClick = function(self)
	if self.onConfirmCallback then
		self.onConfirmCallback()
	end

	self.ClosePanel(self)
end

M.OnCancelClick = function(self)
	if self.onCancelCallback then
		self.onCancelCallback()
	end

	self.ClosePanel(self)
end

M.ClosePanel = function(self)
	local animationName = "S_Vx_PhoneConfirmPanel_close"

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)

	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)
	local rootGo = self.rootGo
	self.playCloseAnimationCo = coroutine.start(function ()
		coroutine.wait(clipTime)

		if gClientUtils.NotNil(rootGo) then
			gMainPhoneUtils.CloseFrontContent()
		end
	end)
end

M.ClearData = function(self)
	self.onCancelCallback = nil
	self.onCancelCallback = nil
	self.playCloseAnimationCo = coroutine.stop(self.playCloseAnimationCo)
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
end
