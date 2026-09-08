-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GalleryFashionPreviewPanelStore.lua
-- Decompiled from: 01886_GalleryFashionPreviewPanelStore.lua_c2b58710bf47.luajit

local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionConfig = LTConfig.FashionConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
C_GalleryFashionPreviewPanelStore = DefClass("C_GalleryFashionPreviewPanelStore", C_GalleryFashionPreviewPanelStore, C_StoreGroup)
GroupName2Class.GalleryFashionPreviewPanelStore = C_GalleryFashionPreviewPanelStore
local M = C_GalleryFashionPreviewPanelStore

M.ctor = function(self)
	self.hasCharacterChange = false
end

M.DefineAllVariables = function(self)
	self.brandId = nil
	self.currentSuitId = nil
	self.suitListData = {}
	self.currentSuitIndex = 0
	self.fashionItemList = {}
	self.selectedSpiritId = nil
	self.currentModelUnit = nil
	self.loadedSuitId = nil
	self.lastSelectedItemIndex = -1
	self.rootArea = nil
	self.inHyperLink = false
	self.modelCameraEnabled = false
	self.prevVCamera = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.hideCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hideCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	if self.subModelStore then
		self.subModelStore:ResetCfg()
	end
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self:DisableModelCameraControl()
	gGallerySceneManager:StopListenDynamicGoLoaded()
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)

	if self.bindData.camera and not gCS.LuaUtils.IsNull(self.bindData.camera.gameObject) then
		GameObject.Destroy(self.bindData.camera.gameObject)

		self.bindData.camera = nil
	end

	gGallerySceneManager:ClearAll()

	self.currentModelUnit = nil
	self.loadedSuitId = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	data = data or {}
	self.bindData.hideCtrl = self.hideCtrlEnum.show

	self:SetCameraBtnsActive(false)

	if self.rootGo then
		self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	end

	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gGallerySceneManager:StartListenDynamicGoLoaded()

	if self.bindData.camera then
		self.bindData.camera.transform:SetParent(nil, false)
		self.bindData.camera.transform:GetChild(0).gameObject:SetActive(true)

		self.bindData.camera.transform.position = gCS.CameraDataMgr.MainCamera.transform.position
		self.bindData.camera.transform.rotation = gCS.CameraDataMgr.MainCamera.transform.rotation
	end

	self.prevVCamera = gGallerySceneManager.vCamera

	gGallerySceneManager:SetVCamera(self.bindData.VCamera)

	self.brandId = data.brandId
	self.currentSuitId = data.suitId

	if not self.currentSuitId or self.currentSuitId ~= 0 then
		local firstSuit = FashionSuitConfig.LoadAt(0)
		self.currentSuitId = firstSuit and firstSuit.Id or nil
	end

	self.suitListData = data.suitListData or {}

	for i, suitData in ipairs(self.suitListData) do
		if suitData.suitId ~= self.currentSuitId then
			self.currentSuitIndex = i

			break
		end
	end

	self.hasCharacterChange = false
	self.selectedSpiritId = data.spiritId or gCS.MyPlayerManager.PlayerUnit.ClientData.cardId

	self:SelectSuitableSpirit(self.currentSuitId)

	local spirit = gSpiritManager:GetSpirit(self.selectedSpiritId)

	if not spirit then
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(self.selectedSpiritId)
		self.bindData.avatarIconId = spiritCfg and spiritCfg.SHeadIconID or 0
	else
		self.bindData.avatarIconId = spirit.config and spirit.config.SHeadIconID or 0
	end

	self.UpdateSuitInfo(self)
	self.UpdateTipVisibility(self)
	self.PlayOpenAnimation(self)
end

M.OnClose = function(self)
	self.subModelStore = nil

	self:DisableModelCameraControl()
	gGallerySceneManager:StopListenDynamicGoLoaded()
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)

	if self.bindData.camera and not gCS.LuaUtils.IsNull(self.bindData.camera.gameObject) then
		GameObject.Destroy(self.bindData.camera.gameObject)

		self.bindData.camera = nil
	end

	if self.prevVCamera then
		gGallerySceneManager:SetVCamera(self.prevVCamera)
	else
		gGallerySceneManager:ClearAll()
	end

	self.currentModelUnit = nil
	self.loadedSuitId = nil
