local bit = require("bit")
EBigMapElementShowMask = {
	Highlight = 8,
	Trace = 512,
	ControllerAttach = 16,
	Selected = 32,
	Fresh = 64,
	InterestByGuide = 128,
	Hover = 8,
	Filter = 256,
	Match = 4,
	ControllerMatch = 2,
	DetailLevel = 1
}
EBigMapElementHideMask = {
	LinkMode = 2048,
	Filter = 256,
	HideEntry = 1024,
	InRange = 512
}
local M = C_NewMapPanelStore

function M:InitMapElement()
	self._id2ElementInfo = {}
	self._elementLayers = {}
end

function M:SetViewMask(viewMask)
	self.viewMask = viewMask

	if self.mapView then
		self.mapView:SetViewMask(self:GetViewMask())
	end

	if self.mapCfg then
		self:SetScale(self.scale, true, true)
	end
end

function M:SetOverrideViewMask(viewMask)
	self.overrideViewMask = viewMask
end

function M:GetViewMask()
	return self.overrideViewMask or self.viewMask or EMapViewMask.BigMap
end

function M:TickElement()
	self:TryFindActualScaleLevel()

	for id, info in pairs(self._id2ElementInfo) do
		self:InnerTickElement(info, info.store, info.widget, info.element)
	end
end

function M:InnerTickElement(info, store, widget, element)
	local scaleState = self:GetIconScaleState(element.instanceId)
	local id = element.instanceId

	if scaleState == EBigMapIconScaleState.None then
		self:ClearShowMask(id, EBigMapElementShowMask.DetailLevel)
	else
		self:SetShowMask(id, EBigMapElementShowMask.DetailLevel)

		element.bigMapData.fresh = false
	end

	if element.bigMapData.fresh then
		self:SetShowMask(id, EBigMapElementShowMask.Fresh)
	else
		self:ClearShowMask(id, EBigMapElementShowMask.Fresh)
	end

	local visible = nil
	visible = info.showMask >= info.hideMask and info.showMask ~= 0

	widget:SetActive(visible)

	if visible then
		if element.bigMapData.customRenderFuncKey then
			self:OnCustomRenderElement(element.bigMapData.customRenderFuncKey, info, store, element, scaleState)
		else
			self:OnRenderCommonElement(info, store, element, scaleState)
		end
	end
end

function M:OnRenderCommonElement(info, store, element, scaleState)
	local useOriginalIcon = false

	if EBigMapElementShowMask.Highlight <= info.showMask then
		useOriginalIcon = true
	end

	local overrideIconId = nil

	if not useOriginalIcon and scaleState == EBigMapIconScaleState.Thumbnail and element.bigMapData.thumbnailIconId then
		overrideIconId = element.bigMapData.thumbnailIconId
	end

	if overrideIconId then
		store.iconId = overrideIconId
		store.hasShadow = 0
		store.isThumbnail = 1
	else
		store.iconId = self:GetIconId(element)
		store.hasShadow = 1
		store.isThumbnail = 0
	end
end

function M:UpdateTracedBoundsPenerate(instanceId)
	local info = self._id2ElementInfo[instanceId]
	local item = self.mapView:GetItemInfo(instanceId)

	if not item or not info then
		return false
	end

	local worldPos = item.resolvedWorldPos
	local areaId = gMapSystem.area:GetAreaIdByGBoundId(item.resolvedGBoundId)
	info.texPos = self:TransformWorldToTex(worldPos, areaId)
	info.widget.rectTransform.localPosition = info.texPos

	self:TryUpdateTraceEffectPos(info)
end

function M:IsTracedElementInRange(instanceId)
	local element = gMapSystem.container:Get(instanceId)

	if not element or not element.mData.rangeInfo then
		return false
	end

	local viewItem = self.mapView:GetItemInfo(instanceId)
	local showRange = false

	if viewItem.coordType == EMapViewerItemCoordType.AttachGate then
		showRange = false
	else
		showRange = self:IsPlayerInRange(element)
	end

	return showRange
end

function M:SetSelected(gpsId, source)
	if not gpsId then
		gMapSubSystem_Pin:ClearTempPin()
	end

	self:ClearScheduleOperation(self.OperationType.Select)

	if self.selectedGpsId ~= nil or gpsId ~= nil then
		self:ScheduleOperation(self.OperationType.Select, {
			gpsId = gpsId,
			source = source
		})
	end
end

