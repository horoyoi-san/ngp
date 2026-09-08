-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RecommendInfoTurnToStore.lua
-- Decompiled from: 00902_RecommendInfoTurnToStore.lua_3250e31a58ba.luajit

local MallRecommendConfig = LTConfig.MallRecommendConfig
local MallBundleConfig = LTConfig.MallBundleConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
C_RecommendInfoTurnToStore = DefClass("C_RecommendInfoTurnToStore", C_RecommendInfoTurnToStore, C_StoreGroup)
GroupName2Class.RecommendInfoTurnToStore = C_RecommendInfoTurnToStore
local M = C_RecommendInfoTurnToStore

M.ctor = function(self)
	self.parentStore = nil
	self.recommendItem = nil
	self.recommendCfg = nil
	self.offShelfTimestamp = 0
	self._videoHomeStore = nil
	self._videoPlayStateMap = {}
end

M.DefineAllVariables = function(self)
	self.offShelfTimestamp = 0
end

M.DefineAllEnumsAutoGen = function(self)
	self.subtitleCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showTimeCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.subtitleCtrlEnum = nil
	self.showTimeCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.offShelfTimestamp = 0
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.parentStore = data and data.parentStore or nil
	self.recommendItem = data and data.recommendItem or nil

	self:RefreshInfo()
	self:RefreshScene()
	self:PlayOpenAnim()
	self:TryPlayPoolVideo()
end

M.OnMallClose = function(self)
	for _, entry in pairs(self._videoPlayStateMap) do
		if entry.state ~= "completed" then
			entry.state = "started"
		end
	end
end

