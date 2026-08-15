C_PoliceSearchPanelStore = DefClass("C_PoliceSearchPanelStore", C_PoliceSearchPanelStore, C_StoreGroup)
GroupName2Class.PoliceSearchPanelStore = C_PoliceSearchPanelStore
local M = C_PoliceSearchPanelStore
local DrugCfg = LTConfig.NpcInformationDrugConfig
local ItemCfg = LTConfig.NpcInformationItemConfig

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.Close)
	self.bindData.exitButton2.luaClick = self:CreateAction(self.Close)
	self.bindData.iconList.luaSimpleRenderItem = self:CreateAction(self.OnRenderIconItem)
	self.bindData.textList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTextItem)
	self.bindData.textList.luaSimpleClick = self:CreateAction(self.OnTextItemClick)
	self.panelId = nil
	self.anim = self.rootWidget.anim
end

function M:DelayShowRootWidget()
	self.rootWidget.renderOpacity = 0.001

	FrameTimer.New(function ()
		if gClientUtils.NotNil(self.rootWidget) then
			self.rootWidget.renderOpacity = 1
		end
	end, 1):Start()
end

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.closeCallback = data and data.closeCallback

	self:ShowSearchCarResult()
end

function M:ShowSearchCarResult()
	local itemList = {}

	for _, v in ipairs(LTConfig.PoliceConfig.SearchCarResult) do
		local item = {
			v.Icon,
			v.Name,
			tIndex = 0
		}

		table.insert(itemList, item)
	end

	local cfg = {
		Text1 = LTConfig.PoliceConfig.SearchPanelSearchingText,
		Text2 = LTConfig.PoliceConfig.SearchPanelSearchedText
	}

	self:ShowContentIconList(itemList, cfg)
end

function M:SetAdditionalCfg(additionalCfg)
	self.bindData.text1 = additionalCfg.Text1
	self.bindData.text2 = additionalCfg.Text2
end

function M:ShowContentIconList(content, additionalCfg)
	self:SetAdditionalCfg(additionalCfg)
	self:PlayAnim("vx_S_PoliceSearchPanel_Item")

	for _, v in ipairs(content) do
		v.tIndex = 0
	end

	self.iconData = content

	self.bindData.iconList:SetSimpleList(#self.iconData)
end

function M:ShowSearchBodyContent(module, additionalCfg)
	local component = module.Component
	local itemList = {}

	if module.DefaultItems then
		local itemsTable = module.DefaultItems:ToTable()

		for _, itemId in ipairs(itemsTable) do
			local itemConfig = ItemCfg.GetConfig(itemId)
			local check = itemConfig.Type ~= ItemCfg.TypeType.Safe
			local fineId = 0

			if check then
				fineId = gPoliceJobManager.examineMgr:GetFineIdByItemType(itemConfig.Type)
			end

			if itemConfig then
				table.insert(itemList, {
					itemConfig.Name,
					tIndex = 0,
					fineId = fineId,
					check = check
				})
			end
		end
	end

	local suggestion = gPoliceJobManager.examineMgr:GetOptionResSuggestion(LTConfig.PoliceConfig.BodySearch)

	self:ShowContentTextList(itemList, additionalCfg, suggestion)
end

function M:ShowBreathCheckContent(module, additionalCfg)
	local isDrunk = false
	local fineId = 0

	if module.Crimes then
		isDrunk = table.contains(module.Crimes:ToTable(), LTConfig.PoliceFineConfig.DeepDrunk)

		if isDrunk then
			fineId = LTConfig.PoliceFineConfig.DeepDrunk
		else
			isDrunk = table.contains(module.Crimes:ToTable(), LTConfig.PoliceFineConfig.DrunkDrive)

			if isDrunk then
				fineId = LTConfig.PoliceFineConfig.DrunkDrive
			end
		end
	end

	local alcoholValue = module.Alcohol / 100
	local alcoholValueStr = string.format("%.2fmg/ml", alcoholValue)
	local suggestion = gPoliceJobManager.examineMgr:GetOptionResSuggestion(LTConfig.PoliceConfig.AlcoholTest)

	self:ShowContentTextList({
		{
			alcoholValueStr,
			tIndex = 0,
			fineId = LTConfig.PoliceFineConfig.DrunkDrive,
			check = isDrunk
		}
	}, additionalCfg, suggestion)
end

function M:ShowDrugTestContent(module, additionalCfg)
	local drugList = {}

	if module.DefaultDrugs then
		local defaultDrugs = module.DefaultDrugs:ToTable()

		for _, v in ipairs(defaultDrugs) do
			local drugCfg = DrugCfg.GetConfig(v)
			local check = drugCfg.Type ~= DrugCfg.TypeType.Safe
			local fineId = 0

			if check then
				fineId = gPoliceJobManager.examineMgr:GetFineIdByDrugType(drugCfg.Type)
			end

			table.insert(drugList, {
				drugCfg.Name,
				tIndex = 0,
				fineId = fineId,
				check = check
			})
		end
	end

	local suggestion = gPoliceJobManager.examineMgr:GetOptionResSuggestion(LTConfig.PoliceConfig.DrugTest)

	self:ShowContentTextList(drugList, additionalCfg, suggestion)
end

function M:ShowContentTextList(content, additionalCfg, suggestion)
	if #content == 0 then
		table.insert(content, {
			LTConfig.PoliceConfig.SearchResultNormal,
			check = false,
			tIndex = 0
		})
	end

	self:SetAdditionalCfg(additionalCfg)
	self:PlayAnim("vx_S_PoliceSearchPanel_Alc")

	for _, v in ipairs(content) do
		v.tIndex = 0
	end

	self.textData = content

	self.bindData.textList:SetSimpleList(#self.textData)

	self.bindData.suggestCtrl = suggestion and 1 or 0
	self.bindData.suggestText = suggestion and suggestion or ""
end

function M:PlayAnim(name)
	self.anim.enabled = true

	self.anim:Play(name)
	self.anim:SampleCurrentAnimation()
end

function M:OnRenderIconItem(btn, index)
	local data = self.iconData[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.iconId = tonumber(data[1])
	store.text = data[2]
	store.checkCtrl = data.check and 1 or 0
end

function M:OnRenderTextItem(btn, index)
	local data = self.textData[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.text = data[1]
	store.checkCtrl = data.check and 1 or 0
end

function M:OnTextItemClick(btn, index)
	local data = self.textData[index + 1]

	if data.check and data.fineId > 0 then
		gPoliceJobManager.examineMgr:ShowAiDialogByFineId(nil, data.fineId)
	end
end

function M:SetCloseCallback(closeCallback)
	self.closeCallback = closeCallback
end

function M:OnClose()
	if self._animFailWatchdogTimer then
		self._animFailWatchdogTimer:Stop()

		self._animFailWatchdogTimer = nil
	end

	if self.closeCallback then
		self.closeCallback()
	end

	self.textData = nil
	self.iconData = nil
end

function M:Close()
	if self.panelId then
		gPanelManager:Close(self.panelId)

		return
	end

	self:OnClose()
	self.rootWidget:SetActive(false)
end

function M:StartAnimFailWatchdog()
	self._animFailWatchdogTimer = Timer.New(function ()
		if self.STATE_EnableOnce and (not self.bindData.exitButton2.isVisible or self.bindData.exitButton2.renderOpacity < 0.001) then
			self:Close()
		end

		self._animFailWatchdogTimer = nil
	end, 5):Start()
end
