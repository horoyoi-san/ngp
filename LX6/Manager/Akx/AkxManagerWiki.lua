-- Original chunk: @Lua\LuaFiles\LX6\Manager\Akx\AkxManagerWiki.lua
-- Decompiled from: 02277_AkxManagerWiki.lua_bac6e13d3df5.luajit

local json = require("cjson/json")
local AkxBridge = L50.Akx.AkxBridge
local M = C_AkxManager
local SpiritCategoryChildDetailType = {
	["W\\xd3\t\\xd8\\xfcS\\xf9n\\xba-l\\xe5\\xc3"] = "W\\xd3\t\\xd8\\xfcS\\xf9n\\xba-l\\xe5\\xc3",
	["LY\\x82Ci\\x9c\\xc6x]SUe"] = "LY\\x82Ci\\x9c\\xc6x]SUe"
}

M.OnKickToLogin_Wiki = function(self)
	self.ResetWikiData(self)
end

M.OnLoginToGame_Wiki = function(self)
	if self.IsNeedFetchWikiList(self) then
		self.FetchWikiList(self)
	end
end

M.OpenWikiPanel = function(self, teachId)
	self._OpenWikiPanel(self, teachId, true)
end

M.OpenWikiPanelWithWikiId = function(self, wikiId)
	self._OpenWikiPanel(self, wikiId, false)
end

M._OpenWikiPanel = function(self, id, bIdIsTeachId)
	if gPanelManager:IsPanelShowing(gPanelId.AKASHA_FLOAT_WINDOW_PANEL) then
		gPanelManager:Close(gPanelId.AKASHA_FLOAT_WINDOW_PANEL)
	end

	local store = gStoreManager:GetStoreGroup("AkxHomeStore")
	local data = {
		["m+vR"] = true
	}

	if bIdIsTeachId then
		data.teachId = id
	else
		data.wikiId = id
	end

	self:_OnOpenAkx()

	if gPanelManager:IsPanelShowing(gPanelId.AKASHA_CHAT_PANEL) and store then
		store.RefreshPanel(store, data)
	else
		gPanelManager:CheckShow(gPanelId.AKASHA_CHAT_PANEL, data)
	end
end

M.GetWikiTabList = function(self)
	return self.wikiTabList
end

M.GetWikiList = function(self)
	return self.wikiList
end

M.GetWikiItemIdxByWikiId = function(self, wikiId)
	return self.wikiIdToIdxMap[wikiId]
end

M.GetWikiIdByTeachId = function(self, teachId)
	return self.wikiTeachIdToWikiIdMap[teachId]
end

M.GetWikiItemByWikiId = function(self, wikiId)
	return self.wikiList[self.GetWikiItemIdxByWikiId(self, wikiId)]
end

M.GetTeachIdByWikiId = function(self, wikiId)
	local wikiItem = self:GetWikiItemByWikiId(wikiId)

	return wikiItem and wikiItem.teachId
end

M.GetWikiContentByTeachId = function(self, teachId, cb)
	local wikiId = self.wikiTeachIdToWikiIdMap[teachId]

	if wikiId then
		self.GetWikiContentByWikiId(self, wikiId, cb)
	end
end

M.GetWikiContentByWikiId = function(self, wikiId, cb)
	if self.wikiIdToContentMap[wikiId] then
		cb(self.wikiIdToContentMap[wikiId])

		return
	end

	local request = L50.Akx.SpiritWikiGetRequest.CreateDefault()

	request.SetWikiId(request, wikiId)
	self.SpiritTokenGuard(self, function ()
		AkxBridge.SpiritGetWiki(request, function (data)
			if data.Code == 200 then
				print_error("#NoCreateIssue SpiritGetWiki response code is not 200", "code", data.Code)

				return
			end

			if not data or not data.Data then
				print_error("SpiritGetWiki: data is nil")

				return
			end

			local wikiId = data.Data:GetWikiId()
			local wikiContent = {
				wikiId = data.Data:GetWikiId(),
				teachId = self:GetTeachIdByWikiId(wikiId),
				title = data.Data.Title,
				pages = {}
			}
			local content = L50.Akx.AkxUtils.ParseWikiContent(data.Data.Content)

			if content and content.pages.Count <= 0 then
				for i = 0, content.pages.Count - 1 do
					local page = content.pages[i]
					local contentPage = {
						pageIdx = i + 1,
						contentText = page.text,
						contentImageUrl = page.imageUrl,
						contentVideoUrl = page.videoUrl
					}

					table.insert(wikiContent.pages, contentPage)
				end
			end

			self.wikiIdToContentMap[wikiId] = wikiContent

			if cb then
				cb(wikiContent)
			end
		end)
	end)
