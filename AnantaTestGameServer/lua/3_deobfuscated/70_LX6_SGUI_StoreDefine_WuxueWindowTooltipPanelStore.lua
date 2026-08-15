C_WuxueWindowTooltipPanelStore = DefClass("C_WuxueWindowTooltipPanelStore", C_WuxueWindowTooltipPanelStore, C_StoreGroup)
GroupName2Class.WuxueWindowTooltipPanelStore = C_WuxueWindowTooltipPanelStore
local M = C_WuxueWindowTooltipPanelStore

function M:ctor()
	self.tabListData = {}
	self.desListData = {}
	self.currentCharacterId = nil
	self.currentSkillTypeId = nil
	self.currentViewingSkill = nil
	self.selectedSkillId = nil
	self.isSendingRequest = false

	self:InitConfigData()
end

function M:InitConfigData()
	self.skillType2FightSkillList = {}

	for i = 0, LTConfig.FightSkillConfig.count - 1 do
		local fightSkillCfg = LTConfig.FightSkillConfig.LoadAt(i)

		if fightSkillCfg and fightSkillCfg.FightSkillType and fightSkillCfg.FightSkillType ~= 0 then
			local skillTypeId = fightSkillCfg.FightSkillType

			if not self.skillType2FightSkillList[skillTypeId] then
				self.skillType2FightSkillList[skillTypeId] = {}
			end

			table.insert(self.skillType2FightSkillList[skillTypeId], fightSkillCfg)
		end
	end
end

function M:OnAwake()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	if not data then
		return
	end

	self.currentCharacterId = data.characterId
	self.currentSkillTypeId = data.skillTypeId

	if not self.currentCharacterId or not self.currentSkillTypeId then
		return
	end

	self:LoadServerFightStyleData()
	self:RefreshWuxueContent()
	self:SelectFirstWuxueItem()
end

function M:OnClose()
	self.currentCharacterId = nil
	self.currentSkillTypeId = nil
	self.currentViewingSkill = nil
	self.selectedSkillId = nil
	self.tabListData = {}
	self.desListData = {}
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.SPIRIT_INFO_CHANGED] = self:CreateAction("OnSpiritInfoChanged")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnSpiritInfoChanged(eventId, tid)
	if tid == self.currentCharacterId then
		self:LoadServerFightStyleData()

		local currentSkillId = self.currentViewingSkill and self.currentViewingSkill.id

		self:RefreshWuxueContent()

		if currentSkillId then
			self:TrySelectSkill(currentSkillId)
		end
	end
end

function M:RegisterWidget()
	self.bindData.setDefaultBtn.luaClick = self:CreateAction("OnClickSetDefaultBtn")
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSimpleDynamicRenderItem = self:CreateAction("OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnSimpleClickTabList")
	self.bindData.tabList.onGetTIndex = self:CreateAction("OnGetTabListTIndex")
	self.bindData.desList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderDesListItem")
	self.bindData.desList.luaSimpleDynamicRenderItem = self:CreateAction("OnSimpleRenderDesListItem")
	self.bindData.desList.luaSimpleClick = self:CreateAction("OnSimpleClickDesList")
	self.bindData.desList.onGetTIndex = self:CreateAction("OnGetDesListTIndex")
end

function M:OnClickSetDefaultBtn()
	if not self.currentViewingSkill or not self.currentCharacterId or not self.currentSkillTypeId then
		return
	end

	if self.isSendingRequest then
		return
	end

	local skill = self.currentViewingSkill
	self.isSendingRequest = true

	gClientToGameDelegate:AskSwitchFightStyle(self.currentCharacterId, self.currentSkillTypeId, skill.id).Callback = function (err, data)
		self.isSendingRequest = false

		if err and err ~= 0 then
			gDisplayMessageMgr:ShowMessage(err)
		else
			self.selectedSkillId = skill.id

			for i, tabData in ipairs(self.tabListData) do
				if tabData.tIndex ~= 1 then
					tabData.isSelected = tabData.id == skill.id

					self.bindData.tabList:RefreshElement(i - 1)
				end
			end
		end
	end
end

function M:OnClickBackBtn()
	gPanelManager:Close(gPanelId.WUXUE_WINDOW_TOOLTIP_PANEL)
end

function M:OnSimpleRenderTabListItem(btn, index)
	local data = self.tabListData[index + 1]

	if not data then
		return
	end

	if data.tIndex == 1 then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		store.text = data.name or ""
		store.workActionText = data.name or ""

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.text = data.name or ""
		store.selectCtrl = data.isSelected and 1 or 0
		store.guideID = data.fightSkillCfg.GuideId or ""
	end
