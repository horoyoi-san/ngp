local bit = require("bit")
EMiniMapElementHideMask = {
	Spirit = 2,
	NeedBadge = 1
}
local DefaultAnimInfo = {
	[0] = {
		start = {
			timeBeforeLoopAnim = 5,
			name = "S_vx_miniMapIcon_open"
		}
	},
	{
		start = {
			timeBeforeLoopAnim = 5,
			name = "S_vx_miniMapIcon_zaoyu_open"
		},
		loop = {
			name = "S_vx_miniMapIcon_zaoyu_loop",
			playInterval = 5,
			loopClip = false
		}
	},
	{
		start = {
			timeBeforeLoopAnim = 5,
			name = "S_vx_miniMapIcon_open"
		}
	}
}
local M = C_MiniMapPanelStore

function M:InitElementContainer()
	self._layers = {}
	self._id2ElementInfo = {}
	self._newAnimIds = {}
	self._animLoopTimers = {}
	self._tickIdCount = {}
	self._tagElementIds = {}
	self._indoorId2EntryElementId = {}
end

function M:TickScaleAndRotation()
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("MiniMapTickScaleRotation")
	end

	local dirty = false

	if self._scaleDirty then
		self._scaleDirty = false
		local unifiedScale = Mathf.Clamp(self.renderScale, LTConfig.GameConfig.MiniMapIconScale, 1) / self.renderScale

		self.csMapContainer:SetScale(self.renderScale, unifiedScale)

		dirty = true
	end

	if self._eulerZDirty then
		self._eulerZDirty = false
		local radZ = (self.renderEulerZ + 90) * math.pi / 180
		self.bindData.northIconRT.anchoredPosition = self:TransformRadToEdgePos(radZ)

		self.csMapContainer:SetEulerZ(self.renderEulerZ)

		dirty = true
	end

	if dirty then
		self.csMapContainer:RefreshChild()
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:TickElementAnim()
	for k, _ in pairs(self._newAnimIds) do
		local id = k
		local info = self._id2ElementInfo[id]

		if not info or info.mapElement.isDestroyed then
			self._newAnimIds[id] = nil
		else
			local store = info.store
			local startAnim = self:GetStartAnimInfo(info.tIndex, info.mapElement)

			if startAnim.name then
				store.rootAnim:Play(startAnim.name)
				store.rootAnim:Sample()
			end

			self._newAnimIds[id] = nil
		end
	end

	local dt = Time.deltaTime

	for id, time in pairs(self._animLoopTimers) do
		if dt < time then
			self._animLoopTimers[id] = time - dt
		else
			local info = self._id2ElementInfo[id]

			if info and info.mapElement and not info.mapElement.isDestroyed then
				local loopAnim = self:GetLoopAnimInfo(info.tIndex, info.mapElement)

				if not loopAnim then
					self._animLoopTimers[id] = nil

					print_error("#NoCreateIssue: MiniMapAnim:不应该发生的情况,name:" .. info.mapElement:GetName() .. " tIndex:" .. tostring(info.tIndex) .. " gpsId:" .. tostring(info.mapElement.gpsId))
				else
					local store = info.store

					if loopAnim.loopClip then
						self._animLoopTimers[id] = nil
					else
						self._animLoopTimers[id] = time + loopAnim.playInterval - dt
					end

					if store.rootAnim then
						store.rootAnim:Play(loopAnim.name)
					end
				end
			else
				self._animLoopTimers[id] = nil
			end
		end
	end
end

function M:AddElement(id)
	local viewItem = self.mapView:GetItemInfo(id)

	if not viewItem then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MiniMapPanelStore:AddElement: Element not found in MapView", gGpsTools.GetGpsDebugDesc(id))

		return
	end

	local element = gMapSystem:GetByInstanceId(id)

	if not element then
		return
	end

	local info = {
		mapElement = element,
		guideMask = 0,
		hideMask = 0
	}
	self._id2ElementInfo[id] = info

	self:SetTIndex(id, element.miniMapData.miniMapTIndex or 0)

	info.store.maskable = true
	local worldPos = viewItem.resolvedWorldPos
	info.worldPos = worldPos

	self:SyncWorldPos(info)
	self:UpdateTexPos(info)
	self:RefreshInnerData(info)

	if element:HasTraceEffect() then
		self:AddTraceInfo(info)
	end

	self:TryAddPolygonRange(id)

	if self:HasRange(element) then
		self:TryAddRange(info)
	end

	if element.miniMapData.tmp_needWeakGuide then
		self:AddWeakGuide(info)
	end

	self:TryAddOrRemoveDetectRange(id, info)
	self:CheckElementUnifiedLayer(id, info)
end

function M:SyncWorldPos(info)
	self.bindData.mapRoot:UpdateAttachItem(info.mapElement.instanceId, info.worldPos, info.guiding)
end

