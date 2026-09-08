-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CraftProducePanelStore.lua
-- Decompiled from: 01505_CraftProducePanelStore.lua_c2c37fe12ed4.luajit

C_CraftProducePanelStore = DefClass("C_CraftProducePanelStore", C_CraftProducePanelStore, C_StoreGroup)
GroupName2Class.CraftProducePanelStore = C_CraftProducePanelStore
local M = C_CraftProducePanelStore

M.ctor = function(self)
end

M.OnAwake = function(self, widget)
	self.storeDict = {}
	self.dataDict = {}
	self.infoListData = {}
end

M.OnEnable = function(self, widget)
	local store = self.GetStoreByWidget(self, widget)

	if not store then
		return
	end

	local id = widget.gameObject:GetInstanceID()
	self.storeDict[id] = store
	self.dataDict[id] = widget.CustomBindData
end

M.OnCustomBindDataChange = function(self, widget)
	local id = widget.gameObject:GetInstanceID()
	self.dataDict[id] = widget.CustomBindData

	self:RefreshDisplay(id)
end

M.OnStart = function(self, widget)
end

M.OnDisable = function(self, widget)
	local id = widget.gameObject:GetInstanceID()
	self.storeDict[id] = nil
	self.dataDict[id] = nil
end

M.OnDestroy = function(self, widget)
end

M.RefreshDisplay = function(self, id)
	local store = self.storeDict[id]
	local data = self.dataDict[id]

	if not store or not data then
		return
	end
end
