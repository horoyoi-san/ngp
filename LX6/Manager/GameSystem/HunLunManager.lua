-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\HunLunManager.lua
-- Decompiled from: 02188_HunLunManager.lua_b4c55d6efaef.luajit

local SocialMediaTabConfig = LTConfig.SocialMediaTabConfig
local ImageAvatar = LTConfig.ImageNewAvatarConfig
local MessageConfig = LTConfig.MessageConfig
local PersonalZoneHeadType = UX.Game.PersonalZoneHeadType
local NameCheckResult = UX.Utils.NameValidityChecker.NameCheckResult
local ConsumableConfig = LTConfig.ConsumableConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local MallMainTabConfig = LTConfig.MallMainTabConfig
local SocialMediaConfig = LTConfig.SocialMediaConfig
local LingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local StaticProps = {}
C_HunLunManager = DefClass("C_HunLunManager", C_HunLunManager, nil, StaticProps)
local M = C_HunLunManager

M.ctor = function(self)
	self:OnInit()
end

M.OnInit = function(self)
	self.changeNameCount = 0
	self.isSelf = false
	self.roleId = 0
	self.roleInfo = {}
	self.birthdayCode = 0
	self.personalInfoCache = nil
end

M.GetBirth = function(self, code)
	if code ~= nil or code ~= 0 then
		return "--/--"
	end

	return math.floor(code / 100) .. "/" .. code % 100
end

M.GetRoleList = function(self, data)
	local list = {}

	for i = 1, SocialMediaConfig.MaxShowRole do
		table.insert(list, {
			["C\\xbe\\xa1\\x86\\xb2"] = 0
		})
	end

	for i, v in ipairs(data) do
		list[i] = {
			npcId = v.Id
		}
	end

	return list
end

M.InitPersonalInfo = function(self, roleId, callback)
	roleId = roleId or gPlayerManager.infoLogin.bindData.pid
	self.npcShareTimeInfo = {}
	self.isSelf = roleId ~= gPlayerManager.infoLogin.bindData.pid
	self.roleId = roleId

	self:GetPersonalInfo(self.roleId, function (data)
		if not data then
			return
		end

		if self.isSelf then
			self.roleInfo = self:UseLocalData(data)

			if callback then
				callback()
			end

			return
		end

		local isFriend = gFriendManager:IsFriend(self.roleId)
		self.birthdayCode = data.Birthday
		self.roleInfo = {
			isFriend = isFriend,
			showAddFriend = not self.isSelf and not isFriend,
			birthday = self:GetBirth(data.Birthday),
			changeBirthAble = data.Birthday ~= 0,
			userName = data.RoleName,
			sign = data.Signature or "",
			fightSpirit = self:GetRoleList(data.BestNpcFriends)
		}

		if callback then
			callback()
		end
	end)
end

