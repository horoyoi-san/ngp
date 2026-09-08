-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_HideAndSeek.lua
-- Decompiled from: 02320_MapSubSystem_HideAndSeek.lua_9ac37310eea1.luajit

MapSubSystem_HideAndSeek = DefClass("MapSubSystem_HideAndSeek", MapSubSystem_HideAndSeek, MapSubSystemBase)
local M = MapSubSystem_HideAndSeek

M.OnInit = function(self)
	self._seekers = {}
	self._hiders = {}
	self._visiblePids = {}
	self._notExistPids = {}
	self._lastTickTime = 0
	self._curCamp = 0
end

M.OnLoadData = function(self)
	self.ClearData(self)
end

M.OnLogin = function(self)
	self.ClearData(self)
end

M.OnLogout = function(self)
	self.ClearData(self)
end

M.ClearData = function(self)
	self.isGhost = false
	self._curCamp = 0

	for _, element in pairs(self._seekers) do
		element.Dispose(element)
	end

	table.clear(self._seekers)

	for _, element in pairs(self._hiders) do
		element.Dispose(element)
	end

	table.clear(self._hiders)
	table.clear(self._visiblePids)
end

M.Tick = function(self)
	if not table.isNilOrEmpty(self._visiblePids) then
		local now = LTUtils.UXTime.GetNowUnixTime()

		for idStr, expireTime in pairs(self._visiblePids) do
			if not expireTime or expireTime < now then
				self._visiblePids[idStr] = nil

				if self._hiders[idStr] then
					self._hiders[idStr]:SetVisible(false)
				end
			end
		end
	end

	if not table.isNilOrEmpty(self._notExistPids) then
		local now = LTUtils.UXTime.GetNowUnixTime()

		if not self._lastTickTime or now - self._lastTickTime <= 1 then
			self._lastTickTime = now

			for idStr, pid in pairs(self._notExistPids) do
				local element = self._seekers[idStr] or self._hiders[idStr]

				if not element then
					self._notExistPids[idStr] = nil
				else
					local success, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(pid, ulong.zero)

					if success then
						element.BindUnit(element, unitId)

						self._notExistPids[idStr] = nil
					end
				end
			end
		end
	end
end

M.OnSceneDestroy = function(self)
	self.ClearData(self)
end

M.CheckCurCamp = function(self, seekers, hiders)
	local pid = gPlayerManager.infoLogin.bindData.pid

	if seekers.Count then
		for i = 1, seekers.Count do
			if seekers[i] ~= pid then
				self.curCampId = 0

				return
			end
		end
	end

	if hiders.Count then
		for i = 1, hiders.Count do
			if hiders[i] ~= pid then
				self.curCampId = 1

				return
			end
		end
	end
end

M.TryAddSeekers = function(self, seekers)
	local raidId = gRaidDataManager.RaidId

	if seekers.Count then
		for i = 1, seekers.Count do
			local id = seekers[i]

			if not id then
				-- Nothing
			else
				local idStr = ulong.tostring(id)

				if not self._seekers[idStr] then
					local element = MapElement.CreateLegacy(EMapElementType.HideAndSeek, idStr, EMapSubSystemType.HideAndSeek, EMapViewMask.MiniMap, raidId)
					local success, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(id, ulong.zero)

					if success then
						element.BindUnit(element, unitId)
					else
						self._notExistPids[idStr] = id
					end

					element.SetTraceInfo(element, EMapGTraceType.Other, 0)

					if self.curCampId ~= 0 then
						element.mData.sIconId = LTConfig.HideAndSeekConfig.MiniMapSeekerIconId_Ally
					else
						element.mData.sIconId = LTConfig.HideAndSeekConfig.MiniMapSeekerIconId
					end

					element.SetVisible(element, true)

					self._seekers[idStr] = element
				end
			end
		end
	end
end

M.TryAddHiders = function(self, hiders)
	local raidId = gRaidDataManager.RaidId

	if hiders.Count then
		for i = 1, hiders.Count do
			local id = hiders[i]

			if not id then
				-- Nothing
			else
				local idStr = ulong.tostring(id)

				if not self._hiders[idStr] then
					local element = MapElement.CreateLegacy(EMapElementType.HideAndSeek, idStr, EMapSubSystemType.HideAndSeek, EMapViewMask.MiniMap, raidId)
					local success, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(id, ulong.zero)

					if success then
						element.BindUnit(element, unitId)
					else
						self._notExistPids[idStr] = id
					end

					element.SetTraceInfo(element, EMapGTraceType.Other, 0)

					if self.curCampId ~= 1 then
						element.mData.sIconId = LTConfig.HideAndSeekConfig.MiniMapHiderIconId_Ally
					else
						element.mData.sIconId = LTConfig.HideAndSeekConfig.MiniMapHiderIconId
					end

					if self._visiblePids[idStr] then
						element.SetVisible(element, true)
					else
						element.SetVisible(element, self.isGhost)
					end

					self._hiders[idStr] = element
				end
			end
		end
	end
end

M.SyncStartGhostMode = function(self)
	self.isGhost = true

	for id, element in pairs(self._hiders) do
		element.SetVisible(element, self.isGhost)
	end
end

M.SyncHideAndSeekGhostMice = function(self, rats)
	if rats.Count then
		for i = 1, rats.Count do
			local pid = rats[i]

			if pid and pid ~= gPlayerManager.infoLogin.bindData.pid then
				self.SyncStartGhostMode(self)

				return
			end
		end
	end
end

M.RemoveSeeker = function(self, id)
	if not id then
		return false
	end

	local element = self._seekers[id]

	if element then
		element.Dispose(element)

		self._seekers[id] = nil
	end

	return true
end

M.RemoveHider = function(self, id)
	if not id then
		return false
	end

	local element = self._hiders[id]

	if element then
		element.Dispose(element)

		self._hiders[id] = nil
	end

	return true
end

M.SyncCatMapMarker = function(self, targetPid, expireTime)
	if self.isGhost then
		return
	end

	local now = LTUtils.UXTime.GetNowUnixTime()

	if expireTime < now then
		return
	end

	local idStr = ulong.tostring(targetPid)
	self._visiblePids[idStr] = expireTime

	for id, element in pairs(self._hiders) do
		if self._visiblePids[id] then
			element.SetVisible(element, true)
		else
			element.SetVisible(element, false)
		end
	end
end

return M