function M:RealSetSelected(gpsId, source)
	local id = gpsId and gMapSystem:GetInstanceIdByGpsId(gpsId)
	local info = id and self._id2ElementInfo[id]
	local oldSelectedGpsId = self.selectedGpsId
	self.selectedGpsId = info and gpsId or nil

	if oldSelectedGpsId then
		local oldId = gMapSystem:GetInstanceIdByGpsId(oldSelectedGpsId)
		local oldInfo = self._id2ElementInfo[oldId]

		if oldInfo then
			self:ClearShowMask(oldId, EBigMapElementShowMask.Selected)

			if oldInfo.store.selectAnim then
				oldInfo.store.selectAnim:Play("S_vx_MapIconTemplate_close")
			end

			self:RefreshIconLayer(oldInfo)
		end
	end

	if oldSelectedGpsId == self.autoSelectGpsId then
		self:ClearAutoSelectInterestSource()
	end

	gMessageManager:SendMessage(gEventConstants.ON_BIG_MAP_SELECT, {
		gpsId = gpsId,
		id = id
	})

	if not info then
		self.bindData.selectEffect:SetActiveFastest(false)
		self:ClearTooltipAttach()
		self:SendFSMSignal(EBigMapFSMSignal.Interaction_Reset)

		return
	end

	gSoundMgr:PlaySoundByTid(70600335)
	self:SetShowMask(id, EBigMapElementShowMask.Selected)
	self:RefreshIconLayer(info)
	self:ClearControllerDropdownCtx()

	self.selectedGpsId = gpsId

	self.bindData.selectEffect:SetActiveFastest(true)

	self.bindData.selectEffect.localPosition = info.texPos
	local store, widget = self:GetElementStore(id)

	if store.selectAnim then
		store.selectAnim:Play("S_vx_MapIconTemplate_open")
		store.selectAnim:Sample()
	end

	self:CancelChooseAnim()
	self.bindData.tmp_onceSelectEffectRoot:SetActive(true)

	self.bindData.tmp_onceSelectEffectRoot.localPosition = self._id2ElementInfo[id].texPos

	self.bindData.tmp_onceSelectEffectAnim:Play(self.ONLY_ONCE_SELECT_ANIM_NAME)
	self.bindData.tmp_onceSelectEffectAnim:Sample()

	local tooltipInfo = gMapSystem:SGetTooltipInfo(id)

	if tooltipInfo then
		self:AttachTooltip(id, source)
		self:SendFSMSignal(EBigMapFSMSignal.Interaction_Select, id)
	else
		self:ClearTooltipAttach()
		self:SendFSMSignal(EBigMapFSMSignal.Interaction_Reset)
		print_warn("#NoCreateIssue No tooltip info")
	end
end

function M:AttachTooltip(id, source)
	self.attachedTooltipId = id
	self.attachedTooltipSource = source or EBigMapSelectSource.None
	self.attachedTooltipElement = gMapSystem:GetByInstanceId(id)

	self:NotifyCompsOnAttachElement(self.attachedTooltipId, self.attachedTooltipElement, self.attachedTooltipSource)
end

function M:ClearTooltipAttach()
	self.attachedTooltipId = nil
	self.attachedTooltipElement = nil

	self:ClearAutoSelectInterestSource()
	self:NotifyCompsOnClearAttachedElement()
end

function M:ClearAutoSelectInterestSource()
	if self.autoSelectGpsId then
		local element = gMapSystem:GetByGpsId(self.autoSelectGpsId)

		if element then
			gMapSystem.ui.bigMapInterestSource:RemoveElement(element.instanceId)
		end

		self.autoSelectGpsId = nil
	end
end

function M:RemoveElement(id)
	local info = self._id2ElementInfo[id]

	if not info then
		return
	end

	if info.element.isDestroyed then
		info.sourceCount = 0
	else
		info.sourceCount = info.sourceCount - 1
	end

	if info.sourceCount > 0 then
		return
	end

	info.store.iconId = 0
	info.store.switch = 0
	info.store.linkCharacterIconId = 0
	info.store.linkCharacter = 0

	if info.store.selectAnim then
		info.store.selectAnim:Play("S_vx_MapIconTemplate_close")

		local clip = info.store.selectAnim:GetClip("S_vx_MapIconTemplate_close")

		if clip then
			clip:SampleAnimation(info.store.selectAnim.gameObject, clip.length)
		else
			print_warn("@sunwei08: No selectAnim clip found for S_vx_MapIconTemplate_close", info.element.gpsId)

			return
		end

		info.store.selectAnim:Stop()
	end

	self:RemoveTraceEffect(info)
	self.bindData.iconPool:DeleteItem(info.widget)

	self._id2ElementInfo[id] = nil

	self:RemoveIndicator(id)
	self:TryRemoveRange(id)
	self:TryRemovePolygonRange(id)
	self._filterCore:OnRemoveElement(id)
	self:NotifyCompsRemoveElement(id, info)

	if id == self._chooseAnimTargetId then
		self:CancelChooseAnim()
	end
