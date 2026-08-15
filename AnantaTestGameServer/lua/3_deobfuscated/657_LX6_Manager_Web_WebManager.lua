local WebPageConfig = LTConfig.WebpageConfig
local ComputerConfig = LTConfig.ComputerConfig
local SurferCore = L50.Surfer.SurferCore
local webStack = require("LX6/Manager/Web/WebStack")
local StaticProps = {}
C_WebManager = DefClass("C_WebManager", C_WebManager, nil, StaticProps)
local M = C_WebManager

function M:ctor()
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

	self:OnStackInit()
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.WEBSITE_STACK_BACK, self:CreateAction(self.OnStackBack))
	gMessageManager:AddMessageListener(gEventConstants.WEBSITE_STACK_FORWARD, self:CreateAction(self.OnStackForward))
	gMessageManager:AddMessageListener(gEventConstants.ON_COMPUTER_APP_CLOSE, self:CreateAction(self.OnExit))
end

function M:OnExit()
	self:OnStackInit()

	self.currentUrl = nil

	SurferCore.Instance:OnExit()
end

function M:SetCurrentComputerId(computerId)
	self.computerId = computerId
	local cfg = ComputerConfig.GetConfig(computerId)

	if not cfg then
		return
	end

	self.homePageList = cfg.WebList
	self.showHomePage = cfg.IsWebMainPage or table.isNilOrEmpty(self.homePageList)
end

function M:ReturnToHomePage()
	local homepageCfg = WebPageConfig.GetConfig(WebPageConfig.HomePage)

	if not homepageCfg then
		return
	end

	self:OnStackInit()
	self:GoToTagetUrl(homepageCfg.Url, false)
end

function M:GoToTagetUrl(url, noEnterStack)
	noEnterStack = noEnterStack or false
	url = self:AddHttpsPrefix(url)

	gMessageManager:SendMessage(gEventConstants.WEBSITE_OPEN_URL, {
		url = url,
		noEnterStack = noEnterStack
	})
end

function M:GoToTargetIndex(index, noEnterStack)
	noEnterStack = noEnterStack or false
	local cfg = WebPageConfig.GetConfig(index)

	if not cfg then
		return
	end

	self:GoToTagetUrl(cfg.Url, noEnterStack)
end

function M:GetWebPageConfig(url)
	local realUrl = self:AddHttpsPrefix(url)
	local baseUrl = self:GetRealUrl(realUrl)
	local cfg = self.web2Cfg[url] or self.web2Cfg[baseUrl]

	if not cfg then
		local errorPageCfg = WebPageConfig.GetConfig(WebPageConfig.ErrorPage)

		return errorPageCfg.PrefabUrl, "", errorPageCfg
	end

	return cfg.PrefabUrl, cfg.HoverUrl, cfg
end

function M:SearchWebPage(url)
	local result = {}

	for key, _ in pairs(self.web2Cfg) do
		if string.find(key, url, 1, true) then
			table.insert(result, key)
		end
	end

	return result
end

function M:AddHttpsPrefix(url)
	if not url or type(url) ~= "string" or url == "" then
		return url
	end

	if url:match("^%w+://") then
		return url
	else
		return WebPageConfig.WebSiteDefaultProtocol .. "://" .. url
	end
end

function M:GetRealUrl(url)
	local path = string.match(url, "(.+)%?")

	if path then
		return path
	end

	return url
end

function M:GetCurrentParam(key)
	local state, value = SurferCore.Instance:TryGetParam(key, nil)

	return state and value or nil
end

function M:AddParam(key, value)
	local url = SurferCore.Instance:AddParam(key, value, nil)

	return url
end

function M:RemoveParam(key)
	local url = SurferCore.Instance:RemoveParam(key, nil)

	return url
end

function M:TryGetCookie(key)
	local state, value = SurferCore.Instance:TryGetCookie(key, nil)

	return state and value or ""
end

function M:SetCookie(key, value, isPersistent)
	isPersistent = isPersistent or false

	SurferCore.Instance:SetCookie(key, value, isPersistent)
end

function M:OnStackInit()
	self.webStack = webStack:new()
	self.webStack.MAX_SIZE = WebPageConfig.WebStackSize
end

function M:OnStackBack()
	self:GoToTagetUrl(self.webStack:back(), true)
end

function M:OnStackForward()
	self:GoToTagetUrl(self.webStack:forward(), true)
end

function M:PushUrlToStack(url)
	self.webStack:push(url)
end

function M:CheckCanGoBackAndForward()
	return self.webStack:canGoBack(), self.webStack:canGoForward()
end

gWebManager = gWebManager or C_WebManager.new()
