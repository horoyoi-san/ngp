-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCCreateMainPanelStore.lua
-- Decompiled from: 00939_OCCreateMainPanelStore.lua_39021a02a51d.luajit

local OriginalCharacterConfig = LTConfig.OriginalCharacterConfig
C_OCCreateMainPanelStore = DefClass("C_OCCreateMainPanelStore", C_OCCreateMainPanelStore, C_StoreGroup)
GroupName2Class.OCCreateMainPanelStore = C_OCCreateMainPanelStore
local M = C_OCCreateMainPanelStore

M.ctor = function(self)
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.RefreshList(self)
end

M.RefreshList = function(self)
	local ocInfos = self.mgr.ocInfo and self.mgr.ocInfo.OCInfoDict
	self.ocDataList = {}

	if ocInfos then
		for ocId, v in pairs(ocInfos) do
			local ele = {
				OCId = ocId
			}

			table.insert(self.ocDataList, ele)
		end
	end

	for i = #self.ocDataList + 1, OriginalCharacterConfig.MaxOCNum do
		self.ocDataList[i] = {}
	end

	self.bindData.ocList:SetSimpleList(#self.ocDataList)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.ocList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.bindData.ocList.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
	self.bindData.ocList.luaSimpleClick = self.CreateAction(self, self.OnClickOCListItem)
end

M.OnGetTIndex = function(self, index)
	return table.isNilOrEmpty(self.ocDataList[index + 1]) and 1 or 0
end

M.OnRenderItem = function(self, btn, index)
	local data = self.ocDataList[index + 1]
end

M.OnClickOCListItem = function(self, btn, index)
	local data = self.ocDataList[index + 1]

	self.mgr:OpenMainPanel(data.OCId)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end