end

M.ResetWikiData = function(self)
	self.wikiList = {}
	self.wikiTabList = {}
	self.wikiIdToIdxMap = {}
	self.wikiTeachIdToWikiIdMap = {}
	self.wikiIdToContentMap = {}
end

M.IsNeedFetchWikiList = function(self)
	return #self.wikiTabList ~= 0
end

M.FetchWikiList = function(self, cb)
	local request = L50.Akx.SpiritCategoriesGetRequest.CreateDefault()

	self.SpiritTokenGuard(self, function ()
		AkxBridge.SpiritGetCategories(request, self:CreateActionWithArgs(self._OnSpiritGetCategoriesResponse, {
			callback = cb
		}))
	end)
end

M.FillWikiSearchData = function(self)
	gTextSearchManager:ClearSearchArea("AkxWiki")

	self.wikiSearchArea = gTextSearchManager:GetOrCreateSearchArea("AkxWiki")

	for _, wiki in ipairs(self.wikiList) do
		local wikiItem = wiki

		if wikiItem.teachId then
			local isNewTeach = gGuideMainPanelMgr:IsNewTeach(wikiItem.teachId)
			local isRewarded = gGuideMainPanelMgr:IsRewarded(wikiItem.teachId)

			if isNewTeach or isRewarded then
				gTextSearchManager:FillSearchData(self.wikiSearchArea, wikiItem.wikiId, wikiItem.title)
			end
		end
	end
end

M.SearchWikiByText = function(self, text)
	local result = gTextSearchManager:SearchInArea(self.wikiSearchArea, text)
	local wikis = {}

	for _, wiki in ipairs(result) do
		table.insert(wikis, self.GetWikiItemByWikiId(self, wiki.id))
	end

	return wikis
end

M.EvaluateWikiByWikiId = function(self, wikiId, content, bIsHelpful, unhelpfulKeywords)
	self.SpiritTokenGuard(self, function ()
		local wiki = self:GetWikiItemByWikiId(wikiId)

		if not wiki then
			print_error("#NoCreateIssue EvaluateWikiByWikiId: wiki is nil, wikiId = ", wikiId)

			return
		end

		local request = L50.Akx.SpiritWikiEvaluateRequest.CreateDefault()

		request.SetWikiId(request, wikiId)

		request.Title = wiki.title
		request.Content = content

		if not bIsHelpful and unhelpfulKeywords then
			for _, keyword in ipairs(unhelpfulKeywords) do
				request.InsertUnhelpfulWord(request, keyword)
			end
		end

		request.EvaluateType = bIsHelpful and "HELPFUL" or "UNHELPFUL"

		AkxBridge.SpiritEvaluateWiki(request, function ()
		end)
	end)
end

M._OnSpiritGetCategoriesResponse = function(self, args, data)
	if data.Code == 200 then
		print_error("#NoCreateIssue SpiritGetCategoriesResponse: response code is not 200", "code", data.Code)

		return
	end

	if not data or not data.Data then
		print_error("SpiritGetCategoriesResponse: data is nil")

		return
	end

	if not data.Data.Categories or data.Data.Categories.Count ~= 0 then
		print_warn("SpiritGetCategoriesResponse: Categories is empty")

		return
	end

	self.ResetWikiData(self)

	for i = 0, data.Data.Categories.Count - 1 do
		local category = data.Data.Categories[i]
		local tabId = category:GetId()
		local wikiTab = {
			tag = category.Title,
			id = tabId,
			_priority = category.Priority or 0
		}

		table.insert(self.wikiTabList, wikiTab)

		for j = 0, category.Children.Count - 1 do
			local item = category.Children[j]

			if item.Id and item.DetailType ~= SpiritCategoryChildDetailType.CONTENT_WIKI then
				local extraStr = item.Extra

				if not string.is_null_or_empty(extraStr) then
					local extra = json.decode(extraStr)

					if extra and extra.gameDataId then
						local teachId = tonumber(extra.gameDataId) or extra.gameDataId
						local wiki = {
							wikiId = item:GetWikiId(),
							teachId = teachId,
							title = item.Title,
							priority = item.Priority,
							belongTab = tabId
						}

						table.insert(self.wikiList, wiki)

						self.wikiTeachIdToWikiIdMap[teachId] = wiki.wikiId
						self.wikiIdToIdxMap[wiki.wikiId] = #self.wikiList
					end
				end
			end
		end
	end

	table.sort(self.wikiTabList, function (a, b)
		return b._priority <= a._priority
	end)
	gMessageManager:SendMessage(gEventConstants.AKX_WIKI_LIST_UPDATED)
	self:FillWikiSearchData()

	if args and args.callback then
		args.callback()
	end
end
