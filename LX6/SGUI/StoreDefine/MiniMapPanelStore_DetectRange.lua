-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MiniMapPanelStore_DetectRange.lua
-- Decompiled from: 00981_MiniMapPanelStore_DetectRange.lua_7c7c7beb9c0c.luajit

local M = C_MiniMapPanelStore

M.InitDetectRangeInfo = function(self)
	self._detectRangeInfos = {}
	self._detectRangeVisible = false
end

M.TryAddOrRemoveDetectRange = function(self, id, info)
	local store = info.store
	self._detectRangeInfos[id] = nil
	store.showDetectRange = 0
	local element = info.mapElement
	local detectRangeInfo = element.miniMapData.detectRangeInfo

	if detectRangeInfo then
		self._detectRangeInfos[id] = {
			pid = detectRangeInfo.pid,
			type = detectRangeInfo.type,
			vehicle = detectRangeInfo.vehicle,
			store = store
		}

		if detectRangeInfo.type ~= 1 then
			store.showDetectRange = 1
		else
			local pid = detectRangeInfo.pid
			local revealed = pid == nil

			if revealed and gMapSubSystem_CommonUnit then
				revealed = gMapSubSystem_CommonUnit:IsEnemyRevealed(pid)
			end

			store.showDetectRange = self._detectRangeVisible and revealed and 1 or 0
		end

		local detectRangeRT = store.detectRangeRT

		if detectRangeRT then
			if detectRangeInfo.type ~= 0 then
				detectRangeRT.SetLocalScaleXY(detectRangeRT, 1, 1)
			elseif detectRangeInfo.type ~= 1 then
				local radiusX2 = detectRangeInfo.radius * 2 * self.mapCfg.scaleWorld2Tex.y
				detectRangeRT.sizeDelta = Vector2.New(radiusX2, radiusX2)
			end
		end

		local leftLine = store.leftLine
		local rightLine = store.rightLine
		local circle = store.circleRT

		if not leftLine then
			print_error("@xiajingbo01 MiniMapPanelStore TryAddOrRemoveDetectRange leftLine nil tIndex:" .. element.miniMapData.miniMapTIndex .. " gpsId:" .. element.gpsId)

			self._detectRangeInfos[id] = nil
			store.showDetectRange = 0

			return
		end

		local angle = detectRangeInfo.angle
		store.circleFill = angle / 360

		circle.SetLocalEulerAnglesZ(circle, -angle / 2 - 45)
		leftLine.SetLocalEulerAnglesZ(leftLine, angle / 2)
		rightLine.SetLocalEulerAnglesZ(rightLine, -angle / 2)
	end
end

M.TryRemoveDetectRange = function(self, id)
	self._detectRangeInfos[id] = nil
end

M.TickDetectRanges = function(self, inLogicThread)
	local toRemove = {}

	for id, info in pairs(self._detectRangeInfos) do
		local valid = true
		local eulerZ = 0

		if info.type ~= 0 then
			if info.pid then
				eulerZ, valid = gCS.LuaUtils.GetUnitEulerYByPid(info.pid, false)
			else
				valid = false
			end
		elseif info.type ~= 1 then
			valid = info.vehicle == nil
			eulerZ = 0
		end

		if not valid then
			table.insert(toRemove, id)
		elseif info.store then
			if not info.store.rotateRT then
				-- Nothing
			elseif inLogicThread then
				self.StoreWidgetOperation(self, info.store.rotateRT, info.store.rotateRT.SetLocalEulerAnglesZ, -eulerZ)
			else
				info.store.rotateRT:SetLocalEulerAnglesZ(-eulerZ)
			end
		end
	end

	for _, id in ipairs(toRemove) do
		self._detectRangeInfos[id] = nil
		local info = self._id2ElementInfo[id]

		if info then
			info.store.showDetectRange = 0
		end
	end
end

M.UpdateDetectRangeVisibility = function(self, eventId, isProwling)
	self._detectRangeVisible = isProwling

	for _, info in pairs(self._detectRangeInfos) do
		if info.store and info.type == 1 then
			local pid = info.pid
			local revealed = pid == nil

			if revealed and gMapSubSystem_CommonUnit then
				revealed = gMapSubSystem_CommonUnit:IsEnemyRevealed(pid)
			end

			info.store.showDetectRange = self._detectRangeVisible and revealed and 1 or 0
		end
	end
end