function M:SetTIndex(id, tIndex)
	local info = self._id2ElementInfo[id]

	if info.tIndex == tIndex then
		return
	end

	if info.tIndex then
		info.csMapElement:UnregisterSelf()

		if info.store then
			info.store.iconId = 0
		end

		self.bindData.mapRoot:RemoveAttachItem(id)
		self.bindData.iconPool:DeleteItem(info.widget)

		if self:HasLoopAnim(info.tIndex, info.mapElement) then
			self._animLoopTimers[id] = nil
		end
	end

	info.tIndex = tIndex
	local widget = self.bindData.iconPool:CreateItem(info.tIndex)

	self.bindData.mapRoot:AddAttachItem(id, widget.rectTransform)

	local store = gStoreManager:GetStoreGroup("MiniMapPanelStore_Icon"):GetStoreByWidget(widget)
	info.widget = widget
	info.store = store
	info.csMapElement = widget:GetComponent(typeof(LX6.Gps.UIMapElement))

	if info.csMapElement then
		info.csMapElement:RegisterSelf()
	end

	widget.gameObject.name = info.mapElement.gpsId
	local startAnimInfo = nil

	if self:HasStartAnim(info.tIndex, info.mapElement) then
		startAnimInfo = self:GetStartAnimInfo(info.tIndex, info.mapElement)
		self._newAnimIds[id] = true
	end

	if self:HasLoopAnim(info.tIndex, info.mapElement) then
		self._animLoopTimers[id] = startAnimInfo and startAnimInfo.timeBeforeLoopAnim or 0
	else
		self._animLoopTimers[id] = nil
	end
end

function M:RemoveElement(id)
	local info = self._id2ElementInfo[id]

	if not info then
		return
	end

	if self._tagElementIds[id] then
		self._tagElementIds[id] = nil
	end

	if info.csMapElement then
		info.csMapElement:UnregisterSelf()
	else
		print_warn("@sunwei08 小地图" .. info.tIndex .. "类Template坏了")
	end

	if info.store then
		info.store.iconId = 0
	end

	self:ClearTraceInfo(info)
	self:TryRemoveRange(info)
	self:TryRemovePolygonRange(id)
	self:ClearWeakGuide(info)
	self:TryRemoveDetectRange(id)
	self.bindData.mapRoot:RemoveAttachItem(id)
	self.bindData.iconPool:DeleteItem(info.widget)

	self._id2ElementInfo[id] = nil
end

function M:UpdateElement(id)
	local info = id and self._id2ElementInfo[id]
	local viewItem = self.mapView:GetItemInfo(id)

	if not viewItem or not info or not info.mapElement or info.mapElement.isDestroyed then
		return
	end

	local worldPos = viewItem.resolvedWorldPos

	if not worldPos then
		return
	end

	self:SetTIndex(id, info.mapElement.miniMapData.miniMapTIndex or 0)

	info.worldPos = worldPos

	self:SyncWorldPos(info)
	self:UpdateTexPos(info)
	self:RefreshInnerData(info)

	local element = info.mapElement

	if element.miniMapData.tmp_needWeakGuide then
		self:AddWeakGuide(info)
	else
		self:ClearWeakGuide(info)
	end

	if element:HasTraceEffect() then
		self:AddTraceInfo(info)
	else
		self:ClearTraceInfo(info)
	end

	if self:HasRange(element) then
		self:TryAddRange(info)
	else
		self:TryRemoveRange(info)
	end

	self:TryAddPolygonRange(id)
	self:TryAddOrRemoveDetectRange(id, info)
	self:CheckElementUnifiedLayer(id, info)
end

function M:UpdateTexPos(info, skipTexPos)
	if not skipTexPos and info.worldPos then
		info.texPos = gMapTransformHelper:TransformWorldPosToTexPos(info.worldPos, self.areaId, info.texPos) or Vector2.zero
	end

	if not info.guiding then
		info.clamped = nil
		info.clampedTexPos = nil

		info.widget.rectTransform:SetParent(self.bindData.commonLayer)

		if not gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.UseNewMiniMapComp) then
			info.widget.rectTransform.localPosition = info.texPos
		end
	else
		local clampedUIPos, outOfBound = self:TransformTex2UIClamp(info.texPos)
		info.clamped = outOfBound
		info.clampedTexPos = self:TransformUI2Tex(clampedUIPos)

		info.widget.rectTransform:SetParent(self.bindData.traceLayer)

		if not gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.UseNewMiniMapComp) then
			info.widget.rectTransform.localPosition = info.clampedTexPos
		end
	end
end

function M:SetVisible(info, visible)
	info.visible = visible

	self:RefreshWidgetVisible(info)
end

function M:RefreshWidgetVisible(info)
	if not info then
		return
	end

	local widgetVisible = info.visible and (not info.hideMask or info.hideMask == 0)
	widgetVisible = not not widgetVisible

	if info.widgetVisible == widgetVisible then
		return
	end

	info.widgetVisible = widgetVisible

	if info.widget then
		info.widget:SetActive(widgetVisible)
	end