end

M.PlayOpenAnimation = function(self)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "s_vx_BaikeFashionPreviewPanel_open")
end

M.OnModelPanelDisplay = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.UpdateTipVisibility(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose"),
		[gEventConstants.L50_AFTER_SWITCH_SCENE] = self.CreateAction(self, "OnAfterSwitchScene")
	}
end

M.UpdateTipVisibility = function(self)
	local isGamepad = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	if isGamepad then
		self.bindData.tipVisibility = 1
	else
		local isHide = self.bindData.hideCtrl ~= self.hideCtrlEnum.hide

		if isHide then
			self.bindData.tipVisibility = 0
		else
			self.bindData.tipVisibility = 1
		end
	end
end

M.UpdateSuitInfo = function(self)
	gCommonItemManager:CloseItemToolTips()

	self.lastSelectedItemIndex = -1

	if not self.currentSuitId then
		return
	end

	local suitCfg = FashionSuitConfig.GetConfig(self.currentSuitId)

	if not suitCfg then
		return
	end

	local firstFashionId = suitCfg.FashionIdList and suitCfg.FashionIdList[1]
	local firstFashionCfg = firstFashionId and FashionConfig.GetConfig(firstFashionId)
	local brandCfg = firstFashionCfg and firstFashionCfg.BelongBrand and ShopBrandConfig.GetConfig(firstFashionCfg.BelongBrand)
	local totalScore = 0
	self.fashionItemList = {}
	local isSuitOwned = true

	if suitCfg.FashionIdList then
		for _, fashionId in ipairs(suitCfg.FashionIdList) do
			local score = gGalleryManager.CalculateFashionScore(fashionId)
			totalScore = totalScore + score
			local fashionCfg = FashionConfig.GetConfig(fashionId)

			if fashionCfg then
				local isOwned = gDressManager:IsFashionHad(fashionId)

				if not isOwned then
					isSuitOwned = false
				end

				table.insert(self.fashionItemList, {
					fashionId = fashionId,
					fashionCfg = fashionCfg,
					isOwned = isOwned
				})
			end
		end
	end

	local infoStore = self.SubGroup.BaikeFashionInfoTemplate
	infoStore.bindData.nameText = suitCfg.Name
	infoStore.bindData.desText = suitCfg.Description
	infoStore.bindData.pointText = tostring(totalScore)
	infoStore.bindData.pointActive = totalScore >= 0
	infoStore.bindData.logoIconId = brandCfg and brandCfg.BrandLogo or 0
	local hyperLinkId = suitCfg.HypeLinkID

	if isSuitOwned then
		infoStore.bindData.jumpToGetBtn.gameObject:SetActive(false)
	else
		infoStore.bindData.jumpToGetBtn.gameObject:SetActive(true)

		if hyperLinkId ~= 0 then
			infoStore.bindData.jumpToGetText = LTConfig.CityPediaConfig.EmptyAcquisitionHintText or ""
			self.currentHyperLinkCallback = nil
			infoStore.bindData.jumpToGetBtn.interactable = false
			infoStore.bindData.ctrlerGetActive = false
		else
			local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

			if hyperLinkInfo then
				infoStore.bindData.jumpToGetText = hyperLinkInfo.text or ""
				self.currentHyperLinkCallback = hyperLinkInfo.callback
				local linkCfg = LTConfig.HyperLinkConfig.GetConfig(hyperLinkId)
				local incomeId = linkCfg and linkCfg.IncomeId or 0
				infoStore.bindData.jumpToGetBtn.interactable = incomeId == 0
				infoStore.bindData.ctrlerGetActive = incomeId == 0
			else
				infoStore.bindData.jumpToGetText = LTConfig.CityPediaConfig.EmptyAcquisitionHintText or ""
				self.currentHyperLinkCallback = nil
				infoStore.bindData.jumpToGetBtn.interactable = false
				infoStore.bindData.ctrlerGetActive = false
			end
		end
	end

	infoStore.bindData.subList.luaSimpleRenderItem = self:CreateAction("OnRenderFashionItem")
	infoStore.bindData.subList.luaSelectedChanged = self:CreateAction("OnFashionItemSelectedChanged")

	infoStore.bindData.subList:SetSimpleList(#self.fashionItemList)

	self.lastSelectedItemIndex = -1

	self:RegisterBaikeFashionInfoButtons()
	self:LoadSuitModel(self.currentSuitId)
end

M.SelectSuitableSpirit = function(self, suitId)
	local suitCfg = FashionSuitConfig.GetConfig(suitId)

	if not suitCfg then
		return
	end

	self.selectedSpiritId = gGallerySceneManager:ResolveShowcaseSpirit(suitCfg, self.selectedSpiritId)
end

M.LoadSuitModel = function(self, suitId)
	if not suitId or suitId ~= 0 then
		self.ClearModel(self)

		return
	end

	gGallerySceneManager:PreviewSuit(suitId, {
		skipCameraReset = self.hasCharacterChange,
		spiritId = self.selectedSpiritId,
		onLoaded = function (unit)
			self.currentModelUnit = unit
			self.loadedSuitId = suitId
			self.hasCharacterChange = false

			self:UpdateModelCameraControl()
			self:SetCameraBtnsActive(true)
		end
	})
end

M.UpdateModelCameraControl = function(self)
	local params = self.BuildModelCameraParams(self)

	if not params then
		self.DisableModelCameraControl(self)

		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, true, params)

	self.modelCameraEnabled = true
