C_DressPlanPanelStore = DefClass("C_DressPlanPanelStore", C_DressPlanPanelStore, C_StoreGroup)
GroupName2Class.DressPlanPanelStore = C_DressPlanPanelStore
local M = C_DressPlanPanelStore
local MessageConfig = LTConfig.MessageConfig
local FashionConfig = LTConfig.FashionConfig
local UXVector3 = UX.Game.UXVector3
local NameCheckResult = UX.Utils.NameValidityChecker.NameCheckResult
local SUIT_TYPE = {
	CURRENT = 0,
	PROFESSION = 2,
	MY_PRESET = 1
}
local PROFESSION_TYPE = {
	NORMAL = 0,
	PROFESSION = 1
}
local NameCheckResultStr = {
	[NameCheckResult.NameEmpty] = 65102274,
	[NameCheckResult.NameTooShort] = 65102288,
	[NameCheckResult.NameTooLong] = 65102289,
	[NameCheckResult.PunctuationOnly] = 65102290,
	[NameCheckResult.NameContainsInvalidCharacter] = 65102291
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.saveBtn.luaClick = self:CreateAction("OnSaveBtnClick")
	self.bindData.useBtn.luaClick = self:CreateAction("OnUseBtnClick")
	self.bindData.coverBtn.luaClick = self:CreateAction("OnCoverBtnClick")
	self.bindData.editBtn.luaClick = self:CreateAction("OnEditBtnClick")
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")

	function self.bindData.scroll.luaInitContent()
		self:InitInfo()
	end
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	gDressManager:ClearCurrentPlayerSpirit(true, true, true)
	gDressManager:SetPlayerFashionsInfo()

	if self.callBack then
		self.callBack()
	end

	gDressManager.fashionProp = {}
end

function M:OnShow(panelId, data)
	gDressManager.fashionProp = {}
	self.callBack = data and data.callBack
	self.fashionId = data and data.fashionId
	self.callBack = data and data.callBack
	self.hasEditProfession = false
	self.lastSelectBtn = nil
	local cameraParams = {
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel
	}

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		cameraParams.rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond
		cameraParams.L1CustomNavRespond = self.bindData.L2CustomNavRespond
		cameraParams.R1CustomNavRespond = self.bindData.R2CustomNavRespond
	end

	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, true, cameraParams)
end

function M:OnClose()
	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, false)
end

function M:InitInfo()
	self.contentStore = gStoreManager:GetStoreGroup("DressPlanContentStore"):GetStoreByWidget(self.bindData.scroll.content)
	self.contentStore.currentList.luaSimpleRenderItem = self:CreateAction("OnRefreshCurrentList")
	self.contentStore.currentList.luaSimpleClick = self:CreateAction("OnChangeCurrentList")
	self.contentStore.myPresetList.luaSimpleRenderItem = self:CreateAction("OnRefreshMyPresetList")
	self.contentStore.myPresetList.luaSimpleClick = self:CreateAction("OnChangeMyPresetList")
	self.contentStore.professionList.luaSimpleRenderItem = self:CreateAction("OnRefreshProfessionList")
	self.contentStore.professionList.luaSimpleClick = self:CreateAction("OnChangeProfessionList")
	self.recordFashionList = gDressManager:GetMyCurrentFashionList()

	if self.contentStore then
		self.selectSuitType = 0
		self.selectPlanIndex = 1

		self:InitCurrentList()
		self:InitMyPresetList()
		self:InitProfessionList()
	end
end

