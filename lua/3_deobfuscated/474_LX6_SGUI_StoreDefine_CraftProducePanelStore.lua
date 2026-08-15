C_CraftProducePanelStore = DefClass("C_CraftProducePanelStore", C_CraftProducePanelStore, C_StoreGroup)
GroupName2Class.CraftProducePanelStore = C_CraftProducePanelStore
local M = C_CraftProducePanelStore

function M:ctor()
	return
end

function M:OnAwake(widget)
	self.storeDict = {}
	self.dataDict = {}
	self.infoListData = {}
end

function M:OnEnable(widget)
	local store = self:GetStoreByWidget(widget)

	if not store then
		return
	end

	local id = widget.gameObject:GetInstanceID()
	self.storeDict[id] = store
	self.dataDict[id] = widget.CustomBindData
end

function M:OnCustomBindDataChange(widget)
	local id = widget.gameObject:GetInstanceID()
	self.dataDict[id] = widget.CustomBindData

	self:RefreshDisplay(id)
end

function M:OnStart(widget)
	return
end

function M:OnDisable(widget)
	local id = widget.gameObject:GetInstanceID()
	self.storeDict[id] = nil
	self.dataDict[id] = nil
end

function M:OnDestroy(widget)
	return
end

function M:RefreshDisplay(id)
	local store = self.storeDict[id]
	local data = self.dataDict[id]

	if not store or not data then
		return
	end
end
