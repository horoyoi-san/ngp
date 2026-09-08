-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideBubblePanelStore.lua
-- Decompiled from: 01755_GuideBubblePanelStore.lua_dec581687865.luajit

C_GuideBubblePanelStore = DefClass("C_GuideBubblePanelStore", C_GuideBubblePanelStore, C_StoreGroup)
GroupName2Class.GuideBubblePanelStore = C_GuideBubblePanelStore
local M = C_GuideBubblePanelStore

M.OnAwake = function(self)
	self.bindData.clickOpen = self.CreateAction(self, "OnClickOpenGuideBtn")
end

M.OnShow = function(self, panelId, data)
	self.data = data
	self.wikiContent = nil
	self._subtitle = ""

	if data.closeTime then
		self._timer = Timer.New(function ()
			local finishNode = self.data and self.data.finishNode

			gPanelManager:Close(gPanelId.S_GUIDE_BUBBLE)
			self:ClearTimer()

			if finishNode then
				finishNode()
			end
		end, data.closeTime):Start()
	end

	self.RefreshText(self)
	self.RequestWikiContent(self)
end

M.OnGroupEnable = function(self)
	local msgEvents = {
		[gEventConstants.AKX_WIKI_LIST_UPDATED] = self.CreateAction(self, "OnWikiListUpdated")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnWikiListUpdated = function(self)
	if not self.data then
		return
	end

	self.RefreshText(self)
	self.RequestWikiContent(self)
end

M.RefreshText = function(self)
	if not self.data then
		return
	end

	local teachId = self.data.guideTeachId
	local wikiId = gAkxManager:GetWikiIdByTeachId(teachId)

	if not wikiId then
		if gAkxManager:IsNeedFetchWikiList() then
			return
		end

		print_error("GuideBubblePanelStore:RefreshText - wikiId not found for teachId:", teachId)

		return
	end

	local wikiItem = gAkxManager:GetWikiItemByWikiId(wikiId)

	if not wikiItem then
		print_error("GuideBubblePanelStore:RefreshText - wikiItem is nil, teachId:", teachId)

		return
	end

	local tabName = self.GetGuideTabName(self, wikiItem.belongTab)
	self._subtitle = tabName
	self.bindData.title = tabName
	self.bindData.content = wikiItem.title
end

M.OnLanguageChange = function(self, lang)
	self.RefreshText(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshText(self)
end

M.OnClose = function(self)
	self.ClearTimer(self)

	self.data = nil
	self.wikiContent = nil
	self._subtitle = nil
end

M.RequestWikiContent = function(self, cb)
	if not self.data then
		return
	end

	local teachId = self.data.guideTeachId
	local curData = self.data
	local wikiId = gAkxManager:GetWikiIdByTeachId(teachId)

	if not wikiId then
		if gAkxManager:IsNeedFetchWikiList() then
			return
		end

		print_error("GuideBubblePanelStore:RequestWikiContent - wikiId not found for teachId:", teachId)

		return
	end

	if self.wikiContent then
		if cb then
			cb(self.wikiContent)
		end

		return
	end

	slot5 = gAkxManager

	slot5:GetWikiContentByTeachId(teachId, function (wikiContent)
		if self.data == curData then
			return
		end

		self.wikiContent = wikiContent

		if cb then
			cb(wikiContent)
		end
	end)
end

M.GetGuideTabName = function(self, tabId)
	if not tabId then
		return ""
	end

	local wikiTabList = gAkxManager:GetWikiTabList()

	for _, tab in ipairs(wikiTabList) do
		if tab.id ~= tabId then
			return tab.tag or ""
		end
	end

	return ""
end

M.OnClickOpenGuideBtn = function(self)
	self:ClearTimer()

	local finishNode = self.data and self.data.finishNode
	local subtitle = self._subtitle or ""
	local curData = self.data
	local cachedWikiContent = self.wikiContent

	if cachedWikiContent then
		gPanelManager:Close(gPanelId.S_GUIDE_BUBBLE)
		self:OpenFullscreen(cachedWikiContent, finishNode, subtitle)
	else
		self.RequestWikiContent(self, function (wikiContent)
			if self.data == curData then
				return
			end

			gPanelManager:Close(gPanelId.S_GUIDE_BUBBLE)
			self:OpenFullscreen(wikiContent, finishNode, subtitle)
		end)
	end
end

M.OpenFullscreen = function(self, wikiContent, finishNode, subtitle)
	if not wikiContent then
		print_error("GuideBubblePanelStore:OpenFullscreen - wikiContent is nil")

		return
	end

	local param = {
		wikiContent = wikiContent,
		finishNode = finishNode,
		subtitle = subtitle or "",
		title = wikiContent.title
	}

	gPanelManager:CheckShow(gPanelId.GUIDE_BUBBLE_FULL_SCREEN_PANEL, param)
end

M.ClearTimer = function(self)
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end