M.GetCurrentBestNpcFriend = function(self)
	local bestNpcFriend = {}
	local npcFriend = self:GetBestNpcs({})

	for i = 1, #npcFriend do
		local cId = npcFriend[i].id
		local index = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfosDic[cId]
		local member = index and gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos[index] or {}

		if not table.isNilOrEmpty(member) then
			local ele = {
				["1\\xebP;,\\xd1\n\\xb9S\\x95_\\xbd\\xb3"] = false,
				["Ԓ\\xfb:\\xf0\\xf8\\xa4\\xe8\\x94%$"] = false,
				Id = member.TemplateId,
				Favor = member.Favor,
				InteractDays = member.InteractDays
			}
			bestNpcFriend[#bestNpcFriend + 1] = ele
		end
	end

	table.sort(bestNpcFriend, function (a, b)
		if a.Favor ~= b.Favor then
			return b.InteractDays <= a.InteractDays
		end

		return b.Favor <= a.Favor
	end)

	for i = 4, #bestNpcFriend do
		bestNpcFriend[i] = nil
	end

	return bestNpcFriend
end

M.UseLocalData = function(self, data)
	self.birthdayCode = data.Birthday or 0
	local bestNpcFriend = self:GetCurrentBestNpcFriend()
	local fightSpirit = self:GetRoleList(not table.isNilOrEmpty(data.BestNpcFriends) and data.BestNpcFriends or bestNpcFriend)
	local ret = {
		["\\xa2\\xa2#\\xb9c;\\xf07"] = false,
		["\\xebP;+\\xd4\\x90S\\xa8S\\xbe\\xb2"] = false,
		changeBirthAble = data.Birthday ~= 0,
		birthday = self:GetBirth(data.Birthday),
		userName = data.RoleName or gPlayerManager.infoLogin.bindData.name,
		sign = data.Signature or "",
		fightSpirit = fightSpirit
	}

	return ret
end

M.ContentIsEmpty = function(self, str)
	for i = 1, #str do
		if string.sub(str, i, i) == "\n" and string.sub(str, i, i) == " " then
			return false
		end
	end

	return true
end

M.tablesEqual = function(self, t1, t2)
	if type(t1) == "table" or type(t2) == "table" then
		return false
	end

	local t1_size = 0
	local t2_size = 0

	for _ in pairs(t1) do
		t1_size = t1_size + 1
	end

	for _ in pairs(t2) do
		t2_size = t2_size + 1
	end

	if t1_size == t2_size then
		return false
	end

	for k, v in pairs(t1) do
		if type(v) ~= "table" and type(t2[k]) ~= "table" then
			if not self:tablesEqual(v, t2[k]) then
				return false
			end
		elseif v == t2[k] then
			return false
		end
	end

	return true
end

local baseInfoUrl, updateUrl = nil

M.GetPersonalInfo = function(self, targetId, callback, doCache)
	if doCache and self.personalInfoCache then
		callback(self.personalInfoCache)

		return
	end

	local task = gClientToGameDelegate:GetPersonalInfo()

	task.Callback = function(err, data0)
		if err == nil and err == 0 then
			print_error("[HunlunManager] GetPersonalInfo RPC失败", err, data0)
			callback(nil)

			self.personalInfoCache = nil

			return
		end

		callback(data0)

		self.personalInfoCache = data0
	end
end

M.OpenPersonalInfoPanel = function(self, roleId)
	if not gSpiritManager:CheckIsMainCharacter() then
		return
	end

	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.BubbleUnlock) then
		return
	end

	self:InitPersonalInfo(roleId, function ()
		gNewBubbleMgr:SwitchCurrentPanel({
			secondShowType = SocialMediaTabConfig.Personal
		})
	end)
end

M.ChangeSign = function(self, sign, callback)
	if self.inSendingSign then
		return
	end

	gClientUtils.EnvSdkReviewWords(sign, function ()
		if self.inSendingSign then
			return
		end

		self.inSendingSign = sign

		self:SendChangeSign(sign, callback)
	end, function ()
		gDisplayMessageMgr:ShowMessage(MessageConfig.FilesCheck)
	end, "Hunlun")
end

M.ShowChangeSign = function(self)
	gDisplayMessageMgr:ShowBomb({
		["\\xd0\\xc8=1\\xe5"] = true,
		exceedLength = SocialMediaConfig.MaxSignLength,
		exceedLengthMsg = SocialMediaConfig.SignExceedLengthMsg,
		msgType = gDisplayMessageId.SELECT,
		titleText = LTConfig.TextScriptTextConfig.GetConfig(89900818).Text,
		btnConfirmCallback = self:CreateAction("ChangeSign", gHunLunManager)
	})
end

M.CreateAction = function(self, action, target)
	return function (...)
		target = target or self

		if type(action) ~= "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

M.ChangeBirth = function(self, month, day, callback)
	gDisplayMessageMgr:ShowMessage(MessageConfig.ChangeBirth, function ()
		self:SendChangeBirth(month, day, callback)
	end, function ()
	end, month, day)
end