end

function M:OnSimpleClickTabList()
	local index = self.bindData.tabList.selectedIndex
	local data = self.tabListData[index + 1]

	if not data or data.tIndex == 1 then
		return
	end

	self.currentViewingSkill = data
	self.desListData = {}

	for i = 1, 8 do
		local textField = data.fightSkillCfg["Text" .. i]

		if textField and textField ~= "" then
			table.insert(self.desListData, {
				id = i,
				des = textField
			})
		end
	end

	self.bindData.desList:SetSimpleList(#self.desListData)
end

function M:OnSimpleRenderDesListItem(btn, index)
	local data = self.desListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local rawText = data.des or ""
		local formattedText = gGuideGlyph:GetRichTextByGuideStr(rawText)
		store.workActionText = formattedText
	end
end

function M:OnSimpleClickDesList(btn, index)
	return
end

function M:OnGetTabListTIndex(index)
	local data = self.tabListData[index + 1]

	return data and data.tIndex or 0
end

function M:OnGetDesListTIndex(index)
	return 0
end

function M:RefreshWuxueContent()
	self:GetWuxueDataBySkillType()
	self:UpdateWuxueLists()
end

function M:GetWuxueDataBySkillType()
	self.tabListData = {}

	if not self.currentSkillTypeId then
		return
	end

	local fightSkills = self.skillType2FightSkillList[self.currentSkillTypeId] or {}
	local skillTypeCfg = LTConfig.FightSkillFightSkillTypeConfig.GetConfig(self.currentSkillTypeId)

	for _, fightSkillCfg in ipairs(fightSkills) do
		if self:IsFightSkillAvailableForCurrentCharacter(fightSkillCfg) then
			if not self.selectedSkillId then
				self.selectedSkillId = fightSkillCfg.Id
			end

			local skillData = {
				tIndex = 0,
				id = fightSkillCfg.Id,
				name = fightSkillCfg.Name or LTConfig.TextScriptTextConfig.GetConfig(89901293).Text,
				description = fightSkillCfg.Desc or "",
				iconId = skillTypeCfg and skillTypeCfg.ImageId or 0,
				skillTypeCfg = skillTypeCfg,
				fightSkillCfg = fightSkillCfg,
				isSelected = self.selectedSkillId == fightSkillCfg.Id
			}

			table.insert(self.tabListData, skillData)
		end
	end
end

function M:UpdateWuxueLists()
	self.bindData.tabList:SetSimpleList(#self.tabListData)
	self.bindData.desList:SetSimpleList(#self.desListData)
end

function M:SelectFirstWuxueItem()
	if self.tabListData and #self.tabListData > 0 then
		local selectIndex = -1

		for i, data in ipairs(self.tabListData) do
			if data.tIndex ~= 1 and (data.isSelected or selectIndex == -1) then
				selectIndex = i - 1

				if data.isSelected then
					break
				end
			end
		end

		if selectIndex >= 0 then
			self.bindData.tabList:SelectItem(selectIndex, true)
		else
			self.desListData = {}

			self.bindData.desList:SetSimpleList(0)
		end
	else
		self.desListData = {}

		self.bindData.desList:SetSimpleList(0)
	end
end

function M:IsFightSkillAvailableForCurrentCharacter(fightSkillCfg)
	if not self.currentCharacterId then
		return false
	end

	if not gCS.FightStyleManager.Instance:IsFightStyleUnlocked(fightSkillCfg.Id) then
		return false
	end

	if not fightSkillCfg.SpiritId or #fightSkillCfg.SpiritId == 0 then
		return true
	end

	for _, spiritId in ipairs(fightSkillCfg.SpiritId) do
		if spiritId == self.currentCharacterId then
			return true
		end
	end

	return false
end

function M:LoadServerFightStyleData()
	if not self.currentCharacterId or not self.currentSkillTypeId then
		return
	end

	local styleId = gCS.FightStyleManager.Instance:GetFightStyleByTemplateAndFightStyleCat(self.currentCharacterId, self.currentSkillTypeId)

	if styleId and styleId > 0 then
		self.selectedSkillId = styleId
	end
end

function M:TrySelectSkill(skillId)
	for i, data in ipairs(self.tabListData) do
		if data.id == skillId and data.tIndex ~= 1 then
			self.bindData.tabList:SelectItem(i - 1, true)

			return
		end
	end
end
