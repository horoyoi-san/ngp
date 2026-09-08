-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineTeamModelViewerStore.lua
-- Decompiled from: 01064_OnlineTeamModelViewerStore.lua_e20530dc969b.luajit

C_OnlineTeamModelViewerStore = DefClass("C_OnlineTeamModelViewerStore", C_OnlineTeamModelViewerStore, C_StoreGroup)
GroupName2Class.OnlineTeamModelViewerStore = C_OnlineTeamModelViewerStore
local M = C_OnlineTeamModelViewerStore
local LayerConstants = LX6.Constants.LayerConstants

M.ctor = function(self)
	self.DefineAllVariables(self)
end

M.DefineAllVariables = function(self)
	self.bindModelName = "model"
	self.bindModelTransName = "modelTransform"
	self.pendingLoadRequest = {}
	self.originalModelSlotPos = {}
	self.currentModelUnit = {}
	self.modelSlotTid = {}
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(true, 20)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	self.bindData.baseTrans.gameObject:SetParent(nil, true)
	self.bindData.baseTrans.gameObject:SetPosition(0, -100, 0)
	self.bindData.baseTrans:SetLocalScale(1)

	self.isStarted = true

	self:ExecutePendingLoadRequests()

	if self.startCallback then
		self.startCallback()

		self.startCallback = nil
	end

	if gClientUtils.NotNil(self.bindData.virtualCamera) then
		self.bindData.virtualCamera.gameObject:SetActive(true)
	end
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.waitCo = coroutine.stop(self.waitCo)
	self.targetWeatherIndex = nil

	self:ClearCharacterModel(1)
	self:ClearCharacterModel(2)
	self:ClearCharacterModel(3)
	self:ClearCharacterModel(4)
	gCS.GuiUtils.SetXuWeiWeatherState(false)
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)
	gCS.PauseManager.Instance:ProessUIModelShow(false)
	GameObject.Destroy(self.bindData.baseTrans.gameObject)

	self.isStarted = false

	table.clear(self.pendingLoadRequest)
	table.clear(self.originalModelSlotPos)
	table.clear(self.currentModelUnit)
	table.clear(self.modelSlotTid)
	gCS.CameraDataMgr:ResetOverrideStreamingCam()
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.ResetCfg = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(true, 20)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	gCS.CameraDataMgr:SetOverrideStreamingCam(gCS.CameraDataMgr.MainCamera)
end

M.GetCamera = function(self)
	return gCS.CameraDataMgr.MainCamera
end

M.GetUnitBySlotIndex = function(self, index)
	return self.currentModelUnit[index]
end

M.GetSlotPosByIndex = function(self, index)
	local slotWorldPos = nil
	local modelSlotBindName = string.format("%s%d", self.bindModelTransName, index)
	local modelSlot = self.bindData[modelSlotBindName]

	if modelSlot then
		slotWorldPos = modelSlot.position
	end

	return slotWorldPos
end

M.ExecutePendingLoadRequests = function(self)
	if #self.pendingLoadRequest ~= 0 then
		return
	end

	local requests = {}

	for index, request in pairs(self.pendingLoadRequest) do
		requests[index] = request
	end

	table.clear(self.pendingLoadRequest)

	for index, request in pairs(requests) do
		if request.type ~= "character" then
			self.LoadCharacterModel(self, index, request.spiritId, request.fashionInfo, request.onLoadComplete)
		end
	end
end