end

function M:RefreshTexPos(info)
	return
end

function M:RefreshInnerData(info)
	info.store.iconId = info.mapElement.miniMapData.iconId or info.mapElement.mData.sIconId or 0

	self:SetAirportPenertrateIcon(info)

	if (self:HasRange(info.mapElement) or self:HasPolygonRange(info.mapElement)) and (info.mapElement.mData.rangeInfo.hideIcon == true or not info.clamped) then
		self:SetVisible(info, false)
	else
		self:SetVisible(info, true)
	end

	if info.mapElement:HasTraceEffect() then
		local rt = info.widget.rectTransform

		rt:SetSiblingIndex(rt.parent.childCount - 1)
	end

	if info.mapElement.mData.eulerZ then
		info.csMapElement:SetRotationInfo(true, info.mapElement.mData.eulerZ)
	else
		info.csMapElement:SetRotationInfo(false, 0)
	end

	info.csMapElement:SetScaleFactor(info.mapElement.mData.scaleFactor or 1)
	self:SetIconColor(info)

	if info.mapElement.miniMapData.arrowNum ~= nil then
		if info.store.arrow ~= nil then
			info.store.arrow:SetActive(true)
		end

		info.store.arrowNum = info.mapElement.miniMapData.arrowNum
	elseif info.store.arrow ~= nil then
		info.store.arrow:SetActive(false)
	end
end

function M:HasStartAnim(tIndex, element)
	local overrideInfo = element.fData.miniMapOverrideAnimInfo

	if overrideInfo and overrideInfo[tIndex] and overrideInfo[tIndex].start then
		local noAnim = overrideInfo[tIndex].start.noAnim or false

		return not noAnim
	end

	local defaultInfo = DefaultAnimInfo[tIndex]

	if defaultInfo and defaultInfo.start then
		return true
	end

	return false
end

function M:HasLoopAnim(tIndex, element)
	local overrideInfo = element.fData.miniMapOverrideAnimInfo

	if overrideInfo and overrideInfo[tIndex] and overrideInfo[tIndex].loop then
		local noAnim = overrideInfo[tIndex].loop.noAnim or false

		return not noAnim
	end

	local defaultInfo = DefaultAnimInfo[tIndex]

	if defaultInfo and defaultInfo.loop then
		return true
	end

	return false
end

function M:GetStartAnimInfo(tIndex, element)
	local overrideInfo = element.fData.miniMapOverrideAnimInfo

	if overrideInfo and overrideInfo[tIndex] and overrideInfo[tIndex].start then
		return overrideInfo[tIndex].start
	end

	local defaultInfo = DefaultAnimInfo[tIndex]

	if defaultInfo and defaultInfo.start then
		return defaultInfo.start
	end

	return nil
end

function M:GetLoopAnimInfo(tIndex, element)
	local overrideInfo = element.fData.miniMapOverrideAnimInfo

	if overrideInfo and overrideInfo[tIndex] and overrideInfo[tIndex].loop then
		return overrideInfo[tIndex].loop
	end

	local defaultInfo = DefaultAnimInfo[tIndex]

	if defaultInfo and defaultInfo.loop then
		return defaultInfo.loop
	end

	return nil
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

function M:OnUnifiedMapStateChange(eventId, params)
	if not self.baseMap or params ~= self.baseMap then
		return
	end

	for id, info in pairs(self._id2ElementInfo) do
		self:CheckElementUnifiedLayer(id, info)
	end
end

function M:CheckElementUnifiedLayer(id, info)
	if not info or not info.store or not info.mapElement then
		return
	end

	local item = self.mapView:GetItemInfo(id)

	if not item then
		return
	end

	if item and item.resolvedWorldPos then
		local layer = 0

		if self.indoorId > 0 then
			layer = self.baseMap:CheckElementUnifiedMapLayer(item.resolvedWorldPos)
		end

		info.layer = layer

		self:SetIconColor(info)
	end
end

local AIR_PORT_ICON_ID = 28000806

function M:SetAirportPenertrateIcon(info)
	if gMapUtils:IsViewItemAttachingAirPort(info.mapElement.instanceId, self.mapView, self.areaId) then
		info.store.iconId = AIR_PORT_ICON_ID
	end
end

local WHITE_COLOR = Color.white

function M:SetIconColor(info)
	if info.store.iconWidget ~= nil then
		local targetColor = nil

		if info.mapElement.miniMapData.dontSetColor then
			targetColor = info.store.iconWidget.color
		elseif info.mapElement.miniMapData.color ~= nil then
			targetColor = info.mapElement.miniMapData.color
		else
			targetColor = WHITE_COLOR
		end

		local targetAlpha = 1

		if info.layer ~= 0 then
			targetAlpha = LTConfig.GpsConfig.DifferentLayerIconAlpha
		end

		info.store.iconWidget.color = Color.New(targetColor.r, targetColor.g, targetColor.b, targetAlpha)
	end
end
