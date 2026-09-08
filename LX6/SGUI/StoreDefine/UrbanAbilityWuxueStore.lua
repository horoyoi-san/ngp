-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityWuxueStore.lua
-- Decompiled from: 01138_UrbanAbilityWuxueStore.lua_a163b7ca23d2.luajit

C_UrbanAbilityWuxueStore = DefClass("C_UrbanAbilityWuxueStore", C_UrbanAbilityWuxueStore, C_StoreGroup)
GroupName2Class.UrbanAbilityWuxueStore = C_UrbanAbilityWuxueStore
local M = C_UrbanAbilityWuxueStore
M.WuXueType = {
	["/\\\\x83\\x8b\\x86U"] = 1,
	["\\xfa\\xd7\r-\\xf2"] = 0,
	["1G\\x95\\x8b\\x91O"] = 2,
	[")F\\x98\\x9f\\x96D"] = 3
}

M.ctor = function(self)
	self.defaultTabListData = {}
	self.modernTabListData = {}
	self.defaultDesListData = {}
	self.modernDesListData = {}
	self.currentCharacterId = nil
	self.currentWuxueType = 0
	self.wuxueType2SkillTypeList = {
		[0] = {},
		{},
		{},
		{}
	}
	self.skillType2FightSkillList = {}
	self.groupSelectedSkills = {}
	self.currentViewingSkill = nil
	self.isSendingRequest = false

	self.InitConfigData(self)
end

M.InitConfigData = function(self)
	for i = 0, LTConfig.FightSkillFightSkillTypeConfig.count - 1 do
		local fightSkillTypeCfg = LTConfig.FightSkillFightSkillTypeConfig.LoadAt(i)

		if fightSkillTypeCfg then
			table.insert(self.wuxueType2SkillTypeList[fightSkillTypeCfg.Type], fightSkillTypeCfg)
		end
	end

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
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityPanelStore")

	self:GenMessageEvents()
	self:RegisterWidget()
end

M.OnEnable = function(self)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.mobileMode = not gCS.LuaUtils.IsNonMobileAdaptive()

	self:InitWuxueTabs()

	self.currentCharacterId = self.urbanAbilityStore:GetCurSpiritTid()

	self:LoadServerFightStyleData()
	self:RefreshWuxueContent()
	self:SelectFirstWuxueItem()
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_CHANGE_SPIRITVIEW_DATA] = self.CreateAction(self, "ChangeSpiriViewData"),
		[gEventConstants.SPIRIT_INFO_CHANGED] = self.CreateAction(self, "OnSpiritInfoChanged")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.ChangeSpiriViewData = function(self, eventId, data)
	if not data.data.alreadyJoin and not data.data.canJoin then
		return
	end

	self.currentCharacterId = data.data.id

	self.LoadServerFightStyleData(self)
	self.RefreshWuxueContent(self)
	self.SelectFirstWuxueItem(self)
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
	self.bindData.defaultTabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderDefaultTabListItem")
	self.bindData.defaultTabList.luaSelectedChanged = self.CreateAction(self, "OnSimpleClickDefaultTabList")
	self.bindData.defaultTabList.onGetTIndex = self.CreateAction(self, "OnGetDefaultTabListTIndex")
	self.bindData.modernTabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderModernTabListItem")
	self.bindData.modernTabList.luaSelectedChanged = self.CreateAction(self, "OnSimpleClickModernTabList")
	self.bindData.modernTabList.onGetTIndex = self.CreateAction(self, "OnGetModernTabListTIndex")
	self.bindData.defaultDesList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderDefaultDesListItem")
	self.bindData.defaultDesList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderDefaultDesListItem")
	self.bindData.defaultDesList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickDefaultDesList")
	self.bindData.defaultDesList.onGetTIndex = self.CreateAction(self, "OnGetDefaultDesListTIndex")
	self.bindData.modernDesList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderModernDesListItem")
	self.bindData.modernDesList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderModernDesListItem")
	self.bindData.modernDesList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickModernDesList")
	self.bindData.modernDesList.onGetTIndex = self.CreateAction(self, "OnGetModernDesListTIndex")
end

M.OnClickSetDefaultBtn = function(self)
	if not self.currentViewingSkill then
		return
	end

	if self.isSendingRequest then
		return
	end

	local skill = self.currentViewingSkill
	local typeId = skill.skillTypeCfg.Id
	local spiritId = self.currentCharacterId

	if not spiritId then
		return
	end

	self.isSendingRequest = true
	slot4 = gClientToGameDelegate

	slot4:AskSwitchFightStyle(spiritId, typeId, skill.id).Callback = function (err, data)
		self.isSendingRequest = false

		if err and err == 0 then
			gDisplayMessageMgr:ShowMessage(err)
		else
			self.groupSelectedSkills[typeId] = skill.id

			for i, data in ipairs(self.defaultTabListData) do
				if data.tIndex == 1 and data.skillTypeCfg and data.skillTypeCfg.Id ~= typeId then
					data.isSelected = data.id ~= skill.id

					self.bindData.defaultTabList:RefreshElement(i - 1)
				end
			end

			gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_UrbanAbilityWuxueTips, {
				fightSkillId = skill.id
			})
			gDisplayMessageMgr:ShowMessageContentDebug(string.format("已将 %s 设为默认武学", skill.name or ""))
		end
	end