M.OnLanguageChange = function(self, lang)
	self.RefreshInfo(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.RefreshInfo = function(self)
	if not self.recommendItem then
		return
	end

	self.recommendCfg = MallRecommendConfig.GetConfig(self.recommendItem.configId)

	if not self.recommendCfg then
		return
	end

	local bgIconId = self.recommendItem.bigPicture

	if not bgIconId or bgIconId ~= 0 then
		bgIconId = self.recommendItem.picture or 0
	end

	self.bindData.bgIconId = bgIconId
	self.bindData.titleText = self.recommendCfg.Name or ""
	self.bindData.subtitleText = self.recommendCfg.SubTitle or ""
	self.bindData.subtitleCtrl = self.recommendCfg.SubTitle and self.recommendCfg.SubTitle == "" and self.subtitleCtrlEnum._true or self.subtitleCtrlEnum._false
	local desText = nil
	local linkTo = self.recommendItem.linkTo

	if linkTo and #linkTo > 2 and linkTo[1] ~= 2 and linkTo[2] then
		local bundleCfg = MallBundleConfig.GetConfig(linkTo[2])

		if bundleCfg then
			desText = bundleCfg.Desc or bundleCfg.Name
		end
	end

	if not desText then
		local firstCfg = self.recommendItem.displayCommodities and #self.recommendItem.displayCommodities <= 0 and MallCommodityConfig.GetConfig(self.recommendItem.displayCommodities[1]) or nil
		local recommendDesc = self.recommendCfg.Desc
		desText = recommendDesc or firstCfg and firstCfg.Desc or self.recommendItem.desc
	end

	self.bindData.desText = desText or ""

	self:InitCountdown()
end

M.RefreshScene = function(self)
	if not self.recommendItem then
		self.bindData.bgActive = true

		return
	end

	local sceneId = gMallManager:GetRecommendSceneId(self.recommendItem)
	local hasScene = sceneId and sceneId >= 0

	if hasScene and self.parentStore then
		local commodityId = self.recommendItem.displayCommodities and self.recommendItem.displayCommodities[1] or 0
		local commodityData = commodityId <= 0 and gMallManager:GenMallCommodityItem(MallCommodityConfig.GetConfig(commodityId)) or nil

		if self.parentStore.TryOnFashion and commodityData then
			self.parentStore:TryOnFashion(commodityData)
		elseif self.parentStore.ApplyMallSceneById then
			self.parentStore:ApplyMallSceneById(sceneId)
			self.parentStore:SetModelBtnActive(false)
		end
	end

	self.bindData.bgActive = not hasScene
end

M.PlayOpenAnim = function(self)
	if not self.rootGo then
		return
	end
end

M.GetTurnToGachaId = function(self)
	local cfg = self.recommendCfg or self.recommendItem and MallRecommendConfig.GetConfig(self.recommendItem.configId)
	local gachaId = cfg and cfg.GetGachaTime or 0

	return gachaId and gachaId <= 0 and gachaId or 0
end

M.TryPlayPoolVideo = function(self)
	if self._videoHomeStore then
		self._videoHomeStore:StopVideo()

		self._videoHomeStore = nil
		self._currentVideoGachaId = nil
	end

	local gachaId = self.GetTurnToGachaId(self)

	if gachaId ~= 0 then
		return
	end

	local now = gLuaDataManager.serverTime
	local currentLogicDayStart = gTimeUtils:GetNextLogicDayStart(now) - 86400
	local entry = self._videoPlayStateMap[gachaId]

	if entry and entry.day == currentLogicDayStart then
		entry = nil
		self._videoPlayStateMap[gachaId] = nil
	end

	local state = entry and entry.state or nil

	if state ~= "completed" then
		return
	end

	local homeStore = gStoreManager:GetStoreGroup("ShopHomePagePanelStore")

	if not homeStore or not homeStore.PlayVideo then
		return
	end

	local GachaConfig = LTConfig.GachaConfig
	local gachaConfig = GachaConfig.GetConfig(gachaId)
	local videoId = gachaConfig and gachaConfig.ButtonVideo or 0

	if videoId < 0 then
		return
	end

	self._videoHomeStore = homeStore
	self._currentVideoGachaId = gachaId

	if state ~= nil then
		self._videoPlayStateMap[gachaId] = {
			["^\\xba\\xa3\\xbb\\xb3"] = "\\xca\\xcf\n!\\xf5",
			day = currentLogicDayStart
		}

		homeStore.PlayVideo(homeStore, videoId, gMallManager.VideoLayer.Bg, function ()
			self:OnVideoEnd()
		end, function ()
			self:OnVideoStart()
		end)
	else
		self._prevBgActive = self.bindData.bgActive
		self.bindData.bgActive = false

		homeStore.PlayVideo(homeStore, videoId, gMallManager.VideoLayer.Bg, function ()
			self:OnVideoEnd()
		end)
	end
end

M.OnVideoStart = function(self)
	local homeStore = self._videoHomeStore

	if homeStore then
		homeStore.bindData.showUICtrl = 0
		slot2 = homeStore.bindData.videoBtn.gameObject

		slot2:SetActive(true)

		homeStore._videoBtnCallback = function()
			self:OnVideoBtnClick()
		end
	end

	self._prevBgActive = self.bindData.bgActive
	self.bindData.bgActive = false
end

M.OnVideoBtnClick = function(self)
	local homeStore = self._videoHomeStore

	if homeStore then
		homeStore.bindData.showUICtrl = 1

		homeStore.bindData.videoBtn.gameObject:SetActive(false)

		homeStore._videoBtnCallback = nil
	end
end

M.OnVideoEnd = function(self)
	local gachaId = self._currentVideoGachaId

	if gachaId and self._videoPlayStateMap[gachaId] then
		self._videoPlayStateMap[gachaId].state = "completed"
	end

	local homeStore = self._videoHomeStore

	if homeStore then
		homeStore.bindData.showUICtrl = 1

		homeStore.bindData.videoBtn.gameObject:SetActive(false)

		homeStore._videoBtnCallback = nil
	end

	self.bindData.bgActive = self._prevBgActive or false
	self._videoHomeStore = nil
	self._currentVideoGachaId = nil
end

M.InitCountdown = function(self)
	local now = gLuaDataManager.serverTime
	self.offShelfTimestamp = 0

	if not self.recommendCfg then
		self.bindData.showTimeCtrl = self.showTimeCtrlEnum._false

		return
	end

	local _, gachaOffShelfTime = gMallManager:GetRecommendShelfTimeFromGacha(self.recommendCfg)
	local offShelfTime = gachaOffShelfTime or self.recommendCfg.OffShelfTime

	if offShelfTime and not gMallManager:IsTimeEmpty(offShelfTime) then
		self.offShelfTimestamp = gTimeUtils:GetUnixTime(offShelfTime.year or 0, offShelfTime.month or 0, offShelfTime.day or 0, offShelfTime.hour or 0, offShelfTime.minute or 0, offShelfTime.second or 0)

		if self.offShelfTimestamp and now >= self.offShelfTimestamp then
			local remainingTime = self.offShelfTimestamp - now

			self.bindData.countDown:Play(remainingTime)

			self.bindData.showTimeCtrl = self.showTimeCtrlEnum._true
		else
			self.offShelfTimestamp = 0
			self.bindData.showTimeCtrl = self.showTimeCtrlEnum._false
		end
	else
		self.bindData.showTimeCtrl = self.showTimeCtrlEnum._false
	end
end

M.OnCountDownFinished = function(self)
	self.bindData.showTimeCtrl = self.showTimeCtrlEnum._false
	self.offShelfTimestamp = 0
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.countDown.luaFinished = self.CreateAction(self, "OnCountDownFinished")
	self.bindData.gotoBtn.luaClick = self.CreateAction(self, "OnClickGotoBtn")
	self.bindData.infoBtn.luaClick = self.CreateAction(self, "OnClickInfoBtn")
end

M.OnClickInfoBtn = function(self)
	local MallConfig = LTConfig.MallConfig
	local desc = MallConfig.ExpirationDateDetail or "time des %s"
	local timeDayStr = gTimeUtils:DateFormat("%d-%02d-%02d", self.offShelfTimestamp)
	local timeHourStr = gTimeUtils:DateFormatDetail("%02d:%02d", self.offShelfTimestamp)
	local timeStr = timeDayStr .. " " .. timeHourStr
	desc = string.format(desc, timeStr)

	gPanelManager:CheckShow(gPanelId.ITEM_INFO_ONLY_TEXT_PANEL, {
		title = MallConfig.ExpirationDateTitle or "time title",
		content = {
			{
				["Y\\xa7\\xb6\\xa3\\xb3"] = "",
				desc = desc
			}
		}
	})
end

M.OnClickGotoBtn = function(self)
	if not self.recommendItem then
		return
	end

	gMallManager:HandleRecommendLinkTo(self.recommendItem, self.parentStore)
end
