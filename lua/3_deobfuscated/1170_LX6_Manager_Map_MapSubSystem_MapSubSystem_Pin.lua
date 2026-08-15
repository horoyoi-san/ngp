MapSubSystem_Pin = DefClass("MapSubSystem_Pin", MapSubSystem_Pin, MapSubSystemBase)
local M = MapSubSystem_Pin
local UNINITED_Y = 974500

function M:OnInit()
	self.PinType = {
		Reward = 1,
		Photo = 3,
		Default = 0,
		Gugu = 2
	}
	self.tempPinInited = false
	self.TEMP_PIN_ID = "__TempPin"
	self.TEMP_PIN_ID_999 = "__TempPin_999"
	self.TEMP_PIN_ID_OUT = "__TempPin_Out"
	self.pins = {}
	self.freshState = {}
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
		}
	}

	gMessageManager:AddMessageListener(gEventConstants.MAP_PINS_UPDATE, function ()
		self:OnFlushData()
	end)
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, function ()
		self:RefreshPinPhysicLandPos()
	end)
end

function M:GetAllTempPinGpsIds()
	return {
		self.TEMP_PIN_ID,
		self.TEMP_PIN_ID_999,
		self.TEMP_PIN_ID_OUT
	}
end

function M:IsTempPin(gpsId)
	return gpsId == self.TEMP_PIN_ID or gpsId == self.TEMP_PIN_ID_999 or gpsId == self.TEMP_PIN_ID_OUT
end

function M:TempPin(worldPos, areaId)
	if not worldPos then
		print_error("@sunwei08: TempPin worldPos is nil")

		return
	end

	self:EnsureTempPin()

	local pinElement, tempPinId = nil
	areaId = areaId or gMapSystem.area.XinQiAreaId

	if areaId == gMapSystem.area.XinQiAreaId then
		pinElement = self.tmp_pinElement
		tempPinId = self.TEMP_PIN_ID
	elseif areaId == gMapSystem.area.ChongXiaoAreaId then
		pinElement = self.tmp_pinElement_999
		tempPinId = self.TEMP_PIN_ID_999
	else
		return nil
	end

	if self._fixedY then
		worldPos.y = self._fixedY
	elseif areaId == gMapAreaMgr.raidId2AreaId[gMapSystem.lastRaidId] then
		worldPos = gUIUtils:GetPhysicsLandPosByXZ(worldPos)
	else
		worldPos.y = UNINITED_Y
	end

	pinElement:SetPosition(worldPos)
	pinElement:SetVisible(true)

	local raidId = gMapSystem.area:SplitAreaId(areaId)
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(raidId, worldPos.x, worldPos.z)
	local outOfArea = blockId <= 0
	pinElement.userdata.outOfArea = outOfArea

	pinElement:SetActions(outOfArea and self.Actions.UnpinnableTemp or self.Actions.PinnableTemp)

	return tempPinId
end

function M:ClearTempPin()
	if self.tmp_pinElement then
		self.tmp_pinElement:SetVisible(false)
	end

	if self.tmp_pinElement_999 then
		self.tmp_pinElement_999:SetVisible(false)
	end
end

function M:GetPinCount()
	return gPlayerManager.infoMinor.bindData.MapPins.Count or 0
end

function M:OnFlushData()
	self:EnsureTempPin()

	local activePins = {}
	local showType = LTConfig.GpsConfig.ShowTypeofMarkGPS[1]
	local thumbnailId = LTConfig.GpsConfig.ShowTypeofMarkGPS[2]

	for raidId, pinDatas in pairs(gPlayerManager.infoMinor.bindData.MapPins or {}) do
		if raidId ~= "Count" then
			for _, pinData in ipairs(pinDatas) do
				local id = pinData.Id
				local worldPos = Vector3.New(pinData.Position.x, pinData.Position.y, pinData.Position.z)
				local pinType = pinData.PinType
				local info = self.pins[id]
				local element = nil

				if info then
					element = info.mapElement
				else
					info = {
						type = pinType
					}
					self.pins[id] = info
					element = MapElement.CreateLegacy(EMapElementType.Mark, id, EMapSubSystemType.Pin, EMapViewMask.AllSgui, raidId, 0)

					self:CommonSetup(element)

					element.fData.ignoreFog = true

					element:SetActions(self.Actions.Exist)

					element.gpsData.removeGpsRange = LTConfig.GameConfig.MarkAutoRemoveGpsRange
					element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

					if self:FetchFreshState(id) then
						element.bigMapData.fresh = true
					end

					gMapSubSystemUtils:SetupScaleLevel(element, showType, thumbnailId)
					element:SetVisible(true)

					info.mapElement = element
				end

				element:SetPosition(worldPos)

				activePins[id] = true
			end
		end
	end

	for id, pinInfo in pairs(self.pins) do
		if not activePins[id] then
			pinInfo.mapElement:Dispose()

			self.pins[id] = nil
		end
	end
end

function M:ClearAllFreshState()
	for _, info in pairs(self.pins) do
		info.mapElement.bigMapData.fresh = nil
	end
end

function M:SGetTooltipInfo(id, element)
	if not self:IsTempPin(id) and not self.pins[id] then
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

function M:ExecuteAction(element, action, ctx)
	if action == gMapSystemElementAction.Pin then
		self:ConfirmPin(element, false)
	elseif action == gMapSystemElementAction.PinAndTrace then
		self:ConfirmPin(element, true)
	elseif action == gMapSystemElementAction.DeletePin then
		self:DeletePin(element.id)
	elseif action == gMapSystemElementAction.Trace or action == gMapSystemElementAction.Untrace then
		gMapSubSystemActionHelper.TryExecuteTraceAction(element, action, ctx)
	end
