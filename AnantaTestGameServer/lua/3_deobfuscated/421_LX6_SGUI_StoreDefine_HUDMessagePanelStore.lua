C_HUDMessagePanelStore = DefClass("C_HUDMessagePanelStore", C_HUDMessagePanelStore, C_StoreGroup)
GroupName2Class.HUDMessagePanelStore = C_HUDMessagePanelStore
local M = C_HUDMessagePanelStore

function M:ctor()
	self.delayTime = 3
	self.callBacks = {}
	self.curType = -1
	self.curTypeStore = nil
	self.curShowData = nil
	self.areaIndex = nil
	self.allTime = 0
	self.TipType = nil
end

function M:OnAwake()
	self.msgEvents = {
		[gEventConstants.BEFORE_SWITCH_SCENE] = function ()
			self:CloseSelf()
		end,
		[gEventConstants.TIME_PAUSE_BY_FULL_PANEL] = function ()
			self:CloseSelf()
		end
	}
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnShow(panelId, data)
	self.isClose = false
	self.allTime = 0
	self.curShowData = data or {}
	self.curShowData.CallBack = self.curShowData.CallBack or {}

	array.concat(self.callBacks, self.curShowData.CallBack)

	self.areaIndex = self.curShowData.areaIndex
	self.bindData.tabRect.selectedIndex = 0

	if not self.alwaysShow then
		if self.timer then
			self.timer:Stop()
		end

		self.timer = Timer.New(function ()
			if gPanelManager:IsPanelShowing(self.m_Id) then
				self:CloseSelf()
			end
		end, self.delayTime):Start()
	end
end

function M:OnUpdate()
	if not self.alwaysShow then
		self.allTime = self.allTime + gLogicTime.deltaTime

		if self.allTime >= 5 then
			self:CloseSelf()
		end
	end
end

function M:OnClose()
	if not self.areaIndex then
		return
	end
end

function M:OnDestroy()
	if self.timer then
		self.timer:Stop()
	end

	if not table.isNilOrEmpty(self.callBacks) then
		for i = 1, #self.callBacks do
			self.callBacks[i]()
		end
	end
end

function M:CloseSelf()
	if self.isClose then
		return
	end

	self.isClose = true

	if self.closeAniName then
		gUIUtils:PlayAniCallback(self.closeAnimation, self.closeAniName, function ()
			gPanelManager:Close(self.m_Id)
		end)
	else
		gPanelManager:Close(self.m_Id)
	end
end

function M:OnRenderTab(index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:Show(self.curShowData, widget)
	end
end
