C_PhoneConfirmPanelStore = DefClass("C_PhoneConfirmPanelStore", C_PhoneConfirmPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneConfirmPanelStore = C_PhoneConfirmPanelStore
local M = C_PhoneConfirmPanelStore

function M:OnAwake()
	self.bindData.confirmButton.luaClick = self:CreateAction(self.OnConfirmClick)
	self.bindData.cancelButton.luaClick = self:CreateAction(self.OnCancelClick)
	self.bindData.fullScreenButton.luaClick = self:CreateAction(self.OnCancelClick)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.onConfirmCallback = args.onConfirmCallback
	self.onCancelCallback = args.onCancelCallback
end

function M:InitView(args)
	M.base.InitView(self, args)
	self:RefreshPanelView(args)

	self.bindData.buttonState = args.buttonState or 0

	if args.autoCloseTime then
		self:StartAutoCloseCo(args.autoCloseTime)
	end
end

function M:StartAutoCloseCo(delayTime)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(delayTime)
		self:ClosePanel()
	end)
end

function M:RefreshPanelView(args)
	if args.title then
		self.bindData.title = args.title
	end

	if args.description then
		self.bindData.description = args.description
	end
end

function M:OnConfirmClick()
	if self.onConfirmCallback then
		self.onConfirmCallback()
	end

	self:ClosePanel()
end

function M:OnCancelClick()
	if self.onCancelCallback then
		self.onCancelCallback()
	end

	self:ClosePanel()
end

function M:ClosePanel()
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

function M:ClearData()
	self.onCancelCallback = nil
	self.onCancelCallback = nil
	self.playCloseAnimationCo = coroutine.stop(self.playCloseAnimationCo)
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
end
