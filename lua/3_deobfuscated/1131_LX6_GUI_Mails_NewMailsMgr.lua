local MessageConfig = LTConfig.MessageConfig
local MailConfig = LTConfig.CompensationMailConfig
local MailTabConfig = LTConfig.CompensationMailTabConfig
local CompensationConfig = LTConfig.CompensationConfig
local UXTime = LTUtils.UXTime
local ConsumableConfig = LTConfig.ConsumableConfig
local BuffConfig = LTConfig.BuffConfig
local MailParameterType = UX.Game.MailParameterType
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local RedDotMgr = SGUI.RedDotMgr
local WebViewManager = LX6.Manager.WebViewManager
local StaticProps = {
	LOCAL_MAILS_INFO_PATH = "LocalMailsInfo"
}
C_NewMailsMgr = DefClass("C_NewMailsMgr", C_NewMailsMgr, nil, StaticProps)
local M = C_NewMailsMgr

function M:ctor()
	self:InitData()
end

function M:InitData()
	self.mailInfos = {}
	self.mailBriefs = {}
	self.mailTabDict = {}
	self.LocalMailsInfo = {}
	self.dirtyInfo = {}
	self.redDot = {}
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self:CreateAction(self.OnAfterSwtichScene))
end

function M:OnBeforeSwitchScene(_, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:SaveLocalMailInfo()
		self:InitData()
	end
end

function M:OnAfterSwtichScene(_, switchType)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	self:AskMailsHead()
	self:LoadLocalMailInfo()
	self:CheckSurveyRead()
end

function M:OnExit()
	self:SaveLocalMailInfo()
	self:RefreshRedDot()
end

function M:AskReceiveMail(id, callback)
	gClientToGameDelegate:AskGetMailItem(id).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			self:RefreshMailIsRetrieved(id, true)
		end

		if callback then
			callback(err)
		end
	end
end

function M:AskReciveAllMails(mailIds, callback)
	if table.isNilOrEmpty(mailIds) then
		if callback then
			callback()
		end

		return
	end

	gClientToGameDelegate:AskGetMailsItem(mailIds).Callback = function (err, successMailsId)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		for i = 1, #successMailsId do
			self:RefreshMailIsRetrieved(successMailsId[i], true)
			self:SetLocalMailsInfo(successMailsId[i], true)
		end

		if callback then
			callback(err)
		end

		self:RefreshRedDot()
	end
end

function M:AskDeleteMails(mailIds, callback)
	if table.isNilOrEmpty(mailIds) then
		if callback then
			callback()
		end

		return
	end

	local msg = #mailIds == 1 and MessageConfig.DeleteMail or MessageConfig.DeleteAllMail

	gDisplayMessageMgr:ShowMessage(msg, function ()
		self:_RealAskDeleteMails(mailIds, callback)
	end)
end

function M:_RealAskDeleteMails(mailIds, callback)
	gClientToGameDelegate:AskDeleteMails(mailIds).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		for i = 1, #mailIds do
			self:RemoveMail(mailIds[i])
		end

		if callback then
			callback(err)
		end
	end
end

function M:AskMailInfo(mailId, callback)
	self:SetLocalMailsInfo(mailId, true)

	if not table.isNilOrEmpty(self.mailInfos[mailId]) and self.dirtyInfo[mailId] then
		if callback then
			callback()
		end

		return
	end

	gClientToGameDelegate:RequestMailInfo(mailId).Callback = function (err, itemMsg)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		else
			self:AddMailDetail(itemMsg)
		end

		if callback then
			callback()
		end
	end
end

function M:AskMailInfos(mailIds, callback)
	if table.isNilOrEmpty(mailIds) then
		if callback then
			callback()
		end

		return
	end

	gClientToGameDelegate:RequestMailsItem(mailIds).Callback = function (err, items)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			for i = 1, #items do
				self:AddMailDetail(items[i])
			end
		end

		if callback then
			callback(err)
		end
	end
end

function M:AskMailsHead(callback)
	gClientToGameDelegate:GetMailHeadList().Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(err)
			end
		end

		if not table.isNilOrEmpty(data) then
			for i = 1, #data do
				self:AddMailBrief(data[i])
			end
		end

		if callback then
			callback(err)
		end

		self:RefreshRedDot()
	end
end

function M:AskFavorMail(mailId, callback)
	local brief = self.mailBriefs[mailId]

	if not brief then
		if callback then
			callback()
		end

		return
	end

	local isFavor = brief.IsFavorite

	local function cb(err)
		if err == MessageConfig.Ok then
			self:RefreshMailFavor(mailId, not isFavor)
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		if callback then
			callback()
		end

		self:RefreshRedDot()
	end

	if isFavor then
		gClientToGameDelegate:AskRemoveMailFromFavorites(mailId).Callback = cb
	else
		gClientToGameDelegate:AskAddMailToFavorites(mailId).Callback = cb
	end
end

function M:AddMailBrief(brief)
	self.mailBriefs[brief.Id] = brief
end

function M:AddMailDetail(detail)
	self.mailInfos[detail.Id] = detail
	self.dirtyInfo[detail.Id] = true
end

function M:RemoveMail(mailId)
	self.mailBriefs[mailId] = nil
	self.mailInfos[mailId] = nil

	self:SetLocalMailsInfo(mailId, nil)
end

function M:RefreshMailFavor(id, favor)
	if not table.isNilOrEmpty(self.mailBriefs[id]) then
		self.mailBriefs[id].IsFavorite = favor
	end

	if not table.isNilOrEmpty(self.mailInfos[id]) then
		self.mailInfos[id].IsFavorite = favor
	end
end

function M:RefreshMailIsRetrieved(id, IsRetrieved)
	if not table.isNilOrEmpty(self.mailBriefs[id]) then
		self.mailBriefs[id].IsRetrieved = IsRetrieved
	end

	if not table.isNilOrEmpty(self.mailInfos[id]) then
		self.mailInfos[id].IsRetrieved = IsRetrieved
	end

	self:RefreshRedDotByMailId(id)
end

function M:DetailTabMail(tabIndex, callback)
	local mailList = {}

	for k, v in pairs(self.mailBriefs) do
		local mailtab = self:GetMailsTabIndex(v.Id)

		if mailtab == tabIndex and self:CheckMailCanDelete(v.Id) then
			table.insert(mailList, v.Id)
		end
	end

	self:AskDeleteMails(mailList, callback)
end

function M:ReceiveAllMail(tabIndex, callback)
	local mailList = {}

	for k, v in pairs(self.mailBriefs) do
		local mailtab = self:GetMailsTabIndex(v.Id)

		if mailtab == tabIndex and self:CheckMailCanRecive(v.Id) then
			table.insert(mailList, v.Id)
		end
	end

	self:AskReciveAllMails(mailList, callback)
end

function M:CheckMailCanDelete(mailId)
	local brief = self.mailBriefs[mailId]

	if not brief then
		return true
	end

	return not self.redDot[mailId] and not brief.IsFavorite
end

function M:CheckMailCanRecive(mailId)
	local brief = self.mailBriefs[mailId]

	if not brief then
		return false
	end

	return brief.HasItem and not brief.IsRetrieved
end

function M:CheckCurrentTabCanDeleteAndRecive(tabIndex)
	local canDelete = false
	local canRecive = false

	for k, v in pairs(self.mailBriefs) do
		local mailtab = self:GetMailsTabIndex(v.Id)

		if mailtab == tabIndex then
			if self:CheckMailCanDelete(v.Id) then
				canDelete = true
			end

			if self:CheckMailCanRecive(v.Id) then
				canRecive = true
			end
		end

		if canDelete and canRecive then
			break
		end
	end

	return canDelete, canRecive
end

function M:GetMailsTabInfo()
	self.mailTabDict = {}

	for i = 0, MailTabConfig.count - 1 do
		local cfg = MailTabConfig.LoadAt(i)
		self.mailTabDict[cfg.Id] = {}
	end

	for k, v in pairs(self.mailBriefs) do
		local brief = v
		local tabIndex = self:GetMailsTabIndex(k)

		if not self.mailTabDict[tabIndex] then
			self.mailTabDict[tabIndex] = {}
		end

		table.insert(self.mailTabDict[tabIndex], brief.Id)
	end

	for i = 1, #self.mailTabDict do
		table.sort(self.mailTabDict[i], function (a, b)
			local aisNew = self.redDot[a]
			local bisNew = self.redDot[b]

			if aisNew ~= bisNew then
				return aisNew
			end

			local briefA = self.mailBriefs[a]
			local briefB = self.mailBriefs[b]

			if briefA.CreateTime ~= briefB.CreateTime then
				return briefB.CreateTime < briefA.CreateTime
			end

			return a < b
		end)
	end

	return self.mailTabDict
end

function M:GetTabInfo(tabIndex)
	local cfg = MailTabConfig.GetConfig(tabIndex)
	local ret = {
		id = cfg.Id,
		iconId = cfg.Icon,
		title = cfg.Title
	}

	return ret
end

function M:GetMailsTabIndex(mailId)
	local brief = self.mailBriefs[mailId]

	if not brief then
		return 1
	end

	local cfg = MailConfig.GetConfig(brief.MailId)

	return cfg and cfg.NewMailTab or 1
end

function M:GetMailsBrief(mailId)
	return self.mailBriefs[mailId]
end

function M:GetMailsInfo(mailId)
	return self.mailInfos[mailId]
end

function M:GetExtraParams(paramList)
	local list = {}

	if table.isNilOrEmpty(paramList) then
		return list
	end

	for i = 1, #paramList do
		local param = paramList[i]

		if param.ParamType == MailParameterType.ItemName then
			local itemConfig = ConsumableConfig.GetConfig(param.Data)

			if itemConfig then
				table.insert(list, itemConfig.Name)
			end
		elseif param.ParamType == MailParameterType.BuffName then
			local buffConfig = BuffConfig.GetConfig(param.Data)

			if buffConfig then
				table.insert(list, buffConfig.Name)
			end
		else
			table.insert(list, param.Data)
		end
	end

	return list
end

function M:GetNameWithParam(name, param)
	return gString.Format(name or "", unpack(self:GetExtraParams(param)))
end

function M:ValidPeriodFormat(expireTime)
	local validPeriod = math.ceil((expireTime - UXTime.GetNowUnixTime()) / 3600)

	if validPeriod <= 0 then
		return TextScriptTextConfig.GetConfig(89900306).Text, 0
	elseif validPeriod > 24 then
		return gString.Format(TextScriptTextConfig.GetConfig(89900071).Text, math.ceil(validPeriod / 24)), validPeriod
	elseif validPeriod > 0 then
		return gString.Format(TextScriptTextConfig.GetConfig(89900308).Text, validPeriod), validPeriod
	else
		return TextScriptTextConfig.GetConfig(89900309).Text, validPeriod
	end
end

function M:GetMailBriefInfo(mailId)
	local brief = self:GetMailsBrief(mailId)
	local cfg = MailConfig.GetConfig(brief.MailId)
	local dropItem = self:SetMailRawPropList(brief)
	local ret = {
		title = cfg and cfg.Title or self:GetNameWithParam(brief.Title, brief.TitleParams),
		senderName = cfg and cfg.Sender or brief.SenderName,
		validTimeStr = self:ValidPeriodFormat(brief.ExpireTime),
		hasAttachment = brief.HasItem,
		isFavorite = brief.IsFavorite,
		isNew = self.redDot[mailId],
		items = dropItem
	}

	return ret
end

function M:GetMailDetailInfo(mailId)
	local info = self:GetMailsInfo(mailId)

	if table.isNilOrEmpty(info) then
		return nil
	end

	local cfg = MailConfig.GetConfig(info.MailId)
	local dropItem = self:SetMailRawPropList(info)
	local content = cfg and cfg.ComponentText or info.Content
	content = self:GetNameWithParam(content, info.ContentParams)
	local ret = {
		title = cfg and cfg.Title or self:GetNameWithParam(info.Title, info.TitleParams),
		content = string.gsub(content, "\\n", "\n"),
		senderName = cfg and cfg.Sender or info.SenderName,
		validTimeStr = self:ValidPeriodFormat(info.ExpireTime),
		hasAttachment = info.HasAttachment,
		isFavorite = info.IsFavorite,
		isNew = self.redDot[mailId],
		items = dropItem,
		createTimeDayStr = gTimeUtils:DateFormat("%d-%02d-%02d", info.CreateTime),
		createTimeHourStr = gTimeUtils:DateFormatDetail("%02d:%02d", info.CreateTime),
		isRetrieved = info.IsRetrieved
	}

	return ret
end

function M:SaveLocalMailInfo()
	gUIUtils:SaveLuaTableToJsonWithPid(StaticProps.LOCAL_MAILS_INFO_PATH, self.LocalMailsInfo)
end

function M:LoadLocalMailInfo()
	self.LocalMailsInfo = gUIUtils:LoadJsonToLuaTableWithPid(StaticProps.LOCAL_MAILS_INFO_PATH) or {}
end

function M:GetMailReadState(id)
	local info = self:GetLocalMailsInfo(id)

	return info == true
end

function M:GetLocalMailsInfo(mailId)
	if not mailId then
		return
	end

	return self.LocalMailsInfo[ulong.tostring(mailId)]
end

function M:SetLocalMailsInfo(mailId, value)
	if not mailId then
		return
	end

	self.LocalMailsInfo[ulong.tostring(mailId)] = value

	if value == nil then
		local redKey = self:GetRedDot(self:GetMailsTabIndex(mailId), mailId)

		RedDotMgr.LuaSetRedDot(false, redKey)
	else
		self:RefreshRedDotByMailId(mailId)
	end
end

function M:RefreshRedDot()
	for mailId, brief in pairs(self.mailBriefs) do
		self:RefreshRedDotByMailId(mailId)
	end
end

function M:RefreshRedDotByMailId(mailId)
	local brief = self:GetMailsBrief(mailId)

	if not brief then
		return
	end

	local hasNew = self:GetMailReadState(mailId) ~= true or brief.HasItem and not brief.IsRetrieved
	local redKey = self:GetRedDot(self:GetMailsTabIndex(mailId), mailId)

	RedDotMgr.LuaSetRedDot(hasNew, redKey)

	self.redDot[mailId] = hasNew
end

function M:SetMailRawPropList(msg)
	local ret = {}
	local attachment = msg.Attachment or {}

	if attachment.Exp and attachment.Exp > 0 then
		table.insert(ret, {
			itemId = ConsumableConfig.RewardExp,
			itemNum = attachment.Exp
		})
	end

	if attachment.UnbindMoney and attachment.UnbindMoney > 0 then
		local cfg = ConsumableConfig.GetConfig(ConsumableConfig.RewardMoney)

		table.insert(ret, {
			itemId = ConsumableConfig.RewardMoney,
			itemNum = attachment.UnbindMoney
		})
	end

	if attachment.BindGold and attachment.BindGold > 0 then
		table.insert(ret, {
			itemId = ConsumableConfig.RewardBindingGold,
			itemNum = attachment.BindGold
		})
	end

	if attachment.PayGold and attachment.PayGold > 0 or attachment.FreeGold and attachment.FreeGold > 0 then
		table.insert(ret, {
			itemId = ConsumableConfig.RewardGold,
			itemNum = gUIUtils:BuildLargeNumStr(attachment.PayGold + attachment.FreeGold)
		})
	end

	if attachment.ItemId and attachment.ItemId > 0 then
		table.insert(ret, {
			itemNum = 1,
			itemId = attachment.ItemId
		})
	end

	if attachment.Items and attachment.Items.Length > 0 then
		for k, v in ipairs(attachment.Items) do
			table.insert(ret, {
				itemId = v.TemplateId,
				itemNum = v.Count
			})
		end
	end

	return ret
end

function M:AddMailMailByServer(mailHead)
	self:AddMailBrief(mailHead)

	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.MailUnlock) then
		return
	end

	self:RefreshRedDot()
	self:SendNumChange()
