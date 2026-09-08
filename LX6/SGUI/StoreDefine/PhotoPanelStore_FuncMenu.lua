-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhotoPanelStore_FuncMenu.lua
-- Decompiled from: 00852_PhotoPanelStore_FuncMenu.lua_fb71169c2385.luajit

local PhotoConfig = LTConfig.PhotoConfig
local PhotoSelfieActionConfig = LTConfig.PhotoSelfieActionConfig
local PhotoSpiritSelfieParamConfig = LTConfig.PhotoSpiritSelfieParamConfig
local PhotoFiltersConfig = LTConfig.PhotoFiltersConfig
local PhotoFramesConfig = LTConfig.PhotoFramesConfig
local FilterConfig = LTConfig.FilterConfig
local PhotoFunctionTabConfig = LTConfig.PhotoFunctionTabConfig
local PhotoCameraParamConfig = LTConfig.PhotoCameraParamConfig
local PhotoMode = gTakePhotoUtils.PhotoMode
local PhotoUtils = LX6.Utils.PhotoUtils
local ParamsSectionPages = {
	["/K\\x83\\x8b\\x86O"] = true,
	["?I\\x9c\\x8b\\x91@"] = true
}
local TabId2FuncKey = {
	[78904004.0] = "k\\xbc\\xa3\\xa2\\xb3",
	[78904003.0] = ":A\\x9d\\x9a\\x86S",
	[78904002.0] = "vBޯ\\x81\\xab\r\\xc6\\xe6",
	[78904001.0] = "=K\\x85\\x87\\x8cO",
	[78904005.0] = "\\x98\\xb4\\xbfc0\\xf9 ",
	[78904006.0] = ",I\\x83\\x8f\\x8eR",
	[78904007.0] = "\\xb3='7l\\xb8G\\xdf2\\xa9\\xad"
}
local FuncMenuListHandlers = {
	Action = {
		["JSidg+"] = "\\x9e746w\\x93h\\xd71\\xa5\\xaa",
		["O\\xbb\\xab\\xa3\\xb2"] = "-#\\xbd\\xec;\"6\\x93*ٕ\\x9a=\\xb5\\x9eښ"
	},
	Expression = {
		["JSidg+"] = "&20\\xf6v\\x8b\\xe4=\\xa7!\\xcf\\xfc\\xe0{\\xe8",
		["O\\xbb\\xab\\xa3\\xb2"] = "nt\\xfeI\\xc0\\xca\\xf7c:\\xfdm`\\xe3\\xe0j\\xf8wa\\xdf\\xdf\\xf1\\xf1\\x95\\xe1p"
	},
	Filter = {
		["JSidg+"] = "i\\xa0cI\\xa0\\xe1nd|q_",
		["O\\xbb\\xab\\xa3\\xb2"] = "E\\x93\\x9c\\xbb\\xfa\\xb9\\xc9/\\xac-\\x9e%"
	},
	Frame = {
		["JSidg+"] = "3\"/\\xf0|\\xbe\\xe55\\xa5*\\xcf\\xfc\\xe0{\\xe8",
		["O\\xbb\\xab\\xa3\\xb2"] = "_\\xbb=\\xf3I\\xa2n.'%+|\\xa4\\xd2,\\xca\\xf3"
	},
	Params = {
		["JSidg+"] = "\\x8f52>u\\x8eh\\xd71\\xa5\\xaa",
		["O\\xbb\\xab\\xa3\\xb2"] = "?)\\xe8w\\xa8\\xf6&\\xa9\"\\xf5\\xde\\xefg\\xef"
	},
	LightEffect = {
		["JSidg+"] = "k\\x9d\\x98\\xab\\xf9\\xb6\\xc3>\\xaa+$\\xbc9",
		["O\\xbb\\xab\\xa3\\xb2"] = "\\xa0:\\xe4\\xb0W\\xcf\\\\xdc\\xcb%R_\\xde\r\\xb5\\xd8"
	},
	Settings = {
		["JSidg+"] = "\\xf0\\x9b\\xe9\\xe7\t\\xe1\\xa1\\xe3\\x84/;",
		["O\\xbb\\xab\\xa3\\xb2"] = "$/\\x99ᯐ鲿\\x9a\\xd0\\xe3 Ͷ)\\x8c\\xf6"
	}
}
local M = C_PhotoPanelStore