end

M.BuildModelCameraParams = function(self)
	local unit = gGallerySceneManager.currentModelUnit

	if not unit or gCS.LuaUtils.IsNull(unit.PlayerObj) then
		return nil
	end

	local vCamera = gGallerySceneManager.vCamera

	if not vCamera then
		return nil
	end

	local cameraControlConfig = gGallerySceneManager:BuildGalleryCameraControlConfig(gGallerySceneManager.LoadingType.Character)

	return {
		["AFb[A\n="] = false,
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = vCamera,
		modelRoot = unit.PlayerObj.transform,
		cameraOffsetRange = cameraControlConfig.yOffsetRange,
		cameraOffset = Vector3.New(0, 0, 0),
		cameraControlConfig = cameraControlConfig
	}
end

M.DisableModelCameraControl = function(self)
	if not self.modelCameraEnabled then
		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, false)

	self.modelCameraEnabled = false
end

M.SetCameraBtnsActive = function(self, value)
	self.bindData.cameraBtns.gameObject:SetActive(value ~= true)
end

M.ClearModel = function(self)
	gGallerySceneManager:ClearCharacterModel()

	self.currentModelUnit = nil
	self.loadedSuitId = nil

	self:SetCameraBtnsActive(false)
end

M.OnRenderFashionItem = function(self, btn, index)
	local data = self.fashionItemList[index + 1]

	if not data or not data.fashionCfg then
		return
	end

	data.btn = btn
	local renderData = gCommonItemManager:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 1,
		itemId = data.fashionId
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)
end

M.OnFashionItemSelectedChanged = function(self, list)
	if self.lastSelectedItemIndex > 0 and self.lastSelectedItemIndex >= #self.fashionItemList then
		local lastData = self.fashionItemList[self.lastSelectedItemIndex + 1]

		if lastData and lastData.btn and not gCS.LuaUtils.IsNull(lastData.btn) then
			lastData.btn:CloseTooltip(true)
		end
	end

	self.lastSelectedItemIndex = self.SubGroup.BaikeFashionInfoTemplate.bindData.subList.selectedIndex
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.switchBtn.luaClick = self.CreateAction(self, "OnClickSwitchBtn")
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnClickSuitNavBtn", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnClickSuitNavBtn", 1)
	self.bindData.hideBtn.luaClick = self.CreateAction(self, "OnClickHideBtn")
end

