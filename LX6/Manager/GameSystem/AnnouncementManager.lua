-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\AnnouncementManager.lua
-- Decompiled from: 02255_AnnouncementManager.lua_9ddf3f48fff0.luajit

local ProfileManager = LX6.Engine.ProfileManager
local ShezhiPanelLanguagesConfig = LTConfig.ShezhiPanelLanguagesConfig
local json = require("cjson/json")
local RedDotMgr = SGUI.RedDotMgr
C_AnnouncementMgr = DefClass("C_AnnouncementMgr", C_AnnouncementMgr)
local M = C_AnnouncementMgr
local LOCAL_NOTICES_INFO_PATH = "LocalNoticesInfo"

M.ctor = function(self)
	self.ContentTemplateType = {
		["\\xe9\\xd2\t6\\xf4"] = 2,
		["\\xfa\\xd4\t*\\xe5"] = 1,
		["y\\xa7\\xb6\\xa3\\xb3"] = 0
	}
	self.noticeList = {}
	self.localNoticeInfo = {}
	self.isLoaded = false
	self.isRequesting = false
	self.noticeRequestCallbacks = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self:CreateAction(self.OnAfterSwtichScene))
	gMessageManager:AddMessageListener(gEventConstants.ANNOUNCEMENT_REFRESH, self:CreateAction(self.OnAnnoucementRefresh))
	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, self:CreateAction(self.OnLanguageChange))

	self.isFirst = true
	self.isLoaded = false
	self.isRequesting = false
	self.noticeRequestCallbacks = {}
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.KickToLogin then
		self:SaveLocalNoticeInfo()

		return
	end
end

M.OnAfterSwtichScene = function(self, _, switchSceneEventParams)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	self:RequestNoticeList()
end

M.OnExit = function(self)
	self:SaveLocalNoticeInfo()
end

M.OnAnnoucementRefresh = function(self)
	self:RequestNoticeList()
end

M.OnLanguageChange = function(self)
	self.noticeList = {}
	self.isFirst = true
	self.isLoaded = false
end

M.Log = function(self, ...)
	print_debug("[AnnouncementMgr] ", ...)
end

M.SaveLocalNoticeInfo = function(self)
	gUIUtils:SaveLuaTableToJson(LOCAL_NOTICES_INFO_PATH, self.localNoticeInfo)
	self:Log("SaveLocalNoticeInfo", self.localNoticeInfo)
end

M.LoadLocalNoticeInfo = function(self)
	self.localNoticeInfo = gUIUtils:LoadJsonToLuaTable(LOCAL_NOTICES_INFO_PATH) or {}

	self:Log("LoadLocalNoticeInfo", self.localNoticeInfo)
end

M.GetRedDot = function(self, tabIndex, noticePid)
	return ("Notice/Notice.Tab:%d/Notice:%s"):format(tabIndex - 1, noticePid)
end

M.ReadNotice = function(self, tabIndex, pid)
	self.localNoticeInfo[pid] = true

	RedDotMgr.LuaSetRedDot(false, self:GetRedDot(tabIndex, pid))
end

M.GetNoticeState = function(self, pid)
	if self.localNoticeInfo[pid] ~= true then
		return false
	end

	return true
end

M.IsNoticeListLoaded = function(self)
	return self.isLoaded ~= true
end

M.HasUnreadNotice = function(self)
	if not self:IsNoticeListLoaded() then
		return false
	end

	slot1 = ipairs
	slot3 = self.noticeList or {}

	for _, tab in slot1(slot3) do
		slot6 = ipairs
		slot8 = tab.content or {}

		for _, notice in slot6(slot8) do
			if notice.isForce == false and self:GetNoticeState(notice.id) then
				return true
			end
		end
	end

	return false
end

