-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCNewPersonalityStore.lua
-- Decompiled from: 00951_OCNewPersonalityStore.lua_494fdb4c09ef.luajit

C_OCNewPersonalityStore = DefClass("C_OCNewPersonalityStore", C_OCNewPersonalityStore, C_StoreGroup)
GroupName2Class.OCNewPersonalityStore = C_OCNewPersonalityStore
local M = C_OCNewPersonalityStore
local OCConfig = LTConfig.OriginalCharacterConfig
local MBTIConfig = LTConfig.OriginalCharacterMBTIConfig
local PersonalityLabelConfig = LTConfig.OriginalCharacterPersonalityLabelConfig

M.ctor = function(self)
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
	self.currentTab = 0
	self.displayStore = nil
	self.selectedOptionIndex = -1
	self.listData = nil
	self.curMBTI = nil
	self.tooltipData = nil
	self.currentTooltipBtn = nil
	self.tabCtrlEnum = {
		["3/2\\xf7|\\x96\\xf68\\xa1;\\xff\\xdf\\xe7}\\xf5"] = 0,
		["\\xe6M?\\xde\\xbaH\\xb5O\\x91\\xbf"] = 1
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.mBTICtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.mBTICtrlEnum = nil
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
	self.tabCtrlEnum = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.currentTab = self.tabCtrlEnum.personalityMain
	self.bindData.tabRect.selectedIndex = self.currentTab
	self.curMBTI = self.mgr.MBTIId

	self.RefreshInput(self)
	self.RefreshOptionList(self)
end

M.OnClose = function(self)
	self.listData = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.OC_DATA_REFRESH] = self.CreateAction(self, "RefreshInput"),
		[gEventConstants.ON_OC_MBTI_CHANGE] = self.CreateAction(self, "RefreshMBTI")
	}
end

M.RegisterWidget = function(self)
	self.bindData.input.luaValueChanged = self.CreateAction(self, self.OnInputInputValueChanged)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnTabRectRender)
	self.bindData.freeList.onGetTIndex = self.CreateAction(self, self.OnFreeListGetTIndex)
	self.bindData.freeList.luaRenderItem = self.CreateAction(self, self.OnRenderOptionItem)
	self.bindData.freeList.luaClick = self.CreateAction(self, self.OnClickOptionItem)
end

M.OnInputInputValueChanged = function(self, text)
end

M.RefreshInput = function(self)
	self.bindData.input.text = self.mgr.personalityAndStory and self.mgr.personalityAndStory.desc or ""
end

M.OnTabRectRender = function(self, index, widget)
	self.currentTab = index
	local store = gStoreManager:GetStoreGroup(widget.Store)

	self:ShowStore(store)
end

M.ShowStore = function(self, store)
	if self.displayStore then
		self.displayStore:OnClose()
	end

	if store then
		store.parentStore = self

		store.OnShow(store, self.m_Id, self.showData)

		self.displayStore = store
	end
end

M.RefreshOptionList = function(self)
	local options = OCConfig.PersonalityMainOptions
	local labels = self.mgr.personalityAndStory and self.mgr.personalityAndStory.labels or {}
	local labelCount = #labels
	local labelSlotIndex = 0
	self.listData = {}

	for i = 1, #options do
		local opt = options[i]

		if opt.tIndex ~= 2 then
			labelSlotIndex = labelSlotIndex + 1

			if labelCount > labelSlotIndex then
				table.insert(self.listData, {
					["\\xd0\\xc810\\xe8"] = false,
					["a\\x9f\\x8a\\x86Y"] = 2,
					x = opt.x,
					y = opt.y,
					label = labels[labelSlotIndex],
					labelIndex = labelSlotIndex
				})
			elseif labelSlotIndex ~= labelCount + 1 and labelCount >= 3 then
				table.insert(self.listData, {
					["\\xd0\\xc810\\xe8"] = true,
					["a\\x9f\\x8a\\x86Y"] = 2,
					x = opt.x,
					y = opt.y
				})
			end
		else
			table.insert(self.listData, {
				tIndex = opt.tIndex,
				x = opt.x,
				y = opt.y
			})
		end
	end

	self.bindData.freeList:SetList(#self.listData)
end

M.OnClickCloseLabelBtn = function(self, labelIndex)
	local labels = self.mgr.personalityAndStory and self.mgr.personalityAndStory.labels

	if not labels then
		return
	end

	table.remove(labels, labelIndex)
	self.RefreshOptionList(self)
end

M.OnFreeListGetTIndex = function(self, index)
	local data = self.listData and self.listData[index + 1]

	return data and data.tIndex or 0
end

M.OnRenderOptionItem = function(self, widget, index)
	local data = self.listData and self.listData[index + 1]

	if not data then
		return
	end

	widget:SetLocalPos(Vector3.New(data.x, data.y, 0))

	local isSelected = index ~= self.selectedOptionIndex

	if data.tIndex ~= 0 then
		local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

		if not store then
			return
		end

		if self.curMBTI then
			local mbtiInfo = MBTIConfig.GetConfig(self.curMBTI)

			if mbtiInfo then
				store.text = mbtiInfo.MBTI
				store.icon = mbtiInfo.Image
			end
		else
			store.text = ""
			store.icon = 0
		end

		if widget.SetSelected then
			widget.SetSelected(widget, isSelected)
		elseif store.isSelected == nil then
			store.isSelected = isSelected and 1 or 0
		end
	elseif data.tIndex ~= 1 then
		local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

		if not store then
			return
		end

		store.isAICtrl = 1
	elseif data.tIndex ~= 2 then
		local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

		if not store then
			return
		end

		if data.isEmpty then
			store.emptyCtrl = 0
		else
			store.emptyCtrl = 1
			store.text = data.label or ""
			store.colorCtrl = data.labelIndex

			if store.closeBtn then
				store.closeBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickCloseLabelBtn, data.labelIndex)
			end
		end

		if widget.SetSelected then
			widget.SetSelected(widget, isSelected)
		elseif store.isSelected == nil then
			store.isSelected = isSelected and 1 or 0
		end

		widget.luaRenderTooltip = self.CreateAction(self, self.OnRenderPersonalityTagTooltip)

		if data.isEmpty then
			widget.SetEnabledTooltip(widget, true)
		else
			widget.SetEnabledTooltip(widget, false)
		end
	end
