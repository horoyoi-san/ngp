dofile("LX6/Manager/Map/Utils/BigMapTooltips/BigMapTooltipDef")

BigMapComp_Tooltip = BigMapComp_Tooltip or {}
local M = BigMapComp_Tooltip
M.__index = M
EBigMapTooltipState = {
	Close = 2,
	Open = 1
}

function M:OnInit()
	self.tooltipInfo = nil
	self.element = nil
	self.curState = EBigMapTooltipState.Open
	self.containerStore = nil
	self.containerWidget = nil
	self.bigMapStore = self.bindData

	self:InitTooltips()
end

function M:InitTooltips()
	self.tooltipHandlers = {}

	for type, cls in pairs(gBigMapTooltipDict) do
		local tooltip = cls.new()
		tooltip.tooltipType = type
		tooltip.bigMap = self.bigMap
		self.tooltipHandlers[type] = tooltip
	end

	self.curTooltip = nil
	self.curTooltipType = -1
	self.closeHandler = self.bigMap:CreateAction("OnClickClose", self)
end

function M:OnActive()
	self.tooltipInfo = gMapSystem:SGetTooltipInfo(self.bigMap.attachedTooltipId)
	self.element = gMapSystem:GetByInstanceId(self.bigMap.attachedTooltipId)
	self.source = self.bigMap.attachedTooltipSource

	self:Refresh()
end

function M:OnInactive()
	self.tooltipInfo = nil
	self.element = nil

	self:Refresh()
end

function M:OnEnd()
	self.curTooltip = nil
	self.curTooltipType = -1
	self.containerInit = false
	self.bindData.tooltipTab.selectedIndex = -1

	self.bindData.tooltipTab:ClearUnusedTabInstances()
end

function M:OnDestroy()
	if self.activeHandler then
		self.activeHandler:OnInActive()

		self.activeHandler = nil
	end
end

function M:OnAttachElement(id, element, source)
	self:OnAttachChanged()
end

function M:OnClearAttachedElement()
	self:OnAttachChanged()
end

function M:OnAttachChanged()
	self.tooltipInfo = gMapSystem:SGetTooltipInfo(self.bigMap.attachedTooltipId)
	self.element = gMapSystem:GetByInstanceId(self.bigMap.attachedTooltipId)
	self.source = self.bigMap.attachedTooltipSource

	self:Refresh()
end

function M:Refresh()
	if not self:CheckContainerLoading() then
		self:WaitLoadingContainer()

		return
	end

	if not self:CheckNeedShow() then
		if self.curState == EBigMapTooltipState.Open then
			self:CloseTooltip(false)
		end

		return
	end

	if not self:CheckInfoValid() then
		return
	end

	if not self:CheckTooltipMatch() then
		self:WaitLoadingTooltip()

		return
	end

	self:OpenTooltip()
end

function M:CheckContainerLoading()
	return self.containerStore ~= nil
end

function M:CheckTooltipMatch()
	return self.tooltipInfo.type == self.curTooltipType
end

function M:CheckNeedShow()
	return self.tooltipInfo ~= nil
end

function M:CheckInfoValid()
	if not self.tooltipInfo.type or self.tooltipInfo.type < 0 or EMapTooltipType.Max < self.tooltipInfo.type then
		print_error("@xiajingbo01 BigMapComp_Tooltip:TooltipInfo type is invalid type:" .. self.tooltipInfo.type .. ", Element:", gGpsTools.GetGpsDebugDesc(self.bigMap.attachedTooltipId) .. ", Subsystem:" .. self.element.subSystemType)

		return false
	end

	return true
end

function M:WaitLoadingContainer()
	if not self.containerInit then
		self.bigMapStore.tooltipTab.OnRenderTab = self.bigMap:CreateAction("OnRenderContainer", self)
		self.bigMapStore.tooltipTab.selectedIndex = 0
		self.containerInit = true
	end
end

local OPEN_ANIM_NAME = "S_vx_MapTooltipTemplate_open"

