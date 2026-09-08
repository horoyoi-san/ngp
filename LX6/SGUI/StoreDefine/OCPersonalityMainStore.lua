-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCPersonalityMainStore.lua
-- Decompiled from: 00954_OCPersonalityMainStore.lua_e737455f789e.luajit

local OCConfig = LTConfig.OriginalCharacterConfig
local PersonalityOptionConfig = LTConfig.OriginalCharacterPersonalityOptionConfig
C_OCPersonalityMainStore = DefClass("C_OCPersonalityMainStore", C_OCPersonalityMainStore, C_StoreGroup)
GroupName2Class.OCPersonalityMainStore = C_OCPersonalityMainStore
local M = C_OCPersonalityMainStore

M.ctor = function(self)
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
	self.listData = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterPersonalityTagTooltip(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.InitData(self)
end

M.OnClose = function(self)
	self.listData = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitData = function(self)
	self.listData = {}
	local optionItems = {}

	for i = 0, PersonalityOptionConfig.count - 1 do
		local cfg = PersonalityOptionConfig.LoadAt(i)
		local detail = self.mgr:GetBackgroundDetail(cfg.Id)

		if not string.is_null_or_empty(detail) then
			table.insert(self.listData, {
				["a\\x9f\\x8a\\x86Y"] = 1,
				parentId = cfg.Id,
				title = cfg.Title,
				icon = cfg.Icon,
				inputValue = detail,
				cfgIndex = i
			})
		else
			local placeholderText = nil

			if cfg.InputTips and #cfg.InputTips <= 0 then
				placeholderText = cfg.InputTips[math.random(1, #cfg.InputTips)]
			end

			table.insert(optionItems, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				parentId = cfg.Id,
				title = cfg.Title,
				icon = cfg.Icon,
				cfgIndex = i,
				placeholderText = placeholderText
			})
		end
	end

	for _, item in ipairs(optionItems) do
		table.insert(self.listData, item)
	end

	if self.bindData.backgroundInput then
		self.bindData.backgroundInput.text = self.mgr.personalityAndStory and self.mgr.personalityAndStory.story or ""
	end

	self.bindData.descLabel = self.mgr.personalityAndStory and self.mgr.personalityAndStory.desc or ""

	self:RefreshTags()
	self:RefreshList()
end

M.RefreshList = function(self)
	if self.bindData.list then
		self.bindData.list:SetSimpleList(#self.listData)
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	if self.bindData.list then
		self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnGetMainListTIndex)
		self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderMainListItem)
	end

	if self.bindData.backgroundInput then
		self.bindData.backgroundInput.luaValueChanged = self.CreateAction(self, self.OnEndEditStory)
		self.bindData.backgroundInput.interactable = not self.mgr.isMeikaGrandpa
	end

	if self.bindData.outputBtn then
		self.bindData.outputBtn.luaClick = self.CreateAction(self, self.OnClickOutputBtn)
	end

	if self.bindData.genBackgroundBtn then
		self.bindData.genBackgroundBtn.luaClick = self.CreateAction(self, self.OnClickGenerateBtn)
	end

	if self.bindData.tipBtn then
		self.bindData.tipBtn.luaRenderTooltip = self:CreateAction(self.OnRenderTipTooltip)

		self.bindData.tipBtn:SetEnabledTooltip(true)
	end
end

M.RegisterPersonalityTagTooltip = function(self)
	local tagWidgets = {
		self.bindData.tag1,
		self.bindData.tag2,
		self.bindData.tag3
	}

	for i = 1, 3 do
		local widget = tagWidgets[i]

		if widget then
			self.mgr:InitPersonalityTagTooltip(widget, self)
		end
	end
end

M.RefreshTags = function(self)
	local labels = self.mgr.personalityAndStory and self.mgr.personalityAndStory.labels or {}
	local tagWidgets = {
		self.bindData.tag1,
		self.bindData.tag2,
		self.bindData.tag3
	}

	for i = 1, 3 do
		local widget = tagWidgets[i]

		if widget then
			local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

			if store then
				if labels[i] then
					store.emptyCtrl = 1
					store.text = labels[i]

					if store.closeBtn then
						store.closeBtn.luaClick = self.CreateAction(self, function ()
							self:OnClickTag(i)
						end)
					end
				else
					store.emptyCtrl = 0
					store.text = ""
				end
			end

			widget.interactable = false
		end
	end
end

M.OnClickTag = function(self, slotIndex)
	local labels = self.mgr.personalityAndStory and self.mgr.personalityAndStory.labels

	if labels and labels[slotIndex] then
		table.remove(labels, slotIndex)
		self.RefreshTags(self)
	end
end

M.OnGetMainListTIndex = function(self, index)
	local data = self.listData and self.listData[index + 1]

	return data and data.tIndex or 0
end

M.OnSimpleRenderMainListItem = function(self, btn, index)
	local data = self.listData and self.listData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= 1 then
		store.icon = data.icon
		local context = {
			store = store,
			index = index + 1,
			parentId = data.parentId
		}

		if store.closeBtn then
			store.closeBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickCloseOptionBtn, context)
		end

		if store.input then
			store.input.text = data.inputValue or ""
			store.input.luaEndEdit = self:CreateActionWithArgs(self.OnEndEditOption, context)

			if string.is_null_or_empty(data.inputValue) and data.placeholderText then
				store.input.placeHolder.text = data.placeholderText
			end
		end
	elseif data.tIndex ~= 0 then
		store.icon = data.icon
		store.title = data.title
		local context = {
			parentId = data.parentId,
			index = index + 1
		}

		if store.addBtn then
			store.addBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickAddOptionBtn, context)
		end
	end