end

function M:AddElement(id)
	if self._id2ElementInfo[id] then
		self._id2ElementInfo[id].sourceCount = self._id2ElementInfo[id].sourceCount + 1

		return
	end

	local element = gMapSystem:GetByInstanceId(id)
	local viewItem = self.mapView:GetItemInfo(id)

	if not element or not viewItem then
		return
	end

	local worldPos = viewItem.resolvedWorldPos
	local areaId = gMapSystem.area:GetAreaIdByGBoundId(viewItem.resolvedGBoundId)

	if not areaId or not worldPos then
		return
	end

	local tIndex = element.fData.bigMapTIndex or 0
	local widget = self.bindData.iconPool:CreateItem(tIndex)
	local store = gStoreManager:GetStoreGroup("NewMapPanelIconStore"):GetStoreByWidget(widget)
	store.iconId = 0
	local info = {
		sourceCount = 1,
		id = id,
		element = element,
		widget = widget,
		store = store,
		tIndex = tIndex,
		texPos = self:TransformWorldToTex(worldPos, areaId),
		showMask = 0,
		hideMask = 0
	}
	self._id2ElementInfo[id] = info

	self:RefreshInnerData(info, widget, store, element)

	local showRange = false
	info.traced = element:HasTraceEffect()

	if info.traced then
		info.tmp_InRange = self:IsTracedElementInRange(id)

		self:UpdateTracedBoundsPenerate(id)
	else
		info.tmp_InRange = self:IsPlayerInRange(element)
	end

	if gMapSystem.ui:IsBigMapGuideInterest(element.instanceId) then
		self:SetShowMask(id, EBigMapElementShowMask.InterestByGuide)
	end

	if info.tmp_InRange then
		showRange = true

		self:SetHideMask(id, EBigMapElementHideMask.InRange)
		self:TryAddRange(id)
	end

	if self:TryAddPolygonRange(id) then
		showRange = true

		self:SetHideMask(id, EBigMapElementHideMask.InRange)
	else
		self:ClearHideMask(id, EBigMapElementHideMask.InRange)
	end

	if info.traced or gMapSubSystem_Task:IsImportantTaskElement(element) then
		self:AddIndicator(id)
	end

	if info.traced then
		self:SetShowMask(id, EBigMapElementShowMask.Trace)

		if not showRange then
			self:AddOrUpdateTraceEffect(info)
		end
	end

	self:RefreshIconLayer(info)
	self:CheckTaskElementShowSwitch(info)
	self._filterCore:OnAddElement(id)
	self:CheckElementFilter(id)
	self:NotifyCompsAddElement(id, info)
end

function M:UpdateElement(id)
	local info = self._id2ElementInfo[id]
	local viewItem = self.mapView:GetItemInfo(id)

	if not viewItem or not info or not info.element or info.element.isDestroyed then
		return
	end

	local element = info.element
	local worldPos = viewItem.resolvedWorldPos
	local areaId = gMapSystem.area:GetAreaIdByGBoundId(viewItem.resolvedGBoundId)

	if not areaId or not worldPos then
		return
	end

	info.texPos = self:TransformWorldToTex(worldPos, areaId)

	self:RefreshInnerData(info, info.widget, info.store, element)

	info.traced = element:HasTraceEffect()
	local showRange = false

	if info.traced then
		info.tmp_InRange = self:IsTracedElementInRange(id)

		self:UpdateTracedBoundsPenerate(id)
	else
		info.tmp_InRange = self:IsPlayerInRange(element)
	end

	if info.tmp_InRange then
		showRange = true

		self:TryAddRange(id)
		self:SetHideMask(id, EBigMapElementHideMask.InRange)
	else
		self:TryRemoveRange(id)
		self:ClearHideMask(id, EBigMapElementHideMask.InRange)
	end

	if self:TryAddPolygonRange(id) then
		showRange = true

		self:SetHideMask(id, EBigMapElementHideMask.InRange)
	else
		self:ClearHideMask(id, EBigMapElementHideMask.InRange)
	end

	local visible = info.showMask >= info.hideMask and info.showMask ~= 0

	if info.traced or gMapSubSystem_Task:IsImportantTaskElement(element) and visible then
		self:AddIndicator(id)
	else
		self:RemoveIndicator(id)
	end

	if info.traced then
		self:SetShowMask(id, EBigMapElementShowMask.Trace)

		if not showRange then
			self:AddOrUpdateTraceEffect(info)
		else
			self:RemoveTraceEffect(info)
		end
	else
		self:ClearShowMask(id, EBigMapElementShowMask.Trace)
		self:RemoveTraceEffect(info)
	end

	self:CheckElementFilter(id)
	self:RefreshIconLayer(info)
