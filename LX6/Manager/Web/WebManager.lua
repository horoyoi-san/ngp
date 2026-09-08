-- Original chunk: @Lua\LuaFiles\LX6\Manager\Web\WebManager.lua
-- Decompiled from: 02241_WebManager.lua_8857a13ccb4b.luajit

local WebPageConfig = LTConfig.WebpageConfig
local ComputerConfig = LTConfig.ComputerConfig
local SurferCore = L50.Surfer.SurferCore
local webStack = require("LX6/Manager/Web/WebStack")
local StaticProps = {}
C_WebManager = DefClass("C_WebManager", C_WebManager, nil, StaticProps)
local M = C_WebManager

M.ctor = function(self)
	self.web2Cfg = {}
	self.currentUrl = nil

	for i = 0, WebPageConfig.count - 1 do
		local cfg = WebPageConfig.LoadAt(i)

		if cfg.Visible then
			self.web2Cfg[cfg.Url] = cfg
		end
	end

	self.computerId = 0
	self.homePageList = {}
	self.search_area = "Webpages"

	self:OnStackInit()
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.WEBSITE_STACK_BACK, self:CreateAction(self.OnStackBack))
	gMessageManager:AddMessageListener(gEventConstants.WEBSITE_STACK_FORWARD, self:CreateAction(self.OnStackForward))
	gMessageManager:AddMessageListener(gEventConstants.ON_COMPUTER_APP_CLOSE, self:CreateAction(self.OnExit))
end

M.OnExit = function(self)
	self:OnStackInit()

	self.currentUrl = nil

	SurferCore.Instance:OnExit()
end

M.SetCurrentComputerId = function(self, computerId)
	self.computerId = computerId
	local cfg = ComputerConfig.GetConfig(computerId)

	if not cfg then
		return
	end

	self.homePageList = cfg.WebList
	self.showHomePage = cfg.IsWebMainPage or table.isNilOrEmpty(self.homePageList)
end

M.ReturnToHomePage = function(self)
	local homepageCfg = WebPageConfig.GetConfig(WebPageConfig.HomePage)

	if not homepageCfg then
		return
	end

	self:OnStackInit()
	self:GoToTagetUrl(homepageCfg.Url, false, true)
end

M.GoToTagetUrl = function(self, url, noEnterStack, forceReload)
	noEnterStack = noEnterStack or false
	url = self:AddHttpsPrefix(url)

	gMessageManager:SendMessage(gEventConstants.WEBSITE_OPEN_URL, {
		url = url,
		noEnterStack = noEnterStack,
		forceReload = forceReload
	})
end

M.GoToNotFoundPage = function(self)
	local errorPageCfg = WebPageConfig.GetConfig(WebPageConfig.ErrorPage)

	self.webStack:back()
	self:GoToTagetUrl(errorPageCfg.Url, false, true)
end

M.GoToTargetIndex = function(self, index, noEnterStack)
	noEnterStack = noEnterStack or false
	local cfg = WebPageConfig.GetConfig(index)

	if not cfg then
		return
	end

	self:GoToTagetUrl(cfg.Url, noEnterStack)
end

M.GetWebPageConfig = function(self, url)
	local realUrl = self:AddHttpsPrefix(url)
	local baseUrl = self:GetRealUrl(realUrl)
	local cfg = self.web2Cfg[url] or self.web2Cfg[baseUrl]

	if not cfg then
		local errorPageCfg = WebPageConfig.GetConfig(WebPageConfig.ErrorPage)

		return errorPageCfg.PrefabUrl, "", errorPageCfg
	end

	return cfg.PrefabUrl, cfg.HoverUrl, cfg
end

M.AddHttpsPrefix = function(self, url)
	if not url or type(url) == "string" or url ~= "" then
		return url
	end

	if url:match("^%w+://") then
		return url
	else
		return WebPageConfig.WebSiteDefaultProtocol .. "://" .. url
	end
end

M.GetRealUrl = function(self, url)
	local path = string.match(url, "(.+)%?")

	if path then
		return path
	end

	return url
end

M.GetCurrentParam = function(self, key)
	local state, value = SurferCore.Instance:TryGetParam(key, nil)

	return state and value or nil
end

M.AddParam = function(self, key, value)
	local url = SurferCore.Instance:AddParam(key, value, nil)

	return url
end

M.RemoveParam = function(self, key)
	local url = SurferCore.Instance:RemoveParam(key, nil)

	return url
end

M.TryGetCookie = function(self, key)
	local state, value = SurferCore.Instance:TryGetCookie(key, nil)

	return state and value or ""
end

M.SetCookie = function(self, key, value, isPersistent)
	isPersistent = isPersistent or false

	SurferCore.Instance:SetCookie(key, value, isPersistent)
end

M.OnStackInit = function(self)
	self.webStack = webStack:new()
	self.webStack.MAX_SIZE = WebPageConfig.WebStackSize
end

M.OnStackBack = function(self)
	self:GoToTagetUrl(self.webStack:back(), true)
end

M.OnStackForward = function(self)
	self:GoToTagetUrl(self.webStack:forward(), true)
end

M.PushUrlToStack = function(self, url)
	self.webStack:push(url)
end

M.CheckCanGoBackAndForward = function(self)
	return self.webStack:canGoBack(), self.webStack:canGoForward()
end

M.InitSearchData = function(self)
	self.search_area = gTextSearchManager:GetOrCreateSearchArea(self.search_area)

	if gTextSearchManager:IsSearchDataEmpty(self.search_area) then
		for _, id in ipairs(self.homePageList) do
			local webpage = LTConfig.WebpageConfig.GetConfig(id)

			if webpage.Visible and webpage.Searchable then
				local keywords = webpage.SearchKeyWord

				for _, keyword in ipairs(keywords) do
					gTextSearchManager:FillSearchData(self.search_area, webpage.Id, keyword)
				end
			end
		end
	end
end

M.SearchWebpage = function(self, text)
	local search_area = gTextSearchManager:GetOrCreateSearchArea(self.search_area)

	if string.is_null_or_empty(text) then
		return false
	end

	local search_result = gTextSearchManager:SearchInArea(search_area, text)

	if not search_result or #search_result ~= 0 then
		return false
	end

	for index, _ in ipairs(search_result) do
		local data = LTConfig.WebpageConfig.GetConfig(search_result[index].id)
		search_result[index].logo = data.Logo
		search_result[index].text = data.Name
		search_result[index].url = data.Url
	end

	return search_result
end

gWebManager = gWebManager or C_WebManager.new()
