C_PhoneAppBaseStoreGroup = DefClass("C_PhoneAppBaseStoreGroup", C_PhoneAppBaseStoreGroup, C_StoreGroup)
local M = C_PhoneAppBaseStoreGroup

function M:OnShow(_, _)
	return
end

function M:ShowPanel(args)
	if self.panelArgs == args then
		self:PlayPanelAnimation(false)

		return false
	end

	self.panelArgs = args

	self:PlayPanelAnimation(args.isFromMainPhone)
	self:InitMessageEvents()
	self:InitModel(args)
	self:InitView(args)

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

function M:PlayPanelAnimation(isFromMainPhone)
	local rootWidget = self.rootWidget

	if gClientUtils.NotNil(rootWidget) and rootWidget.TryChangePage then
		local target = isFromMainPhone and 1 or 2

		rootWidget:TryChangePage(panelAnimCtrl, target)
	end
end

function M:InitMessageEvents()
	self:ClearMessageEvents()

	local messageEvents = self.GetMessageEvents and self:GetMessageEvents()

	if messageEvents then
		self:RegisterMessageEvents(messageEvents)
	end
end

function M:InitModel(_)
	self.hasDestroy = nil
end

function M:InitView(_)
	return
end

function M:ClearStoreGroupData()
	self:ClearMessageEvents()

	self.customEventAnimation = nil
	self.panelArgs = nil
	self.currentTabStore = nil

	if self.hasDestroy then
		return
	end

	self.hasDestroy = true

	self:ClearData()
end

function M:ClearData()
	return
end

function M:OnExit()
	self:PlayCloseAnimation()
	self:OnExecuteExitAction()
	self:ClearStoreGroupData()
end

function M:PlayCloseAnimation()
	if not self.panelArgs or self.panelArgs.hasPlayCloseAnimation or gClientUtils.IsNil(self.customEventAnimation) then
		return
	end

	if self.customEventAnimation and self.panelArgs.fromPosition then
		local rootWidget = self.rootWidget

		if gClientUtils.NotNil(rootWidget) and rootWidget.TryChangePage then
			rootWidget:TryChangePage(panelAnimCtrl, 0)
		end

		if self.bindData.bindWidget then
			self.bindData.bindWidget.activeCtrlDelay = 0.4
		end

		self.panelArgs.hasPlayCloseAnimation = true

		self.customEventAnimation:DoMove(self.panelArgs.fromPosition, false)
	end
end

function M:OnExitClick()
	self:OnExit()
end

function M:OnExecuteExitAction()
	return
end

function M:OnInputFieldActivate()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_INPUT_FIELD_ACTIVE)
end

function M:OnInputFieldDeActivate()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_INPUT_FIELD_DE_ACTIVE)
end

function M:PlayBackToMainAnimation()
	return
end

function M:OnDestroy()
	self:ClearStoreGroupData()
end