end

function M:GetElementStore(id)
	local info = self._id2ElementInfo[id]

	if not info then
		return nil
	end

	return info.store, info.widget
end

function M:RefreshInnerData(info, widget, store, element)
	widget.gameObject.name = element.gpsId
	store.guideId = element.gpsId
	local iconId = self:GetIconId(element)
	iconId = iconId and iconId > 0 and iconId or 0

	if element.fData.bigMapTIndex == 1 then
		store.iconId = iconId
		store.taskIconId = element.mData.badgeIconId or 0
	else
		store.iconId = iconId
	end

	if element.mData.eulerZ then
		store.eulerZ = element.mData.eulerZ
	end

	local uniformScale = 1 / self.scale
	local uniformIconScale = LTConfig.GameConfig.MapIconDefaultRate * uniformScale

	self:UpdateIconScale(info, uniformIconScale)

	widget.transform.localPosition = info.texPos
	local typeCtrl = element.bigMapData.iconSizeType or 2
	store.iconSizeTypeCtrl = typeCtrl

	if element.bigMapData.showName then
		store.showName = 1
		store.name = element:GetName()
	else
		store.showName = 0
		store.name = nil
	end

	if element.bigMapData.customAddElemFuncKey then
		self:OnCustomAddElement(element.bigMapData.customAddElemFuncKey, info, store, element)
	end

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.ShowDebugInfo) then
		local text = nil

		if element.type == EMapElementType.Mark and not gMapSubSystem_Pin:IsTempPin(element.gpsId) then
			text = ulong.tostring(element.gpsId)
		else
			text = element.gpsId
		end

		local name = element:GetName()

		if name then
			text = text .. "\n" .. name
		end

		store.debugLabel.text = text

		store.debugPanel.gameObject:SetActive(true)
	end

	if element.mData.linkSpecificAgentId then
		local agentSpecificCfg = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(element.mData.linkSpecificAgentId)

		if agentSpecificCfg and agentSpecificCfg.QImageId then
			store.linkCharacter = 1
			store.linkCharacterIconId = agentSpecificCfg.QImageId
		else
			store.linkCharacter = 0
		end
	else
		store.linkCharacter = 0
	end
end

function M:OnPerformAction(element, action, fromShortcut)
	print_debug("Perform action " .. gMapSystemElementActionName[action] .. " on element " .. element.gpsId)

	local subSystem = element:GetSubSystem()
	local actionCfg = LTConfig.GpsMapActionConfig.GetConfig(action)

	if actionCfg then
		local triggerSoundId = nil

		if fromShortcut then
			triggerSoundId = actionCfg.HoverTriggerSoundId
		else
			triggerSoundId = actionCfg.TooltipTriggerSoundId
		end

		if triggerSoundId and triggerSoundId > 0 then
			gSoundMgr:PlaySoundByTid(triggerSoundId)
		end
	end

	subSystem:ExecuteAction(element, action, self.showContext)
	self:SetSelected(nil)
end

function M:UpdateIconScale(info, unifiedScale)
	local scale = info.element.mData.scaleFactor

	if not scale or scale == 0 then
		scale = 1
	end

	scale = scale * unifiedScale

	info.store.uniScaleRT:SetLocalScaleXY(scale, scale)

	if info.traceEffectWidget then
		info.traceEffectWidget.rectTransform:SetLocalScaleXY(scale, scale)
	end
end

function M:GetIconId(element)
	local iconId = element.bigMapData.iconId or element.mData.sIconId

	if not iconId or type(iconId) ~= "number" then
		return 0
	end

	return iconId
end

function M:GetIconScaleState(id)
	local info = self._id2ElementInfo[id]

	if not info then
		return EBigMapIconScaleState.None
	end

	if info.element.bigMapData.iconScaleType then
		return gBigMapHelper:GetIconState(self.dynamicScaleLevel, info.element.bigMapData.iconScaleType)
	elseif info.element.bigMapData.scaleLevel then
		return info.element.bigMapData.scaleLevel <= self.bgScaleLevel and EBigMapIconScaleState.Normal or EBigMapIconScaleState.None
	else
		return EBigMapIconScaleState.Normal
	end
