local Mathf = Mathf
local M = C_NewMapPanelStore

function M:OnCustomAddElement(key, info, store, element)
	if self[key] then
		self[key](self, info, store, element)
	else
		print_error_without_stack("NewMapPanelStore_CustomElementAdd: 未找到自定义添加函数:", key)
	end
end

function M:OnCustomRenderElement(key, info, store, element, scaleState)
	if self[key] then
		self[key](self, info, store, element, scaleState)
	else
		print_error_without_stack("NewMapPanelStore_CustomElementRender: 未找到自定义渲染函数:", key)
	end
end

function M:OnCustomRenderPin(info, store, element, scaleState)
	self:OnRenderCommonElement(info, store, element, scaleState)

	local item = self.mapView:GetItemInfo(element.instanceId)

	if item and item.resolvedWorldPos and not self.bindData.bigWorldBg:InCurrentFloor(item.resolvedWorldPos.y) then
		store.iconId = LTConfig.GpsConfig.MarkGPSIconId
	end
end

function M:OnCustomAddGangsterIcon(info, store, element)
	local id = element.userdata.gangsterId
	local cfg = LTConfig.FactionConfig.GetConfig(id)
	local influence = gMapSubSystem_Gangster:GetGangsterInfluence(id)
	store.influence = string.format("%.0f%%", influence)
	store.isShowInfluence = id == LTConfig.FactionConfig.JiaMuFaction and 0 or 1
	store.gangsterName = cfg.name
end

function M:OnCustomRenderGangsterIcon(info, store, element, scaleState)
	local widget = info.widget
	local elementContainerRT = widget.rectTransform
	local iconRT = store.gangIconRT
	local uniformIconRT = store.uniformIconRT
	local expectOffsetX = (elementContainerRT.rect.width - iconRT.rect.width) / 2

	uniformIconRT:SetLocalPositionX(expectOffsetX * uniformIconRT.localScale.x)

	if self.curScaleLevel > 1 then
		element.bigMapData.unselectable = true
	else
		element.bigMapData.unselectable = false
	end

	store.scaleState = Mathf.Clamp(self.curScaleLevel, 1, 3) - 1
end

function M:OnCustomRenderFactionIcon(info, store, element, scaleState)
	self:OnRenderCommonElement(info, store, element, scaleState)

	local level = element.userdata.dispositionLevel or 1
	store.attitude = Mathf.Clamp(level - 1, 0, 5)
end
