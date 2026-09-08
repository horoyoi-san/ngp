-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Pin.lua
-- Decompiled from: 02304_MapSubSystem_Pin.lua_2355ab2d1450.luajit

MapSubSystem_Pin = DefClass("MapSubSystem_Pin", MapSubSystem_Pin, MapSubSystemBase)
local M = MapSubSystem_Pin
local UNINITED_Y = 974500

M.OnInit = function(self)
	self.PinType = {
		[".M\\x86\\x8f\\x91E"] = 1,
		["}\\xa6\\xad\\xbb\\xb9"] = 3,
		["\\xfd\\xde(\\xe5"] = 0,
		["]7zN"] = 2
	}
	self.tempPinInited = false
	self.TEMP_PIN_ID = "__TempPin"
	self.TEMP_PIN_ID_999 = "__TempPin_999"
	self.TEMP_PIN_ID_OUT = "__TempPin_Out"
	self.pins = {}
	self.clientChecked = {}
	self.freshState = {}
	self.traceState = {}
	self.tmp_pinElement = nil
	self.tmp_pinElement_999 = nil
	self.Actions = {
		PinnableTemp = {
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.PinAndTrace,
				gMapSystemElementAction.Pin
			}
		},
		UnpinnableTemp = {
			[gMapSystem_Element_State.Normal] = {}
		},
		Exist = {
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.Trace,
				gMapSystemElementAction.DeletePin
			},
			[gMapSystem_Element_State.Tracing] = {
				gMapSystemElementAction.Untrace,
				gMapSystemElementAction.DeletePin
			}
		},
		ExtractionShooterPin = {}
	}
	self.extractionShooterMarks = {}
	self.eventHandlers = {
		[gEventConstants.MAP_PINS_UPDATE] = function ()
			self:FlushData()
		end,
		[gEventConstants.L50_AFTER_SWITCH_SCENE] = function ()
			self:RefreshPinPhysicLandPos()
		end,
		[gEventConstants.LINK_MODE_CHANGE] = function ()
			self:OnFlushData(true)
		end,
		[gEventConstants.LINK_MEMBER_INFO_CHANGE] = function ()
			self:OnFlushData(true)
		end,
		[gEventConstants.TEAM_REFRESH_DATA] = function ()
			self:OnFlushData(true)
		end,
		[gEventConstants.MAP_CHANGE_TO_INDOOR_MAP_EARLY] = function ()
			self:FlushData()
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.GetAllTempPinGpsIds = function(self)
	return {
		self.TEMP_PIN_ID,
		self.TEMP_PIN_ID_999,
		self.TEMP_PIN_ID_OUT
	}
end

M.IsTempPin = function(self, gpsId)
	return gpsId ~= self.TEMP_PIN_ID or gpsId ~= self.TEMP_PIN_ID_999 or gpsId ~= self.TEMP_PIN_ID_OUT
end

M.Tick = function(self, forceRefresh)
	if forceRefresh or gGpsTools.TryTick("ReCheckPinPos", 5) then
		local pinDatas = gPlayerManager.infoMinor.bindData.MapPins and gPlayerManager.infoMinor.bindData.MapPins[gMapSystem.lastRaidId]

		if pinDatas then
			for _, pinData in ipairs(pinDatas) do
				local id = pinData.Id

				if self.clientChecked[id] then
					-- Nothing
				else
					local pinInfo = self.pins[id]

					if pinInfo then
						local pinPos = pinData.Position
						local hit, hitPoint = self.GetPhysicsLandPosByXZ(self, pinPos.x, pinPos.z)

						if hit then
							local uxVec = UX.Game.UXVector3.New(hitPoint.x, hitPoint.y, hitPoint.z)
							slot14 = gClientToGameDelegate

							slot14:AskPutMapPin(gMapSystem.lastRaidId, uxVec, self.PinType.Default).Callback = function (err, id)
								if err ~= LTConfig.MessageConfig.Ok then
									self.clientChecked[id] = true

									self:HandlePinSuccess(id, gMapSystem.lastRaidId, hitPoint, self.PinType.Default, pinInfo.mapElement:IsTracing())
								end
							end
						elseif pinPos.y ~= UNINITED_Y then
							slot13 = gClientToGameDelegate

							slot13:AskPutMapPinFar(gMapSystem.lastRaidId, pinPos.x, pinPos.z, self.PinType.Default).Callback = function (err, pinData)
								if err ~= LTConfig.MessageConfig.Ok then
									local pinPos = Vector3.New(pinData.PinPos.X, pinData.PinPos.Y, pinData.PinPos.Z)

									self:HandlePinSuccess(pinData.Id, gMapSystem.lastRaidId, pinPos, self.PinType.Default, pinInfo.mapElement:IsTracing())
								end
							end
						end
					end
				end
			end
		end
	end
end

M.IsExtractionShooterTrackElement = function(self, element)
	return element and gLinkManager:CheckIsExtractionShooter() and element.gpsData and element.gpsData.pId == nil
end

M.GetPhysicsLandPosByXZ = function(self, x, z)
	local position = Vector3.New(x, 500, z)
	local direction = Vector3.New(0, -1, 0)
	local hit, hitInfo = nil
	hit, hitInfo = gCS.LuaUtils.Raycast(position, direction, 520, LX6.Constants.LayerConstants.colliderMoveLayer, hitInfo)

	if hit then
		return true, hitInfo.point
	end

	return false, nil
end

M.TempPin = function(self, worldPos, areaId)
	if not worldPos then
		print_error("@sunwei08: TempPin worldPos is nil")

		return
	end

	self:EnsureTempPin()

	local pinElement, tempPinId = nil
	areaId = areaId or gMapSystem.area.XinQiAreaId

	if areaId ~= gMapSystem.area.XinQiAreaId then
		pinElement = self.tmp_pinElement
		tempPinId = self.TEMP_PIN_ID
	elseif areaId ~= gMapSystem.area.ChongXiaoAreaId then
		pinElement = self.tmp_pinElement_999
		tempPinId = self.TEMP_PIN_ID_999
	else
		return nil
	end

	local raidId = gMapManager:GetParentRaidId(gMapSystem.lastRaidId)

	if self._fixedY then
		worldPos.y = self._fixedY
	elseif areaId ~= gMapAreaMgr.raidId2AreaId[raidId] then
		local hit, hitPoint = self.GetPhysicsLandPosByXZ(self, worldPos.x, worldPos.z)

		if hit then
			worldPos = hitPoint
		else
			worldPos.y = UNINITED_Y
		end
	else
		worldPos.y = UNINITED_Y
	end

	pinElement:SetPosition(worldPos)
	pinElement:SetVisible(true)

	local raidId = gMapSystem.area:SplitAreaId(areaId)
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(raidId, worldPos.x, worldPos.z)
	local outOfArea = blockId > 0
	pinElement.userdata.outOfArea = outOfArea

	pinElement:SetActions(outOfArea and self.Actions.UnpinnableTemp or self.Actions.PinnableTemp)

	return tempPinId
end

M.ClearTempPin = function(self)
	if self.tmp_pinElement then
		self.tmp_pinElement:SetVisible(false)
	end

	if self.tmp_pinElement_999 then
		self.tmp_pinElement_999:SetVisible(false)
	end
end

M.GetPinCount = function(self)
	return 0
end

M.OnFlushData = function(self, refreshColor)
	self:EnsureTempPin()

	local activePins = {}
	local showType = LTConfig.GpsConfig.ShowTypeofMarkGPS[1]
	local thumbnailId = LTConfig.GpsConfig.ShowTypeofMarkGPS[2]
	slot5 = pairs
	slot7 = gPlayerManager.infoMinor.bindData.MapPins or {}

	for raidId, pinDatas in slot5(slot7) do
		if raidId == "Count" then
			for _, pinData in ipairs(pinDatas) do
				local id = pinData.Id
				local worldPos = Vector3.New(pinData.Position.x, pinData.Position.y, pinData.Position.z)
				local pinType = pinData.PinType
				local info = self.pins[id]
				local element = nil

				if info then
					element = info.mapElement

					if refreshColor then
						self.SetupCommonBigWorldPin(self, element)
					end
				else
					info = {
						type = pinType
					}
					self.pins[id] = info
					element = MapElement.CreateLegacy(EMapElementType.Mark, id, EMapSubSystemType.Pin, EMapViewMask.AllSgui, raidId, 0)

					self.SetupCommonBigWorldPin(self, element)

					element.fData.ignoreFog = true

					element.SetActions(element, self.Actions.Exist)

					element.gpsData.removeGpsRange = LTConfig.GameConfig.MarkAutoRemoveGpsRange
					element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

					if self.FetchFreshState(self, id) then
						element.bigMapData.fresh = true
					end

					gMapSubSystemUtils:SetupScaleLevel(element, showType, thumbnailId)
					element:SetVisible(true)

					info.mapElement = element
				end

				element.SetSyncTrackPos(element, worldPos)
				element.SetPosition(element, worldPos)

				activePins[id] = true

				if self.FetchTraceState(self, id) then
					gMapSubSystemActionHelper.TryExecuteTraceAction(element, gMapSystemElementAction.Trace)
				end
			end
		end
	end

	for id, pinInfo in pairs(self.pins) do
		if not activePins[id] then
			pinInfo.mapElement:Dispose()

			self.pins[id] = nil
			self.clientChecked[id] = nil
		end
	end

	self.Tick(self, true)
end

M.ClearAllFreshState = function(self)
	for _, info in pairs(self.pins) do
		info.mapElement.bigMapData.fresh = nil
	end
end

M.SGetTooltipInfo = function(self, id, element)
	if not self.IsTempPin(self, id) and not self.pins[id] then
		return nil
	end

	local isTemporary = self:IsTempPin(id)
	local tooltipInfo = {
		type = EMapTooltipType.Pin,
		pinInfo = {
			maxPinCount = LTConfig.GameConfig.MapPinMaxCount,
			pinCount = self:GetPinCount(),
			isTemporary = isTemporary,
			outOfArea = isTemporary and element.userdata.outOfArea
		}
	}

	return tooltipInfo
end

M.ExecuteAction = function(self, element, action, ctx)
	if action ~= gMapSystemElementAction.Pin then
		self.ConfirmPin(self, element, false)
	elseif action ~= gMapSystemElementAction.PinAndTrace then
		self.ConfirmPin(self, element, true)
	elseif action ~= gMapSystemElementAction.DeletePin then
		self.DeletePin(self, element.id)
	elseif action ~= gMapSystemElementAction.Trace or action ~= gMapSystemElementAction.Untrace then
		gMapSubSystemActionHelper.TryExecuteTraceAction(element, action, ctx)
	end
end

M.RefreshPinPhysicLandPos = function(self)
	for _, info in pairs(self.pins) do
		local element = info.mapElement

		if element and element.raidId ~= gMapSystem.lastRaidId then
			local worldPos = element.GetWorldPos(element)

			if worldPos.y ~= UNINITED_Y then
				worldPos.y = 0
				local hit, hitPoint = self.GetPhysicsLandPosByXZ(self, worldPos.x, worldPos.z)

				if hit then
					worldPos = hitPoint
				else
					worldPos.y = UNINITED_Y
				end

				element.SetPosition(element, worldPos)
			end
		end
	end
end

M.ConfirmPin = function(self, element, trace)
	local worldPos = element.GetWorldPos(element)
	local pinType = element.userdata.pinType
	local raidId = element.raidId
	local uxVec = UX.Game.UXVector3.New(worldPos.x, worldPos.y, worldPos.z)

	self.ClearTempPin(self)

	if worldPos.y ~= UNINITED_Y then
		slot7 = gClientToGameDelegate

		slot7:AskPutMapPinFar(raidId, worldPos.x, worldPos.z, pinType).Callback = function (err, pinData)
			if err ~= LTConfig.MessageConfig.Ok then
				local pinPos = Vector3.New(pinData.PinPos.X, pinData.PinPos.Y, pinData.PinPos.Z)

				self:HandlePinSuccess(pinData.Id, raidId, pinPos, pinType, true)
			end
		end
	else
		slot7 = gClientToGameDelegate

		slot7:AskPutMapPin(raidId, uxVec, pinType).Callback = function (err, id)
			if err ~= LTConfig.MessageConfig.Ok then
				self:HandlePinSuccess(id, raidId, worldPos, pinType, trace)
			end
		end
	end
end

M.HandlePinSuccess = function(self, id, raidId, worldPos, pinType, trace)
	self.SetFreshId(self, id)
	self.AddMapPinClient(self, raidId, worldPos, pinType, id)

	if trace then
		self.SetTraceId(self, id)
	end
end

M.SetFreshId = function(self, id)
	self.freshState[id] = true
end

M.FetchFreshState = function(self, id)
	local state = self.freshState[id]
	self.freshState[id] = nil

	return state
end

M.SetTraceId = function(self, id)
	self.traceState[id] = true
end

M.FetchTraceState = function(self, id)
	local state = self.traceState[id]
	self.traceState[id] = nil

	return state
end

M.DeletePin = function(self, id)
	slot2 = gClientToGameDelegate

	slot2:AskRemoveMapPin(id).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			self:RemovePinClient(id)
		end
	end
end

M.EnsureTempPin = function(self)
	if self.tempPinInited then
		if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
			if self.tmp_pinElement then
				self.tmp_pinElement.fData.bigMapTIndex = 0
				self.tmp_pinElement.fData.hudTIndex = 0
				self.tmp_pinElement.miniMapData.miniMapTIndex = 0
				self.tmp_pinElement.mData.tintColor = nil
			end

			if self.tmp_pinElement_999 then
				self.tmp_pinElement_999.fData.bigMapTIndex = 0
				self.tmp_pinElement_999.fData.hudTIndex = 0
				self.tmp_pinElement_999.miniMapData.miniMapTIndex = 0
				self.tmp_pinElement_999.mData.tintColor = nil
			end
		else
			if self.tmp_pinElement then
				local pId = self.tmp_pinElement.gpsData.pId or gPlayerManager.infoLogin.bindData.pid
				self.tmp_pinElement.fData.bigMapTIndex = 9
				self.tmp_pinElement.fData.hudTIndex = 11
				self.tmp_pinElement.miniMapData.miniMapTIndex = 7
				self.tmp_pinElement.mData.tintColor = gLinkManager:GetColorInfo(pId)
			end

			if self.tmp_pinElement_999 then
				local pId = self.tmp_pinElement_999.pId or gPlayerManager.infoLogin.bindData.pid
				self.tmp_pinElement_999.fData.bigMapTIndex = 9
				self.tmp_pinElement_999.fData.hudTIndex = 11
				self.tmp_pinElement_999.miniMapData.miniMapTIndex = 7
				self.tmp_pinElement_999.mData.tintColor = gLinkManager:GetColorInfo(pId)
			end
		end

		return
	end

	if not self.tmp_pinElement then
		local element = MapElement.CreateLegacy(EMapElementType.Mark, self.TEMP_PIN_ID, EMapSubSystemType.Pin, EMapViewMask.BigMap, LTConfig.RaidConfig.WorldMap, 0)

		self.SetupCommonBigWorldPin(self, element)

		element.bigMapData.scaleLevel = 0
		element.bigMapData.cantMatch = true
		element.bigMapData.ignoreInScalePromoteCheck = true
		element.bigMapData.notAddToFilterMenu = true
		element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

		element.SetVisible(element, false)
		element.SetPosition(element, Vector3.New(-10000, 0, -10000))
		element.SetActions(element, self.Actions.Temp)

		element.userdata = {
			pinType = self.PinType.Default
		}
		self.tmp_pinElement = element
	end

	if not self.tmp_pinElement_999 then
		local element = MapElement.CreateLegacy(EMapElementType.Mark, self.TEMP_PIN_ID_999, EMapSubSystemType.Pin, EMapViewMask.BigMap, LTConfig.RaidConfig.Chongxiao, 0)

		self.SetupCommonBigWorldPin(self, element)

		element.bigMapData.scaleLevel = 0
		element.bigMapData.cantMatch = true
		element.bigMapData.ignoreInScalePromoteCheck = true
		element.bigMapData.notAddToFilterMenu = true
		element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

		element.SetVisible(element, false)
		element.SetPosition(element, Vector3.New(-10000, 0, -10000))
		element.SetActions(element, self.Actions.Temp)

		element.userdata = {
			["\\x96':u\\x8dN\\xcb6\\xb8\\xa0"] = true,
			pinType = self.PinType.Default
		}
		self.tmp_pinElement_999 = element
	end

	self.tempPinInited = true
end

M.AddMapPinClient = function(self, raidId, position, pinType, id)
	self.RemoveAllPinClient(self)

	if gPlayerManager.infoMinor.bindData.MapPins[raidId] ~= nil then
		gPlayerManager.infoMinor.bindData.MapPins[raidId] = {}
	end

	local list = gPlayerManager.infoMinor.bindData.MapPins[raidId]

	table.insert(list, {
		Position = position,
		PinType = pinType,
		Id = id
	})
	gMessageManager:SendMessage(gEventConstants.MAP_PINS_UPDATE, {
		state = gMapUtils.MapPinState.Add,
		id = id
	})
end

M.RemovePinClient = function(self, id)
	for i, v in pairs(gPlayerManager.infoMinor.bindData.MapPins) do
		local raidPinList = v

		if type(v) ~= "table" then
			for i = #raidPinList, 1, -1 do
				if raidPinList[i].Id ~= id then
					table.remove(raidPinList, i)

					break
				end
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.MAP_PINS_UPDATE, {
		state = gMapUtils.MapPinState.Remove,
		id = id
	})
