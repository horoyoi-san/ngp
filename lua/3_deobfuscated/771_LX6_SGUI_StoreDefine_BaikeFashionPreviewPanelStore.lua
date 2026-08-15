local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionConfig = LTConfig.FashionConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local LayerConstants = LX6.Constants.LayerConstants

require("LX6/Manager/Baike/BaikeCameraManager")

C_BaikeFashionPreviewPanelStore = DefClass("C_BaikeFashionPreviewPanelStore", C_BaikeFashionPreviewPanelStore, C_StoreGroup)
GroupName2Class.BaikeFashionPreviewPanelStore = C_BaikeFashionPreviewPanelStore
local M = C_BaikeFashionPreviewPanelStore
M.HideCtrl = {
	Hide = 1,
	Show = 0
}

function M:ctor()
	self.hasCharacterChange = false
end

function M:DefineAllVariables()
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
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	if self.subModelStore then
		self.subModelStore:ResetCfg()
	end
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearModel()
	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, false)
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	if not data then
		return
	end

	self.bindData.modelTab.selectedIndex = 0
	self.bindData.hideCtrl = self.HideCtrl.Show

	if self.rootGo then
		self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	end

	self.brandId = data.brandId
	self.currentSuitId = data.suitId
	self.suitListData = data.suitListData or {}

	for i, suitData in ipairs(self.suitListData) do
		if suitData.suitId == self.currentSuitId then
			self.currentSuitIndex = i

			break
		end
	end

	self.hasCharacterChange = false
	self.selectedSpiritId = data.spiritId or gDressManager.CurrentSpiritId

	self:SelectSuitableSpirit(self.currentSuitId)

	local spirit = gSpiritManager:GetSpirit(self.selectedSpiritId)

	if not spirit then
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(self.selectedSpiritId)
		self.bindData.avatarIconId = spiritCfg and spiritCfg.SHeadIconID or 0
	else
		self.bindData.avatarIconId = spirit.config and spirit.config.SHeadIconID or 0
	end

	self:UpdateSuitInfo()
	self:UpdateTipVisibility()
end

function M:OnClose()
	self.subModelStore = nil

	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, false)
end

function M:PlayOpenAnimation()
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "s_vx_BaikeFashionPreviewPanel_open")
end

function M:OnModelPanelDisplay()
	self.subModelStore = gStoreManager:GetStoreGroup("BaikeModelViewerStore")

	if self.subModelStore then
		self.subModelStore:SetSceneLoadCompleteCallback(function ()
			self:PlayOpenAnimation()
		end)
	end

	self:LoadSuitModel(self.currentSuitId)
	self:InitBaikeCamera()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	self:UpdateTipVisibility()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose"),
		[gEventConstants.AFTER_SWITCH_SCENE] = self:CreateAction("OnAfterSwitchScene")
	}
end

function M:UpdateTipVisibility()
	local isGamepad = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()

	if isGamepad then
		self.bindData.tipVisibility = 1
	else
		local isHide = self.bindData.hideCtrl == self.HideCtrl.Hide

		if isHide then
			self.bindData.tipVisibility = 0
		else
			self.bindData.tipVisibility = 1
		end
	end
end

function M:UpdateSuitInfo()
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
			local score = gBaiKeArchiveManager.CalculateFashionScore(fashionId)
			totalScore = totalScore + score
			local fashionCfg = FashionConfig.GetConfig(fashionId)

			if fashionCfg then
				local isOwned = gDressManager:IsFashionHaved(fashionId)

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
	infoStore.bindData.pointActive = totalScore > 0
	infoStore.bindData.logoIconId = brandCfg and brandCfg.BrandLogo or 0
	local hyperLinkId = suitCfg.HypeLinkID

	if isSuitOwned then
		infoStore.bindData.jumpToGetBtn.gameObject:SetActive(false)
	else
		infoStore.bindData.jumpToGetBtn.gameObject:SetActive(true)

		if hyperLinkId == 0 then
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
				infoStore.bindData.jumpToGetBtn.interactable = incomeId ~= 0
				infoStore.bindData.ctrlerGetActive = incomeId ~= 0
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

