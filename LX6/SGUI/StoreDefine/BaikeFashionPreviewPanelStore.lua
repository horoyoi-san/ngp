-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeFashionPreviewPanelStore.lua
-- Decompiled from: 01567_BaikeFashionPreviewPanelStore.lua_80d0e75a4020.luajit

local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionConfig = LTConfig.FashionConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig

require("LX6/Manager/Baike/BaikeCameraManager")

C_BaikeFashionPreviewPanelStore = DefClass("C_BaikeFashionPreviewPanelStore", C_BaikeFashionPreviewPanelStore, C_StoreGroup)
GroupName2Class.BaikeFashionPreviewPanelStore = C_BaikeFashionPreviewPanelStore
local M = C_BaikeFashionPreviewPanelStore
M.HideCtrl = {
	["R+y^"] = 1,
	["I*rL"] = 0
}

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
	self:ClearModel()
	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, false)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
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
end

M.OnClose = function(self)
	self.subModelStore = nil

	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, false)
end

M.PlayOpenAnimation = function(self)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "s_vx_BaikeFashionPreviewPanel_open")
end

M.OnModelPanelDisplay = function(self)
	self.subModelStore = gStoreManager:GetStoreGroup("BaikeModelViewerStore")

	if self.subModelStore then
		slot1 = self.subModelStore

		slot1:SetSceneLoadCompleteCallback(function ()
			self:PlayOpenAnimation()
		end)
	end

	self.LoadSuitModel(self, self.currentSuitId)
	self.InitBaikeCamera(self)
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
		local isHide = self.bindData.hideCtrl ~= self.HideCtrl.Hide

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
			local score = gBaiKeArchiveManager.CalculateFashionScore(fashionId)
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

M.LoadSuitModel = function(self, suitId)
	if not suitId or suitId ~= 0 then
		self.ClearModel(self)

		return
	end

	if not self.subModelStore then
		return
	end

	if self.loadedSuitId ~= suitId and not self.hasCharacterChange then
		return
	end

	local suitCfg = FashionSuitConfig.GetConfig(suitId)

	if not suitCfg or not suitCfg.FashionIdList then
		return
	end

	local spiritId = self.selectedSpiritId

	if not spiritId or spiritId ~= 0 then
		return
	end

	self.ClearModel(self)

	self.loadedSuitId = suitId
	self.hasCharacterChange = false
	local fashionInfo = {
		WearFashionInfoList = {},
		WearFashionEditInfoList = {}
	}

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		table.insert(fashionInfo.WearFashionInfoList, {
			FashionId = fashionId
		})
	end

	slot5 = self.subModelStore

	slot5:LoadCharacterModel(spiritId, fashionInfo, suitId, function (unit)
		self.currentModelUnit = unit

		self:InitBaikeCamera()
	end)
end

M.ClearModel = function(self)
	if self.subModelStore then
		self.subModelStore:ClearCharacterModel()
	end

	self.currentModelUnit = nil
	self.loadedSuitId = nil
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
	self.bindData.modelTab.OnRenderTab = self.CreateAction(self, "OnModelPanelDisplay")
end

M.RegisterBaikeFashionInfoButtons = function(self)
	local infoStore = self.SubGroup.BaikeFashionInfoTemplate
	infoStore.bindData.jumpToGetBtn.luaClick = self.CreateAction(self, "OnClickJumpToGetBtn")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.BAIKE_FASHION_PREVIEW_PANEL)
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
		["\\x90:,&H\\x8fD\\xcf>\\xaf\\xae"] = true,
		["t\\x95\\x87\\x9dݹ\\xce>\\x9a/\\xa0\""] = true,
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
	local isHide = self.bindData.hideCtrl ~= self.HideCtrl.Hide

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
		if self.subModelStore and self.subModelStore.scenePrefab then
			self.PlayOpenAnimation(self)
		elseif self.subModelStore then
			slot4 = self.subModelStore

			slot4:SetSceneLoadCompleteCallback(function ()
				self:PlayOpenAnimation()
			end)
		end
	end
end

M.InitBaikeCamera = function(self)
	local camera = self.subModelStore:GetCamera()
	local modelRoot = self.subModelStore:GetModelSlot()
	local params = {
		["AFb[A\n="] = false,
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
			local bodyType = modelCfg.CameraBodyType == 0 and modelCfg.CameraBodyType or modelCfg.BodyType
			local fashionBaseCfg = LTConfig.FashionBaseConfig.GetConfig(bodyType)

			if fashionBaseCfg then
				params.cameraOffsetRange = fashionBaseCfg.PediaCameraOffset or params.cameraOffsetRange
				local parm = fashionBaseCfg.PediaCameraParm

				if parm then
					params.cameraOffset = Vector3.New(parm.offsetx or 0, parm.offsety or 0, parm.offsetz or 0)
					params.cameraEuler = Vector3.New(parm.eulerx or 0, parm.eulery or 0, parm.eulerz or 0)
					params.fov = parm.fov == 0 and parm.fov or nil
				end
			end
		end
	end

	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, true, params)
end