function M:WaitLoadingTooltip()
	if self.containerStore.tooltipTab.selectedIndex > 0 and self.containerStore.tooltipTab.selectedIndex ~= self.tooltipInfo.type and self.activeHandler then
		self.activeHandler:OnInActive()

		self.activeHandler = nil
	end

	self.containerStore.tooltipTab.selectedIndex = self.tooltipInfo.type
end

function M:OpenTooltip()
	self.containerStore.rootAnim:Stop()
	self.containerStore.rootAnim:Play(OPEN_ANIM_NAME)
	self.containerStore.rootAnim:Sample()
	self.containerWidget:SetActive(true)

	self._cachedCtrlAttaschState = self.bindData.controllerAttachIndicator.bActive

	self.bindData.controllerAttachIndicator:SetActive(false)

	if self.activeHandler then
		self.activeHandler:OnInActive()

		self.activeHandler = nil
	end

	local handler = self.tooltipHandlers[self.tooltipInfo.type]

	if handler then
		handler.tooltipInfo = self.tooltipInfo
		handler.element = self.element
		handler.root = self.curTooltip
		handler.container = self
		handler.source = self.source
		local actions, blockReason = self.element:GetActionInfos()

		handler:OnActive()
		handler:SetUpInfo()

		self.activeHandler = handler

		self.containerStore.closeBtn:SetActive(true)

		if handler.store then
			self.containerStore.showPin = 1

			handler:SetUpActions(handler.store, actions, blockReason)
		end
	end

	self.curState = EBigMapTooltipState.Open
end

local HIDE_ANIM_NAME = "S_vx_MapTooltipTemplate_close"

function M:CloseTooltip(immediately)
	self.containerStore.closeBtn:SetActive(false)
	self.bindData.controllerAttachIndicator:SetActive(self._cachedCtrlAttaschState)

	if self.activeHandler and self.curState == EBigMapTooltipState.Open then
		self.activeHandler:OnInActive()

		self.activeHandler = nil
	end

	if immediately then
		self.containerStore.rootAnim:Stop()
		self.containerWidget:SetActive(false)
	else
		local clip = self.containerStore.rootAnim:GetClip(HIDE_ANIM_NAME)

		self.containerStore.rootAnim:Play(HIDE_ANIM_NAME)

		if self.CloseAniDelay then
			gLuaTimeMgrUtils.CancelUnitDelay(self.CloseAniDelay)
		end

		self.CloseAniDelay = gLuaTimeMgrUtils.Delay(function ()
			self.CloseAniDelay = nil

			self.containerWidget:SetActive(false)
		end, clip.length)
	end

	self.curState = EBigMapTooltipState.Close
end

function M:OnRenderContainer(index, tab)
	self.containerWidget = tab
	self.containerStore = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore"):GetStoreByWidget(tab)
	self.containerStore.tooltipTab.OnRenderTab = self.bigMap:CreateAction("OnRenderTooltip", self)
	self.containerStore.closeBtn.luaClick = self.closeHandler

	for type, handler in pairs(self.tooltipHandlers) do
		handler.containerStore = self.containerStore
	end

	self:Refresh()
end

function M:OnRenderTooltip(index, tab)
	self.curTooltip = tab
	self.curTooltipType = index

	self:Refresh()
end

function M:OnClickClose()
	self.bigMap:SetSelected(nil)
end

function M:CheckTooltipHandlerActive(handler)
	return self.actived and handler.tooltipType == self.curTooltipType
end

function M:PretendClickTooltip()
	if not self.tooltipInfo or not self.tooltipInfo.type then
		return
	end

	local element = gMapSystem:GetByInstanceId(self.bigMap.attachedTooltipId)

	if not element then
		return
	end

	local actions, blockReason = element:GetActionInfos()
	local handler = self.tooltipHandlers[self.tooltipInfo.type]

	if handler then
		handler:PretendClick(blockReason, actions)
	end
end
