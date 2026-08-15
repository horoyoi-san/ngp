local bit = require("bit")
local TMP_MapGuideType = {
	Trace = 1,
	Weak = 2
}
local M = C_MiniMapPanelStore

function M:InitTraceData()
	self.bindData.sideTaskTip:SetActive(false)

	self._tickIds = {}
	self._guideIds = {}
end

function M:IncreaseTickCounter(id)
	self._tickIds[id] = (self._tickIds[id] or 0) + 1
end

function M:DecreaseTickCounter(id)
	local tickCounter = self._tickIds[id]

	if tickCounter then
		tickCounter = tickCounter - 1

		if tickCounter > 0 then
			self._tickIds[id] = tickCounter
		else
			self._tickIds[id] = nil
		end
	end
end

function M:TickTraceEffect()
	for id, _ in pairs(self._guideIds) do
		local info = self._id2ElementInfo[id]
		local viewItem = self.mapView:GetItemInfo(id)

		if info and viewItem then
			self:UpdateTexPos(info)

			if info.mapElement.mData.rangeInfo ~= nil then
				self:UpdateTracingRange(info)
			elseif self:HasPolygonRange(info.mapElement) then
				self:SetVisible(info, false)

				if info.traceEffectWidget and not info.traceEffectWidget.bDestroy then
					info.traceEffectWidget:SetActive(false)
				end
			else
				self:SetVisible(info, true)

				if info.traceEffectWidget and not info.traceEffectWidget.bDestroy then
					info.traceEffectWidget:SetActive(true)

					local x, y = self:TransformTex2UIXY(info.clampedTexPos.x, info.clampedTexPos.y)

					info.traceEffectWidget.rectTransform:SetLocalPositionXY(x, y)
				end
			end
		end
	end
end

function M:AddTraceInfo(info)
	local id = info.mapElement.instanceId

	self:AddGuideMask(info, TMP_MapGuideType.Trace)
	self:IncreaseTickCounter(id)

	if not info.traceEffectWidget then
		local widget = self.bindData.traceEffectPool:CreateItem(0)
		info.traceEffectWidget = widget
	end
end

function M:ClearTraceInfo(info)
	local id = info.mapElement.instanceId

	self:RemoveGuideMask(info, TMP_MapGuideType.Trace)
	self:DecreaseTickCounter(id)

	if info.traceEffectWidget then
		self.bindData.traceEffectPool:DeleteItem(info.traceEffectWidget)

		info.traceEffectWidget = nil
	end
end

function M:AddWeakGuide(info)
	self:AddGuideMask(info, TMP_MapGuideType.Weak)
end

function M:ClearWeakGuide(info)
	self:RemoveGuideMask(info, TMP_MapGuideType.Weak)
end

function M:AddGuideMask(info, guideMask)
	local oldGuideMask = info.guideMask
	info.guideMask = bit.bor(info.guideMask, guideMask)

	if oldGuideMask == 0 and info.guideMask > 0 then
		self._guideIds[info.mapElement.instanceId] = true
		info.guiding = true

		self:SyncWorldPos(info)

		info.store.maskable = false

		self:UpdateTexPos(info)
	end
end

function M:RemoveGuideMask(info, guideMask)
	if bit.band(info.guideMask, guideMask) ~= 0 then
		info.guideMask = info.guideMask - guideMask
	end

	if info.guideMask == 0 then
		self._guideIds[info.mapElement.instanceId] = nil
		info.guiding = nil

		self:SyncWorldPos(info)

		info.store.maskable = true

		self:UpdateTexPos(info)
	end
end

function M:NotifySideTaskUnlock()
	self.bindData.sideTaskTip:SetActive(true)

	local anim = self.bindData.sideTaskTip:GetComponent(typeof(UnityEngine.Animation))

	anim:Play()
end

function M:NotifyMainTaskUnlock(instanceId)
	if self._id2ElementInfo[instanceId] then
		self._id2ElementInfo[instanceId].store.rootAnim:Play("S_vx_miniMapIcon_open")
	end
end

function M:UpdateTracingRange(info)
	local element = info.mapElement
	local viewItem = self.mapView:GetItemInfo(element.instanceId)

	if not viewItem then
		gGpsTools.Assert(gGpsModule.SafeAssert, "UpdateTracingRange: viewItem is nil for id: " .. tostring(element.instanceId))

		return
	end

	local widgetEnable = false
	local rangeWidgetEnable = false

	if viewItem.coordType ~= EMapViewerItemCoordType.AttachGate and not info.clamped then
		widgetEnable = false
		rangeWidgetEnable = true
	else
		widgetEnable = true
		rangeWidgetEnable = false
	end

	self:SetVisible(info, widgetEnable)

	if info.traceEffectWidget then
		info.traceEffectWidget:SetActive(widgetEnable)

		local x, y = self:TransformTex2UIXY(info.clampedTexPos.x, info.clampedTexPos.y)

		info.traceEffectWidget.rectTransform:SetLocalPositionXY(x, y)
	end

	if info.rangeWidget then
		info.rangeWidget:SetActive(rangeWidgetEnable)
	end
end
