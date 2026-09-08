-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MiniMapPanelStore_Trace.lua
-- Decompiled from: 00979_MiniMapPanelStore_Trace.lua_9bc615823fa5.luajit

local bit = require("bit")
local TMP_MapGuideType = {
	["y\\xbc\\xa3\\xac\\xb3"] = 1,
	["M'|P"] = 2
}
local M = C_MiniMapPanelStore

M.InitTraceData = function(self)
	self.bindData.sideTaskTip:SetActive(false)

	self._tickIds = {}
	self._guideIds = {}
end

M.IncreaseTickCounter = function(self, id)
	self._tickIds[id] = (self._tickIds[id] or 0) + 1
end

M.DecreaseTickCounter = function(self, id)
	local tickCounter = self._tickIds[id]

	if tickCounter then
		tickCounter = tickCounter - 1

		if tickCounter <= 0 then
			self._tickIds[id] = tickCounter
		else
			self._tickIds[id] = nil
		end
	end
end

local HIDE_ARROW = 0
local SHOW_ARROW = 1
local ARROW_UP = 0
local ARROW_DOWN = 1
local UXVector3 = UX.Game.UXVector3
local _tmpPolygonVertexList = {}
local _tmpPoint = UXVector3.New(0, 0, 0)

local IsTargetInDangerArea = function(areaDatas, wx, wz)
	if not areaDatas then
		return false
	end

	_tmpPoint.X = wx
	_tmpPoint.Z = wz

	for _, areaData in ipairs(areaDatas) do
		if not areaData.isSafe then
			local pts = areaData.points
			local n = #pts / 2

			if n > 3 then
				for i = 1, n do
					local v = _tmpPolygonVertexList[i]

					if v then
						v.X = pts[i * 2 - 1]
						v.Z = pts[i * 2]
					else
						_tmpPolygonVertexList[i] = UXVector3.New(pts[i * 2 - 1], 0, pts[i * 2])
					end
				end

				for i = #_tmpPolygonVertexList, n + 1, -1 do
					_tmpPolygonVertexList[i] = nil
				end

				if gCS.LuaUtils.PointInPolygon(_tmpPoint, _tmpPolygonVertexList) then
					return true
				end
			end
		end
	end

	return false
end

M.TickTraceEffect = function(self, inLogicThread)
	for id, _ in pairs(self._guideIds) do
		local info = self._id2ElementInfo[id]
		local viewItem = self.mapView:GetItemInfo(id)

		if info and viewItem then
			self.UpdateTexPos(self, info, nil, inLogicThread)

			if info.mapElement.mData.rangeInfo == nil then
				self.UpdateTracingRange(self, info, inLogicThread)
			elseif self.HasPolygonRange(self, info.mapElement) or self.CheckGpsCustomAreaRange(self, info.mapElement) then
				if inLogicThread then
					self.StoreWidgetOperation(self, self, self.SetVisible, info, false)
				else
					self.SetVisible(self, info, false)
				end

				if info.traceEffectWidget and not info.traceEffectWidget.bDestroy then
					if inLogicThread then
						self.StoreWidgetOperation(self, info.traceEffectWidget, info.traceEffectWidget.SetActive, false)
					else
						info.traceEffectWidget:SetActive(false)
					end
				end
			else
				if inLogicThread then
					self.StoreWidgetOperation(self, self, self.SetVisible, info, true)
				else
					self.SetVisible(self, info, true)
				end

				if info.traceEffectWidget and not info.traceEffectWidget.bDestroy then
					if inLogicThread then
						self.StoreWidgetOperation(self, info.traceEffectWidget, info.traceEffectWidget.SetActive, true)
					else
						info.traceEffectWidget:SetActive(true)
					end

					local x, y = self.TransformTex2UIXY(self, info.clampedTexPos.x, info.clampedTexPos.y)

					if inLogicThread then
						self.StoreWidgetOperation(self, info.traceEffectWidget.rectTransform, info.traceEffectWidget.rectTransform.SetLocalPositionXY, x, y)
					else
						info.traceEffectWidget.rectTransform:SetLocalPositionXY(x, y)
					end
				end
			end

			local targetInDanger = self.isInDangerArea and IsTargetInDangerArea(self:GetSafeAreaDatas(), info.worldPos.x, info.worldPos.z)

			if targetInDanger then
				local playerY = inLogicThread and self._tempData.playerUnitLocalPos.y or gMapSystem:GetCurPlayerLocalPosition().y
				local targetY = info.worldPos.y
				local tolerance = LTConfig.GpsConfig.MiniMapAltitudeTolerances

				if tolerance >= math.abs(playerY - targetY) then
					info.store.minimapShowArrow = SHOW_ARROW
					info.store.minimapArrow = playerY - targetY >= 0 and ARROW_UP or ARROW_DOWN
				else
					info.store.minimapShowArrow = HIDE_ARROW
				end
			else
				info.store.minimapShowArrow = HIDE_ARROW
			end
		end
	end
