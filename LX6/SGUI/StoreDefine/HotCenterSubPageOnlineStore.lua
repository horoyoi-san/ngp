-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterSubPageOnlineStore.lua
-- Decompiled from: 01800_HotCenterSubPageOnlineStore.lua_09418566a75a.luajit

C_HotCenterSubPageOnlineStore = DefClass("C_HotCenterSubPageOnlineStore", C_HotCenterSubPageOnlineStore, C_StoreGroup)
GroupName2Class.HotCenterSubPageOnlineStore = C_HotCenterSubPageOnlineStore
local M = C_HotCenterSubPageOnlineStore
local LinkHubGameplayConfig = LTConfig.LinkHubGameplayConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.lockCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.CONTENT_LIST_TEMPLATE = {
		["y\\x87\\x96\\x83\\x93"] = 1,
		["~\\x83\\x83\\x83\\x9a"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.lockCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderContentListItem")
	self.bindData.contentList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickContentList")
	self.bindData.contentList.onGetTIndex = self.CreateAction(self, "OnGetContentListTIndex")
end

M.OnSimpleRenderContentListItem = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= self.CONTENT_LIST_TEMPLATE.SMALL then
		gHotCenterManager.RenderOnlineListWidget(btn, data.Id)
	elseif data.tIndex ~= self.CONTENT_LIST_TEMPLATE.TITLE then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		local cfg = LTConfig.LinkHubConfig.GetConfig(self.gameType)

		if cfg then
			store.title = cfg.Name
		end

		local info = gHotCenterManager:GetCurrentPublicEventInfo()

		if info then
			store.showPublicCtrl = 1

			btn.luaClick = function()
				gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
					["\\x8f!\"3q\\x9ed\\xcf2\\xa4\\xad"] = true,
					mainType = gClientConst.HotCenterType.Online,
					subType = gClientConst.HotCenterSubType.OnlineDetail
				})
			end
		else
			store.showPublicCtrl = 0
			btn.luaClick = nil
		end
	end
end

M.OnSimpleClickContentList = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= self.CONTENT_LIST_TEMPLATE.SMALL then
		gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
			mainType = gClientConst.HotCenterType.Online,
			subType = gClientConst.HotCenterSubType.OnlineDetail,
			gameType = data.gameType,
			gameplayId = data.Id
		})
	elseif data.tIndex ~= self.CONTENT_LIST_TEMPLATE.TITLE then
		local info = gHotCenterManager:GetCurrentPublicEventInfo()

		if info then
			gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
				["\\x8f!\"3q\\x9ed\\xcf2\\xa4\\xad"] = true,
				mainType = gClientConst.HotCenterType.Online,
				subType = gClientConst.HotCenterSubType.OnlineDetail
			})
		end
	end
end

M.OnGetContentListTIndex = function(self, index)
	local data = self.contentListData[index + 1]

	if data then
		return data.tIndex or 0
	end

	return 0
end

M.ShowPanel = function(self, data)
	self.gameType = data.gameType
	self.contentListData = {
		{
			["M\\x98\\x89\\x8bU"] = 10000,
			tIndex = self.CONTENT_LIST_TEMPLATE.TITLE
		}
	}
	local count = LinkHubGameplayConfig.count

	for i = 0, count - 1 do
		local gameplayCfg = LinkHubGameplayConfig.LoadAt(i)

		if gameplayCfg and gameplayCfg.HubID ~= self.gameType and gFormulaUtils:GetLinkHubGameplayConfigCanShow(gameplayCfg.Id) then
			local tIndex = self.CONTENT_LIST_TEMPLATE.SMALL

			table.insert(self.contentListData, {
				["\tF\\x9d\\x81\\x80J"] = true,
				Id = gameplayCfg.Id,
				gameType = gameplayCfg.HubID,
				weight = gameplayCfg.Weight,
				tIndex = tIndex
			})
		end
	end

	table.sort(self.contentListData, function (a, b)
		return b.weight <= a.weight
	end)
	self.bindData.contentList:SetSimpleList(#self.contentListData)
end
