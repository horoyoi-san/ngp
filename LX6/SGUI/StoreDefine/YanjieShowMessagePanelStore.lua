-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieShowMessagePanelStore.lua
-- Decompiled from: 01256_YanjieShowMessagePanelStore.lua_a4f202bf2867.luajit

C_YanjieShowMessagePanelStore = DefClass("C_YanjieShowMessagePanelStore", C_YanjieShowMessagePanelStore, C_StoreGroup)
GroupName2Class.YanjieShowMessagePanelStore = C_YanjieShowMessagePanelStore
local M = C_YanjieShowMessagePanelStore
local ShowTypeControl = {
	[":G\\x9d\\x82\\x8cV"] = 0,
	["N#nP"] = 1
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.InitMessageEvents(self)
end

M.InitMessageEvents = function(self)
	local msgEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = function (_, panelId)
			if panelId ~= gPanelId.S_YANJIE_HOME_PAGE_PANEL then
				self:ClosePanel()
			end
		end,
		[gEventConstants.PANEL_ON_SHOW] = function (_, panelId)
			self:OnPanelShow(panelId)
		end
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId

	self.InitModel(self, args)
	self.InitView(self)
end

M.InitModel = function(self, data)
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()

	self.popUpQueue:Push(data)

	if not self.checkQueueCo then
		self.ExecuteShowQueue(self)
	end
end

M.InitView = function(self)
end

M.ExecuteShowQueue = function(self)
	self.checkQueueCo = coroutine.start(function ()
		while self.popUpQueue.count <= 0 do
			local data = self.popUpQueue:Pop()

			self:ShowDataView(data)
			coroutine.wait(2)
		end

		self:ClosePanel()

		self.checkQueueCo = nil
	end)
end

M.ShowDataView = function(self, data)
	if data.isFollow then
		self.bindData.showTypeCtrl = ShowTypeControl.Follow
		self.bindData.tips = data.roleName
	elseif data.isTask then
		self.bindData.showTypeCtrl = ShowTypeControl.Task
		self.bindData.tips = data.taskName
	end
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnPanelShow = function(self, panelId)
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

M.OnClose = function(self)
	self.popUpQueue = nil
	self.checkQueueCo = coroutine.stop(self.checkQueueCo)
end
