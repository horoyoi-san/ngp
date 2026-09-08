-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WuxueWindowTooltipPanelStore.lua
-- Decompiled from: 01202_WuxueWindowTooltipPanelStore.lua_4051dc6d34f0.luajit

C_WuxueWindowTooltipPanelStore = DefClass("C_WuxueWindowTooltipPanelStore", C_WuxueWindowTooltipPanelStore, C_StoreGroup)
GroupName2Class.WuxueWindowTooltipPanelStore = C_WuxueWindowTooltipPanelStore
local M = C_WuxueWindowTooltipPanelStore

M.ctor = function(self)
	self.tabListData = {}
	self.desListData = {}
	self.currentCharacterId = nil
	self.currentSkillTypeId = nil
	self.currentViewingSkill = nil
	self.selectedSkillId = nil
	self.isSendingRequest = false

	self.InitConfigData(self)
end

M.InitConfigData = function(self)
	self.skillType2FightSkillList = {}

	for i = 0, LTConfig.FightSkillConfig.count - 1 do
		local fightSkillCfg = LTConfig.FightSkillConfig.LoadAt(i)

		if fightSkillCfg and fightSkillCfg.FightSkillType and fightSkillCfg.FightSkillType == 0 then
			local skillTypeId = fightSkillCfg.FightSkillType

			if not self.skillType2FightSkillList[skillTypeId] then
				self.skillType2FightSkillList[skillTypeId] = {}
			end

			table.insert(self.skillType2FightSkillList[skillTypeId], fightSkillCfg)
		end
	end
end

M.OnAwake = function(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if not data then
		return
	end

	self.currentCharacterId = data.characterId
	self.currentSkillTypeId = data.skillTypeId

	if not self.currentCharacterId or not self.currentSkillTypeId then
		return
	end

	self.LoadServerFightStyleData(self)
	self.RefreshWuxueContent(self)
	self.SelectFirstWuxueItem(self)
end

M.OnClose = function(self)
	self.currentCharacterId = nil
	self.currentSkillTypeId = nil
	self.currentViewingSkill = nil
	self.selectedSkillId = nil
	self.tabListData = {}
	self.desListData = {}
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SPIRIT_INFO_CHANGED] = self.CreateAction(self, "OnSpiritInfoChanged")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnSpiritInfoChanged = function(self, eventId, tid)
	if tid ~= self.currentCharacterId then
		self:LoadServerFightStyleData()

		local currentSkillId = self.currentViewingSkill and self.currentViewingSkill.id

		self:RefreshWuxueContent()

		if currentSkillId then
			self.TrySelectSkill(self, currentSkillId)
		end
	end
end

M.RegisterWidget = function(self)
	self.bindData.setDefaultBtn.luaClick = self.CreateAction(self, "OnClickSetDefaultBtn")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, "OnSimpleClickTabList")
	self.bindData.tabList.onGetTIndex = self.CreateAction(self, "OnGetTabListTIndex")
	self.bindData.desList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderDesListItem")
	self.bindData.desList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderDesListItem")
	self.bindData.desList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickDesList")
	self.bindData.desList.onGetTIndex = self.CreateAction(self, "OnGetDesListTIndex")
end