M.LoadCharacterModel = function(self, index, spiritId, fashionInfo, onLoadComplete)
	if not self.isStarted then
		self.pendingLoadRequest[index] = {
			["n;m^"] = "@Om{O*",
			spiritId = spiritId,
			fashionInfo = fashionInfo,
			onLoadComplete = onLoadComplete
		}

		return
	end

	if self.modelSlotTid[index] ~= spiritId then
		return
	end

	if not spiritId or spiritId ~= 0 then
		self.ClearCharacterModel(self, index)

		return
	end

	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)

	self.ClearCharacterModel(self, index)

	self.modelSlotTid[index] = spiritId

	print_debug("OnlineTeamModelViewerStore LoadCharacterModel Begin spiritId:" .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

	local modelSlotBindName = string.format("%s%d", self.bindModelTransName, index)
	local modelSlot = self.bindData[modelSlotBindName]

	if not self.originalModelSlotPos[index] and modelSlot then
		self.originalModelSlotPos[index] = modelSlot.localPosition
	end

	local modelId = agentConfig.GeneralModelId
	local moduleBindName = string.format("%s%d", self.bindModelName, index)
	local currentLoadIndex = index
	self.bindData[moduleBindName] = {
		["\\x96':l\\xbb@\\xda>\\xa4\\xbe"] = false,
		["lc\\xbfcC\\xbf\\xd4FispK"] = 0,
		modelId = modelId,
		layer = LayerConstants.Player,
		otherData = {
			["\\xf2\\x94\\xf8=\\xf2\\xe5\\x86\\xc1\\x8d/8"] = true,
			["\\x8a=7w\\x8al\\xd63\\xaf\\xb5"] = true,
			SubType = spiritId,
			cardId = spiritId,
			fashionWearInfo = fashionInfo
		},
		callback = function (unit)
			if spiritId == self.modelSlotTid[index] then
				unit.DestroyUnit(unit, true)

				return
			end

			print_debug("OnlineTeamModelViewerStore LoadCharacterModel End spiritId:" .. spiritId .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)
			unit.PlayerObj.gameObject:SetLayerRecursively(LayerConstants.Npc)

			self.currentModelUnit[currentLoadIndex] = unit
			unit.PlayerObj.transform.localScale = Vector3.one
			unit.PlayerObj.transform.localEulerAngles = Vector3(0, 0, 0)
			local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)

			if modelCfg and self.bindData[modelSlotBindName] and self.originalModelSlotPos[currentLoadIndex] then
				local bodyType = modelCfg.CameraBodyType == 0 and modelCfg.CameraBodyType or modelCfg.BodyType
				local fashionBaseCfg = LTConfig.FashionBaseConfig.GetConfig(bodyType)

				if fashionBaseCfg and fashionBaseCfg.PediaModelOffset then
					local offset = fashionBaseCfg.PediaModelOffset
					local newPos = self.originalModelSlotPos[currentLoadIndex] + Vector3.New(offset.x, offset.y, offset.z)
					self.bindData[modelSlotBindName].localPosition = newPos
				end
			end

			gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(unit.PlayerObj)
			gCS.SceneDataMgr.UIUnitManager:AddUnit(unit.Pid, unit)
			gCS.LuaUtils.SetUIUnitBindItemListLod(unit)
			gCS.PauseManager.Instance:ProessUIModelShow(false, unit)
			gCS.PauseManager.Instance:ProessUIModelShow(true, unit)
			gCS.LuaUtils.ForceSetPlayerTransform(unit.PlayerObj.transform)

			unit.State.ActionGroupId = 1

			gCS.AnimControllerManager.PlayAction(unit, 1001, 1, 9999, 0, -1, false, nil, 0)

			if onLoadComplete then
				onLoadComplete(unit)
			end
		end
	}
end

M.ClearCharacterModel = function(self, index)
	if self.currentModelUnit[index] then
		local unit = self.currentModelUnit[index]

		if gCS.LuaUtils.IsBaseUnitValid(unit) then
			gCS.PauseManager.Instance:ProessUIModelShow(false, self.currentModelUnit[index])
			self.currentModelUnit[index]:DestroyUnit(true)
		end

		self.currentModelUnit[index] = nil
	end

	self.modelSlotTid[index] = nil

	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()

	local modelSlotBindName = string.format("%s%d", self.bindModelTransName, index)
	local modelSlot = self.bindData[modelSlotBindName]

	if self.originalModelSlotPos[index] and modelSlot then
		modelSlot.localPosition = self.originalModelSlotPos[index]
	end
end