function M:SelectSuitableSpirit(suitId)
	local suitCfg = FashionSuitConfig.GetConfig(suitId)

	if not suitCfg or not suitCfg.FashionIdList then
		return
	end

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		local fashionCfg = FashionConfig.GetConfig(fashionId)

		if fashionCfg then
			self.selectedSpiritId = gDressManager:SelectSuitableSpiritForFashion(fashionCfg, self.selectedSpiritId)

			return
		end
	end
end

function M:LoadSuitModel(suitId)
	if not suitId or suitId == 0 then
		self:ClearModel()

		return
	end

	if not self.subModelStore then
		return
	end

	if self.loadedSuitId == suitId and not self.hasCharacterChange then
		return
	end

	local suitCfg = FashionSuitConfig.GetConfig(suitId)

	if not suitCfg or not suitCfg.FashionIdList then
		return
	end

	local spiritId = self.selectedSpiritId

	if not spiritId or spiritId == 0 then
		return
	end

	self:ClearModel()

	self.loadedSuitId = suitId
	self.hasCharacterChange = false

	if not gDressManager.SpriteFashionInfoDict or not gDressManager.SpriteFashionInfoDict[spiritId] then
		gDressManager:SetPlayerFashionsInfo()
	end

	local fashionInfo = nil

	if gDressManager.SpriteFashionInfoDict and gDressManager.SpriteFashionInfoDict[spiritId] then
		local spiritFashionInfo = gDressManager.SpriteFashionInfoDict[spiritId]

		if spiritFashionInfo.WearFashionInfoList then
			fashionInfo = table.clone(spiritFashionInfo)
			fashionInfo.WearFashionInfoList = {}
			fashionInfo.WearFashionEditInfoList = {}

			for _, fashionId in ipairs(suitCfg.FashionIdList) do
				table.insert(fashionInfo.WearFashionEditInfoList, {
					FashionId = fashionId
				})
			end
		end
	end

	if not fashionInfo then
		fashionInfo = {
			WearFashionInfoList = {},
			WearFashionEditInfoList = {}
		}

		for _, fashionId in ipairs(suitCfg.FashionIdList) do
			table.insert(fashionInfo.WearFashionEditInfoList, {
				FashionId = fashionId
			})
		end
	end

	self.subModelStore:LoadCharacterModel(spiritId, fashionInfo, suitId, function (unit)
		self.currentModelUnit = unit

		self:InitBaikeCamera()
	end)
end

function M:ClearModel()
	if self.subModelStore then
		self.subModelStore:ClearCharacterModel()
	end

	self.currentModelUnit = nil
	self.loadedSuitId = nil
end

function M:OnRenderFashionItem(btn, index)
	local data = self.fashionItemList[index + 1]

	if not data or not data.fashionCfg then
		return
	end

	data.btn = btn
	local renderData = gCommonItemManager:GetItemRenderData({
		itemNum = 1,
		itemId = data.fashionId,
		countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)
end

function M:OnFashionItemSelectedChanged(list)
	if self.lastSelectedItemIndex >= 0 and self.lastSelectedItemIndex < #self.fashionItemList then
		local lastData = self.fashionItemList[self.lastSelectedItemIndex + 1]

		if lastData and lastData.btn and not gCS.LuaUtils.IsNull(lastData.btn) then
			lastData.btn:CloseTooltip(true)
		end
	end

	self.lastSelectedItemIndex = self.SubGroup.BaikeFashionInfoTemplate.bindData.subList.selectedIndex
end

function M:RegisterWidget()
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.switchBtn.luaClick = self:CreateAction("OnClickSwitchBtn")
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnClickSuitNavBtn", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnClickSuitNavBtn", 1)
	self.bindData.hideBtn.luaClick = self:CreateAction("OnClickHideBtn")
	self.bindData.modelTab.OnRenderTab = self:CreateAction("OnModelPanelDisplay")
end

function M:RegisterBaikeFashionInfoButtons()
	local infoStore = self.SubGroup.BaikeFashionInfoTemplate
	infoStore.bindData.jumpToGetBtn.luaClick = self:CreateAction("OnClickJumpToGetBtn")
end