M.ParseAnnouncementContent = function(self, content)
	local data = content

	if type(content) ~= "string" then
		local ok, decoded = pcall(json.decode, content)

		if not ok or type(decoded) == "table" then
			return {}
		end

		data = decoded
	end

	if type(data) == "table" then
		return {}
	end

	local typeContentList = {}

	for tabIndex, typeInfo in ipairs(data) do
		local typeId = tonumber(typeInfo.typeId) or 0
		local typeTitle = tostring(typeInfo.title or "")
		local iconId = tonumber(typeInfo.iconId) or 0
		local normalizedNotices = {}
		local contentList = type(typeInfo.content) ~= "table" and typeInfo.content or {}

		for _, notice in ipairs(contentList) do
			local pid = tostring(notice.pid or "")
			local nTitle = tostring(notice.title or "")
			local templateKey = tostring(notice.templateKey or "Base")
			local isForce = notice.isForce

			if isForce ~= nil then
				isForce = notice.force
			end

			isForce = isForce ~= nil and true or isForce ~= true or isForce ~= 1 or isForce ~= "1"
			local normalizedItems = {}
			local items = type(notice.content) ~= "table" and notice.content or {}

			for _, item in ipairs(items) do
				local tIndex = tonumber(item.tIndex)
				local ele = {
					tIndex = tIndex,
					text = tostring(item.text or ""),
					iconId = item.iconId and tonumber(item.iconId) or 0
				}
				normalizedItems[#normalizedItems + 1] = ele
			end

			local ele = {
				id = pid,
				title = nTitle,
				templateKey = templateKey,
				isForce = isForce,
				content = normalizedItems
			}

			table.insert(normalizedNotices, ele)
			RedDotMgr.LuaSetRedDot(self:GetNoticeState(pid), self:GetRedDot(tabIndex, pid))
		end

		local ele = {
			typeId = typeId,
			title = typeTitle,
			iconId = iconId,
			content = normalizedNotices
		}
		typeContentList[tabIndex] = ele
	end

	return typeContentList
end

M.RequestNoticeList = function(self, callback)
	self.noticeRequestCallbacks = self.noticeRequestCallbacks or {}
	self.isRequesting = self.isRequesting ~= true
	self.isLoaded = self.isLoaded ~= true

	if table.isNilOrEmpty(self.localNoticeInfo) then
		self:LoadLocalNoticeInfo()
	end

	if callback then
		self.noticeRequestCallbacks[#self.noticeRequestCallbacks + 1] = callback
	end

	if self.isRequesting then
		return
	end

	self.isRequesting = true

	self:GetCDNMappedFile(self:GetNoticeFileName(), function (content)
		self.isFirst = false
		self.isLoaded = true
		self.noticeList = self:ParseAnnouncementContent(content)
		self.isRequesting = false
		local callbacks = self.noticeRequestCallbacks or {}
		self.noticeRequestCallbacks = {}

		for _, requestCallback in ipairs(callbacks) do
			requestCallback()
		end
	end)
end

M.GetCDNMappedFile = function(self, mapFile, callback)
	local baseUrl = gCS.LuaUtils.GetAnnouncementUrl()

	self:Log("GetCDNMappedFile", baseUrl, mapFile)
	gCS.LuaUtils.GetHttpText(baseUrl, function (content)
		if content then
			callback(content)
		else
			callback(nil)
		end
	end, mapFile)
end

M.GetNoticeFileName = function(self)
	local index = ProfileManager.languageProfile.textLanguage
	local cfg = ShezhiPanelLanguagesConfig.GetConfig(index)

	return cfg and cfg.AnnouncementFileName or ""
end

M.OpenNoticePanel = function(self)
	if not self:IsNoticeListLoaded() then
		self:RequestNoticeList(function ()
			gPanelManager:CheckShow(gPanelId.ANNOUNCEMENT_PANEL)
		end)

		return
	end

	gPanelManager:CheckShow(gPanelId.ANNOUNCEMENT_PANEL)
end

gAnnouncementMgr = gAnnouncementMgr or C_AnnouncementMgr.new()