M.GetHeadIconList = function(self, UnlockedSystemHeadList)
	local listDic = {}
	local list = {}

	for i, v in ipairs(UnlockedSystemHeadList) do
		listDic[v.Id] = i
	end

	for i = 0, ImageAvatar.count - 1 do
		local cfg = ImageAvatar.LoadAt(i)

		if listDic[cfg.Id] then
			local use = gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId ~= cfg.Id
			local ele = {
				["a\\x9f\\x8a\\x86Y"] = 1,
				id = cfg.Id,
				icon = cfg.SguiImageId,
				selected = use,
				isUsed = use,
				name = cfg.ImageName
			}

			table.insert(list, ele)
		end
	end

	return list
end

M.GetBadgeList = function(self, badgeData)
	local list = {}

	return list
end

M.GetHeadIconAndName = function(self, avatarId)
	local cfg = ImageAvatar.GetConfig(avatarId)

	return cfg and cfg.SguiImageId, cfg and cfg.ImageName or "", ""
end

local NameCheckResultStr = gClientUtils.NameCheckResultStr
M.NameCheckResultStr = NameCheckResultStr
local RENAME_CARD_LACK_MESSAGE = MessageConfig.ItemNotEnough
local RENAME_CUSTOM_MESSAGE = MessageConfig.NameInvalidMessage or MessageConfig.NameInvalid
local RENAME_SAME_NAME_MSG = MessageConfig.NameSameAsCurrent or 75109955
local RENAME_AI_VOICE_DISABLE_MSG = MessageConfig.VoiceCallDisable or 75109958
local RENAME_AI_VOICE_ENABLE_MSG = MessageConfig.VoiceCallEnable or 75109956
local RENAME_CD_TEXT_DAY = 89901533
local RENAME_CD_TEXT_HOUR = 89901534
local RENAME_CD_TEXT_MINUTE = 89901535

M.SyncLastChangeNameTime = function(self, timeStamp)
	if not gPlayerManager.infoLogin or not gPlayerManager.infoLogin.bindData then
		return
	end

	gPlayerManager.infoLogin.bindData.lastChangeNameTime = timeStamp or 0
end

M.GetRenameCDSeconds = function(self)
	local days = LTConfig.GameConfig.MinRenameDays or 7

	return days * 86400
end

M.GetRenameRemainSeconds = function(self)
	local bindData = gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData
	local lastChangeNameTime = bindData and bindData.lastChangeNameTime or 0

	if not lastChangeNameTime or lastChangeNameTime < 0 then
		return 0
	end

	local serverTime = gCS.TimeManager.ServerUnixTime

	return math.max(0, lastChangeNameTime + self:GetRenameCDSeconds() - serverTime)
end

M.GetRenameRemainText = function(self, remainSeconds)
	remainSeconds = math.max(0, math.floor(remainSeconds or 0))
	local day = math.floor(remainSeconds / 86400)
	local hour = math.floor(remainSeconds % 86400 / 3600)
	local minute = math.ceil(remainSeconds % 3600 / 60)

	if minute > 60 then
		minute = 0
		hour = hour + 1
	end

	if hour > 24 then
		hour = 0
		day = day + 1
	end

	local TextCfg = LTConfig.TextScriptTextConfig
	local cfg = nil

	if day <= 0 then
		cfg = TextCfg.GetConfig(RENAME_CD_TEXT_DAY)
	elseif hour <= 0 then
		cfg = TextCfg.GetConfig(RENAME_CD_TEXT_HOUR)
	else
		cfg = TextCfg.GetConfig(RENAME_CD_TEXT_MINUTE)
		minute = math.max(1, minute)
	end

	if not cfg or string.is_null_or_empty(cfg.Text) then
		print_error("[HunLunManager] GetRenameRemainText config missing, day:", day, "hour:", hour, "minute:", minute)

		return ""
	end

	if day <= 0 then
		return gString.Format(cfg.Text, day, hour, minute)
	end

	if hour <= 0 then
		return gString.Format(cfg.Text, hour, minute)
	end

	return gString.Format(cfg.Text, minute)
end

M.ShowRenameTextMessage = function(self, text)
	if text and text == "" then
		gDisplayMessageMgr:ShowMessageContent(text)
	else
		print_error("[HunLunManager] rename message missing: ", text)
	end