function M:InitCurrentList()
	self.currentList = {}
	local view = {
		title = FashionConfig.SuitSchemeDefaultName,
		isHideEdit = 1,
		type = SUIT_TYPE.CURRENT,
		index = 1
	}
	local fashionList, fashionEditList = gDressManager:GetMyCurrentFashionList()
	view.fashionList = fashionList
	view.fashionEditList = fashionEditList
	view.professionType = PROFESSION_TYPE.NORMAL

	table.insert(self.currentList, view)
	self.contentStore.currentList:SetSimpleList(#self.currentList)
end

function M:OnRefreshCurrentList(btn, index)
	local data = self.currentList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.isHideEdit = data.isHideEdit
		store.title = data.title
		store.professionType = data.professionType
		btn.isSelected = data.type == self.selectSuitType and data.index == self.selectPlanIndex

		if btn.isSelected then
			self.selectPlanIndex = data.index
			self.selectSuitType = data.type
			self.lastSelectBtn = btn
			self.bindData.showBtnType = self:GetBtnType()
		end
	end
end

function M:OnChangeCurrentList(btn, index)
	local data = self.currentList[index + 1]

	if btn.isSelected then
		self:SetCurrentSuit(btn, data)
	end
end

function M:InitMyPresetList()
	local list = gDressManager:GetSuitSchemeName()
	self.myPresetList = {}

	for i = 1, #FashionConfig.CustomSuitSchemeName do
		local view = {
			title = list[i] and list[i].SchemeName or FashionConfig.CustomSuitSchemeName[i].Name,
			Gender = FashionConfig.CustomSuitSchemeName[i].Gender,
			isHideEdit = 0,
			index = i + 1,
			type = SUIT_TYPE.MY_PRESET,
			fashionList = self:GetPresetFashionList(list[i]),
			fashionEditList = self:GetPresetFashionEditList(list[i]),
			professionType = PROFESSION_TYPE.NORMAL,
			inRandomPool = list[i] and list[i].JoinRandomPool or false
		}

		table.insert(self.myPresetList, view)
	end

	self.contentStore.myPresetList:SetSimpleList(#self.myPresetList)
end

function M:GetPresetFashionList(list)
	local fashionList = {}

	if list and not table.isNilOrEmpty(list.WearFashionInfoList) then
		local count = list.WearFashionInfoList.Count

		if count == nil then
			count = #list.WearFashionInfoList
		end

		for i = 1, count do
			table.insert(fashionList, list.WearFashionInfoList[i].FashionId)
		end
	end

	return fashionList
end

function M:GetPresetFashionEditList(list)
	local fashionEditList = {}

	if list and not table.isNilOrEmpty(list.WearFashionEditInfoList) then
		local count = list.WearFashionEditInfoList.Count

		for i = 1, count do
			local viewInfo = fashionEditList[list.WearFashionEditInfoList[i].FashionId]
			viewInfo = {
				FashionId = list.WearFashionEditInfoList[i].FashionId,
				Scale = list.WearFashionEditInfoList[i].Scale,
				Offset = list.WearFashionEditInfoList[i].Offset,
				Rotation = list.WearFashionEditInfoList[i].Rotation
			}

			table.insert(fashionEditList, viewInfo)
		end
	end

	return fashionEditList
end

function M:OnRefreshMyPresetList(btn, index)
	local data = self.myPresetList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local tempView = {
			store = store,
			index = data.index
		}
		store.editBtn.luaClick = self:CreateActionWithArgs("OnEditPlanNameBtnClick", tempView)
		store.isHideEdit = data.isHideEdit
		store.title = data.title
		store.professionType = data.professionType
		btn.isSelected = data.type == self.selectSuitType and data.index == self.selectPlanIndex

		if btn.isSelected then
			self.bindData.isEmptyPreset = table.isNilOrEmpty(data.fashionList) and 0 or 1

			self:SetCurrentSuit(btn, data)
		end
	end
end

function M:OnChangeMyPresetList(btn, index)
	local data = self.myPresetList[index + 1]

	if btn.isSelected then
		self.bindData.isEmptyPreset = table.isNilOrEmpty(data.fashionList) and 0 or 1

		self:SetCurrentSuit(btn, data)
	end
end

function M:InitProfessionList()
	self.professionList = {}

	gDressManager:InitFunctionSuitTypes()

	local list = gDressManager:GetBodyType2FunctionSuits()
	local index = #FashionConfig.CustomSuitSchemeName + 1

	for functionSuitId, info in pairs(list) do
		index = index + 1
		local view = {
			title = info.Title,
			isHideEdit = 1,
			index = index,
			type = SUIT_TYPE.PROFESSION,
			fashionList = info.FashionIdList,
			fashionEditList = info.FashionEditList,
			fashionType = info.TagId,
			functionSuitId = functionSuitId,
			Icon = info.Icon,
			IconChoose = info.IconChoose,
			professionType = PROFESSION_TYPE.PROFESSION,
			Title = info.Title
		}

		table.insert(self.professionList, view)
	end

	self.contentStore.professionList:SetSimpleList(#self.professionList)
end

function M:OnRefreshProfessionList(btn, index)
	local data = self.professionList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.editBtn.luaClick = self:CreateAction("OnEditProfessBtnClick")
		store.isHideEdit = data.isHideEdit
		store.title = data.title
		store.unselectBg = data.Icon
		store.selectBg = data.IconChoose
		store.professionType = data.professionType
		btn.isSelected = data.type == self.selectSuitType and data.index == self.selectPlanIndex

		if btn.isSelected then
			self:SetCurrentSuit(btn, data)
		end
	end
end

function M:OnChangeProfessionList(btn, index)
	local data = self.professionList[index + 1]

	if btn.isSelected then
		self:SetCurrentSuit(btn, data)
	end
end

function M:SetCurrentSuit(btn, data)
	if self.selectSuitType == data.type and self.selectPlanIndex == data.index and not self.hasEditProfession then
		return
	end

	if self.hasEditProfession then
		self.hasEditProfession = false
	elseif self.lastSelectBtn then
		self.lastSelectBtn.isSelected = false
	end

	self.selectPlanIndex = data.index
	self.selectSuitType = data.type
	self.lastSelectBtn = btn
	self.bindData.showBtnType = self:GetBtnType()

	self.bindData.outFitCheckBtn:SetSelected(data.inRandomPool)
	gDressManager:DressNewFashionListAndEdit(data.fashionList, data.fashionEditList, self.recordFashionList)

	self.recordFashionList = data.fashionList
	self.recordFashionEditList = data.fashionEditList
	gDressManager.fashionProp = {}
end

function M:GetBtnType()
	if self.selectSuitType == SUIT_TYPE.MY_PRESET then
		return 1
	elseif self.selectSuitType == SUIT_TYPE.PROFESSION then
		return 2
	end

	return 0
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.DRESS_PLAN_PANEL)
	gPanelManager:CheckShow(gPanelId.S_CHANGE_DRESS)
end

function M:OnSaveBtnClick()
	local function callBack()
		gDressManager:DressSuitFashionList(self.currentList[1].fashionList, true, false, true)

		self.recordFashionList = self.currentList[1].fashionList
		self.myPresetList[self.selectPlanIndex - 1].fashionList = self.currentList[1].fashionList
		self.myPresetList[self.selectPlanIndex - 1].inRandomPool = self.bindData.outFitCheckBtn.isSelected

		self.contentStore.myPresetList:RefreshList()
	end

	gDressData:AskSetSpiritCustomSuitSchemeInfo(gDressManager.CurrentSpiritId, self.selectPlanIndex - 1, callBack, self.bindData.outFitCheckBtn.isSelected)
end

function M:OnUseBtnClick()
	local function callBack()
		self.lastSelectBtn.isSelected = false
		self.selectPlanIndex = 1
		self.selectSuitType = SUIT_TYPE.CURRENT

		self:InitCurrentList()

		if not table.isNilOrEmpty(self.recordFashionEditList) then
			for i = 1, #self.recordFashionEditList do
				local info = self.recordFashionEditList[i]
				local rotation = UXVector3.New(info.Rotation.X, info.Rotation.Y, info.Rotation.Z)
				local offset = UXVector3.New(info.Offset.X, info.Offset.Y, info.Offset.Z)

				gDressManager:PreSetPropEditInfo(info.FashionId, rotation, offset, info.Scale)
			end
		end

		gDressManager:DressSuitFashionList(self.recordFashionList, true, false, true)
	end

	gDressData:AskSetSpiritFashions(callBack)
end

function M:OnCoverBtnClick()
	gDisplayMessageMgr:ShowMessage(MessageConfig.FashionSuitApplyReconfirm, function ()
		local suitSchemeInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId]

		gDressData:AskSetSpiritFunctionSuitSchemeInfo(gDressManager.CurrentSpiritId, self.professionList[self.selectPlanIndex - #FashionConfig.CustomSuitSchemeName - 1].functionSuitId, true, suitSchemeInfo)
	end, nil)
end

function M:OnEditBtnClick()
	local professionInfo = self.professionList[self.selectPlanIndex - #FashionConfig.CustomSuitSchemeName - 1]

	local function callBack()
		local function cb()
			self.hasEditProfession = true

			self:InitProfessionList()
		end

		local suitSchemeInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId]

		gDressData:AskSetSpiritFunctionSuitSchemeInfo(gDressManager.CurrentSpiritId, professionInfo.functionSuitId, false, suitSchemeInfo, cb)
	end

	local view = {
		fashionType = professionInfo and professionInfo.fashionType or 1,
		isShowProfessionEdit = true,
		callBack = callBack,
		title = professionInfo.Title
	}

	gPanelManager:CheckShow(gPanelId.S_CHANGE_DRESS, view)
end

function M:OnEditProfessBtnClick()
	return
end

function M:OnEditPlanNameBtnClick(tempView)
	self.selectPlanIndex = tempView.index

	gDisplayMessageMgr:ShowBomb({
		isInput = true,
		inputCheck = self:CreateAction("CheckInputName"),
		exceedLength = FashionConfig.CustomSuitSchemeNameMaxLength,
		exceedLengthMsg = MessageConfig.GetConfig(NameCheckResultStr[NameCheckResult.NameTooLong]).Content,
		msgType = gDisplayMessageId.SELECT,
		titleText = LTConfig.TextScriptTextConfig.GetConfig(89901174).Text,
		btnConfirmCallback = self:CreateActionWithArgs("ChangeName", tempView.store)
	})
end

function M:ChangeName(store, name)
	if self:ContentIsEmpty(name) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.FilesNameNone)

		return false
	end

	local result = gCS.GuiUtils.IsInputNameValidNoMsg(name, 1, FashionConfig.CustomSuitSchemeNameMaxLength)

	if result ~= 0 then
		print_error("名字不合法")

		return false
	end

	local newName = name
	self.createRoleCoroutine = gCoroutineManager:StartCoroutine(function ()
		local wait = EnvSDK.reviewNickNameAsync(newName)

		coroutine.yield(wait)

		if wait.result.code == 200 then
			local function callBack()
				store.title = name
			end

			gDressData:AskModifySpiritCustomSuitSchemeName(gDressManager.CurrentSpiritId, self.selectPlanIndex - 1, name, callBack)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.FilesCheck)
		end

		self.createRoleCoroutine = nil
	end)

	return true
end

function M:CheckInputName(text)
	if self:ContentIsEmpty(text) then
		return false, LTConfig.TextScriptTextConfig.GetConfig(89901122).Text
	end

	local result = gCS.GuiUtils.IsInputNameValidNoMsg(text, 1, FashionConfig.CustomSuitSchemeNameMaxLength)
	local textCfg = MessageConfig.GetConfig(NameCheckResultStr[result])

	return result == 0, textCfg and textCfg.Content or ""
end

function M:ContentIsEmpty(str)
	for i = 1, #str do
		if string.sub(str, i, i) ~= "\n" and string.sub(str, i, i) ~= " " then
			return false
		end
	end

	return true
end
