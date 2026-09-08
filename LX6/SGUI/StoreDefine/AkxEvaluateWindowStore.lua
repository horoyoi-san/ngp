-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AkxEvaluateWindowStore.lua
-- Decompiled from: 01601_AkxEvaluateWindowStore.lua_b0950d5af9e9.luajit

C_AkxEvaluateWindowStore = DefClass("C_AkxEvaluateWindowStore", C_AkxEvaluateWindowStore, C_StoreGroup)
GroupName2Class.AkxEvaluateWindowStore = C_AkxEvaluateWindowStore
local M = C_AkxEvaluateWindowStore

M.ctor = function(self)
	self.keywords = {}
	self.multiChoice = {}
end

M.OnAwake = function(self)
	self.bindData.btnSubmit.luaClick = self.CreateAction(self, "OnClickBtnSubmit")
	self.bindData.btnCancel.luaClick = self.CreateAction(self, "OnClickBtnCancel")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnClickListItem")
end

M.OnShow = function(self, panelId, data)
	self.data = data

	self.RenderRecommandList(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.content:ActivateInputField()
	end

	self.keywords = {}
	self.multiChoice = {}
end

M.RenderRecommandList = function(self)
	self.recommandList = {}

	for i, v in ipairs(LTConfig.AkashaConfig.FeedbackChoice) do
		table.insert(self.recommandList, v)
	end

	self.bindData.list:SetSimpleList(#self.recommandList)
end

M.OnClickBtnSubmit = function(self)
	local content = self.bindData.content.text

	if string.is_null_or_empty(content) then
		content = "unlike it"
	end

	if self.data and self.data.wikiId then
		gAkxManager:EvaluateWikiByWikiId(self.data.wikiId, content, self.data.like, self.keywords)
	else
		gAkxManager:EvaluateSession(self.data.sessionid, self.data.messageid, content, self.data.like, self.keywords)
	end

	if self.data.callback then
		self.data.callback(true)
	end

	gPanelManager:Close(gPanelId.AKASHA_REPORT_PANEL)
end

M.OnClickBtnCancel = function(self)
	if self.data.callback then
		self.data.callback(false)
	end

	gPanelManager:Close(gPanelId.AKASHA_REPORT_PANEL)
end

M.OnSimpleRenderListItem = function(self, item, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(item.Store):GetStoreByWidget(item)
	store.title.text = self.recommandList[index]
end

M.OnClickListItem = function(self, item, index)
	index = index + 1
	local keyword = self.recommandList[index]
	local current = self.multiChoice[index] and true or false
	local newState = not current

	if newState then
		if not table.find(self.keywords, keyword) then
			table.insert(self.keywords, keyword)
		end
	else
		local _, idx = table.find(self.keywords, keyword)

		if idx then
			table.remove(self.keywords, idx)
		end
	end

	self.multiChoice[index] = newState

	item.SetSelected(item, newState)
end

M.OnActiveDeviceChange = function(self, device)
end