end

M.IsSameAsCurrentPlayerName = function(self, name)
	local bindData = gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData
	local currentName = bindData and bindData.playerName or nil

	return not string.is_null_or_empty(name) and name ~= currentName
end

M.GetSameNameTip = function(self)
	local cfg = MessageConfig.GetConfig(RENAME_SAME_NAME_MSG)

	return cfg and cfg.Content or ""
end

M.CheckInputName = function(self, text)
	if self:ContentIsEmpty(text) then
		return false, ""
	end

	if self:IsSameAsCurrentPlayerName(text) then
		return false, self:GetSameNameTip()
	end

	return gClientUtils.CheckNameFormat(text, LTConfig.GameConfig.PlayerNameMinLength, LTConfig.GameConfig.PlayerNameMaxLength)
end

M.GetUtf8CodePoint = function(self, str, index)
	local b1 = string.byte(str, index)

	if not b1 then
		return nil, index + 1
	end

	if b1 >= 128 then
		return b1, index + 1
	end

	local b2 = string.byte(str, index + 1)

	if b1 > 194 and b1 >= 224 and b2 then
		return (b1 - 192) * 64 + b2 - 128, index + 2
	end

	local b3 = string.byte(str, index + 2)

	if b1 > 224 and b1 >= 240 and b2 and b3 then
		return (b1 - 224) * 4096 + (b2 - 128) * 64 + b3 - 128, index + 3
	end

	local b4 = string.byte(str, index + 3)

	if b1 > 240 and b1 >= 245 and b2 and b3 and b4 then
		return (b1 - 240) * 262144 + (b2 - 128) * 4096 + (b3 - 128) * 64 + b4 - 128, index + 4
	end

	return nil, index + 1
end

M.IsAllChinese = function(self, str)
	if self:ContentIsEmpty(str) then
		return false
	end

	local index = 1

	while index < #str do
		local codePoint, nextIndex = self:GetUtf8CodePoint(str, index)

		if not codePoint or codePoint <= 19968 or codePoint <= 40959 then
			return false
		end

		index = nextIndex
	end

	return true
end

M.TryStartRename = function(self)
	local remainSeconds = self:GetRenameRemainSeconds()

	if remainSeconds <= 0 then
		self:ShowRenameTextMessage(self:GetRenameRemainText(remainSeconds))

		return false
	end

	local renameCardCount = gCommonItemManager:GetPackItemNum(ConsumableConfig.RenameCard) or 0

	if renameCardCount >= 1 then
		gDisplayMessageMgr:ShowMessage(75109951, function ()
			self:OpenRenameCardMall()
		end)

		return false
	end

	self:ShowChangeName()

	return true
end

M.OpenRenameCardMall = function(self)
	if not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.ShopUnlock) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MallLock)

		return
	end

	gPanelManager:CheckShow(gPanelId.SHOP_HOME_PAGE, {
		["\\xb8\\xa4\\x9fk<\\xd77"] = 0,
		["\\x9c;-2w\\x99H\\xcd.\\x83\\xbd"] = 0,
		tabId = MallMainTabConfig and MallMainTabConfig.Sale or nil
	})
end

M.ShowChangeName = function(self)
	gDisplayMessageMgr:ShowBomb({
		["\\xea2\\xa2\\xe0\\xe2\\x98\\xe1\\xf6\\xbe\\x81\\xc0\\x804\\xf7\\xbd6\\x84\\xf8W\\x96\\xa1 \\x83"] = true,
		["\\xd0\\xc8=1\\xe5"] = true,
		inputCheck = self:CreateAction("CheckInputName", gHunLunManager),
		onValidateChar = function (text, charIndex, addedChar)
			if addedChar ~= string.byte(" ") then
				return 0
			end

			return addedChar
		end,
		exceedLength = LTConfig.GameConfig.PlayerNameMaxLength,
		exceedLengthMsg = MessageConfig.GetConfig(NameCheckResultStr[NameCheckResult.NameTooLong]).Content,
		placeHolder = MessageConfig.GetConfig(65400666).Content,
		msgType = gDisplayMessageId.SELECT,
		titleText = LTConfig.TextScriptTextConfig.GetConfig(89900812).Text,
		btnConfirmCallback = self:CreateAction("ChangeName", gHunLunManager)
	})
