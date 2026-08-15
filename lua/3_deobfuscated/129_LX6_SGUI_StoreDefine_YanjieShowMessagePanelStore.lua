C_YanjieShowMessagePanelStore = DefClass("C_YanjieShowMessagePanelStore", C_YanjieShowMessagePanelStore, C_StoreGroup)
GroupName2Class.YanjieShowMessagePanelStore = C_YanjieShowMessagePanelStore
local M = C_YanjieShowMessagePanelStore
local ShowTypeControl = {
	Follow = 0,
	Task = 1
}

function M:ctor()
	return
end

function M:OnAwake()
	self:InitMessageEvents()
end

function M:InitMessageEvents()
	local msgEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = function (_, panelId)
			if panelId == gPanelId.S_YANJIE_HOME_PAGE_PANEL then
				self:ClosePanel()
			end
		end,
		[gEventConstants.PANEL_ON_SHOW] = function (_, panelId)
			self:OnPanelShow(panelId)
		end
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, args)
	self.panelId = panelId

	self:InitModel(args)
	self:InitView()
end

function M:InitModel(data)
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()

	self.popUpQueue:Push(data)

	if not self.checkQueueCo then
		self:ExecuteShowQueue()
	end
end

function M:InitView()
	return
end

function M:ExecuteShowQueue()
	self.checkQueueCo = coroutine.start(function ()
		while self.popUpQueue.count > 0 do
			local data = self.popUpQueue:Pop()

			self:ShowDataView(data)
			coroutine.wait(2)
		end

		self:ClosePanel()

		self.checkQueueCo = nil
	end)
end

function M:ShowDataView(data)
	if data.isFollow then
		self.bindData.showTypeCtrl = ShowTypeControl.Follow
		self.bindData.tips = data.roleName
	elseif data.isTask then
		self.bindData.showTypeCtrl = ShowTypeControl.Task
		self.bindData.tips = data.taskName
	end
end

function M:ClosePanel()
	gPanelManager:Close(self.panelId)
end

function M:OnPanelShow(panelId)
	local targetPanelIdList = {
		gPanelId.S_YANJIE_MINE_PANEL,
		gPanelId.S_YANJIE_SEARCH_PANEL,
		gPanelId.S_YANJIE_DETAIL_PAGE_PANEL,
		gPanelId.S_YANJIE_COLLECTION_PANEL
	}

	if table.find(targetPanelIdList, panelId) then
		gPanelManager:SetActiveById(self.panelId, true)
	end
end

function M:OnClose()
	self.popUpQueue = nil
	self.checkQueueCo = coroutine.stop(self.checkQueueCo)
end