end

M.RemoveAllPinClient = function(self)
	for raidId, raidPinList in pairs(gPlayerManager.infoMinor.bindData.MapPins) do
		if type(raidPinList) ~= "table" then
			gPlayerManager.infoMinor.bindData.MapPins[raidId] = nil
		end
	end

	gMessageManager:SendMessage(gEventConstants.MAP_PINS_UPDATE, {
		state = gMapUtils.MapPinState.Remove
	})
end

M.GmSetPinY = function(self, enable, y)
	if not enable then
		self._fixedY = nil
	else
		self._fixedY = y
	end
end

M.SetupCommonBigWorldPin = function(self, element)
	element.fData.ignoreFog = true
	element.fData.dontClearFog = true

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		element.fData.bigMapTIndex = 0
		element.fData.hudTIndex = 0
		element.miniMapData.miniMapTIndex = 0
		element.mData.tintColor = nil
	else
		element.fData.bigMapTIndex = 9
		element.fData.hudTIndex = 11
		element.miniMapData.miniMapTIndex = 7
		local pId = element.gpsData.pId or gPlayerManager.infoLogin.bindData.pid
		element.mData.tintColor = gLinkManager:GetColorInfo(pId)
	end

	element.mData.sIconId = LTConfig.GpsConfig.MarkGPSIconId
	element.miniMapData.iconId = LTConfig.GpsConfig.MarkGPSIconId
	element.bigMapData.iconId = LTConfig.GpsConfig.GreyMarkGpsIconId
	element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Pin
	element.bigMapData.customRenderFuncKey = "OnCustomRenderPin"
	local nameCfg = LTConfig.TextScriptTextConfig.GetConfig(89900330)
	element.mData.lName = GpsLText.CreateCommonText(nameCfg, "Text")

	if gLinkManager:CheckIsExtractionShooter() and element.gpsData.pId then
		self.SetupExtractionShooterPinExtra(self, element, element.gpsData.pId)
	end
