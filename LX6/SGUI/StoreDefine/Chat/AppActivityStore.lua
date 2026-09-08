-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\AppActivityStore.lua
-- Decompiled from: 01925_AppActivityStore.lua_e10d9747eaf1.luajit

C_AppActivityStore = DefClass("C_AppActivityStore", C_AppActivityStore, C_PhoneAppBaseStoreGroup)
local M = C_AppActivityStore
local k_EmptyTable = {}

M.OnClose = function(self)
end

M.GetMessageEvents = function(self)
	return k_EmptyTable
end

M.GetDefaultShowType = function(self)
	return 0
end

M.ShowFragment = function(self, showType, params)
	params = params or {}
	params[gClientConst.PhoneAppShowTypeLevel.SecondLevel] = showType

	self:_ShowFragment(params)
end

M.OnRenderTab = function(self, index, widget)
	self._OnRenderTab(self, index, widget)
end

M.OnShowFragment = function(self, tabIndex, args, store, widget)
end

M.CloseCurrentFragment = function(self)
	self._CloseCurrentFragment(self)
end

M.CloseThisActivity = function(self)
	self._CloseThisActivity(self)
end

M.OnExitClick = function(self)
	self._OnExitClick(self)
end

M.GetCurrentShowType = function(self)
	local fragmentInfo = self.fragmentInfoStack:Peek()

	return fragmentInfo and self:_GetShowType(fragmentInfo)
end

M.ShowPanel = function(self, args)
	args = args or {}
	self.showTypeField = gClientConst.PhoneAppShowTypeLevel.SecondLevel
	args[self.showTypeField] = args[self.showTypeField] or self:GetDefaultShowType()

	M.base.ShowPanel(self, args)
	self:_OnShow(args)
	self:OnShow(args[gClientConst.PhoneAppShowTypeLevel.FirstLevel], args)
end

M.InitMessageEvents = function(self)
	M.base.InitMessageEvents(self)
	self.RegisterMessageEvents(self, self._GetMessageEvents(self))
end

M._GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, self._OnPhoneAppHide)
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.fragmentInfoStack = gDataStructureUtils.GetStack()

	self.fragmentInfoStack.IndexOf = function(stack, showType)
		if stack.count <= 0 then
			for i = stack.bottomIndex, stack.topIndex do
				local fragmentInfo = stack[i]

				if self:_GetShowType(fragmentInfo) ~= showType then
					return i
				end
			end
		end
	end
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self._ShowFragment(self, args)
end

M._ShowFragment = function(self, args)
	local fragmentInfo = {
		args = args
	}
	local showType = self._GetShowType(self, fragmentInfo)

	if showType ~= self.GetCurrentShowType(self) then
		local store = self.GetCurrentFragmentStore(self)

		if store then
			store._ShowFragment(store, args, showType, self)
		elseif args == self.fragmentInfoStack:Peek().args then
			print_warn("AppActivityStore: 连续的 ShowFragment! showType:", showType)
		end

		return
	end

	self.fragmentInfoStack:Delete(showType)
	self.fragmentInfoStack:Push(fragmentInfo)

	self.bindData.tabRect.selectedIndex = showType
end

M.GetCurrentFragmentStore = function(self)
	return (self.fragmentInfoStack:Peek() or k_EmptyTable).store
end

M._OnRenderTab = function(self, index, widget)
	local showType = index
	local fragmentInfo = self.fragmentInfoStack:Peek()

	if self:_GetShowType(fragmentInfo) ~= showType then
		local store = gStoreManager:GetStoreGroup(widget.Store)
		fragmentInfo.store = store
		fragmentInfo.widget = widget

		if fragmentInfo.argsPassed then
			store.OnResume(store)
		else
			local tabIndex = self._GetShowType(self, fragmentInfo)

			store._ShowFragment(store, fragmentInfo.args, tabIndex, self)
			self.OnShowFragment(self, tabIndex, fragmentInfo.args, store, widget)

			fragmentInfo.argsPassed = true
		end

		self.currentStore = store
	else
		print_error("AppActivityStore.OnRenderTab: showType not match", "index", index, "widget", widget, "fragmentInfo", fragmentInfo, "fragmentInfoStack", self.fragmentInfoStack)
	end

	gClientUtils.InitNavAreasInChildren(widget, self.panelId)
end

M._GetShowType = function(self, fragmentInfo)
	return fragmentInfo and fragmentInfo.args and fragmentInfo.args[self.showTypeField]
end

M._OnExitClick = function(self)
	local currentFrag = self.fragmentInfoStack:Peek()

	if not currentFrag or not currentFrag.store:HandleExit() then
		self.CloseCurrentFragment(self)
	end
end

M.OnExecuteExitAction = function(self)
	self:_OnClose()
	self:OnClose()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M._OnClose = function(self)
	while self.fragmentInfoStack.count <= 0 do
		local fragmentInfo = self.fragmentInfoStack:Pop()

		if fragmentInfo.store then
			fragmentInfo.store:OnClose()
		end
	end
end

M._CloseThisActivity = function(self)
	self.OnExit(self)
end

M._CloseCurrentFragment = function(self)
	local fragmentInfo = self.fragmentInfoStack:Pop()

	if fragmentInfo then
		if fragmentInfo.store then
			fragmentInfo.store:OnClose()
		end

		local fragmentToShow = self.fragmentInfoStack:Peek()

		if fragmentToShow then
			self.bindData.tabRect.selectedIndex = self._GetShowType(self, fragmentToShow)
		else
			self.CloseThisActivity(self)
		end
	else
		print_error("AppActivityStore.CloseCurrentFragment: fragmentInfoStack.count == 0", "fragmentInfoStack", self.fragmentInfoStack)
	end
end

M._OnPhoneAppHide = function(self)
	self._OnBasePanelClose(self)
end

M._OnBasePanelClose = function(self, _)
	while self.fragmentInfoStack.count <= 0 do
		self.CloseCurrentFragment(self)
	end
end

M._OnShow = function(self, _)
	self.panelId = gChatUtils.GetMainPhonePanelId()
end
