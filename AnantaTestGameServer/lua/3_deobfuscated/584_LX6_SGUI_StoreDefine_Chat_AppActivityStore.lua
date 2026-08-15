C_AppActivityStore = DefClass("C_AppActivityStore", C_AppActivityStore, C_PhoneAppBaseStoreGroup)
local M = C_AppActivityStore
local k_EmptyTable = {}

function M:OnClose()
	return
end

function M:GetMessageEvents()
	return k_EmptyTable
end

function M:GetDefaultShowType()
	return 0
end

function M:ShowFragment(showType, params)
	params = params or {}
	params[gClientConst.PhoneAppShowTypeLevel.SecondLevel] = showType

	self:_ShowFragment(params)
end

function M:OnRenderTab(index, widget)
	self:_OnRenderTab(index, widget)
end

function M:OnShowFragment(tabIndex, args, store, widget)
	return
end

function M:CloseCurrentFragment()
	self:_CloseCurrentFragment()
end

function M:CloseThisActivity()
	self:_CloseThisActivity()
end

function M:OnExitClick()
	self:_OnExitClick()
end

function M:GetCurrentShowType()
	local fragmentInfo = self.fragmentInfoStack:Peek()

	return fragmentInfo and self:_GetShowType(fragmentInfo)
end

function M:ShowPanel(args)
	args = args or {}
	self.showTypeField = gClientConst.PhoneAppShowTypeLevel.SecondLevel
	args[self.showTypeField] = args[self.showTypeField] or self:GetDefaultShowType()

	M.base.ShowPanel(self, args)
	self:_OnShow(args)
	self:OnShow(args[gClientConst.PhoneAppShowTypeLevel.FirstLevel], args)
end

function M:InitMessageEvents()
	M.base.InitMessageEvents(self)
	self:RegisterMessageEvents(self:_GetMessageEvents())
end

function M:_GetMessageEvents()
	return {
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction(self._OnPhoneAppHide)
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.fragmentInfoStack = gDataStructureUtils.GetStack()

	function self.fragmentInfoStack.IndexOf(stack, showType)
		if stack.count > 0 then
			for i = stack.bottomIndex, stack.topIndex do
				local fragmentInfo = stack[i]

				if self:_GetShowType(fragmentInfo) == showType then
					return i
				end
			end
		end
	end
end

function M:InitView(args)
	M.base.InitView(self, args)
	self:_ShowFragment(args)
end

function M:_ShowFragment(args)
	local fragmentInfo = {
		args = args
	}
	local showType = self:_GetShowType(fragmentInfo)

	if showType == self:GetCurrentShowType() then
		local store = self:GetCurrentFragmentStore()

		if store then
			store:_ShowFragment(args, showType, self)
		elseif args ~= self.fragmentInfoStack:Peek().args then
			print_warn("AppActivityStore: 连续的 ShowFragment! showType:", showType)
		end

		return
	end

	self.fragmentInfoStack:Delete(showType)
	self.fragmentInfoStack:Push(fragmentInfo)

	self.bindData.tabRect.selectedIndex = showType
end

function M:GetCurrentFragmentStore()
	return (self.fragmentInfoStack:Peek() or k_EmptyTable).store
end

function M:_OnRenderTab(index, widget)
	local showType = index
	local fragmentInfo = self.fragmentInfoStack:Peek()

	if self:_GetShowType(fragmentInfo) == showType then
		local store = gStoreManager:GetStoreGroup(widget.Store)
		fragmentInfo.store = store
		fragmentInfo.widget = widget

		if fragmentInfo.argsPassed then
			store:OnResume()
		else
			local tabIndex = self:_GetShowType(fragmentInfo)

			store:_ShowFragment(fragmentInfo.args, tabIndex, self)
			self:OnShowFragment(tabIndex, fragmentInfo.args, store, widget)

			fragmentInfo.argsPassed = true
		end

		self.currentStore = store
	else
		print_error("AppActivityStore.OnRenderTab: showType not match", "index", index, "widget", widget, "fragmentInfo", fragmentInfo, "fragmentInfoStack", self.fragmentInfoStack)
	end

	gClientUtils.InitNavAreasInChildren(widget, self.panelId)
end

function M:_GetShowType(fragmentInfo)
	return fragmentInfo and fragmentInfo.args and fragmentInfo.args[self.showTypeField]
end

function M:_OnExitClick()
	local currentFrag = self.fragmentInfoStack:Peek()

	if not currentFrag or not currentFrag.store:HandleExit() then
		self:CloseCurrentFragment()
	end
end

function M:OnExecuteExitAction()
	self:_OnClose()
	self:OnClose()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:_OnClose()
	while self.fragmentInfoStack.count > 0 do
		local fragmentInfo = self.fragmentInfoStack:Pop()

		if fragmentInfo.store then
			fragmentInfo.store:OnClose()
		end
	end
end

function M:_CloseThisActivity()
	self:OnExit()
end

function M:_CloseCurrentFragment()
	local fragmentInfo = self.fragmentInfoStack:Pop()

	if fragmentInfo then
		if fragmentInfo.store then
			fragmentInfo.store:OnClose()
		end

		local fragmentToShow = self.fragmentInfoStack:Peek()

		if fragmentToShow then
			self.bindData.tabRect.selectedIndex = self:_GetShowType(fragmentToShow)
		else
			self:CloseThisActivity()
		end
	else
		print_error("AppActivityStore.CloseCurrentFragment: fragmentInfoStack.count == 0", "fragmentInfoStack", self.fragmentInfoStack)
	end
end

function M:_OnPhoneAppHide()
	self:_OnBasePanelClose()
end

function M:_OnBasePanelClose(_)
	while self.fragmentInfoStack.count > 0 do
		self:CloseCurrentFragment()
	end
end

function M:_OnShow(_)
	self.panelId = gChatUtils.GetMainPhonePanelId()
end
