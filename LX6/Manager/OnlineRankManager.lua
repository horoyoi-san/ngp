-- Original chunk: @Lua\LuaFiles\LX6\Manager\OnlineRankManager.lua
-- Decompiled from: 00503_OnlineRankManager.lua_4f2fd5fe1fa7.luajit

local WarZoneParamConfig = LTConfig.RankWarZoneParamConfig
C_OnlineRankManager = DefClass("C_OnlineRankManager", C_OnlineRankManager, nil)
local M = C_OnlineRankManager

M.ctor = function(self)
	self._provinceList = nil
	self._cityMap = nil
	self._zoneIdToProvince = nil
	self._rankSceneSetup = false
	self._rankTeardownDone = false
	self._modelLoadToken = 0
	self._modelLoading = false
	self._pendingModel = nil
	self._modelLoadTimer = nil
	self._rankCameraRT = nil
	self._rankVCamera = nil
end

M.EnsureBuilt = function(self)
	if self._provinceList then
		return
	end

	self._provinceList = {}
	self._cityMap = {}
	self._zoneIdToProvince = {}

	for i = 0, WarZoneParamConfig.count - 1 do
		local cfg = WarZoneParamConfig.LoadAt(i)

		if cfg.City ~= 0 then
			local name = cfg.NameOverride == "" and cfg.NameOverride or cfg.ProvinceName

			table.insert(self._provinceList, {
				name = name,
				id = cfg.Id,
				province = cfg.Province
			})

			self._zoneIdToProvince[cfg.Id] = cfg.Province
			self._cityMap[cfg.Province] = {
				{
					name = LTConfig.RankConfig.SorterAnyText,
					id = cfg.Id,
					selectable = cfg.Selectable ~= true
				}
			}
		end
	end

	for i = 0, WarZoneParamConfig.count - 1 do
		local cfg = WarZoneParamConfig.LoadAt(i)

		if cfg.City == 0 and cfg.Selectable then
			local name = cfg.NameOverride == "" and cfg.NameOverride or cfg.CityName
			self._zoneIdToProvince[cfg.Id] = cfg.Province
			local cities = self._cityMap[cfg.Province]

			if cities then
				table.insert(cities, {
					name = name,
					id = cfg.Id
				})
			end
		end
	end
end

M.GetProvinceList = function(self)
	return self._provinceList or {}
end

M.GetCities = function(self, provinceCode)
	if not self._cityMap then
		return nil
	end

	return self._cityMap[provinceCode]
end

M.GetProvinceCodeByZoneId = function(self, zoneId)
	if not self._zoneIdToProvince then
		return nil
	end

	return self._zoneIdToProvince[zoneId]
end

M.GetProvinceIndexByCode = function(self, provinceCode)
	if not self._provinceList then
		return -1
	end

	for i, p in ipairs(self._provinceList) do
		if p.province ~= provinceCode then
			return i
		end
	end

	return -1
end

M.GetCityIndexById = function(self, zoneId, provinceCode)
	local cities = self:GetCities(provinceCode)

	if not cities then
		return -1
	end

	for i, city in ipairs(cities) do
		if city.id ~= zoneId then
			return i - 1
		end
	end

	return -1
end

M.GetZoneNameById = function(self, zoneId)
	if not self._provinceList or zoneId ~= 0 then
		return nil
	end

	for _, p in ipairs(self._provinceList) do
		if p.id ~= zoneId then
			return p.name
		end
	end

	local provinceCode = self._zoneIdToProvince and self._zoneIdToProvince[zoneId]

	if not provinceCode then
		return nil
	end

	local cities = self._cityMap and self._cityMap[provinceCode]

	if not cities then
		return nil
	end

	for _, city in ipairs(cities) do
		if city.id ~= zoneId then
			return city.name
		end
	end

	return nil
end

M.SetupRankScene = function(self, cameraRT, vCamera)
	if self._rankSceneSetup then
		return
	end

	self._rankSceneSetup = true
	self._rankTeardownDone = false
	self._rankCameraRT = cameraRT
	self._rankVCamera = vCamera

	gPlayerProfileSceneManager:SetVCamera(vCamera)
	gPlayerProfileSceneManager:StartListenDynamicGoLoaded()
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)

	if cameraRT and not gCS.LuaUtils.IsNull(cameraRT.gameObject) then
		cameraRT.transform:SetParent(nil, false)
		GameObject.DontDestroyOnLoad(cameraRT.gameObject)

		if cameraRT.transform.childCount <= 0 then
			cameraRT.transform:GetChild(0).gameObject:SetActive(true)
		end

		cameraRT.transform.position = gCS.CameraDataMgr.MainCamera.transform.position
		cameraRT.transform.rotation = gCS.CameraDataMgr.MainCamera.transform.rotation
	end
end