end

M.ShowRenameVoicePromptIfNeeded = function(self, name, callback, done)
	local bindData = gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData
	local oldName = bindData and bindData.playerName or ""
	local oldAllChinese = self:IsAllChinese(oldName)
	local newAllChinese = self:IsAllChinese(name)
	local confirmCallback = callback

	if oldAllChinese == newAllChinese then
		if newAllChinese then
			confirmCallback = function()
				gDisplayMessageMgr:ShowMessage(RENAME_AI_VOICE_ENABLE_MSG, function ()
					self:EnableVoiceCallAfterRename()

					if callback then
						callback()
					end
				end, function ()
					self:DisableVoiceCallAfterRename()

					if callback then
						callback()
					end
				end)
			end
		else
			confirmCallback = function()
				gDisplayMessageMgr:ShowMessage(RENAME_AI_VOICE_DISABLE_MSG, function ()
					if callback then
						callback()
					end
				end)
			end
		end
	end

	self:ShowChangeNameConfirm(name, confirmCallback)
end

M.ShowChangeNameConfirm = function(self, name, callback)
	local costItem = gCommonItemManager:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 1,
		itemId = ConsumableConfig.RenameCard
	})
	local bindData = gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData
	local oldName = bindData and bindData.playerName or ""
	local oldAllChinese = self:IsAllChinese(oldName)
	local newAllChinese = self:IsAllChinese(name)
	local confirmMessageId = oldAllChinese and not newAllChinese and 75109978 or 75109957
	local msgCfg = MessageConfig.GetConfig(confirmMessageId)
	local confirmText = msgCfg and gString.Format(msgCfg.Content, name) or name

	gDisplayMessageMgr:ShowBomb({
		["\\xd0\\xc8=1\\xe5"] = false,
		msgType = gDisplayMessageId.SELECT,
		titleText = LTConfig.TextScriptTextConfig.GetConfig(89900812).Text,
		costText = confirmText,
		costItemList = {
			costItem
		},
		btnConfirmCallback = function (_, done)
			self:SendChangeName(name, callback, done)

			return gDisplayMessageMgr.CONFIRM_ASYNC
		end
	})
end

M.EnableVoiceCallAfterRename = function(self)
	gClientToGameDelegate:AskChangeRoleUseSystemName(false).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		local bindData = gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData

		if bindData then
			bindData.UsePlayerName = true
		end

		if gCS.MyPlayerManager.PlayerInfo then
			gCS.MyPlayerManager.PlayerInfo.UsePlayerName = true
		end

		gSpiritManager:RefreshMainSpiritName()
	end

	local ProfileManager = LX6.Engine.ProfileManager
	local gameProfile = ProfileManager.gameProfile
	gameProfile.isVoiceCallEnabled = true

	ProfileManager.SaveGameProperty()

	local ShezhiPanelShezhiConfig = LTConfig.ShezhiPanelShezhiConfig
	local voiceCallId = ShezhiPanelShezhiConfig.CallNameVoice
	local cfg = ShezhiPanelShezhiConfig.GetConfig(voiceCallId)

	if cfg and cfg.SubTemplate and gSettingServerManager then
		for _, sub in ipairs(cfg.SubTemplate) do
			if sub.type ~= 0 then
				gSettingServerManager:SetTemplate11Value(voiceCallId, sub.data, sub.valueType or "number", 1)

				break
			end
		end

		gSettingServerManager:FlushServerSettings()
	end
end