end

function M:GetMatchIds(uiRadius, ignoreSelected)
	local uiPos = self:GetPointerUIPos()
	local texPos = self:TransformUIToTex(uiPos)
	local threshold = uiRadius / self.scale
	local sqrThreshold = threshold * threshold
	local matchIds = {}
	local minSqrDist = math.huge

	for id, info in pairs(self._id2ElementInfo) do
		local element = info.element

		if not element then
			-- Nothing
		elseif info.showMask >= info.hideMask then
			if info.showMask == 0 then
				-- Nothing
			elseif ignoreSelected and element.gpsId == self.selectedGpsId then
				-- Nothing
			elseif not element.bigMapData.unselectable then
				if element.bigMapData.cantMatch then
					-- Nothing
				else
					local sqrDist = (texPos - info.texPos).sqrMagnitude

					if sqrDist < sqrThreshold then
						if sqrDist < minSqrDist then
							minSqrDist = sqrDist

							table.insert(matchIds, 1, id)
						else
							table.insert(matchIds, id)
						end
					end
				end
			end
		end
	end

	return matchIds
end

function M:RefreshIconLayer(info)
	local layer = nil

	if info.element.instanceId == self._curHoverId or self.controllerAttachCtx and table.contains(self.controllerAttachCtx.ids, info.element.instanceId) then
		layer = 4
	elseif info.element.gpsId == self.selectedGpsId then
		layer = 3
	elseif info.traced then
		layer = 2
	else
		layer = 1
	end

	if info.layer == layer then
		return
	end

	info.layer = layer
	local rt = info.widget.transform

	if layer == 1 then
		rt:SetParent(self._normalIconLayer)
	elseif layer == 2 then
		rt:SetParent(self._traceIconLayer)
	elseif layer == 3 then
		rt:SetParent(self._selectedIconLayer)
	elseif layer == 4 then
		rt:SetParent(self._hoverIconLayer)
	end
end

function M:SetShowMask(id, showMask)
	local info = self._id2ElementInfo[id]

	if info then
		info.showMask = bit.bor(info.showMask, showMask)
	end
end

function M:ClearShowMask(id, showMask)
	local info = self._id2ElementInfo[id]

	if info then
		info.showMask = bit.band(info.showMask, bit.bnot(showMask))
	end
end

function M:SetHideMask(id, hideMask)
	local info = self._id2ElementInfo[id]

	if info then
		info.hideMask = bit.bor(info.hideMask, hideMask)
	end
end

function M:ClearHideMask(id, hideMask)
	local info = self._id2ElementInfo[id]

	if info then
		info.hideMask = bit.band(info.hideMask, bit.bnot(hideMask))
	end
end

function M:GetFilterTag(id)
	local info = self._id2ElementInfo[id]

	if info then
		local filterTag = info.element.bigMapData.filterTag

		if filterTag then
			local filterTag2 = info.element.bigMapData.tmp_filterTag2

			return filterTag, filterTag2
		end

		local iconId = self:GetIconId(info.element)

		if iconId and iconId > 0 then
			local tags = gBigMapHelper:GetFilterTagsByIconId(iconId)

			return tags and tags[1]
		end
	end
end

function M:TryFindActualScaleLevel()
	if self:IsJiaMuViewEnabled() then
		self.dynamicScaleLevel = self.curScaleLevel

		return
	end

	for i = self.curScaleLevel, 5 do
		self.dynamicScaleLevel = i

		for _, info in pairs(self._id2ElementInfo) do
			local element = info.element

			if not element.bigMapData.ignoreInScalePromoteCheck and info.showMask >= info.hideMask and self:GetIconScaleState(element.instanceId) == EBigMapIconScaleState.Normal then
				return
			end
		end
	end
end

function M:CheckTaskElementShowSwitch(info)
	local isTask = info.element.userdata and info.element.userdata.taskLineId

	if not isTask then
		return
	end

	local element = info.element
	local limitSpirits = element.fData.bigMapLimitSpirits

	if not limitSpirits then
		return
	end

	if self.filterCharacterTid and not array.contains(limitSpirits, self.filterCharacterTid) then
		info.store.switch = 1

		return
	end

	info.store.switch = 0
end

function M:IsLegendMode()
	return self.fsms and self.fsms[2].currentState == EBigMapFSMState.LegendMode
end

function M:OnRemoveGps(_, data)
	local element = gMapSystem:GetByGpsId(data and data.instanceId)

	if element == nil then
		return
	end

	self:UpdateElement(element.instanceId)
end
