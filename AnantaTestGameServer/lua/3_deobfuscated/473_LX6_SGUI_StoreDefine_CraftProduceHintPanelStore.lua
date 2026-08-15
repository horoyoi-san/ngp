local ProduceConfig = LTConfig.ProduceConfig
C_CraftProduceHintPanelStore = DefClass("C_CraftProduceHintPanelStore", C_CraftProduceHintPanelStore, C_StoreGroup)
GroupName2Class.CraftProduceHintPanelStore = C_CraftProduceHintPanelStore
local M = C_CraftProduceHintPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.storeDict = {}
	self.dataDict = {}
end

function M:OnAwake(widget)
	self:DefineAllVariables()
	self:GenMessageEvents()
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

function M:GenMessageEvents()
	return
end

function M:RefreshDisplay(id)
	local store = self.storeDict[id]
	local data = self.dataDict[id]

	if not store or not data then
		return
	end

	if data.formulaId == 0 then
		return
	end

	store.ani:Play("S_CraftProducePanel_MakeInformation")

	local cfg = ProduceConfig.GetConfig(data.formulaId)
	local _, itemId = gCommonItemManager:GetRewardList(cfg.DropId)

	gCommonItemManager:OnCommonItemRender(store.targetBtn, 0, gCommonItemManager:GetItemRenderData({
		itemId = itemId,
		countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP
	}))
end