M.DisableVoiceCallAfterRename = function(self)
	local ProfileManager = LX6.Engine.ProfileManager
	local gameProfile = ProfileManager.gameProfile
	gameProfile.isVoiceCallEnabled = false

	ProfileManager.SaveGameProperty()

	local ShezhiPanelShezhiConfig = LTConfig.ShezhiPanelShezhiConfig
	local voiceCallId = ShezhiPanelShezhiConfig.CallNameVoice
	local cfg = ShezhiPanelShezhiConfig.GetConfig(voiceCallId)

	if cfg and cfg.SubTemplate and gSettingServerManager then
		for _, sub in ipairs(cfg.SubTemplate) do
			if sub.type ~= 0 then
				gSettingServerManager:SetTemplate11Value(voiceCallId, sub.data, sub.valueType or "number", 2)

				break
			end
		end

		gSettingServerManager:FlushServerSettings()
	end
end

M.ChangeName = function(self, name, done)
	if self.inSendingName then
		return false
	end

	if self:ContentIsEmpty(name) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.FilesNameNone)

		return false
	end

	if self:IsSameAsCurrentPlayerName(name) then
		gDisplayMessageMgr:ShowMessage(RENAME_SAME_NAME_MSG)

		return false
	end

	local ok, errMsg = gClientUtils.CheckNameFormat(name, LTConfig.GameConfig.PlayerNameMinLength, LTConfig.GameConfig.PlayerNameMaxLength)

	if not ok then
		if errMsg and errMsg == "" then
			gDisplayMessageMgr:ShowMessageContent(errMsg)
		end

		return false
	end

	local newName = name

	gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_VOICE_CALL_PINYIN, name)
	gClientUtils.EnvSdkReviewWords(newName, function ()
		if done then
			done(true)
		end

		self:ShowRenameVoicePromptIfNeeded(newName)
	end, function ()
		gDisplayMessageMgr:ShowMessage(MessageConfig.FilesCheck)

		if done then
			done(false)
		end
	end, "Hunlun")

	return gDisplayMessageMgr.CONFIRM_ASYNC
end

M.SendChangeName = function(self, name, callback, done)
	if self.inSendingName then
		return
	end

	self.inSendingName = name

	gClientToGameDelegate:AskChangeNameByItem(name).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if done then
				done(false)
			end
		else
			if done then
				done(true)
			else
				gDisplayMessageMgr:CloseBomb()
			end

			gDisplayMessageMgr:ShowMessage(MessageConfig.PzNoteSave or MessageConfig.FilesCheck)
			self:ApplyPlayerNameChange(name)

			if callback then
				callback()
			end

			gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
		end

		self.inSendingName = nil
	end
end

M.ApplyPlayerNameChange = function(self, name)
	self.roleInfo.userName = name

	self:ApplyPlayerNameLocally(name)

	local bindData = gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData

	if gLinkPlayerHub and bindData and bindData.pid then
		gLinkPlayerHub:UpdatePlayerName(bindData.pid, name)
	end

	gMessageManager:SendMessage(gEventConstants.PLAYER_CHANGE_NAME, {
		Pid = bindData and bindData.pid,
		Name = name
	})
end

M.ApplyPlayerNameLocally = function(self, name)
	local bindData = gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData

	if bindData then
		bindData.playerName = name

		if bindData.UsePlayerName then
			bindData.name = name
		end
	end

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.MyPlayerManager.PlayerUnit.ClientData.Name = name
	end

	if gCS.MyPlayerManager.PlayerInfo then
		gCS.MyPlayerManager.PlayerInfo.Name = name
	end

	UniSDKManager.OnUserNameChange(name)
	gSpiritManager:RefreshMainSpiritName()
	LX6.Utils.DRPFUtils.Clear()
end

M.GetHeadIconInfo = function(self, callback)
	gClientToGameDelegate:QueryPersonalZoneHeadExtendInfo().Callback = function (err, iconData)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		elseif callback then
			callback(iconData)
		end
	end
end

M.SendChangeBirth = function(self, month, day, callback)
	local birthdayCode = month * 100 + day

	gClientToGameDelegate:AskUpdatePersonalZoneBirthday(birthdayCode).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			self.birthdayCode = birthdayCode
			self.roleInfo.changeBirthAble = false
			self.roleInfo.birthday = self:GetBirth(birthdayCode)

			if callback then
				callback()
			end

			gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
		end
	end
end