end

M.OnClickOptionItem = function(self, widget, index)
	self.selectedOptionIndex = index
	local data = self.listData and self.listData[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= 0 then
		self.OnClickMBTIBtn(self)
	elseif data.tIndex ~= 1 then
		self.bindData.tabRect.selectedIndex = self.tabCtrlEnum.personalityAi
	end
end

M.OnClickMBTIBtn = function(self)
	if self.bindData.mBTICtrl == 1 then
		self.bindData.mBTICtrl = 1

		self.SubGroup.OCMBTIPanelStore:OnShow()
	end
end

M.RefreshMBTI = function(self)
	self.curMBTI = self.mgr.MBTIId
	self.bindData.mBTICtrl = 0

	self.RefreshOptionList(self)
end

M.OnRenderPersonalityTagTooltip = function(self, btn, widget)
	local store = gStoreManager:GetStoreGroup("OCTabWindowListTemplate"):GetStoreByWidget(widget)

	if not store then
		return
	end

	self.currentTooltipBtn = btn
	local currentLabels = self.mgr.personalityAndStory.labels or {}
	local idToLabelName = {}
	local allConfigs = {}

	for i = 0, PersonalityLabelConfig.count - 1 do
		local cfg = PersonalityLabelConfig.LoadAt(i)

		if cfg then
			table.insert(allConfigs, cfg)

			idToLabelName[cfg.Id] = cfg.Labels
		end
	end

	local labelRepelsMap = {}

	for _, cfg in ipairs(allConfigs) do
		if cfg.ConflictLabel then
			for _, conflictId in pairs(cfg.ConflictLabel) do
				local conflictName = idToLabelName[conflictId]

				if conflictName then
					if not labelRepelsMap[cfg.Labels] then
						labelRepelsMap[cfg.Labels] = {}
					end

					labelRepelsMap[cfg.Labels][conflictName] = true
				end
			end
		end
	end

	local ownedRepels = {}

	for _, myLabelName in ipairs(currentLabels) do
		local repels = labelRepelsMap[myLabelName]

		if repels then
			for targetName, _ in pairs(repels) do
				ownedRepels[targetName] = true
			end
		end
	end

	local validItems = {}

	for _, config in ipairs(allConfigs) do
		local labelName = config.Labels
		local isHidden = false

		for _, curName in ipairs(currentLabels) do
			if curName ~= labelName then
				isHidden = true

				break
			end
		end

		if not isHidden and ownedRepels[labelName] then
			isHidden = true
		end

		if not isHidden then
			local myConflicts = labelRepelsMap[labelName]

			if myConflicts then
				for _, curName in ipairs(currentLabels) do
					if myConflicts[curName] then
						isHidden = true

						break
					end
				end
			end
		end

		if not isHidden then
			table.insert(validItems, config)
		end
	end

	self.tooltipData = validItems
	store.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderPersonalityTagTooltipItem)
	slot10 = store.list

	slot10:SetSimpleList(#validItems)

	store.input.luaEndEdit = function(text, enter)
		if enter then
			self:OnEndEditPersonalityTagTooltip(store.input)
		end
	end
end

M.OnRenderPersonalityTagTooltipItem = function(self, btn, index)
	local data = self.tooltipData and self.tooltipData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.delCtrl = 1
		store.text = data.Labels
		btn.luaClick = self.CreateActionWithArgs(self, self.OnClickAddPersonalityTagFromTooltip, data.Labels)
	end
end

M.OnClickAddPersonalityTagFromTooltip = function(self, label)
	if not label then
		return
	end

	local labels = self.mgr.personalityAndStory.labels

	if not labels then
		self.mgr.personalityAndStory.labels = {}
		labels = self.mgr.personalityAndStory.labels
	end

	if #labels > 3 then
		return
	end

	self.mgr:AddPersonalityLabel(label)

	if self.currentTooltipBtn then
		self.currentTooltipBtn:CloseTooltip()
	end

	self.RefreshOptionList(self)
end

M.OnEndEditPersonalityTagTooltip = function(self, input)
	if not input or string.is_null_or_empty(input.text) then
		return
	end

	local labels = self.mgr.personalityAndStory.labels

	if not labels then
		self.mgr.personalityAndStory.labels = {}
		labels = self.mgr.personalityAndStory.labels
	end

	if #labels > 3 then
		return
	end

	self.mgr:AddPersonalityLabel(input.text)

	if self.currentTooltipBtn then
		self.currentTooltipBtn:CloseTooltip()
	end

	self.RefreshOptionList(self)
end
