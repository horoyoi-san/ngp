local ProfileManager = LX6.Engine.ProfileManager
local ShezhiPanelLanguagesConfig = LTConfig.ShezhiPanelLanguagesConfig
local json = require("cjson/json")
local PlayerPrefs = UnityEngine.PlayerPrefs
local RedDotMgr = SGUI.RedDotMgr
C_AnnouncementMgr = DefClass("C_AnnouncementMgr", C_AnnouncementMgr)
local M = C_AnnouncementMgr
local LOCAL_NOTICES_INFO_PATH = "LocalNoticesInfo"

function M:ctor()
	self.ContentTemplateType = {
		Picture = 2,
		Content = 1,
		Title = 0
	}
	self.noticeList = {}
	self.localNoticeInfo = {}
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self:CreateAction(self.OnAfterSwtichScene))
	gMessageManager:AddMessageListener(gEventConstants.ANNOUNCEMENT_REFRESH, self:CreateAction(self.OnAnnoucementRefresh))

	self.isFirst = true
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:SaveLocalNoticeInfo()

		return
	end
end

function M:OnAfterSwtichScene(_, switchType)
	self:RequestNoticeList()
end

function M:OnExit()
	self:SaveLocalNoticeInfo()
end

function M:OnAnnoucementRefresh()
	self:RequestNoticeList()
end

function M:Log(...)
	print_debug("[AnnouncementMgr] ", ...)
end

function M:SaveLocalNoticeInfo()
	gUIUtils:SaveLuaTableToJson(LOCAL_NOTICES_INFO_PATH, self.localNoticeInfo)
	self:Log("SaveLocalNoticeInfo", self.localNoticeInfo)
end

function M:LoadLocalNoticeInfo()
	self.localNoticeInfo = gUIUtils:LoadJsonToLuaTable(LOCAL_NOTICES_INFO_PATH) or {}

	self:Log("LoadLocalNoticeInfo", self.localNoticeInfo)
end

function M:GetRedDot(tabIndex, noticePid)
	return ("Notice/Notice.Tab:%d/Notice:%s"):format(tabIndex - 1, noticePid)
end

function M:ReadNotice(tabIndex, pid)
	self.localNoticeInfo[pid] = true

	RedDotMgr.LuaSetRedDot(false, self:GetRedDot(tabIndex, pid))
end

function M:GetNoticeState(pid)
	if self.localNoticeInfo[pid] == true then
		return false
	end

	return true
end

function M:ParseAnnouncementContent(content)
	local data = content

	if type(content) == "string" then
		local ok, decoded = pcall(json.decode, content)

		if not ok or type(decoded) ~= "table" then
			return {}
		end

		data = decoded
	end

	if type(data) ~= "table" then
		return {}
	end

	local typeContentList = {}

	for tabIndex, typeInfo in ipairs(data) do
		local typeId = tonumber(typeInfo.typeId) or 0
		local typeTitle = tostring(typeInfo.title or "")
		local iconId = tonumber(typeInfo.iconId) or 0
		local normalizedNotices = {}
		local contentList = type(typeInfo.content) == "table" and typeInfo.content or {}

		for _, notice in ipairs(contentList) do
			local pid = tostring(notice.pid or "")
			local nTitle = tostring(notice.title or "")
			local templateKey = tostring(notice.templateKey or "Base")
			local isImportant = notice.isImportant == "true"
			local normalizedItems = {}
			local items = type(notice.content) == "table" and notice.content or {}

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
				content = normalizedItems
			}
			local hasRed = self:GetNoticeState(pid)

			table.insert(normalizedNotices, ele)

			self.hasImport = self.hasImport or isImportant and hasRed

			RedDotMgr.LuaSetRedDot(hasRed, self:GetRedDot(tabIndex, pid))
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

function M:RequestNoticeList(callback)
	self:Log("RequestNoticeList")

	if table.isNilOrEmpty(self.localNoticeInfo) then
		self:LoadLocalNoticeInfo()
	end

	self.hasImport = false

	self:GetCDNMappedFile(self:GetNoticeFileName(), function (content)
		self.isFirst = false
		self.noticeList = self:ParseAnnouncementContent(content)

		if callback then
			callback()
		end
	end)
end

function M:GetCDNMappedFile(mapFile, callback)
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

function M:GetNoticeFileName()
	local index = ProfileManager.languageProfile.textLanguage
	local cfg = ShezhiPanelLanguagesConfig.GetConfig(index)

	return cfg and cfg.AnnouncementFileName or ""
end

function M:OpenNoticePanel()
	if table.isNilOrEmpty(self.noticeList) then
		self:RequestNoticeList(function ()
			gPanelManager:CheckShow(gPanelId.ANNOUNCEMENT_PANEL)
		end)

		return
	end

	gPanelManager:CheckShow(gPanelId.ANNOUNCEMENT_PANEL)
end

gAnnouncementMgr = gAnnouncementMgr or C_AnnouncementMgr.new()