end

function M:RefreshPinPhysicLandPos()
	for _, info in pairs(self.pins) do
		local element = info.mapElement

		if element and element.raidId == gMapSystem.lastRaidId then
			local worldPos = element:GetWorldPos()

			if worldPos.y == UNINITED_Y then
				worldPos.y = 0
				worldPos = gUIUtils:GetPhysicsLandPosByXZ(worldPos)

				element:SetPosition(worldPos)
			end
		end
	end
end

function M:ConfirmPin(element, trace)
	if LTConfig.GameConfig.MapPinMaxCount <= gPlayerManager.infoMinor.bindData.MapPins.Count then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.MapMarkPointLimited)

		return
	end

	local worldPos = element:GetWorldPos()
	local pinType = element.userdata.pinType
	local raidId = element.raidId
	local uxVec = UX.Game.UXVector3.New(worldPos.x, worldPos.y, worldPos.z)

	self:ClearTempPin()

	gClientToGameDelegate:AskPutMapPin(raidId, uxVec, pinType).Callback = function (err, id)
		if err == LTConfig.MessageConfig.Ok then
			self:HandlePinSuccess(id, raidId, worldPos, pinType, trace)
		end
	end
end

function M:HandlePinSuccess(id, raidId, worldPos, pinType, trace)
	self:SetFreshId(id)
	self:AddMapPinClient(raidId, worldPos, pinType, id)

	if trace then
		gMapSubSystemActionHelper.TryExecuteTraceAction(self.pins[id].mapElement, gMapSystemElementAction.Trace)
	end
end

function M:SetFreshId(id)
	self.freshState[id] = true
end

function M:FetchFreshState(id)
	local state = self.freshState[id]
	self.freshState[id] = nil

	return state
end

function M:DeletePin(id)
	gClientToGameDelegate:AskRemoveMapPin(id).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self:RemovePinClient(id)
		end
	end
end

function M:EnsureTempPin()
	if self.tempPinInited then
		return
	end

	if not self.tmp_pinElement then
		local element = MapElement.CreateLegacy(EMapElementType.Mark, self.TEMP_PIN_ID, EMapSubSystemType.Pin, EMapViewMask.BigMap, LTConfig.RaidConfig.WorldMap, 0)

		self:CommonSetup(element)

		element.bigMapData.scaleLevel = 0
		element.bigMapData.cantMatch = true
		element.bigMapData.ignoreInScalePromoteCheck = true
		element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

		element:SetVisible(false)
		element:SetPosition(Vector3.New(-10000, 0, -10000))
		element:SetActions(self.Actions.Temp)

		element.userdata = {
			pinType = self.PinType.Default
		}
		self.tmp_pinElement = element
	end

	if not self.tmp_pinElement_999 then
		local element = MapElement.CreateLegacy(EMapElementType.Mark, self.TEMP_PIN_ID_999, EMapSubSystemType.Pin, EMapViewMask.BigMap, LTConfig.RaidConfig.Chongxiao, 0)

		self:CommonSetup(element)

		element.bigMapData.scaleLevel = 0
		element.bigMapData.cantMatch = true
		element.bigMapData.ignoreInScalePromoteCheck = true
		element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

		element:SetVisible(false)
		element:SetPosition(Vector3.New(-10000, 0, -10000))
		element:SetActions(self.Actions.Temp)

		element.userdata = {
			isTemporary = true,
			pinType = self.PinType.Default
		}
		self.tmp_pinElement_999 = element
	end
end

function M:AddMapPinClient(raidId, position, pinType, id)
	if gPlayerManager.infoMinor.bindData.MapPins[raidId] == nil then
		gPlayerManager.infoMinor.bindData.MapPins[raidId] = {}
	end

	local list = gPlayerManager.infoMinor.bindData.MapPins[raidId]

	table.insert(list, {
		Position = position,
		PinType = pinType,
		Id = id
	})

	gPlayerManager.infoMinor.bindData.MapPins.Count = gPlayerManager.infoMinor.bindData.MapPins.Count + 1

	gMessageManager:SendMessage(gEventConstants.MAP_PINS_UPDATE, {
		state = gMapUtils.MapPinState.Add,
		id = id
	})
end

function M:RemovePinClient(id)
	for i, v in pairs(gPlayerManager.infoMinor.bindData.MapPins) do
		local raidPinList = v

		if type(v) == "table" then
			for i = #raidPinList, 1, -1 do
				if raidPinList[i].Id == id then
					table.remove(raidPinList, i)

					gPlayerManager.infoMinor.bindData.MapPins.Count = gPlayerManager.infoMinor.bindData.MapPins.Count - 1

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

function M:GmSetPinY(enable, y)
	if not enable then
		self._fixedY = nil
	else
		self._fixedY = y
	end
end

function M:CommonSetup(element)
	element.fData.ignoreFog = true
	element.fData.dontClearFog = true
	element.mData.sIconId = LTConfig.GpsConfig.MarkGPSIconId
	element.miniMapData.iconId = LTConfig.GpsConfig.MarkGPSIconId
	element.bigMapData.iconId = LTConfig.GpsConfig.GreyMarkGpsIconId
	element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Pin
	element.bigMapData.customRenderFuncKey = "OnCustomRenderPin"
	local nameCfg = LTConfig.TextScriptTextConfig.GetConfig(89900330)
	element.mData.lName = GpsLText.CreateCommonText(nameCfg, "Text")
end

return M
