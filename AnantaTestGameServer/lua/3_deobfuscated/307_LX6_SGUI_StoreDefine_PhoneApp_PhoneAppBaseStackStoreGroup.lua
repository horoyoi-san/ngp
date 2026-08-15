C_PhoneAppBaseStackStoreGroup = DefClass("C_PhoneAppBaseStackStoreGroup", C_PhoneAppBaseStackStoreGroup, C_PhoneAppBaseStoreGroup)
local M = C_PhoneAppBaseStackStoreGroup

function M:ShowPanel(args)
	args = args or {}
	local showTypeField = self:GetShowTypeField()
	args[showTypeField] = args[showTypeField] or 0

	M.base.ShowPanel(self, args)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.stackPanel = gDataStructureUtils.GetStack()

	function self.stackPanel.IndexOf(stack, showType)
		if stack.count > 0 then
			for i = stack.bottomIndex, stack.topIndex do
				local stackInfo = stack[i]

				if self:GetShowType(stackInfo) == showType then
					return i
				end
			end
		end
	end
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.panelArgs.bindWidget = self.bindData.bindWidget

	self:ShowContentPanel(args)
end

function M:ShowContentPanel(stackInfo)
	local showType = self:GetShowType(stackInfo)

	if self.hasDestroy or not showType then
		return
	end

	local curShowType = self:GetCurrentShowType()

	if showType == curShowType then
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

function M:GetCurrentShowType()
	local stackInfo = self.stackPanel and self.stackPanel:Peek()

	return stackInfo and self:GetShowType(stackInfo)
end

function M:OnRenderTab(index, widget)
	local showType = index
	local stackInfo = self.stackPanel:Peek()

	if self:GetShowType(stackInfo) == showType then
		local store = gStoreManager:GetStoreGroup(widget.Store)
		self.currentTabStore = store
		stackInfo.panelId = self.panelId

		store:ShowPanel(stackInfo)
	end
end

function M:CloseContentPanel()
	local lastStackPanel = self.stackPanel:Pop()

	if self.stackPanel.count == 0 then
		self:OnExit()

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

function M:GetShowType(stackInfo)
	local showTypeField = self:GetShowTypeField()

	return stackInfo and stackInfo[showTypeField]
end

function M:OnExitClick()
	self:CloseContentPanel()
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.FirstLevel
end