end

M.SetupExtractionShooterPinExtra = function(self, element, pid)
	element.bigMapData.unselectable = true
	element.bigMapData.filterTag = nil
	element.bigMapData.customRenderFuncKey = nil
	local memberIndex = gLinkManager.LinkMemberIndex[gLinkManager.LinkMode]
	element.mData.playerNumber = memberIndex and memberIndex[pid] or 0
end

M.SetupExtractionShooterPin = function(self, element, pid)
	element.gpsData.pId = pid

	self.SetupCommonBigWorldPin(self, element)
end

M.OnBigMapExtractionShooterMark = function(self, raidId, worldPos)
	if raidId == gSceneDataMgr.CurrentRaidId then
		return
	end

	if not worldPos then
		return
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid
	local element = self.extractionShooterMarks[myPid]

	if not element then
		element = MapElement.CreateLegacy(EMapElementType.Mark, tostring(myPid), EMapSubSystemType.Pin, EMapViewMask.AllSgui, raidId, 0)

		self.SetupExtractionShooterPin(self, element, myPid)
		element.SetVisible(element, true)
		element.SetTraceInfo(element, EMapGTraceType.Other)

		self.extractionShooterMarks[myPid] = element
	end

	element:SetRaidId(raidId)
	element:SetSyncTrackPos(worldPos)
	element:SetPosition(worldPos)
	gMapSystem.trace:RemoveMainTrace(true)
	gMapSystem.trace:SetMainTraceGpsId(element.gpsId, false, true)
	gMapSystem.trace:DoSyncTrackGPS(element.gpsId)