function M:OnClickBackBtn()
	gPanelManager:Close(gPanelId.BAIKE_FASHION_PREVIEW_PANEL)
end

function M:OnClickSwitchBtn()
	local suitCfg = FashionSuitConfig.GetConfig(self.currentSuitId)

	if not suitCfg or not suitCfg.FashionIdList then
		return
	end

	local requiredGender, belongSpiritId = nil

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg then
			if cfg.Gender ~= 0 then
				requiredGender = cfg.Gender
			end

			if cfg.BelongSpiritId and cfg.BelongSpiritId > 0 then
				belongSpiritId = cfg.BelongSpiritId
			end
		end
	end

	local filterFunc = nil

	if belongSpiritId and belongSpiritId > 0 then
		function filterFunc(spiritId)
			return spiritId == belongSpiritId
		end
	elseif requiredGender and requiredGender > 0 then
		function filterFunc(spiritId)
			local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)

			if not spiritCfg then
				return false
			end

			local agentCfg = LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)

			return agentCfg and agentCfg.SexType == requiredGender
		end
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.rootArea then
		self.rootArea.enabled = false
	end

	gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER_PANEL, {
		onlyPreview = true,
		showBaikeSpirits = true,
		useStaticBlur = true,
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

function M:OnClickSuitNavBtn(direction)
	local targetIndex = self.currentSuitIndex + direction
	local totalCount = #self.suitListData

	if totalCount == 0 then
		return
	end

	if targetIndex < 1 then
		targetIndex = totalCount
	elseif totalCount < targetIndex then
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

	self:UpdateSuitInfo()
end

function M:OnClickHideBtn()
	self.bindData.hideCtrl = 1 - self.bindData.hideCtrl
	local isHide = self.bindData.hideCtrl == self.HideCtrl.Hide

	self.rootArea:ChangeButtonNameByActionId(10, isHide and 126 or 104)

	self.bindData.backBtnActive = not isHide

	self:UpdateTipVisibility()
end

function M:OnClickJumpToGetBtn()
	if self.currentHyperLinkCallback then
		self.inHyperLink = true

		self.currentHyperLinkCallback()
	end
end

function M:OnPanelClose(_, panelId)
	if self.inHyperLink then
		if gClientUtils.NotNil(self.bindData.anim) then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "s_vx_BaikeFashionPreviewPanel_back")
		end

		self.inHyperLink = false
	end
end

function M:OnAfterSwitchScene(eventId, switchType)
	if switchType == gSwitchSceneType.Reconnect then
		if self.subModelStore and self.subModelStore.scenePrefab then
			self:PlayOpenAnimation()
		elseif self.subModelStore then
			self.subModelStore:SetSceneLoadCompleteCallback(function ()
				self:PlayOpenAnimation()
			end)
		end
	end
end

function M:InitBaikeCamera()
	local camera = self.subModelStore:GetCamera()
	local modelRoot = self.subModelStore:GetModelSlot()
	local params = {
		banRotate = false,
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = camera,
		modelRoot = modelRoot,
		cameraType = gBaikeCameraManager.CameraType.Fashion,
		cameraOffsetRange = {
			-0.5,
			0.5
		}
	}

	if self.selectedSpiritId then
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(self.selectedSpiritId)
		local agentCfg = spiritCfg and LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)
		local modelCfg = agentCfg and LTConfig.GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

		if modelCfg then
			local bodyType = modelCfg.CameraBodyType ~= 0 and modelCfg.CameraBodyType or modelCfg.BodyType
			local fashionBaseCfg = LTConfig.FashionBaseConfig.GetConfig(bodyType)

			if fashionBaseCfg then
				params.cameraOffsetRange = fashionBaseCfg.PediaCameraOffset or params.cameraOffsetRange
				local parm = fashionBaseCfg.PediaCameraParm

				if parm then
					params.cameraOffset = Vector3.New(parm.offsetx or 0, parm.offsety or 0, parm.offsetz or 0)
					params.cameraEuler = Vector3.New(parm.eulerx or 0, parm.eulery or 0, parm.eulerz or 0)
					params.fov = parm.fov ~= 0 and parm.fov or nil
				end
			end
		end
	end

	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, true, params)
end