M.SendChangeSign = function(self, sign, callback)
	gClientToGameDelegate:AskUpdatePersonalZoneDescription(self.roleId, sign).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			self.roleInfo.sign = sign

			if callback then
				callback()
			end

			gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
		end

		self.inSendingSign = nil
	end
end

M.SendChangeHeadIcon = function(self, avatarId, callback)
	if gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId ~= avatarId then
		if callback then
			callback()
		end

		return
	end

	gClientToGameDelegate:AskUpdatePersonalZoneHead(PersonalZoneHeadType.System, avatarId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.FilesAvatar)

			gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId = avatarId
			self.roleInfo.headIcon = self:GetHeadIconAndName(avatarId)

			if callback then
				callback()
			end
		end
	end
end

M.SendChangeBadge = function(self, badgeList, areaId, callback)
	if self:tablesEqual(self.roleInfo.reputation[areaId].badgeList, badgeList) then
		if callback then
			callback()
		end

		return
	end

	local sendList = {}

	for i = 1, #badgeList do
		if badgeList[i].hide == true then
			local ele = {
				AchieveId = badgeList[i].id,
				Index = i,
				CountryId = areaId
			}

			table.insert(sendList, ele)
		end
	end

	gClientToGameDelegate:AskUpdatePersonalZoneAchieveList(sendList, areaId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.FilesAchievementUp)

			self.roleInfo.reputation[areaId].badgeList = badgeList

			if callback then
				callback()
			end
		end
	end
end

M.SendChangeSpirit = function(self, fightList, callback)
	if self:tablesEqual(self.roleInfo.fightSpirit, fightList) then
		if callback then
			callback()
		end

		return
	end

	local sendList = {}

	for i = 1, #fightList do
		if fightList[i].hide == true then
			local ele = {
				Id = fightList[i].id,
				Index = i,
				ShowFavorLevel = fightList[i].showFavorLevel or false,
				ShowFavorTime = fightList[i].showFavorTime or false
			}

			table.insert(sendList, ele)
		end
	end

	gClientToGameDelegate:AskSetBestNpcs(sendList).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			self.roleInfo.fightSpirit = fightList

			if callback then
				callback()
			end
		end
	end
end

M.GetBestNpcs = function(self, fightSpirit)
	local lingList = LingGuiUtils:GetAllLingList()
	local favorInfos = gNpcFavorManager:GetAllSpiritFavorInfo()
	local timeInfos = gNpcFavorManager:GetRoleTimeDict()
	local blockDict = gNewBubbleMgr.blockDict
	local filters = {}
	local id2SelectIndex = {}

	for i = 1, #SocialMediaConfig.BestieFilter do
		local filter = SocialMediaConfig.BestieFilter[i]
		filters[filter.BestieFilterName] = filter.Limit
	end

	for i = 1, #fightSpirit do
		if fightSpirit[i].hide == true then
			id2SelectIndex[fightSpirit[i].id] = i
		end
	end

	local showList = {}

	for i = 1, #lingList do
		local tId = lingList[i].Tid
		local cId = gSpiritManager.fight2Cultivation[tId]

		if cId and blockDict[cId] == true then
			local favorInfo = favorInfos[cId] or {}
			local timeInfo = timeInfos[cId] or 0

			if not table.isNilOrEmpty(favorInfo) and filters.NpcFavorLimit > favorInfo.favor or filters.NpcSparkDays < timeInfo then
				local ele = {
					["[\\xa4\\x9d\\x86E"] = false,
					["a\\x9f\\x8a\\x86Y"] = 2,
					headIcon = lingList[i].sIcon,
					name = lingList[i].Name,
					id = cId,
					favorLevel = favorInfo.favorLevel or 0,
					favorAmount = favorInfo.favorAmount or 0,
					totTime = timeInfos[cId] or 0,
					selected = id2SelectIndex[cId] == nil,
					selectedIndex = id2SelectIndex[cId] or 0
				}

				table.insert(showList, ele)
			end
		end
	end

	return showList
end

gHunLunManager = gHunLunManager or C_HunLunManager.new()