end

M.OnBigMapExtractionShooterCancelMark = function(self, targetElement)
	local myPid = gPlayerManager.infoLogin.bindData.pid

	if targetElement.gpsData.pId == myPid then
		return true
	end

	local wasMainTrace = gMapSystem.trace.mainTraceGpsId ~= targetElement.gpsId

	if wasMainTrace then
		gMapSystem.trace:RemoveMainTrace(true)
	end

	self.extractionShooterMarks[myPid] = nil

	targetElement.Dispose(targetElement)

	if wasMainTrace then
		gMapSystem.trace:DoSyncTrackGPS(nil)
	end

	return true
end

M.OnSceneDestroy = function(self)
	for _, elem in pairs(self.extractionShooterMarks) do
		elem.Dispose(elem)
	end

	table.clear(self.extractionShooterMarks)
end

M.CanDrawMyExtractionShooterMarkPath = function(self)
	if not gLinkManager:CheckIsExtractionShooter() then
		return false
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid

	if not self.extractionShooterMarks[myPid] then
		return false
	end

	return true
end

M.GetMyExtractionShooterMarkPath = function(self)
	local myPid = gPlayerManager.infoLogin.bindData.pid
	local playerPosition = gClientUtils.GetPlayerPosition()
	local path = {
		["0M\\x9f\\x89\\x97I"] = 0
	}

	if self.extractionShooterMarks[myPid] then
		local worldPos = self.extractionShooterMarks[myPid]:GetWorldPos()
		local pos = Vector3.New(worldPos.x, worldPos.y, worldPos.z)
		path[path.Length] = pos
		path.Length = path.Length + 1
	end

	playerPosition = Vector3.New(playerPosition.X, playerPosition.Y, playerPosition.Z)
	path[path.Length] = playerPosition
	path.Length = path.Length + 1

	return path
