-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_ExtractionContainer.lua
-- Decompiled from: 02316_MapSubSystem_ExtractionContainer.lua_a192087d9aa5.luajit

local ItemContainerConfig = LTConfig.ExtractionShooterItemContainerConfig
local GpsInfoConfig = LTConfig.ExtractionShooterGpsInfoConfig
MapSubSystem_ExtractionContainer = DefClass("MapSubSystem_ExtractionContainer", MapSubSystem_ExtractionContainer, MapSubSystemBase)
local M = MapSubSystem_ExtractionContainer

M.OnInit = function(self)
	self.highItems = {}
	self.middleItems = {}
end

M.OnLogin = function(self)
end

M.OnLogout = function(self)
	self.ClearAll(self)
end

M.OnSceneInit = function(self)
	self.ClearAll(self)
end

M.OnSceneDestroy = function(self)
	self.ClearAll(self)
end

M.ClearAll = function(self)
	for _, item in pairs(self.highItems) do
		item.Dispose(item)
	end

	table.clear(self.highItems)

	for _, item in pairs(self.middleItems) do
		item.Dispose(item)
	end

	table.clear(self.middleItems)
end

M.SGetTooltipInfo = function(self, id, element)
	local cfg = ItemContainerConfig.GetConfig(id)

	if not cfg then
		return
	end

	local gpsInfoId = cfg.GpsInfo
	local gpsInfoCfg = GpsInfoConfig.GetConfig(gpsInfoId)

	if not gpsInfoCfg then
		return
	end

	local tooltipInfo = {
		type = EMapTooltipType.Common,
		header = {
			name = gpsInfoCfg.GpsName,
			imageId = gpsInfoCfg.HeadImage or 0
		},
		commonInfo = {
			desc = gpsInfoCfg.GpsDesc or ""
		}
	}

	return tooltipInfo
end

M.SyncExtractionGpsInfo = function(self, highItemGpsInfos, middleItemGpdInfos)
	self.ClearAll(self)

	for id, infos in pairs(highItemGpsInfos) do
		if infos.Infos then
			local cfg = ItemContainerConfig.GetConfig(id)

			if not cfg then
				print_error("@xuqiang05 ItemContainer config not found, id:", id)
			else
				for _, posInfo in pairs(infos.Infos) do
					local element = MapElement.CreateLegacy(EMapElementType.ExtractionContainer, id, EMapSubSystemType.ExtractionContainer, EMapViewMask.AllSgui, gMapSystem.lastRaidId)
					local position = posInfo.Position
					local worldPos = Vector3.New(position.X, position.Y, position.Z)

					element:SetPosition(worldPos)

					local iconId = cfg.HighValueIcon or 0
					element.mData.sIconId = iconId

					element:SetActions(self.NormalTraceableActions)
					element:SetVisible(true)

					self.highItems[id] = element
				end
			end
		end
	end

	for id, infos in pairs(middleItemGpdInfos) do
		if infos.Infos then
			local cfg = ItemContainerConfig.GetConfig(id)

			if not cfg then
				print_error("@xuqiang05 ItemContainer config not found, id:", id)
			else
				for _, posInfo in pairs(infos.Infos) do
					local element = MapElement.CreateLegacy(EMapElementType.ExtractionContainer, id, EMapSubSystemType.ExtractionContainer, EMapViewMask.AllSgui, gMapSystem.lastRaidId)
					local position = posInfo.Position
					local worldPos = Vector3.New(position.X, position.Y, position.Z)

					element:SetPosition(worldPos)

					local iconId = cfg.MiddleValueIcon or 0
					element.mData.sIconId = iconId

					element:SetActions(self.NormalTraceableActions)
					element:SetVisible(true)

					self.middleItems[id] = element
				end
			end
		end
	end
end

return M
