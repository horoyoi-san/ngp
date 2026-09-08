-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CraftProduceHintPanelStore.lua
-- Decompiled from: 01504_CraftProduceHintPanelStore.lua_fa750b1e070b.luajit

local ProduceConfig = LTConfig.ProduceConfig
C_CraftProduceHintPanelStore = DefClass("C_CraftProduceHintPanelStore", C_CraftProduceHintPanelStore, C_StoreGroup)
GroupName2Class.CraftProduceHintPanelStore = C_CraftProduceHintPanelStore
local M = C_CraftProduceHintPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.storeDict = {}
	self.dataDict = {}
end

M.OnAwake = function(self, widget)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
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

M.GenMessageEvents = function(self)
end

M.RefreshDisplay = function(self, id)
	local store = self.storeDict[id]
	local data = self.dataDict[id]

	if not store or not data then
		return
	end

	if data.formulaId ~= 0 then
		return
	end

	store.ani:Play("S_CraftProducePanel_MakeInformation")

	local cfg = ProduceConfig.GetConfig(data.formulaId)
	local _, itemId = gCommonItemManager:GetRewardList(cfg.DropId)

	gCommonItemManager:OnCommonItemRender(store.targetBtn, 0, gCommonItemManager:GetItemRenderData({
		itemId = itemId
	}))
end