end

M.TempPinAndTrace = function(self, worldPos, areaId)
	local raidId = gMapManager:GetParentRaidId(gMapSystem.lastRaidId)

	if self._fixedY then
		worldPos.y = self._fixedY
	elseif areaId ~= gMapAreaMgr.raidId2AreaId[raidId] then
		local hit, hitPoint = self.GetPhysicsLandPosByXZ(self, worldPos.x, worldPos.z)

		if hit then
			worldPos = hitPoint
		else
			worldPos.y = UNINITED_Y
		end
	else
		worldPos.y = UNINITED_Y
	end

	local raidId = gMapSystem.area:SplitAreaId(areaId)

	if gLinkManager:CheckIsExtractionShooter() then
		self.OnBigMapExtractionShooterMark(self, raidId, worldPos)

		return
	end

	local pinType = self.PinType.Default
	local uxVec = UX.Game.UXVector3.New(worldPos.x, worldPos.y, worldPos.z)

	if worldPos.y ~= UNINITED_Y then
		if raidId ~= gMapSystem.lastRaidId then
			slot7 = gClientToGameDelegate

			slot7:AskPutMapPinFar(raidId, worldPos.x, worldPos.z, pinType).Callback = function (err, pinData)
				if err ~= LTConfig.MessageConfig.Ok then
					local pinPos = Vector3.New(pinData.PinPos.X, pinData.PinPos.Y, pinData.PinPos.Z)

					self:HandlePinSuccess(pinData.Id, raidId, pinPos, pinType, true)
				end
			end
		else
			slot7 = gClientToGameDelegate

			slot7:AskPutMapPin(raidId, uxVec, pinType).Callback = function (err, id)
				if err ~= LTConfig.MessageConfig.Ok then
					self:HandlePinSuccess(id, raidId, worldPos, pinType, true)
				end
			end
		end
	else
		slot7 = gClientToGameDelegate

		slot7:AskPutMapPin(raidId, uxVec, pinType).Callback = function (err, id)
			if err ~= LTConfig.MessageConfig.Ok then
				self.clientChecked[id] = true

				self:HandlePinSuccess(id, raidId, worldPos, pinType, true)
			end
		end
	end
end

M.SyncMapPins = function(self, mapPins)
	for raidId, pinDatas in pairs(gPlayerManager.infoMinor.bindData.MapPins) do
		if raidId == "Count" then
			for _, pinData in ipairs(pinDatas) do
				local id = pinData.Id
				local pinInfo = self.pins[id]

				if pinInfo and pinInfo.mapElement and gMapSystem.trace:CheckIsMainTraceGPS(pinInfo.mapElement.instanceId) then
					self.SetTraceId(self, id)
				end
			end
		end
	end

	gPlayerManager.infoMinor.bindData.MapPins = {}

	for id, mapPin in pairs(mapPins) do
		local raidId = mapPin.RaidId
		local pinInfo = {
			Id = id,
			PinType = mapPin.Type,
			Position = Vector3.New(mapPin.Position.X, mapPin.Position.Y, mapPin.Position.Z)
		}
		gPlayerManager.infoMinor.bindData.MapPins[raidId] = gPlayerManager.infoMinor.bindData.MapPins[raidId] or {}

		table.insert(gPlayerManager.infoMinor.bindData.MapPins[raidId], pinInfo)
	end

	self.FlushData(self)
end

return M