M.RegisterBaikeFashionInfoButtons = function(self)
	local infoStore = self.SubGroup.BaikeFashionInfoTemplate
	infoStore.bindData.jumpToGetBtn.luaClick = self.CreateAction(self, "OnClickJumpToGetBtn")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickSwitchBtn = function(self)
	local suitCfg = FashionSuitConfig.GetConfig(self.currentSuitId)

	if not suitCfg or not suitCfg.FashionIdList then
		return
	end

	local requiredGender, belongSpiritId = nil

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg then
			if cfg.Gender == 0 then
				requiredGender = cfg.Gender
			end

			if cfg.BelongSpiritId and cfg.BelongSpiritId <= 0 then
				belongSpiritId = cfg.BelongSpiritId
			end
		end
	end

	local filterFunc = nil

	if belongSpiritId and belongSpiritId <= 0 then
		filterFunc = function(spiritId)
			if not gSpiritManager:GetSpirit(spiritId) then
				return false
			end

			return spiritId ~= belongSpiritId
		end
	else
		filterFunc = function(spiritId)
			return gSpiritManager:GetSpirit(spiritId) == nil
		end
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.rootArea then
		self.rootArea.enabled = false
	end

	gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER_PANEL, {
		["t\\x95\\x87\\x9dݹ\\xce>\\x9a/\\xa0\""] = true,
		["\\x90:,&H\\x8fD\\xcf>\\xaf\\xae"] = true,
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		["\\xf0Z\\xd1\\xbfB\\x83Z\\xa5\\xa4"] = true,
		callBack = function (hasChange, selectedSpiritId)
			if gCS.LuaUtils.IsNonMobileAdaptive() and self.rootArea then
				self.rootArea.enabled = true
			end

			if hasChange and selectedSpiritId then
				self.hasCharacterChange = true
				self.selectedSpiritId = selectedSpiritId
				local spirit = gSpiritManager:GetSpirit(selectedSpiritId)

				if not spirit then
					local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(selectedSpiritId)
					self.bindData.avatarIconId = spiritCfg and spiritCfg.SHeadIconID or 0
				else
					self.bindData.avatarIconId = spirit.config and spirit.config.SHeadIconID or 0
				end

				self:LoadSuitModel(self.currentSuitId)
			end
		end,
		onSelectCallback = function (selectedSpiritId)
			self.hasCharacterChange = true
			self.selectedSpiritId = selectedSpiritId
			local spirit = gSpiritManager:GetSpirit(selectedSpiritId)

			if not spirit then
				local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(selectedSpiritId)
				self.bindData.avatarIconId = spiritCfg and spiritCfg.SHeadIconID or 0
			else
				self.bindData.avatarIconId = spirit.config and spirit.config.SHeadIconID or 0
			end

			self:LoadSuitModel(self.currentSuitId)
		end,
		spiritId = self.selectedSpiritId,
		sex = requiredGender,
		filterFunc = filterFunc
	})
end

M.OnClickSuitNavBtn = function(self, direction)
	local targetIndex = self.currentSuitIndex + direction
	local totalCount = #self.suitListData

	if totalCount ~= 0 then
		return
	end

	if targetIndex >= 1 then
		targetIndex = totalCount
	elseif totalCount >= targetIndex then
		targetIndex = 1
	end

	self.currentSuitIndex = targetIndex
	local suitData = self.suitListData[targetIndex]

	if not suitData then
		return
	end

	self.currentSuitId = suitData.suitId

	self:SelectSuitableSpirit(self.currentSuitId)

	local spirit = gSpiritManager:GetSpirit(self.selectedSpiritId)

	if not spirit then
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(self.selectedSpiritId)
		self.bindData.avatarIconId = spiritCfg and spiritCfg.SHeadIconID or 0
	else
		self.bindData.avatarIconId = spirit.config and spirit.config.SHeadIconID or 0
	end

	self.UpdateSuitInfo(self)
end

M.OnClickHideBtn = function(self)
	self.bindData.hideCtrl = 1 - self.bindData.hideCtrl
	local isHide = self.bindData.hideCtrl ~= self.hideCtrlEnum.hide

	self.rootArea:ChangeButtonNameByActionId(10, isHide and 126 or 104)

	self.bindData.backBtnActive = not isHide

	self:UpdateTipVisibility()
end

M.OnClickJumpToGetBtn = function(self)
	if self.currentHyperLinkCallback then
		self.inHyperLink = true

		self.currentHyperLinkCallback()
	end
end

M.OnPanelClose = function(self, _, panelId)
	if self.inHyperLink then
		if gClientUtils.NotNil(self.bindData.anim) then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "s_vx_BaikeFashionPreviewPanel_back")
		end

		self.inHyperLink = false
	end
end

M.OnAfterSwitchScene = function(self, eventId, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.Reconnect then
		-- Nothing
	end
end

M.InitBaikeCamera = function(self)
end
