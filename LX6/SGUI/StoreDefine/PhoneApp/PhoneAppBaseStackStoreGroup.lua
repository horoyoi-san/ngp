-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneApp\PhoneAppBaseStackStoreGroup.lua
-- Decompiled from: 01963_PhoneAppBaseStackStoreGroup.lua_2b63afe4990c.luajit

C_PhoneAppBaseStackStoreGroup = DefClass("C_PhoneAppBaseStackStoreGroup", C_PhoneAppBaseStackStoreGroup, C_PhoneAppBaseStoreGroup)
local M = C_PhoneAppBaseStackStoreGroup

M.ShowPanel = function(self, args)
	args = args or {}
	local showTypeField = self:GetShowTypeField()
	args[showTypeField] = args[showTypeField] or 0

	M.base.ShowPanel(self, args)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.stackPanel = gDataStructureUtils.GetStack()

	self.stackPanel.IndexOf = function(stack, showType)
		if stack.count <= 0 then
			for i = stack.bottomIndex, stack.topIndex do
				local stackInfo = stack[i]

				if self:GetShowType(stackInfo) ~= showType then
					return i
				end
			end
		end
	end
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	self.panelArgs.bindWidget = self.bindData.bindWidget

	self.ShowContentPanel(self, args)
end

M.ShowContentPanel = function(self, stackInfo)
	local showType = self.GetShowType(self, stackInfo)

	if self.hasDestroy or not showType then
		return
	end

	local curShowType = self.GetCurrentShowType(self)

	if showType ~= curShowType then
		if self.currentTabStore and self.currentTabStore.ShowContentPanel then
			self.currentTabStore:ShowContentPanel(stackInfo)
		end

		return
	end

	if self.bindData.tabAnimRoot then
		self.bindData.tabAnimRoot:PlaySwitchTabAnim(curShowType or -1, self.currentTabStore and self.currentTabStore.rootWidget, showType)
	end

	self.stackPanel:Delete(showType)
	self.stackPanel:Push(stackInfo)

	self.bindData.tabRect.selectedIndex = showType
end

M.GetCurrentShowType = function(self)
	local stackInfo = self.stackPanel and self.stackPanel:Peek()

	return stackInfo and self:GetShowType(stackInfo)
end

M.OnRenderTab = function(self, index, widget)
	local showType = index
	local stackInfo = self.stackPanel:Peek()

	if self:GetShowType(stackInfo) ~= showType then
		local store = gStoreManager:GetStoreGroup(widget.Store)
		self.currentTabStore = store
		stackInfo.panelId = self.panelId

		store:ShowPanel(stackInfo)
	end
end

M.CloseContentPanel = function(self)
	local lastStackPanel = self.stackPanel:Pop()

	if self.stackPanel.count ~= 0 then
		self.OnExit(self)

		if self.bindData.tabAnimRoot and self.currentTabStore then
			local lastShowType = self:GetShowType(lastStackPanel)

			self.bindData.tabAnimRoot:PlaySwitchTabAnim(lastShowType, self.currentTabStore.rootWidget, -1)
		end
	else
		local stackInfo = self.stackPanel:Peek()
		stackInfo.lastShowType = self:GetShowType(lastStackPanel)
		local showType = self:GetShowType(stackInfo)

		if self.bindData.tabAnimRoot and self.currentTabStore then
			self.bindData.tabAnimRoot:PlaySwitchTabAnim(stackInfo.lastShowType, self.currentTabStore.rootWidget, showType)
		end

		self.bindData.tabRect:SelectIndexWithClose(showType)
	end
end

M.GetShowType = function(self, stackInfo)
	local showTypeField = self:GetShowTypeField()

	return stackInfo and stackInfo[showTypeField]
end

M.OnExitClick = function(self)
	self.CloseContentPanel(self)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.FirstLevel
end