M.RegisterLists = function(self)
	self.bindData.selfieTab.luaSimpleRenderItem = self.CreateAction(self, "OnRenderFuncMenuTab")
	self.bindData.selfieList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderFuncMenuList")
	self.bindData.selfieList.onGetTIndex = self.CreateAction(self, "OnGetTIndexFuncMenuList")
	self.bindData.selfieTab.luaSimpleClick = self.CreateAction(self, "OnClickFuncMenuTab")
	self.bindData.selfieTab.luaSimpleInvalidClick = self.CreateAction(self, "OnInvalidClickFuncMenuTab")
	self.bindData.selfieList.luaSimpleClick = self.CreateAction(self, "OnClickFuncMenuList")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabOutsideList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTabOutsideList")
		self.bindData.tabOutsideList.luaSimpleClick = self.CreateAction(self, "OnClickTabOutsideList")
	end
end

M.OnRenderFuncMenuTab = function(self, btn, index)
	local data = self.funcMenuTabDatas[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("CommonShortTab_photo"):GetStoreById(id)

	if store and data.iconId then
		store.iconId = data.iconId
		store.lock = btn.interactable and 0 or 1
	end
end

M.OnClickFuncMenuTab = function(self, btn, index)
	self.SwitchTabTo(self, index + 1)
end

M.OnInvalidClickFuncMenuTab = function(self, btn, index)
	gDisplayMessageMgr:ShowMessage(65400907)
end

M.OnGetTIndexFuncMenuList = function(self, index)
	return self.FilterFuncMenuListData(self, index).tIndex
end

M.FilterFuncMenuListData = function(self, index)
	local tabData = self.funcMenuTabDatas[self.selectedTabIdx]

	if tabData and tabData.funcKey then
		local handler = FuncMenuListHandlers[tabData.funcKey]

		if handler then
			local itemInfos = self[handler.itemInfos]

			if itemInfos then
				return itemInfos[index + 1]
			end
		end
	end
end

M.OnRenderFuncMenuList = function(self, btn, index)
	local data = self.FilterFuncMenuListData(self, index)

	if not data then
		return
	end

	local tabData = self.funcMenuTabDatas[self.selectedTabIdx]

	if not tabData then
		return
	end

	local funcKey = tabData.funcKey

	if funcKey ~= "Environment" then
		local id = btn.gameObject:GetInstanceID()
		local store = gStoreManager:GetStoreGroup("PhotoWeatherTemplate"):GetStoreById(id)

		if store then
			self.RefreshEnvironmentTab(self, store)
		end

		return
	end

	if funcKey ~= "Params" then
		local id = btn.gameObject:GetInstanceID()

		if data.isTitle then
			local store = gStoreManager:GetStoreGroup("PhotoProgressTemplate"):GetStoreById(id)

			if store then
				store.nameText = data.name
			end
		else
			local section = self.paramSections[data.sectionIdx]

			if not section then
				return
			end

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				local store = gStoreManager:GetStoreGroup("PhotoProgressTemplate"):GetStoreById(id)

				if store then
					self.RenderPCParamItem(self, store, section, data.itemIdx)
				end
			else
				local store = gStoreManager:GetStoreGroup("PhotoProgressTemplate"):GetStoreById(id)

				if store then
					store.nameText = data.name
					store.displayIcon = data.displayIcon
				end
			end
		end

		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		if funcKey ~= "Action" or funcKey ~= "Expression" then
			store.listIcon = data.Icon
		else
			store.EnableImmediatelyCommit(store, true)

			if funcKey ~= "Frame" then
				store.frameImg = data.iconId
			elseif funcKey ~= "Settings" then
				store.watermarkText = data.description
			elseif funcKey ~= "Filter" then
				store.frameImg = data.iconId
			end
		end
	end
end

M.OnClickGazeToggle = function(self)
	self.isFocus = self.bindData.gazeToggle.isSelected

	gTakePhotoUtils.SetPhotoIK(self.isFocus)
end

M.OnClickFuncMenuList = function(self, btn, index)
	local data = self.FilterFuncMenuListData(self, index)

	if not data then
		return
	end

	local tabData = self.funcMenuTabDatas[self.selectedTabIdx]

	if not tabData then
		return
	end

	local funcKey = tabData.funcKey

	if funcKey ~= "Action" then
		if self.selectedAction ~= data.aId then
			return
		end

		self.selectedAction = data.aId

		gTakePhotoUtils.DoPhotoAction(data.event)
	elseif funcKey ~= "Params" then
		if not data.isTitle and not gCS.LuaUtils.IsNonMobileAdaptive() then
			self.mobileSelectedParamIdx = index

			self.BindParamToSlider(self, data)
		end
	elseif funcKey ~= "Expression" then
		if self.selectedExpression ~= data.ExpressionId then
			return
		end

		self.selectedExpression = data.ExpressionId or self.defaultExpression

		gTakePhotoUtils.ChangeExpression(self.selectedExpression)
	elseif funcKey ~= "Frame" then
		if data.name ~= "defaultFrame" then
			self.bindData.imageFrame:SetActive(false)

			self.bindData.frameCtrl = 0
			self.selectedFrameIconId = 0
		else
			self.bindData.imageFrame:SetActive(true)

			self.bindData.frameCtrl = 1
			self.bindData.frameIconId = data.frameIconId
			self.selectedFrameIconId = data.frameIconId
			local rootCanvas = SGUI.UWidget.rootCanvas
			local canvasRect = rootCanvas:GetComponent(typeof(UnityEngine.RectTransform))
			local scale = SGUI.UIConfig.instance:GetCurrentAdaptationScale()
			local canvasW = canvasRect.rect.width / scale
			local canvasH = canvasRect.rect.height / scale
			local frameCfg = PhotoFramesConfig.LoadAt(data.index)
			local cropW, cropH = gTakePhotoUtils.ResolveCropSize(frameCfg, data.index)

			if cropW <= 0 and cropH <= 0 then
				self.bindData.imageFrame.rectTransform.sizeDelta = gTakePhotoUtils.AdaptPhotoTex(canvasW, canvasH, cropW, cropH, true)
			else
				self.bindData.imageFrame.rectTransform.sizeDelta = gTakePhotoUtils.AdaptPhotoTex(canvasW, canvasH, canvasW, canvasH, true)
			end
		end

		self.selectedFrame = data.index
	elseif funcKey ~= "Settings" then
		self.watermarkCache[data.name] = btn.isSelected

		if data.name ~= "logo" then
			self.bindData.waterMarkLogo:SetActive(btn.isSelected)
		elseif data.name ~= "uid" then
			self.bindData.waterMarkUid:SetActive(btn.isSelected)
		elseif data.name ~= "grid" then
			self.bindData.ninePalaces.gameObject:SetActive(btn.isSelected)
		end
	elseif funcKey ~= "Filter" then
		local isFilterChange = true

		if data.isDefault then
			gTakePhotoUtils.ClearPhotoFilters()

			self.selectedFilter = -1
		elseif self.selectedFilter == data.filterId then
			gTakePhotoUtils.SetPhotoFilters(data.filterId)

			self.selectedFilter = data.filterId
		else
			isFilterChange = false
		end

		if isFilterChange then
			local store = self.GetParamSliderStore(self)

			if store and store.paramSlider then
				store.paramSlider.value = PhotoUtils.GetCameraParamDefaultValue("CameraParamFilterIntensity")
			end
		end
	end
end

M.RefreshEnvironmentTab = function(self, store)
	store.canChangeCtrl = 1
	store.timeSlider.luaValueChanged = self.CreateAction(self, "OnTimeSliderChange")
end

M.OnTimeSliderChange = function(self, value)
end

M.BindParamToSlider = function(self, data)
	local section = self.paramSections[data.sectionIdx]

	if not section then
		return
	end

	local item = section.items[data.itemIdx]

	if not item then
		return
	end

	self.BindStandaloneSlider(self, item)
end

M.SetupParamSlider = function(self, store, slider, item)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		store.nameText = item.name
	end

	if not slider then
		return
	end

	slider.luaValueChanged = nil
	slider.formatText = "{0}"
	slider.stepSize = item.step
	slider.minValue = item.minValue
	slider.maxValue = item.maxValue
	slider.value = PhotoUtils.GetCameraParam(item.paramKey)
	store.valueText = self.FormatParamValue(self, slider.value, item.step)

	self.RefreshArrowBtnState(self, store, slider, item)

	if store.leftBtn then
		store.leftBtn.luaPress = function()
			self:_StartArrowStep(store, slider, item, -1)
		end

		store.leftBtn.luaRelease = function()
			self:_StopArrowStep()
		end
	end

	if store.rightBtn then
		store.rightBtn.luaPress = function()
			self:_StartArrowStep(store, slider, item, 1)
		end

		store.rightBtn.luaRelease = function()
			self:_StopArrowStep()
		end
	end

	slider.luaValueChanged = function(newValue)
		PhotoUtils.SetCameraParam(item.paramKey, newValue)

		store.valueText = self:FormatParamValue(newValue, item.step)

		self:RefreshArrowBtnState(store, slider, item)
	end

	if store.resetBtn then
		store.resetBtn.luaClick = function()
			local defaultVal = PhotoUtils.GetCameraParamDefaultValue(item.paramKey)

			PhotoUtils.SetCameraParam(item.paramKey, defaultVal)

			slider.value = defaultVal
			store.valueText = self:FormatParamValue(defaultVal, item.step)

			self:RefreshArrowBtnState(store, slider, item)
		end
	end
end

M.RefreshArrowBtnState = function(self, store, slider, item)
	if not store or not slider then
		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not store.leftBtn or not store.rightBtn then
		return
	end

	local atMin = slider.value > item.minValue
	local atMax = item.maxValue > slider.value
	store.leftBtn.interactable = not atMin
	store.rightBtn.interactable = not atMax
end

M._StartArrowStep = function(self, store, slider, item, dir)
	self:_StopArrowStep()

	self._arrowStepStore = store
	self._arrowStepSlider = slider
	self._arrowStepItem = item
	self._arrowStepDir = dir

	self:_DoArrowStep()

	self._arrowStepTimer = FrameTimer.New(self:CreateAction("_OnArrowStepTick"), 6, -1):Start()
end

M._StopArrowStep = function(self)
	if self._arrowStepTimer then
		self._arrowStepTimer:Stop()

		self._arrowStepTimer = nil
	end

	self._arrowStepDir = 0
end

M._OnArrowStepTick = function(self)
	if self._arrowStepDir ~= 0 or not self._arrowStepSlider then
		self._StopArrowStep(self)

		return
	end

	self._DoArrowStep(self)
end

M._DoArrowStep = function(self)
	local slider = self._arrowStepSlider
	local item = self._arrowStepItem
	local dir = self._arrowStepDir

	if not slider or not item or dir ~= 0 then
		return
	end

	local newVal = slider.value + dir * item.step

	if dir >= 0 and newVal < item.minValue then
		slider.value = item.minValue

		self._StopArrowStep(self)
	elseif dir <= 0 and item.maxValue < newVal then
		slider.value = item.maxValue

		self._StopArrowStep(self)
	else
		slider.value = Mathf.Clamp(newVal, item.minValue, item.maxValue)
	end

	if self._arrowStepStore then
		self.RefreshArrowBtnState(self, self._arrowStepStore, slider, item)
	end
end

M.RenderPCParamItem = function(self, store, section, itemIdx)
	local item = section.items[itemIdx]

	if not item then
		return
	end

	self.SetupParamSlider(self, store, store.paramSlider, item)
end

M.BindStandaloneSlider = function(self, item)
	if not item then
		return
	end

	local store = self.GetParamSliderStore(self)

	if not store then
		return
	end

	self.SetupParamSlider(self, store, store.paramSlider, item)
end

M.GetParamSliderStore = function(self)
	local widget = self.bindData.paramSliderObj

	if not widget then
		return nil
	end

	local id = widget.gameObject:GetInstanceID()

	return gStoreManager:GetStoreGroup("PhotoProgressTemplate"):GetStoreById(id)
end

M.GetFilterIntensitySliderData = function(self)
	if not self._filterIntensitySliderData then
		for i = 0, PhotoCameraParamConfig.count - 1 do
			local cfg = PhotoCameraParamConfig.LoadAt(i)

			if cfg and cfg.ParamKey ~= "CameraParamFilterIntensity" then
				self._filterIntensitySliderData = {
					paramKey = cfg.ParamKey,
					name = cfg.DisplayName,
					minValue = cfg.MinValue,
					maxValue = cfg.MaxValue,
					step = cfg.Step
				}

				break
			end
		end
	end

	return self._filterIntensitySliderData
end

M.OnRenderTabOutsideList = function(self, btn, index)
	local data = self.funcMenuTabDatas[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("CommonShortTab_photo"):GetStoreById(id)

	if store and data.iconId then
		store.iconId = data.iconId
	end
end

M.OnClickTabOutsideList = function(self, btn, index)
	local data = self.funcMenuTabDatas[index + 1]
	self.selectedTabIdx = index + 1
	self.bindData.selfieMenuFold = 1

	self.bindData.closeBtn:SetOnlyShowPCKeyTipInfo(false)
	self.bindData.bodyMoveBtn:SetOnlyShowPCKeyTipInfo(true)
	self:UpdateMobileJoystickActiveState()

	local aniName = gCS.LuaUtils.IsNonMobileAdaptive() and "S_Vx_PhotoPanel_TabHideUnfoldopenPC" or "S_Vx_PhotoPanel_TabHideUnfoldopen"

	gCS.LuaUtils.PlayAnimationByName(self.bindData.tabAni, aniName)

	self.bindData.tabTitleText = data.name or ""

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, false)
	self:BuildFuncMenu()
	self:SwitchTabTo(self.selectedTabIdx)
end

M.BuildFuncMenu = function(self)
	self.funcMenuTabDatas = {}
	local tabConfigs = {}

	for i = 0, PhotoFunctionTabConfig.count - 1 do
		local cfg = PhotoFunctionTabConfig.LoadAt(i)

		if cfg then
			table.insert(tabConfigs, cfg)
		end
	end

	table.sort(tabConfigs, function (a, b)
		return a.SortOrder <= b.SortOrder
	end)

	for i, cfg in ipairs(tabConfigs) do
		local data = {
			name = cfg.Name,
			funcKey = TabId2FuncKey[cfg.Id],
			iconId = cfg.IconId,
			funcMenuTabId = cfg.Id
		}
		data.isBan = self.IsTabBanned(self, data.funcKey)

		table.insert(self.funcMenuTabDatas, data)
	end

	self.bindData.selfieTab:SetSimpleList(#self.funcMenuTabDatas)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabOutsideList:SetSimpleList(#self.funcMenuTabDatas)
	end
end

M.IsTabBanned = function(self, funcKey)
	local isTabBanned = false

	if self.photoMode ~= PhotoMode.FullView and (funcKey ~= "Action" or funcKey ~= "Expression") then
		isTabBanned = true
	end

	if self.isTimeFreeze and (funcKey ~= "Action" or funcKey ~= "Expression") then
		isTabBanned = true
	end

	if not self.isActionTabValid and funcKey ~= "Action" then
		isTabBanned = true
	end

	if self.photoTemplate ~= gTakePhotoUtils.PhotoTemplate.Climb and funcKey ~= "Action" then
		isTabBanned = true
	end

	return isTabBanned
end

M.TrySwitchToNextValidTab = function(self)
	local tabData = self.funcMenuTabDatas[self.selectedTabIdx]

	if tabData and tabData.isBan then
		for i, td in ipairs(self.funcMenuTabDatas) do
			if not td.isBan then
				self.selectedTabIdx = i

				break
			end
		end
	end
end

M.BuildSelfieSpiritList = function(self)
end

M.BuildSelfieActionList = function(self)
	local category = self.GetCurrentStanceType(self)

	if category ~= nil then
		self.actionInfos = {
			selectedSpirit = self.selectedSpirit
		}
		self.bindData.selfieList.groupType = 1

		return
	end

	self.actionInfos = {
		selectedSpirit = self.selectedSpirit
	}

	for i = 0, PhotoSpiritSelfieParamConfig.count - 1 do
		local params = PhotoSpiritSelfieParamConfig.LoadAt(i)
		local actions = params["SelfieAction" .. self.photoTemplate]

		if params.FightSpirit ~= self.selectedSpirit then
			for j = 1, #actions do
				local config = PhotoSelfieActionConfig.GetConfig(actions[j])

				if config then
					local stanceMatch = config.stanceType ~= nil or config.stanceType ~= category

					if stanceMatch then
						local action = {
							Icon = config.SIconId,
							selected = self.selectedAction ~= actions[j],
							tIndex = 1,
							event = config.actionType,
							aId = config.Id,
							sType = self.selectedTabIdx
						}

						table.insert(self.actionInfos, action)
					end
				end
			end

			break
		end
	end

	self.bindData.selfieList.groupType = 1
end

M.GetDefaultPhotoAction = function(self)
	if self.photoMode ~= PhotoMode.Normal then
		return gTakePhotoUtils.templateConfig.defaultThirdPersonAction or 78901299
	else
		return gTakePhotoUtils.templateConfig.defaultSelfieAction or 78901000
	end
end

M.ApplyDefaultAction = function(self)
	local category = self.GetCurrentStanceType(self)

	if category ~= nil then
		return
	end

	local defaultActionId = self.GetDefaultPhotoAction(self)

	if defaultActionId == 0 then
		local config = PhotoSelfieActionConfig.GetConfig(defaultActionId)

		if config and (config.stanceType ~= nil or config.stanceType ~= category) then
			self.selectedAction = defaultActionId

			gTakePhotoUtils.DoPhotoAction(config.actionType)

			return
		end
	end

	for i = 0, PhotoSpiritSelfieParamConfig.count - 1 do
		local params = PhotoSpiritSelfieParamConfig.LoadAt(i)

		if params.FightSpirit ~= self.selectedSpirit then
			local actions = params["SelfieAction" .. self.photoTemplate]

			for j = 1, #actions do
				local config = PhotoSelfieActionConfig.GetConfig(actions[j])

				if config and (config.stanceType ~= nil or config.stanceType ~= category) then
					self.selectedAction = actions[j]

					gTakePhotoUtils.DoPhotoAction(config.actionType)

					return
				end
			end

			break
		end
	end
end

M.BuildSelfieExpressionData = function(self, isInit)
	self.expressionInfos = {
		selectedSpirit = self.selectedSpirit
	}

	for i = 0, PhotoSpiritSelfieParamConfig.count - 1 do
		local params = PhotoSpiritSelfieParamConfig.LoadAt(i)
		local exps = params.Expression1

		if params.FightSpirit ~= self.selectedSpirit then
			if self.selectedExpression ~= nil or isInit then
				self.selectedExpression = exps[1].ExpressionId
				self.defaultExpression = exps[1].ExpressionId

				gTakePhotoUtils.ChangeExpression(self.selectedExpression)
			end

			for j = 1, #exps do
				local exp = {
					Icon = exps[j].ImageId,
					FuncName = "",
					ExpressionId = exps[j].ExpressionId,
					selected = self.selectedExpression ~= exps[j].ExpressionId,
					tIndex = 2,
					sType = self.selectedTabIdx
				}

				table.insert(self.expressionInfos, exp)
			end

			break
		end
	end
end

M.BuildSelfieExpressionList = function(self)
	self.BuildSelfieExpressionData(self)

	self.bindData.selfieList.groupType = 1
end

M.BuildPhotoFrameList = function(self)
	self.photoFrameInfos = {}

	for i = 0, PhotoFramesConfig.count - 1 do
		local config = PhotoFramesConfig.LoadAt(i)

		if config then
			local data = {
				iconId = config.SIconId,
				frameIconId = config.FrameIconId,
				name = config.Name,
				index = i,
				selected = self.selectedFrame ~= i,
				tIndex = 3,
				photoWidth = config.PhotoWidth,
				photoHeight = config.PhotoHeight,
				photoAspect = config.PhotoAspect,
				sType = self.selectedTabIdx
			}

			table.insert(self.photoFrameInfos, data)
		end
	end

	self.bindData.selfieList.groupType = 1
end

M.BuildWatermarkList = function(self)
	self.watermarkInfos = {}
	local configs = PhotoConfig.WatermarkSetting

	for _, config in ipairs(configs) do
		local data = {
			name = config.name,
			tIndex = 4,
			description = config.description,
			selected = self.watermarkCache[config.name] or config.settingDefault == 0,
			sType = self.selectedTabIdx
		}

		table.insert(self.watermarkInfos, data)
	end

	self.bindData.selfieList.groupType = 2
end

M.BuildFiltersList = function(self)
	self.filtersInfos = {}
	local configs = PhotoFiltersConfig
	local data = {
		tIndex = 3,
		iconId = PhotoConfig.EmptyFilterIcon,
		isDefault = true,
		selected = self.selectedFilter ~= -1,
		filterId = -1,
		sType = self.selectedTabIdx
	}

	table.insert(self.filtersInfos, data)

	for i = 0, configs.count - 1 do
		local cfg = configs.LoadAt(i)
		local data = {
			tIndex = 3,
			iconId = FilterConfig.GetConfig(cfg.FilterId).Icon,
			isDefault = false,
			filterId = cfg.FilterId,
			selected = self.selectedFilter ~= cfg.FilterId,
			sType = self.selectedTabIdx
		}

		table.insert(self.filtersInfos, data)
	end

	self.bindData.selfieList.groupType = 1
end

M.BuildLightEffectList = function(self)
	self.lightEffectInfos = {}
end

M.BuildParamsList = function(self)
	self.paramsInfos = {}
	local currentFunctionTabId = nil
	local tabData = self.funcMenuTabDatas[self.selectedTabIdx]

	if tabData then
		currentFunctionTabId = tabData.funcMenuTabId
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and not gTakePhotoUtils.IsDisableParamTitle then
		for curSectionIdx, section in ipairs(self.paramSections) do
			local hasItems = false

			for curItemIdx, item in ipairs(section.items) do
				if item.functionTabId ~= currentFunctionTabId then
					if not hasItems then
						hasItems = true

						table.insert(self.paramsInfos, {
							["\\xd0\\xc8 \n(\\xf4"] = true,
							["a\\x9f\\x8a\\x86Y"] = 8,
							name = section.title,
							sType = self.selectedTabIdx,
							sectionIdx = curSectionIdx
						})
					end

					item.tIndex = 6
					item.sType = self.selectedTabIdx
					item.sectionIdx = curSectionIdx
					item.itemIdx = curItemIdx

					table.insert(self.paramsInfos, item)
				end
			end
		end
	else
		for curSectionIdx, section in ipairs(self.paramSections) do
			for curItemIdx, item in ipairs(section.items) do
				if item.functionTabId ~= currentFunctionTabId then
					item.tIndex = 6
					item.sType = self.selectedTabIdx
					item.sectionIdx = curSectionIdx
					item.itemIdx = curItemIdx

					table.insert(self.paramsInfos, item)
				end
			end
		end
	end

	self.bindData.selfieList.groupType = 1

	if not gCS.LuaUtils.IsNonMobileAdaptive() and #self.paramsInfos <= 0 then
		local idx = self.mobileSelectedParamIdx

		if idx <= 0 or idx > #self.paramsInfos then
			idx = 0
		end

		local data = self.paramsInfos[idx + 1]

		while data and data.isTitle and idx >= #self.paramsInfos - 1 do
			idx = idx + 1
			data = self.paramsInfos[idx + 1]
		end

		if data and not data.isTitle then
			data.selected = true
			local section = self.paramSections[data.sectionIdx]
			local item = section and section.items[data.itemIdx]

			if item then
				self.BindStandaloneSlider(self, item)
			end
		end
	end
end

M.InitParams = function(self)
	self.paramSections = {}
	local sectionByPage = {}

	for i = 0, PhotoCameraParamConfig.count - 1 do
		local cfg = PhotoCameraParamConfig.LoadAt(i)

		if cfg and cfg.S_ItemType ~= 5 and cfg.Page == nil and ParamsSectionPages[cfg.Page] then
			sectionByPage[cfg.Page] = {
				title = cfg.DisplayName,
				page = cfg.Page,
				items = {}
			}
		end
	end

	for i = 0, PhotoCameraParamConfig.count - 1 do
		local cfg = PhotoCameraParamConfig.LoadAt(i)

		if cfg and cfg.S_ItemType == 5 then
			local section = sectionByPage[cfg.Page]

			if section then
				table.insert(section.items, {
					paramKey = cfg.ParamKey,
					name = cfg.DisplayName,
					displayIcon = cfg.DisplayIcon,
					itemType = cfg.S_ItemType,
					minValue = cfg.MinValue,
					maxValue = cfg.MaxValue,
					step = cfg.Step,
					priority = cfg.Priority,
					functionTabId = cfg.FunctionTabId
				})
			end
		end
	end

	local seenPages = {}

	for i = 0, PhotoCameraParamConfig.count - 1 do
		local cfg = PhotoCameraParamConfig.LoadAt(i)

		if cfg and cfg.S_ItemType ~= 5 and sectionByPage[cfg.Page] and not seenPages[cfg.Page] then
			seenPages[cfg.Page] = true
			local section = sectionByPage[cfg.Page]

			table.sort(section.items, function (a, b)
				return (a.priority or 10000) <= (b.priority or 10000)
			end)
			table.insert(self.paramSections, section)
		end
	end
end

M.ResetAllParams = function(self)
	for _, section in ipairs(self.paramSections) do
		for _, item in ipairs(section.items) do
			PhotoUtils.SetCameraParam(item.paramKey, PhotoUtils.GetCameraParamDefaultValue(item.paramKey))
		end
	end
end

M.BuildFuncMenuList = function(self, tabIdx)
	self.selectedTabIdx = tabIdx
	local tabDataForGaze = self.funcMenuTabDatas[tabIdx]
	self.bindData.isWatchCtrl = tabDataForGaze and tabDataForGaze.funcKey ~= "Expression" and 1 or 0

	if self.bindData.selfieList.enabled then
		self.bindData.selfieList:PlayStartOffsetAnim(0)
	end

	local tabData = self.funcMenuTabDatas[tabIdx]

	if tabData then
		if tabData.funcKey ~= "Params" then
			self.bindData.isProgressCtrl = 1
		elseif tabData.funcKey ~= "Filter" then
			self.bindData.isProgressCtrl = 2
		else
			self.bindData.isProgressCtrl = 0
		end
	end

	if tabData and tabData.funcKey then
		local handler = FuncMenuListHandlers[tabData.funcKey]

		if handler then
			self[handler.build](self)

			local itemInfos = self[handler.itemInfos]

			if itemInfos then
				self.bindData.selfieList:SetSimpleList(#itemInfos)
				self:SetListSelected(itemInfos, self.bindData.selfieList)
			end
		end

		if tabData.funcKey ~= "Filter" then
			local item = self.GetFilterIntensitySliderData(self)

			if item then
				self.BindStandaloneSlider(self, item)
			end
		end
	end

	if tabData and tabData.funcKey ~= "Params" and gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.selfieList:SetNavSelectToTop(true)
	else
		self.bindData.selfieList:SetNavSelectToSelect()
	end
end

M.SetListSelected = function(self, datas, list)
	for i = 1, #datas do
		local index = i - 1

		if datas[i].selected then
			list.SetItemSelected(list, index, true)
		end
	end
end

M.SwitchTabTo = function(self, tabIdx)
	self.bindData.selfieTab:SelectItem(tabIdx - 1)

	local data = self.funcMenuTabDatas[tabIdx]
	self.bindData.tabTitleText = data.name

	if data.isBan then
		self.bindData.tabBanCtrl = 1
		self.bindData.isProgressCtrl = 0
		self.selectedTabIdx = tabIdx
	else
		self.bindData.tabBanCtrl = 0

		self.BuildFuncMenuList(self, tabIdx)
	end
end