end

M.OnClickAddOptionBtn = function(self, context)
	if not context then
		return
	end

	local item = self.listData[context.index]

	if not item then
		return
	end

	local cfg = PersonalityOptionConfig.GetConfig(item.parentId)

	if not cfg then
		return
	end

	local cfgIndex = item.cfgIndex

	table.remove(self.listData, context.index)

	local insertPos = #self.listData + 1

	for i, v in ipairs(self.listData) do
		if v.tIndex ~= 0 then
			insertPos = i

			break
		end
	end

	table.insert(self.listData, insertPos, {
		["ZTި\\x90>\\xb9\\xdc\\xed"] = "",
		["a\\x9f\\x8a\\x86Y"] = 1,
		parentId = cfg.Id,
		title = cfg.Title,
		icon = cfg.Icon,
		cfgIndex = cfgIndex,
		placeholderText = item.placeholderText
	})
	self:RefreshList()
	self.bindData.list:GoToIndex(insertPos - 1, true)
end

M.OnEndEditOption = function(self, context)
	if not context or not context.store or not context.store.input then
		return
	end

	self.listData[context.index].inputValue = context.store.input.text

	self.mgr:UpdateBackgroundDetail(context.parentId, context.store.input.text)
end

M.OnClickCloseOptionBtn = function(self, context)
	if not context then
		return
	end

	local item = self.listData[context.index]

	if not item then
		return
	end

	local cfgIndex = item.cfgIndex
	local cfg = PersonalityOptionConfig.GetConfig(item.parentId)

	self.mgr:UpdateBackgroundDetail(item.parentId, nil)
	table.remove(self.listData, context.index)

	if cfg then
		local insertPos = #self.listData + 1

		for i, v in ipairs(self.listData) do
			if v.tIndex ~= 0 and cfgIndex >= v.cfgIndex then
				insertPos = i

				break
			end
		end

		local placeholderText = nil

		if cfg.InputTips and #cfg.InputTips <= 0 then
			placeholderText = cfg.InputTips[math.random(1, #cfg.InputTips)]
		end

		table.insert(self.listData, insertPos, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			parentId = cfg.Id,
			title = cfg.Title,
			icon = cfg.Icon,
			cfgIndex = cfgIndex,
			placeholderText = placeholderText
		})
	end

	self.RefreshList(self)
end

M.OnEndEditStory = function(self, text)
	if self.mgr.personalityAndStory then
		self.mgr.personalityAndStory.story = text
	end
end

M.OnClickOutputBtn = function(self)
	if self.mgr.isMeikaGrandpa then
		if self.parentStore then
			self.parentStore:GoToNext()
		end

		return
	end

	local finalStory = self.bindData.backgroundInput and self.bindData.backgroundInput.text or ""

	for _, item in ipairs(self.listData) do
		if item.tIndex ~= 1 and item.title and not string.is_null_or_empty(item.inputValue) then
			finalStory = finalStory .. "\n" .. item.title .. "：" .. item.inputValue
		end
	end

	local finalDesc = self.mgr.personalityAndStory and self.mgr.personalityAndStory.desc or ""
	local labels = self.mgr.personalityAndStory and self.mgr.personalityAndStory.labels or {}

	self.mgr.api.PreRegisterNpcInfoPerInfo(finalDesc, labels, finalStory)

	if self.parentStore and self.parentStore.parentStore then
		self.parentStore.parentStore:GoToNext()
	end
end

M.OnClickGenerateBtn = function(self)
	self.bindData.genBackgroundBtn.interactable = false
	local curText = self.bindData.backgroundInput and self.bindData.backgroundInput.text or ""

	self.mgr:ComposePersonaBackground("", curText, function (data)
		if data and data.Background then
			if self.bindData.backgroundInput then
				self.bindData.backgroundInput.text = data.Background
			end

			if self.mgr.personalityAndStory then
				self.mgr.personalityAndStory.story = data.Background
			end
		end

		self.bindData.genBackgroundBtn.interactable = true
	end)
end

M.OnRenderTipTooltip = function(self, btn, widget)
	local storeGroup = gStoreManager:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, widget)

	if not store or not store.list then
		return
	end

	store.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderTipItem)
	store.list.luaSimpleClick = self:CreateAction(self.OnClickTipItem)

	store.list:SetSimpleList(#OCConfig.BackgroundAssistTips)
end

M.OnRenderTipItem = function(self, btn, index)
	local tip = OCConfig.BackgroundAssistTips[index + 1]

	if not tip then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.text = tip
	end
end

M.OnClickTipItem = function(self, btn, index)
	local tip = OCConfig.BackgroundAssistTips[index + 1]

	if not tip then
		return
	end

	local cur = self.bindData.backgroundInput and self.bindData.backgroundInput.text or ""
	local newText = string.is_null_or_empty(cur) and tip .. "：" or cur .. "\n" .. tip .. "："

	if self.bindData.backgroundInput then
		self.bindData.backgroundInput.text = newText

		self.bindData.backgroundInput:MoveTextEnd(true)
	end
end
