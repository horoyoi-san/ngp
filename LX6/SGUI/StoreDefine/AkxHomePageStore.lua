-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AkxHomePageStore.lua
-- Decompiled from: 01604_AkxHomePageStore.lua_5bb197c9b726.luajit

C_AkxHomePageStore = DefClass("C_AkxHomePageStore", C_AkxHomePageStore, C_StoreGroup)
GroupName2Class.AkxHomePageStore = C_AkxHomePageStore
local M = C_AkxHomePageStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.recommandList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderRecommandListItem)
	self.bindData.suggestList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderSuggestListItem)
	self.bindData.suggestList.luaSimpleClick = self.CreateAction(self, self.OnClickBtnSuggest)
end

M.OnShow = function(self, _, params)
	if params and params.question then
		gAkxManager:PushMessage(params.question)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnEnable = function(self)
	local msgEvents = {
		[gEventConstants.AKX_SUGGEST_CONTENT_UPDATED] = self.CreateAction(self, "RenderSuggestContent"),
		[gEventConstants.AKX_MORE_PEOPLE_ASKING_LIST_UPDATED] = self.CreateAction(self, "RenderMorePeopleAsking")
	}

	self.RegisterMessageEvents(self, msgEvents)
	self.RenderSuggestContent(self)
	self.RenderMorePeopleAsking(self)
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.RenderSuggestContent = function(self)
	self.recommandList = {}
	local suggestContents = gAkxManager:GetSuggestContents()

	for i = 0, LTConfig.AkashaSuggestionConfig.count - 1 do
		local content = LTConfig.AkashaSuggestionConfig.LoadAt(i)

		if content.Type ~= LTConfig.AkashaSuggestionConfig.TypeType.Front then
			local content = {
				name = content.EntryName,
				icon = content.Icon,
				iconColor = content.IconColor and Color.NewByStr(content.IconColor)
			}

			if suggestContents[content.name] then
				content = table.combine(content, suggestContents[content.name])
			end

			table.insert(self.recommandList, content)
		end
	end

	self.bindData.recommandList:SetSimpleList(#self.recommandList)
end

M.RenderMorePeopleAsking = function(self)
	self.suggestList = gAkxManager:GetMorePeopleAsking()

	self.bindData.suggestList:SetSimpleList(#self.suggestList)
end

M.OnSimpleRenderSuggestListItem = function(self, item, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(item.Store):GetStoreByWidget(item)
	local suggest = self.suggestList[index]
	store.title.text = suggest
end

M.OnClickBtnSuggest = function(self, item, index)
	index = index + 1
	local question = self.suggestList[index]

	gAkxManager:PushMessage(question)
end

M.OnSimpleRenderRecommandListItem = function(self, item, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(item.Store):GetStoreByWidget(item)
	local content = self.recommandList[index]
	store.title.text = content.title

	if content.iconColor then
		store.bgColor = content.iconColor
	end

	if content.icon and content.icon == 0 then
		store.Commit(store, "icon", content.icon, COMMIT_FORCE)
	end

	item.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRecommandListBtnRenderTooltip", content)
end

M.OnRecommandListBtnRenderTooltip = function(self, content, btn, tooltip, index)
	local store = gStoreManager:GetStoreGroup(tooltip.Store):GetStoreByWidget(tooltip)
	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderRecommandListTooltipBtn", content)
	store.list.luaSimpleClick = self:CreateActionWithArgs("OnClickRecommandListTooltipBtn", content)

	store.list:SetSimpleList(#content.contents)
end

M.OnRenderRecommandListTooltipBtn = function(self, content, item, idx)
	idx = idx + 1
	local store = gStoreManager:GetStoreGroup(item.Store):GetStoreByWidget(item)
	store.title = content.contents[idx].text
end

M.OnClickRecommandListTooltipBtn = function(self, content, item, index)
	index = index + 1

	gAkxManager:DoSuggestContentAction(content.contents[index])
end