end

M.AddTraceInfo = function(self, info)
	local id = info.mapElement.instanceId

	self.AddGuideMask(self, info, TMP_MapGuideType.Trace)
	self.IncreaseTickCounter(self, id)

	if not info.traceEffectWidget then
		local widget = self.bindData.traceEffectPool:CreateItem(0)
		info.traceEffectWidget = widget
	end

	local traceStore = gStoreManager:GetStoreGroup("MiniMapTraceEffectStore"):GetStoreByWidget(info.traceEffectWidget)

	if traceStore then
		traceStore.tintColor1 = info.mapElement.mData.tintColor or "3263FF"
		traceStore.tintColor2 = info.mapElement.mData.tintColor or "3263FF"
	end
end

M.ClearTraceInfo = function(self, info)
	local id = info.mapElement.instanceId

	self.RemoveGuideMask(self, info, TMP_MapGuideType.Trace)
	self.DecreaseTickCounter(self, id)

	if info.traceEffectWidget then
		self.bindData.traceEffectPool:DeleteItem(info.traceEffectWidget)

		info.traceEffectWidget = nil
	end

	info.store.minimapShowArrow = HIDE_ARROW
end

M.AddWeakGuide = function(self, info)
	self.AddGuideMask(self, info, TMP_MapGuideType.Weak)
end

M.ClearWeakGuide = function(self, info)
	self.RemoveGuideMask(self, info, TMP_MapGuideType.Weak)
end

M.AddGuideMask = function(self, info, guideMask)
	local oldGuideMask = info.guideMask
	info.guideMask = bit.bor(info.guideMask, guideMask)

	if oldGuideMask ~= 0 and info.guideMask <= 0 then
		self._guideIds[info.mapElement.instanceId] = true
		info.guiding = true
		info.store.maskable = false

		self.UpdateTexPos(self, info)
	end
end

M.RemoveGuideMask = function(self, info, guideMask)
	if bit.band(info.guideMask, guideMask) == 0 then
		info.guideMask = info.guideMask - guideMask
	end

	if info.guideMask ~= 0 then
		self._guideIds[info.mapElement.instanceId] = nil
		info.guiding = nil
		info.store.maskable = true

		self.UpdateTexPos(self, info)
	end
end

M.UpdateTracingRange = function(self, info, inLogicThread)
	local element = info.mapElement
	local viewItem = self.mapView:GetItemInfo(element.instanceId)

	if not viewItem then
		gGpsTools.Assert(gGpsModule.SafeAssert, "UpdateTracingRange: viewItem is nil for id: " .. tostring(element.instanceId))

		return
	end

	local widgetEnable = false
	widgetEnable = viewItem.coordType ~= EMapViewerItemCoordType.AttachGate or info.clamped

	if info.traceEffectWidget then
		local x, y = self.TransformTex2UIXY(self, info.clampedTexPos.x, info.clampedTexPos.y)

		if inLogicThread then
			self.StoreWidgetOperation(self, info.traceEffectWidget, info.traceEffectWidget.SetActive, widgetEnable)
			self.StoreWidgetOperation(self, info.traceEffectWidget.rectTransform, info.traceEffectWidget.rectTransform.SetLocalPositionXY, x, y)
		else
			info.traceEffectWidget:SetActive(widgetEnable)
			info.traceEffectWidget.rectTransform:SetLocalPositionXY(x, y)
		end
	end
end