M.OnClickSetDefaultBtn = function(self)
	if not self.currentViewingSkill or not self.currentCharacterId or not self.currentSkillTypeId then
		return
	end

	if self.isSendingRequest then
		return
	end

	local skill = self.currentViewingSkill
	self.isSendingRequest = true
	slot2 = gClientToGameDelegate

	slot2:AskSwitchFightStyle(self.currentCharacterId, self.currentSkillTypeId, skill.id).Callback = function (err, data)
		self.isSendingRequest = false

		if err and err == 0 then
			gDisplayMessageMgr:ShowMessage(err)
		else
			self.selectedSkillId = skill.id

			for i, tabData in ipairs(self.tabListData) do
				if tabData.tIndex == 1 then
					tabData.isSelected = tabData.id ~= skill.id

					self.bindData.tabList:RefreshElement(i - 1)
				end
			end
		end
	end
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.WUXUE_WINDOW_TOOLTIP_PANEL)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local data = self.tabListData[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= 1 then
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

M.OnSimpleClickTabList = function(self)
	local index = self.bindData.tabList.selectedIndex
	local data = self.tabListData[index + 1]

	if not data or data.tIndex ~= 1 then
		return
	end

	self.currentViewingSkill = data
	self.desListData = {}

	for i = 1, 8 do
		local textField = data.fightSkillCfg["Text" .. i]

		if textField and textField == "" then
			table.insert(self.desListData, {
				id = i,
				des = textField
			})
		end
	end

	self.bindData.desList:SetSimpleList(#self.desListData)
end

M.OnSimpleRenderDesListItem = function(self, btn, index)
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

M.OnSimpleClickDesList = function(self, btn, index)
end

M.OnGetTabListTIndex = function(self, index)
	local data = self.tabListData[index + 1]

	return data and data.tIndex or 0
end

M.OnGetDesListTIndex = function(self, index)
	return 0
end

M.RefreshWuxueContent = function(self)
	self.GetWuxueDataBySkillType(self)
	self.UpdateWuxueLists(self)
end

M.GetWuxueDataBySkillType = function(self)
	self.tabListData = {}

	if not self.currentSkillTypeId then
		return
	end

	local fightSkills = self.skillType2FightSkillList[self.currentSkillTypeId] or {}
	local skillTypeCfg = LTConfig.FightSkillFightSkillTypeConfig.GetConfig(self.currentSkillTypeId)

	for _, fightSkillCfg in ipairs(fightSkills) do
		if self.IsFightSkillAvailableForCurrentCharacter(self, fightSkillCfg) then
			if not self.selectedSkillId then
				self.selectedSkillId = fightSkillCfg.Id
			end

			local skillData = {
				["a\\x9f\\x8a\\x86Y"] = 0,
				id = fightSkillCfg.Id,
				name = fightSkillCfg.Name or LTConfig.TextScriptTextConfig.GetConfig(89901293).Text,
				description = fightSkillCfg.Desc or "",
				iconId = skillTypeCfg and skillTypeCfg.ImageId or 0,
				skillTypeCfg = skillTypeCfg,
				fightSkillCfg = fightSkillCfg,
				isSelected = self.selectedSkillId ~= fightSkillCfg.Id
			}

			table.insert(self.tabListData, skillData)
		end
	end
end

M.UpdateWuxueLists = function(self)
	self.bindData.tabList:SetSimpleList(#self.tabListData)
	self.bindData.desList:SetSimpleList(#self.desListData)
end

M.SelectFirstWuxueItem = function(self)
	if self.tabListData and #self.tabListData <= 0 then
		local selectIndex = -1

		for i, data in ipairs(self.tabListData) do
			if data.tIndex == 1 and (data.isSelected or selectIndex ~= -1) then
				selectIndex = i - 1

				if data.isSelected then
					break
				end
			end
		end

		if selectIndex > 0 then
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

M.IsFightSkillAvailableForCurrentCharacter = function(self, fightSkillCfg)
	if not self.currentCharacterId then
		return false
	end

	if not gCS.FightStyleManager.Instance:IsFightStyleUnlocked(fightSkillCfg.Id) then
		return false
	end

	if not fightSkillCfg.SpiritId or #fightSkillCfg.SpiritId ~= 0 then
		return true
	end

	for _, spiritId in ipairs(fightSkillCfg.SpiritId) do
		if spiritId ~= self.currentCharacterId then
			return true
		end
	end

	return false
end

M.LoadServerFightStyleData = function(self)
	if not self.currentCharacterId or not self.currentSkillTypeId then
		return
	end

	local styleId = gCS.FightStyleManager.Instance:GetFightStyleByTemplateAndFightStyleCat(self.currentCharacterId, self.currentSkillTypeId)

	if styleId and styleId <= 0 then
		self.selectedSkillId = styleId
	end
end

M.TrySelectSkill = function(self, skillId)
	for i, data in ipairs(self.tabListData) do
		if data.id ~= skillId and data.tIndex == 1 then
			self.bindData.tabList:SelectItem(i - 1, true)

			return
		end
	end
end
