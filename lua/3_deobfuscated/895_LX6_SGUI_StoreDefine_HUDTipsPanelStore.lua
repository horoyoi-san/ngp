local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
C_HUDTipsPanelStore = DefClass("C_HUDTipsPanelStore", C_HUDTipsPanelStore, C_StoreGroup)
GroupName2Class.HUDTipsPanelStore = C_HUDTipsPanelStore
local M = C_HUDTipsPanelStore
local TaskTipsType2Tab = {
	[TaskTipsType.Task] = 0,
	[TaskTipsType.Tower] = 1,
	[TaskTipsType.Camp] = 1,
	[TaskTipsType.Collection] = 1,
	[TaskTipsType.Event] = 2,
	[TaskTipsType.CampFinish] = 3
}

function M:ctor()
	self.delayTime = 3.5
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

function M:OnUpdate()
	if not self.alwaysShow then
		self.allTime = self.allTime + gLogicTime.deltaTime

		if self.allTime >= 5 then
			self:CloseSelf()
		end
	end
end

function M:OnShow(panelId, data)
	self.isClose = false
	self.allTime = 0
	self.curShowData = data or {}
	self.curShowData.CallBack = self.curShowData.CallBack or {}

	if type(self.curShowData.CallBack) == "table" then
		array.concat(self.callBacks, self.curShowData.CallBack)
	elseif type(self.curShowData.CallBack) == "function" then
		table.insert(self.callBacks, self.curShowData.CallBack)
	end

	self.areaIndex = self.curShowData.areaIndex
	local data = self.curShowData.Param

	if data then
		if data.alwaysShow then
			self.alwaysShow = data.alwaysShow
		end

		if not data.TipType then
			slot4 = -1
		end

		self.TipType = slot4
		self.curType = TaskTipsType2Tab[self.TipType]

		if not self.curType then
			gPanelManager:Close(self.m_Id)

			return
		end

		self.bindData.tabRect.selectedIndex = self.curType
		self.delayTime = data.delayTime or 3.5
	end

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

	self:ClearMessageEvents()
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

	if self.curTypeStore and self.curTypeStore.Show then
		self.curTypeStore:Show(self.curShowData, widget)
	end
end