end

function M:DeleteMailByServer(id)
	self:RemoveMail(id)
	self:SendNumChange()
end

function M:SendNumChange()
	gMessageManager:SendMessage(gEventConstants.MAILS_NUM_CHANGE)
end

function M:GetRedDot(tabIndex, mailId)
	return ("Mail/Mail.Tab:%d/Mail:%s"):format(tabIndex - 1, ulong.tostring(mailId))
end

function M:OpenSurvey()
	local url = CompensationConfig.MobileSurveyUrl

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		url = CompensationConfig.StandAloneSurveyUrl
	end

	self.LocalMailsInfo[ulong.tostring(ulong.zero)] = true

	gRedPointMgr:RegisterRedDotByKey(LTConfig.PanelRedDotConfig.Survey, false)
	self:SaveLocalMailInfo()
	self:OpenWebView(url)
end

function M:CheckSurveyRead()
	local red = self:GetLocalMailsInfo(ulong.zero)
	local unlocked = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Survey)

	gRedPointMgr:RegisterRedDotByKey(LTConfig.PanelRedDotConfig.Survey, not red and unlocked)
end

function M:OpenWebView(url)
	WebViewManager.Instance:OpenWebView(url)
end

gNewMailsMgr = gNewMailsMgr or C_NewMailsMgr.new()
