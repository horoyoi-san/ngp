-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneApp\PhoneAppBaseStoreGroup.lua
-- Decompiled from: 01232_PhoneAppBaseStoreGroup.lua_d0d387840173.luajit

C_PhoneAppBaseStoreGroup = DefClass("C_PhoneAppBaseStoreGroup", C_PhoneAppBaseStoreGroup, C_StoreGroup)
local M = C_PhoneAppBaseStoreGroup

M.OnShow = function(self, _, _)
end

M.ShowPanel = function(self, args)
	if self.panelArgs ~= args then
		self.PlayPanelAnimation(self, false)

		return false
	end

	self.panelArgs = args

	self.PlayPanelAnimation(self, args.isFromMainPhone)
	self.InitMessageEvents(self)
	self.InitModel(self, args)
	self.InitView(self, args)

	if self.rootWidget and args.fromPosition and not args.hasPlayOpenAnimation then
		self.customEventAnimation = self.rootWidget:GetComponentInChildren(typeof(L50.Script.SGUI.UPlayCustomEventAnimation))

		if self.customEventAnimation then
			args.hasPlayOpenAnimation = true
			local initRootPosition = self.customEventAnimation.transform.position
			self.customEventAnimation.transform.position = args.fromPosition

			self.customEventAnimation:DoMove(initRootPosition)
		end
	end

	return true
end

local panelAnimCtrl = 1773233425

M.PlayPanelAnimation = function(self, isFromMainPhone)
	local rootWidget = self.rootWidget

	if gClientUtils.NotNil(rootWidget) and rootWidget.TryChangePage then
		local target = isFromMainPhone and 1 or 2

		rootWidget:TryChangePage(panelAnimCtrl, target)
	end
end

M.InitMessageEvents = function(self)
	self:ClearMessageEvents()

	local messageEvents = self.GetMessageEvents and self:GetMessageEvents()

	if messageEvents then
		self.RegisterMessageEvents(self, messageEvents)
	end
end

M.InitModel = function(self, _)
	self.hasDestroy = nil
end

M.InitView = function(self, _)
end

M.ClearStoreGroupData = function(self)
	self.ClearMessageEvents(self)

	self.customEventAnimation = nil
	self.panelArgs = nil
	self.currentTabStore = nil

	if self.hasDestroy then
		return
	end

	self.hasDestroy = true

	self.ClearData(self)
end

M.ClearData = function(self)
end

M.OnExit = function(self)
	self.PlayCloseAnimation(self)
	self.OnExecuteExitAction(self)
	self.ClearStoreGroupData(self)
end

M.PlayCloseAnimation = function(self)
	if not self.panelArgs or self.panelArgs.hasPlayCloseAnimation or gClientUtils.IsNil(self.customEventAnimation) then
		return
	end

	if self.customEventAnimation and self.panelArgs.fromPosition then
		local rootWidget = self.rootWidget

		if gClientUtils.NotNil(rootWidget) and rootWidget.TryChangePage then
			rootWidget.TryChangePage(rootWidget, panelAnimCtrl, 0)
		end

		if self.bindData.bindWidget then
			self.bindData.bindWidget.activeCtrlDelay = 0.4
		end

		self.panelArgs.hasPlayCloseAnimation = true

		self.customEventAnimation:DoMove(self.panelArgs.fromPosition, false)
	end
end

M.OnExitClick = function(self)
	self.OnExit(self)
end

M.OnExecuteExitAction = function(self)
end

M.OnInputFieldActivate = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_INPUT_FIELD_ACTIVE)
end

M.OnInputFieldDeActivate = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_INPUT_FIELD_DE_ACTIVE)
end

M.PlayBackToMainAnimation = function(self)
end

M.OnDestroy = function(self)
	self.ClearStoreGroupData(self)
end