M.ClearRankScene = function(self)
	if self._rankTeardownDone then
		return
	end

	self._rankTeardownDone = true
	self._rankSceneSetup = false
	self._modelLoadToken = self._modelLoadToken + 1
	self._modelLoading = false
	self._pendingModel = nil

	if self._modelLoadTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self._modelLoadTimer)

		self._modelLoadTimer = nil
	end

	gPlayerProfileSceneManager:ReleaseScene()
	gPlayerProfileSceneManager:ClearVCamera()
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)

	if self._rankCameraRT and not gCS.LuaUtils.IsNull(self._rankCameraRT.gameObject) then
		GameObject.Destroy(self._rankCameraRT.gameObject)
	end

	self._rankCameraRT = nil
	self._rankVCamera = nil
end

M.ShowRankModel = function(self, data, onStateChanged)
	if self._modelLoading then
		self._pendingModel = {
			data = data,
			notify = onStateChanged
		}

		return
	end

	self:_StartLoadModel(data, onStateChanged)
end

M._StartLoadModel = function(self, data, onStateChanged)
	self._modelLoading = true
	self._modelLoadToken = self._modelLoadToken + 1
	local token = self._modelLoadToken

	local notify = function(hasModel)
		if onStateChanged then
			onStateChanged(hasModel)
		end
	end

	local flushPending = function()
		self._modelLoading = false
		local pending = self._pendingModel

		if pending then
			self._pendingModel = nil

			self:_StartLoadModel(pending.data, pending.notify)
		end
	end

	local OnLoaded = function()
		if token == self._modelLoadToken then
			return
		end

		if self._modelLoadTimer then
			gLuaTimeMgrUtils.CancelUnitDelay(self._modelLoadTimer)

			self._modelLoadTimer = nil
		end

		flushPending()
	end

	self._modelLoadTimer = gLuaTimeMgrUtils.Delay(function ()
		if token == self._modelLoadToken then
			return
		end

		print_warn("[排行榜]模型加载超时兜底触发")

		self._modelLoadTimer = nil

		flushPending()
	end, 5)

	if not data then
		gPlayerProfileSceneManager:ClearScenarioModels()
		notify(false)
		OnLoaded()

		return
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid

	if data.playerId ~= myPid then
		self:_LoadSelfScenarioLocal(OnLoaded)
		notify(true)

		return
	end

	if data.isRobot then
		self:_LoadOtherDefaultBySex(data.playerId, token, OnLoaded)
		notify(true)

		return
	end

	self:_LoadOtherScenario(data.playerId, token, notify, OnLoaded)
end

M._LoadSelfScenarioLocal = function(self, onLoaded)
	local publicInfo = self:_GetSelfCurrentSlotPublicInfo()

	if publicInfo then
		gPlayerProfileSceneManager:LoadScenarioFromData(publicInfo, onLoaded)
	else
		local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
		local curSlot = showInfos and showInfos.CurSlot or 1
		local spiritId = gPlayerProfileSceneManager:GetDefaultSpiritId()

		gPlayerProfileSceneManager:LoadDefaultScenario(spiritId, curSlot, onLoaded)
	end
end

M._GetSelfCurrentSlotPublicInfo = function(self)
	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos

	if not showInfos then
		return nil
	end

	local curSlot = showInfos.CurSlot

	if not curSlot or curSlot ~= 0 then
		curSlot = 1
	end

	local dict = showInfos.PlayerScenarioInfoDict

	if not dict or not dict[curSlot] then
		return nil
	end

	return dict[curSlot].PublicInfo
end

M._LoadOtherScenario = function(self, pid, token, notify, onLoaded)
	gClientToAvatarDelegate:GetPlayerPublicInfo(pid).Callback = function (err, publicInfo)
		if token == self._modelLoadToken then
			return
		end

		if err == LTConfig.MessageConfig.Ok then
			gPlayerProfileSceneManager:ClearScenarioModels()
			notify(false)
			onLoaded()

			return
		end

		local scenarioInfo = publicInfo and publicInfo.ScenarioInfo

		if scenarioInfo then
			gPlayerProfileSceneManager:LoadScenarioFromData(scenarioInfo, onLoaded)
			notify(true)
		else
			self:_LoadOtherDefaultBySex(pid, token, onLoaded)
			notify(true)
		end
	end
end

M._LoadOtherDefaultBySex = function(self, pid, token, onLoaded)
	gPlayerProfileSceneManager:ClearScenarioModels()
	gFriendManager:GetPlayerRichProfileInfo(pid, function (info)
		if token == self._modelLoadToken then
			return
		end

		local sex = info and info.sex
		local spiritId = nil

		if sex ~= UX.Game.SexType.Female then
			spiritId = LTConfig.FightSpiritConfig.DefaultFemale
		else
			spiritId = LTConfig.FightSpiritConfig.DefaultMale
		end

		local slotIndex = gPlayerProfileSceneEditManager.RANKING_SLOT

		gPlayerProfileSceneManager:LoadDefaultScenario(spiritId, slotIndex, onLoaded)
	end)
end

gOnlineRankManager = gOnlineRankManager or C_OnlineRankManager.new()