end

M.OnSimpleRenderDefaultTabListItem = function(self, btn, index)
	local data = self.defaultTabListData[index + 1]

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

M.OnSimpleClickDefaultTabList = function(self)
	local index = self.bindData.defaultTabList.selectedIndex
	local data = self.defaultTabListData[index + 1]

	if not data or data.tIndex ~= 1 then
		return
	end

	self.currentViewingSkill = data
	self.defaultDesListData = {}

	for i = 1, 8 do
		local textField = data.fightSkillCfg["Text" .. i]

		if textField and textField == "" then
			table.insert(self.defaultDesListData, {
				id = i,
				des = textField
			})
		end
	end

	self.bindData.defaultDesList:SetSimpleList(#self.defaultDesListData)
end

M.OnSimpleRenderModernTabListItem = function(self, btn, index)
	local data = self.modernTabListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.iconId = data.iconId or 0
	end
end

M.OnSimpleClickModernTabList = function(self)
	local index = self.bindData.modernTabList.selectedIndex
	local data = self.modernTabListData[index + 1]

	if not data then
		return
	end

	self.bindData.modernNameText = data.name or ""
	self.modernDesListData = {}

	for i = 1, 8 do
		local textField = data.fightSkillCfg["Text" .. i]

		if textField and textField == "" then
			table.insert(self.modernDesListData, {
				id = i,
				des = textField
			})
		end
	end

	self.bindData.modernDesList:SetSimpleList(#self.modernDesListData)
end

M.OnSimpleRenderDefaultDesListItem = function(self, btn, index)
	local data = self.defaultDesListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local textData = data.des
		local rawText = ""

		if self.mobileMode then
			rawText = textData[1] or ""
		elseif self.gamepadMode then
			rawText = textData[3] or textData[1] or ""
		else
			rawText = textData[2] or textData[1] or ""
		end

		local formattedText = gGuideGlyph:GetRichTextByGuideStr(rawText)
		store.workActionText = formattedText
	end
end

M.OnSimpleClickDefaultDesList = function(self, btn, index)
	local data = self.defaultDesListData[index + 1]

	if data then
		self.OnWuxueDescSelected(self, data, true)
	end
end

M.OnSimpleRenderModernDesListItem = function(self, btn, index)
	local data = self.modernDesListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local textData = data.des
		local rawText = ""

		if self.mobileMode then
			rawText = textData[1] or ""
		elseif self.gamepadMode then
			rawText = textData[3] or textData[1] or ""
		else
			rawText = textData[2] or textData[1] or ""
		end

		local formattedText = gGuideGlyph:GetRichTextByGuideStr(rawText)
		store.workActionText = formattedText
	end
end

M.OnSimpleClickModernDesList = function(self, btn, index)
	local data = self.modernDesListData[index + 1]

	if data then
		self.OnWuxueDescSelected(self, data, false)
	end
end

M.OnWuxueDescSelected = function(self, descData, isDefault)
end

M.InitWuxueTabs = function(self)
	local tabData = {}

	for i = 0, 3 do
		table.insert(tabData, {
			id = i,
			cfgId = i + 1
		})
	end

	if self.SubGroup and self.SubGroup.CommonTabSingleStore then
		slot2 = self.SubGroup.CommonTabSingleStore

		slot2:SetData(tabData, nil, 0, 0, function (uList, isSub)
			self:OnWuxueTabChanged(uList, isSub)
		end, function (btn, index, data, store, isSub, list)
			self:OnRenderWuxueTab(btn, index, data, store, isSub, list)
		end)
	end
end

M.OnWuxueTabChanged = function(self, uList, isSub)
	local selectedIndex = uList.selectedIndex

	if selectedIndex > 0 and selectedIndex >= 4 then
		self.currentWuxueType = selectedIndex

		self.RefreshWuxueContent(self)
		self.SelectFirstWuxueItem(self)
	end
end

M.OnRenderWuxueTab = function(self, btn, index, data, store, isSub, list)
	if data then
		local typeTagCfg = LTConfig.FightSkillTypeTagConfig.GetConfig(data.cfgId)
		store.title = typeTagCfg.TypeTagName
		store.guideID = typeTagCfg.GuideId
	end
end

M.RefreshWuxueContent = function(self)
	self.GetWuxueDataByType(self, self.currentWuxueType, self.currentCharacterId)
	self.UpdateWuxueLists(self)
end

M.GetWuxueDataByType = function(self, wuxueType, characterId)
	local wuxueData = {
		defaultTabs = {},
		modernTabs = {}
	}
	local skillTypeList = self.wuxueType2SkillTypeList[wuxueType] or {}

	for _, skillTypeCfg in ipairs(skillTypeList) do
		local skillTypeId = skillTypeCfg.Id

		if wuxueType == self.WuXueType.Unique or self.IsUniqueWuxueAvailableForCurrentCharacter(self, skillTypeCfg) then
			if skillTypeId == self.WuXueType.Modern then
				table.insert(wuxueData.defaultTabs, {
					["a\\x9f\\x8a\\x86Y"] = 1,
					name = skillTypeCfg.Name
				})
			end

			local fightSkills = self.skillType2FightSkillList[skillTypeId] or {}

			for i, fightSkillCfg in ipairs(fightSkills) do
				if self.IsFightSkillAvailableForCurrentCharacter(self, fightSkillCfg) then
					if not self.groupSelectedSkills[skillTypeId] then
						self.groupSelectedSkills[skillTypeId] = fightSkillCfg.Id
					end

					local skillData = {
						id = fightSkillCfg.Id,
						name = fightSkillCfg.Name or LTConfig.TextScriptTextConfig.GetConfig(89901293).Text,
						description = fightSkillCfg.Desc or "",
						iconId = skillTypeCfg.ImageId or 0,
						skillTypeCfg = skillTypeCfg,
						fightSkillCfg = fightSkillCfg,
						isSelected = self.groupSelectedSkills[skillTypeId] ~= fightSkillCfg.Id
					}

					if wuxueType ~= self.WuXueType.Modern then
						table.insert(wuxueData.modernTabs, skillData)
					else
						table.insert(wuxueData.defaultTabs, skillData)
					end
				end
			end
		end
	end

	self.defaultTabListData = wuxueData.defaultTabs
	self.modernTabListData = wuxueData.modernTabs
end

M.UpdateWuxueLists = function(self)
	self.bindData.defaultTabList:SetSimpleList(#self.defaultTabListData)
	self.bindData.modernTabList:SetSimpleList(#self.modernTabListData)
	self.bindData.defaultDesList:SetSimpleList(#self.defaultDesListData)
	self.bindData.modernDesList:SetSimpleList(#self.modernDesListData)
	self:UpdateVisibility()
end

M.UpdateVisibility = function(self)
	self.bindData.modernCtrl = self.currentWuxueType ~= 2 and 1 or 0
end

M.SelectFirstWuxueItem = function(self)
	if self.currentWuxueType ~= self.WuXueType.Modern then
		if self.modernTabListData and #self.modernTabListData <= 0 then
			self.bindData.modernTabList:SelectItem(0, true)
		else
			self.modernDesListData = {}

			self.bindData.modernDesList:SetSimpleList(0)
		end
	else
		local skillIndex = -1

		if self.defaultTabListData and #self.defaultTabListData <= 0 then
			for i, data in ipairs(self.defaultTabListData) do
				if data.tIndex == 1 and (data.isSelected or skillIndex ~= -1) then
					skillIndex = i - 1

					if data.isSelected then
						break
					end
				end
			end
		end

		if skillIndex > 0 then
			self.bindData.defaultTabList:SelectItem(skillIndex, true)
		else
			self.defaultDesListData = {}

			self.bindData.defaultDesList:SetSimpleList(0)
		end
	end
end

M.IsUniqueWuxueAvailableForCurrentCharacter = function(self, fightSkillCfg)
	if not self.currentCharacterId then
		return false
	end

	if #fightSkillCfg.SpiritId <= 0 then
		for _, spiritId in ipairs(fightSkillCfg.SpiritId) do
			if spiritId ~= self.currentCharacterId then
				return true
			end
		end
	end

	return false
end

M.TrySelectSkill = function(self, skillId)
	if self.currentWuxueType ~= self.WuXueType.Modern then
		for i, data in ipairs(self.modernTabListData) do
			if data.id ~= skillId then
				self.bindData.modernTabList:SelectItem(i - 1, true)

				return
			end
		end
	else
		for i, data in ipairs(self.defaultTabListData) do
			if data.id ~= skillId and data.tIndex == 1 then
				self.bindData.defaultTabList:SelectItem(i - 1, true)

				return
			end
		end
	end
end

M.OnGetDefaultTabListTIndex = function(self, index)
	local data = self.defaultTabListData[index + 1]

	return data and data.tIndex or 0
end

M.OnGetModernTabListTIndex = function(self, index)
	return 0
end

M.OnGetDefaultDesListTIndex = function(self, index)
	return 0
end

M.OnGetModernDesListTIndex = function(self, index)
	return 0
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
	if not self.currentCharacterId then
		return
	end

	self.groupSelectedSkills = {}

	for skillTypeId, _ in pairs(self.skillType2FightSkillList) do
		local styleId = gCS.FightStyleManager.Instance:GetFightStyleByTemplateAndFightStyleCat(self.currentCharacterId, skillTypeId)

		if styleId and styleId <= 0 then
			self.groupSelectedSkills[skillTypeId] = styleId
		end
	end
end
