local bit = require("bit")
local M = C_NewMapPanelStore

function M:IsSpecialView()
	return bit.band(self:GetViewMask(), EMapViewMask.BigMap) == 0
end

function M:PreHandleParams(legacy_params)
	local params = legacy_params or {}
	self.params = params
	params.raidId = params.raidId or params.MapRaidId or gRaidDataManager.RaidId
	params.indoorId = params.indoorId or params.MapIndoorId or gMapManager.IndoorId

	if params.id and params.id > 1000000 and not params.AutoSelectTaskId then
		params.AutoSelectTaskId = params.id
	end

	params.id = nil

	if params.taxiMode then
		self:SendFSMSignal(EBigMapFSMSignal.SwitchModeTaxi)
		gMapSubSystem_TaxiDest:OnTaxiMapOpen()
	elseif params.factionMode then
		self:SendFSMSignal(EBigMapFSMSignal.SwitchModeFaction)
	elseif params.legendMode then
		self:SendFSMSignal(EBigMapFSMSignal.SwitchModeLegend)
	elseif params.metroMode then
		self:SendFSMSignal(EBigMapFSMSignal.SwitchModeMetro)

		local cfg = params.curMetroEntranceId and LTConfig.MapentranceConfig.GetConfig(params.curMetroEntranceId)

		if cfg and cfg.Type == gMapUtils.RaidMapEntranceType.Metro then
			local metroId = params.curMetroEntranceId
			params.curMetroEntranceId = nil
			params.autoSelectEntranceId = metroId
			self.showContext.currentEnteringMetroId = metroId

			if self.mapCfg and self.mapCfg.scaleData and self.mapCfg.scaleData.minScale then
				params.initScale = self.mapCfg.scaleData.minScale
			end
		end
	end

	if params.OnClose then
		array.push(self._onCloseCbs, params.OnClose)
	end
end

function M:GetAutoSelectGpsId(params)
	if params.autoPinWorldPos then
		if params.autoSelectGpsId then
			return params.autoSelectGpsId
		else
			return gMapSubSystem_Pin:TempPin(self.params.autoPinWorldPos)
		end
	end

	if params.autoSelectGpsId then
		return params.autoSelectGpsId
	end

	if params.AutoSelectTaskId then
		return gMapSubSystem_Task:GetFirstGpsIdByTaskId(params.AutoSelectTaskId)
	end

	if params.autoSelectEntranceId then
		return gGpsTools.GetMapId(EMapElementType.Entrance, params.autoSelectEntranceId)
	end

	if params.autoSelectCompoundId then
		return gGpsTools.GetMapId(EMapElementType.Compound, params.autoSelectCompoundId)
	end

	if params.autoSelectSubQuestid then
		return gGpsTools.GetMapId(EMapElementType.Collection, params.autoSelectSubQuestid)
	end

	if params.autoSelectLegendId and gMapSubSystem_Legend then
		local gpsId = gMapSubSystem_Legend:GetElementGpsId(params.autoSelectLegendId)

		if gpsId and gpsId ~= 0 then
			return gpsId
		end
	end

	if params.autoSelectFactionId then
		local element = gMapSubSystem_Faction:GetFirstElement(params.autoSelectFactionId)

		if element then
			return element.gpsId
		end
	end
end

function M:HandleAutoSelect()
	local autoSelectGpsId = self:GetAutoSelectGpsId(self.params)

	if autoSelectGpsId then
		local element = gMapSystem:GetByGpsId(autoSelectGpsId)

		if element then
			gMapSystem.ui.bigMapInterestSource:AddElement(element.instanceId)

			local raidId = element.raidId
			local indoorId = element.indoorId

			if gMapUIUtils.HasConfig(raidId, indoorId) then
				self.params.raidId = raidId
				self.params.indoorId = indoorId
			end
		end

		self:ScheduleOperation(self.OperationType.WaitSelect, {
			maxWaitTime = 0.4,
			gpsId = autoSelectGpsId,
			timeOutMessage = LTConfig.MessageConfig.LockedAreaLoact
		})

		self.autoSelectGpsId = autoSelectGpsId
	end
end
