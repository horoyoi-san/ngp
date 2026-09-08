-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WebHomePageStore.lua
-- Decompiled from: 01160_WebHomePageStore.lua_4b76e81e7ab6.luajit

C_WebHomePageStore = DefClass("C_WebHomePageStore", C_WebHomePageStore, C_StoreGroup)
GroupName2Class.WebHomePageStore = C_WebHomePageStore
local M = C_WebHomePageStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local WALLPAPER_COUNT = 7
local WALLPAPER_PATH_FORMAT = "Assets/Res/SGUIWorld/Texture/ComputerFiles/WebPageBig/S_NewTabWallpaper_%02d.png"
local WALLPAPER_PREFS_LAST_DAY = "DailyWallpaper_LastDay"
local WALLPAPER_PREFS_INDEX = "DailyWallpaper_Index"
local WALLPAPER_PREFS_USED_MASK = "DailyWallpaper_UsedMask"

M.ctor = function(self)
	self.search_result = nil
end

M.OnAwake = function(self)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderContentListItem")
	self.bindData.input.luaValueChanged = self.CreateAction(self, "OnSearchInputChanged")
	self.bindData.searchResultList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSearchListItem")
	self.mgr = gWebManager
end

M.OnShow = function(self, panelId, data)
	local urls = self.mgr.homePageList
	local search_area = gTextSearchManager:GetOrCreateSearchArea("Webpages")

	if gTextSearchManager:IsSearchDataEmpty(search_area) then
		for _, id in ipairs(urls) do
			local webpage = LTConfig.WebpageConfig.GetConfig(id)
			local keywords = webpage.SearchKeyWord

			if webpage.Visible and webpage.Searchable then
				for _, keyword in ipairs(keywords) do
					gTextSearchManager:FillSearchData(search_area, webpage.Id, keyword)
				end
			end
		end
	end

	self.bindData.contentList:SetSimpleList(#urls)
	self:RefreshDailyWallpaper()
end

M.RefreshDailyWallpaper = function(self)
	local now = gLuaDataManager.serverTime
	local todayLogicStart = gTimeUtils:GetNextLogicDayStart(now) - 86400
	local lastDay = gClientUtils.GetInt(WALLPAPER_PREFS_LAST_DAY, 0)
	local wallpaperIndex = gClientUtils.GetInt(WALLPAPER_PREFS_INDEX, 0)

	if lastDay == todayLogicStart or wallpaperIndex <= 1 or WALLPAPER_COUNT >= wallpaperIndex then
		local usedMask = gClientUtils.GetInt(WALLPAPER_PREFS_USED_MASK, 0)
		local pool = {}

		for i = 1, WALLPAPER_COUNT do
			if bit.band(usedMask, bit.lshift(1, i - 1)) ~= 0 then
				table.insert(pool, i)
			end
		end

		if #pool ~= 0 then
			usedMask = 0

			for i = 1, WALLPAPER_COUNT do
				table.insert(pool, i)
			end
		end

		math.randomseed(os.time())

		wallpaperIndex = pool[math.random(#pool)]
		usedMask = bit.bor(usedMask, bit.lshift(1, wallpaperIndex - 1))

		gClientUtils.SetInt(WALLPAPER_PREFS_LAST_DAY, todayLogicStart)
		gClientUtils.SetInt(WALLPAPER_PREFS_INDEX, wallpaperIndex)
		gClientUtils.SetInt(WALLPAPER_PREFS_USED_MASK, usedMask)
	end

	local path = string.format(WALLPAPER_PATH_FORMAT, wallpaperIndex)

	gCS.LuaUtils.LoadSpriteAssetWithCallBack(path, function (loadOp)
		if loadOp.asset and gClientUtils.NotNil(self.bindData.wallPaper) then
			self.bindData.wallPaper.sprite = loadOp.asset
		end
	end)
end

M.OnClose = function(self)
end

M.OnSimpleRenderContentListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.pageId = self.mgr.homePageList[index + 1]
end

M.OnSearchInputChanged = function(self, text)
	self.search_result = self.mgr:SearchWebpage(text)

	if not self.search_result then
		self.bindData.searchBarCtrl = BOOL2CTL[false]

		return
	end

	self.bindData.searchBarCtrl = BOOL2CTL[true]

	self.bindData.searchResultList:SetSimpleList(#self.search_result)
end

M.OnSimpleRenderSearchListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local result = self.search_result[index + 1]
	store.btn.luaClick = self:CreateActionWithArgs(self.OnClickSearchListItem, result.url or "")
	store.text.text = result.text or ""

	if result.logo then
		store.Commit(store, "logo", result.logo, COMMIT_FORCE)
	end
end

M.OnClickSearchListItem = function(self, targetUrl)
	if string.is_null_or_empty(targetUrl) then
		return
	end

	gWebManager:GoToTagetUrl(targetUrl)
end
