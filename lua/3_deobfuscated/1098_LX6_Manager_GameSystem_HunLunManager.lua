local json = require("cjson/json")
local SocialMediaTabConfig = LTConfig.SocialMediaTabConfig
local ImageAvatar = LTConfig.ImageAvatarConfig
local CollectionCountryConfig = LTConfig.CollectionCountryConfig
local MessageConfig = LTConfig.MessageConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local PersonalZoneHeadType = UX.Game.PersonalZoneHeadType
local NameCheckResult = UX.Utils.NameValidityChecker.NameCheckResult
local ConsumableConfig = LTConfig.ConsumableConfig
local SocialMediaConfig = LTConfig.SocialMediaConfig
local LingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local StaticProps = {}
C_HunLunManager = DefClass("C_HunLunManager", C_HunLunManager, nil, StaticProps)
local M = C_HunLunManager

function M:ctor()
	self:OnInit()
end

function M:OnInit()
	self.changeNameCount = 0
	self.isSelf = false
	self.roleId = 0
	self.roleInfo = {}
	self.birthdayCode = 0
end

function M:SelfRoleIdStr()
	return ulong.tostring(gPlayerManager.infoLogin.bindData.pid)
end

function M:GetFansNum()
	if self.roleInfo then
		return self.roleInfo.fanCount, self.roleInfo.newFansCount
	end

	return 0, 0
end

function M:GetBirth(code)
	if code == nil or code == 0 then
		return "--/--"
	end

	return math.floor(code / 100) .. "/" .. code % 100
end

function M:GetRoleList(data)
	local list = {}

	for i = 1, SocialMediaConfig.MaxShowRole do
		table.insert(list, {
			npcId = 0
		})
	end

	for i, v in ipairs(data) do
		list[i] = {
			npcId = v.Id
		}
	end

	return list
end

function M:GetFriendUseTime(data)
	local tot = 0

	for i = 1, #data do
		local durationTime = self:GetDurationTime(data[i])
		local id = data[i].id or data[i].Id
		self.npcShareTimeInfo[id] = durationTime
		tot = tot + durationTime
	end

	return tot
end

function M:GetDurationTime(data)
	local id = data.id or data.Id

	if id == NpcCultivationConfig.DefaultFemale or id == NpcCultivationConfig.DefaultMale then
		return 0
	end

	local duration = data.SwitchInTime ~= 0 and data.FightShareDuration + gCS.TimeManager.ServerUnixTime - data.SwitchInTime or data.FightShareDuration

	return duration
end

function M:GetBadgeIconByQualityId(id)
	local quality = id % 10
	local fId = math.floor(id / 10)
	local cfg = LTConfig.AchievementFirstCategoryConfig.GetConfig(fId)

	if cfg then
		if quality == M.AchievementQuality.Copper then
			return ConsumableConfig.GetConfig(cfg.CopperBadge).SItemIconId
		elseif quality == M.AchievementQuality.Sliver then
			return ConsumableConfig.GetConfig(cfg.SilverBadge).SItemIconId
		elseif quality == M.AchievementQuality.Gold then
			return ConsumableConfig.GetConfig(cfg.GoldBadge).SItemIconId
		end
	end

	return 0
end

function M:GetReputation(data)
	local placeList = {}
	local areas = data.areas or {}

	for i = 0, CollectionCountryConfig.count - 1 do
		local countryCfg = CollectionCountryConfig.LoadAt(i)
		local index = i + 1
		local rate = areas[index] and areas[index].exploreDegree or 0
		local badgeList = {}

		for _ = 1, 3 do
			local ele = {
				id = 0,
				icon = 0,
				hide = true
			}

			table.insert(badgeList, ele)
		end

		for j = 1, #data.achievementSelect do
			if data.achievementSelect[j].country == countryCfg.Id then
				local ele = {
					hide = false,
					icon = self:GetBadgeIconByQualityId(data.achievementSelect[j].id),
					id = data.achievementSelect[j].id
				}
				badgeList[data.achievementSelect[j].index] = ele
			end
		end

		local ele = {
			areaName = countryCfg.Name,
			areaRate = rate,
			areaId = countryCfg.Id,
			areaIcon = countryCfg.FilePicture,
			badgeList = badgeList
		}

		table.insert(placeList, ele)
	end

	return placeList
end

function M:InitPersonalInfo(roleId, callback)
	roleId = roleId or gPlayerManager.infoLogin.bindData.pid
	self.npcShareTimeInfo = {}
	self.isSelf = roleId == gPlayerManager.infoLogin.bindData.pid
	self.roleId = roleId

	self:GetRemainChangeNameCount()
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
		local avatarId = tonumber(data.avatar)
		local placeList = self:GetReputation(data)
		self.birthdayCode = data.birthday
		local headIcon, _ = self:GetHeadIconAndName(avatarId)
		local roleTime, _ = self:GetFriendUseTime(data.npcShareTimeInfo)
		self.roleInfo = {
			newBubbleLike = 0,
			newSpiritNum = 0,
			newFansCount = 0,
			isFriend = isFriend,
			showAddFriend = not self.isSelf and not isFriend,
			birthday = self:GetBirth(data.birthday),
			changeBirthAble = data.birthday == 0,
			useAvatar = avatarId,
			headIcon = headIcon,
			userName = data.roleName,
			sign = data.signature or "",
			roleCount = data.spiritNum,
			fanCount = data.totalFans,
			reputation = placeList,
			achievementNum = data.achievementNum,
			likeNum = data.bubbleLike,
			friendNum = data.friendCount,
			fightSpirit = self:GetRoleList(data.bestNpcFriends),
			miTuLevel = data.astrayLevel,
			roleTime = roleTime
		}

		if callback then
			callback()
		end
	end)
end

function M:GetCurrentBestNpcFriend()
	local bestNpcFriend = {}
	local npcFriend = self:GetBestNpcs({})

	for i = 1, #npcFriend do
		local cId = npcFriend[i].id
		local index = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfosDic[cId]
		local member = index and gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos[index] or {}

		if not table.isNilOrEmpty(member) then
			local ele = {
				ShowFavorTime = false,
				ShowFavorLevel = false,
				Id = member.TemplateId,
				Favor = member.Favor,
				InteractDays = member.InteractDays
			}
			bestNpcFriend[#bestNpcFriend + 1] = ele
		end
	end

	table.sort(bestNpcFriend, function (a, b)
		if a.Favor == b.Favor then
			return b.InteractDays < a.InteractDays
		end

		return b.Favor < a.Favor
	end)

	for i = 4, #bestNpcFriend do
		bestNpcFriend[i] = nil
	end

	return bestNpcFriend
end

function M:UseLocalData(data)
	self.birthdayCode = data.birthday or 0
	local headIcon, _ = self:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	local roleTime = self:GetFriendUseTime(data.npcShareTimeInfo)
	local bestNpcFriend = self:GetCurrentBestNpcFriend()
	local hasFavorCount = #gNewBubbleMgr:GetCurrentFavorNpcList()
	local fightSpirit = self:GetRoleList(not table.isNilOrEmpty(data.bestNpcFriends) and data.bestNpcFriends or bestNpcFriend)
	local ret = {
		showAddFriend = false,
		isFriend = false,
		changeBirthAble = data.birthday == 0,
		birthday = self:GetBirth(data.birthday),
		useAvatar = gImageManager.avatar,
		headIcon = headIcon,
		userName = gPlayerManager.infoLogin.bindData.name,
		sign = data.signature or "",
		roleCount = gSpiritManager:GetSpiritNum(),
		reputation = self:GetReputation(data),
		achievementNum = data.achievementNum,
		likeNum = hasFavorCount,
		friendNum = #gFriendManager.friendPids,
		fightSpirit = fightSpirit,
		miTuLevel = data.astrayLevel,
		roleTime = roleTime,
		fanCount = data.totalFans,
		newFansCount = data.newFans,
		newBubbleLike = data.newBubbleLike or 0,
		newSpiritNum = data.newSpiritNum or 0
	}

	return ret
end

function M:ContentIsEmpty(str)
	for i = 1, #str do
		if string.sub(str, i, i) ~= "\n" and string.sub(str, i, i) ~= " " then
			return false
		end
	end

	return true
end

function M:tablesEqual(t1, t2)
	if type(t1) ~= "table" or type(t2) ~= "table" then
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

	if t1_size ~= t2_size then
		return false
	end

	for k, v in pairs(t1) do
		if type(v) == "table" and type(t2[k]) == "table" then
			if not self:tablesEqual(v, t2[k]) then
				return false
			end
		elseif v ~= t2[k] then
			return false
		end
	end

	return true
end

local baseInfoUrl, updateUrl = nil

function M:GetPersonalInfo(targetId, callback)
	if baseInfoUrl == nil then
		baseInfoUrl = gImageManager:GetBaseUrl() .. "/player/getProfile?roleId=%s&targetId=%s&skey=%s"
	end

	local url = gString.Format(baseInfoUrl, self:SelfRoleIdStr(), ulong.tostring(targetId), gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("[HunlunManager] requestHttpNotSuccess url=", url, isSuccess, data, code)
			callback(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("[HunlunManager] requestDecodeFailure url=", url, isSuccess, data_lua, code)
			callback(nil)

			return
		end

		callback(data_lua.data)
	end)
end

function M:OpenPersonalInfoPanel(roleId)
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

function M:ChangeSign(sign, callback)
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

local NameCheckResultStr = {
	[NameCheckResult.NameEmpty] = 65102274,
	[NameCheckResult.NameTooShort] = 65102288,
	[NameCheckResult.NameTooLong] = 65102289,
	[NameCheckResult.PunctuationOnly] = 65102290,
	[NameCheckResult.NameContainsInvalidCharacter] = 65102291
}

function M:ShowChangeSign()
	gDisplayMessageMgr:ShowBomb({
		isInput = true,
		exceedLength = SocialMediaConfig.MaxSignLength,
		exceedLengthMsg = SocialMediaConfig.SignExceedLengthMsg,
		msgType = gDisplayMessageId.SELECT,
		titleText = LTConfig.TextScriptTextConfig.GetConfig(89900818).Text,
		btnConfirmCallback = self:CreateAction("ChangeSign", gHunLunManager)
	})
end

function M:CheckInputName(text)
	if self:ContentIsEmpty(text) then
		return false, ""
	end

	local result = gCS.GuiUtils.IsInputNameValidNoMsg(text, LTConfig.GameConfig.PlayerNameMinLength, LTConfig.GameConfig.PlayerNameMaxLength)
	local textCfg = MessageConfig.GetConfig(NameCheckResultStr[result])

	return result == 0, textCfg and textCfg.Content or ""
end

function M:ShowChangeName()
	gDisplayMessageMgr:ShowBomb({
		isInput = true,
		inputCheck = self:CreateAction("CheckInputName", gHunLunManager),
		exceedLength = LTConfig.GameConfig.PlayerNameMaxLength,
		exceedLengthMsg = MessageConfig.GetConfig(NameCheckResultStr[NameCheckResult.NameTooLong]).Content,
		msgType = gDisplayMessageId.SELECT,
		titleText = LTConfig.TextScriptTextConfig.GetConfig(89900812).Text,
		btnConfirmCallback = self:CreateAction("ChangeName", gHunLunManager)
	})
end

function M:ChangeName(name, callback)
	if self.inSendingName then
		return false
	end

	if self:ContentIsEmpty(name) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.FilesNameNone)

		return false
	end

	local result = gCS.GuiUtils.IsInputNameValidNoMsg(name, LTConfig.GameConfig.PlayerNameMinLength, LTConfig.GameConfig.PlayerNameMaxLength)

	if result ~= 0 then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.NameInvalid)

		return false
	end

	local newName = name

	gClientUtils.EnvSdkReviewWords(newName, function ()
		gDisplayMessageMgr:ShowMessage(MessageConfig.ChangeNameTip, function ()
			self:SendChangeName(name, callback)
		end, nil, newName)
	end, function ()
		gDisplayMessageMgr:ShowMessage(MessageConfig.FilesCheck)
	end, "Hunlun")

	return true
end

function M:ChangeBirth(month, day, callback)
	gDisplayMessageMgr:ShowMessage(MessageConfig.ChangeBirth, function ()
		self:SendChangeBirth(month, day, callback)
	end, function ()
		return
	end, month, day)
end

function M:GetHeadIconList(UnlockedSystemHeadList)
	local listDic = {}
	local list = {}

	for i, v in ipairs(UnlockedSystemHeadList) do
		listDic[v.Id] = i
	end

	for i = 0, ImageAvatar.count - 1 do
		local cfg = ImageAvatar.LoadAt(i)

		if cfg.IsUnlock or listDic[cfg.Id] then
			local use = gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId == cfg.Id
			local ele = {
				tIndex = 1,
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

function M:GetBadgeList(badgeData)
	local list = {}

	return list
end

function M:GetHeadIconAndName(avatarId)
	local cfg = ImageAvatar.GetConfig(avatarId)

	return cfg and cfg.SguiImageId, cfg.ImageName or 0, ""
end

function M:GetPlayerAchievementList(callback)
	gClientToGameDelegate:AskPlayerAchievements().Callback = function (err, badgeData)
		if err ~= 0 then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		elseif callback then
			callback(badgeData)
		end
	end
end

function M:GetHeadIconInfo(callback)
	gClientToGameDelegate:QueryPersonalZoneHeadExtendInfo().Callback = function (err, iconData)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		elseif callback then
			callback(iconData)
		end
	end
end

function M:GetRemainChangeNameCount()
	gClientToGameDelegate:AskRemainChangeNameCount().Callback = function (err, data)
		self.changeNameCount = data
	end
end

function M:ClearNewSpirit(callback)
	if self.isSelf ~= true then
		return
	end

	gClientToGameDelegate:AskClearPersonalZoneNewSpiritNum().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			self.roleInfo.newSpiritNum = 0

			if callback then
				callback()
			end
		end
	end
end

function M:SendChangeBirth(month, day, callback)
	local birthdayCode = month * 100 + day

	gClientToGameDelegate:AskUpdatePersonalZoneBirthday(birthdayCode).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			self.birthdayCode = birthdayCode
			self.roleInfo.birthday = self:GetBirth(birthdayCode)

			if callback then
				callback()
			end

			gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
		end
	end
end

function M:SendChangeSign(sign, callback)
	gClientToGameDelegate:AskUpdatePersonalZoneDescription(self.roleId, sign).Callback = function (err)
		if err ~= MessageConfig.Ok then
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

function M:SendChangeName(name, callback)
	if self.inSendingName then
		return
	end

	self.inSendingName = name

	gClientToGameDelegate:AskChangeNameByItem(name).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.PzNoteSave)

			self.roleInfo.userName = name

			if callback then
				callback()
			end

			gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
		end

		self.inSendingName = nil
	end
end

function M:SendChangeHeadIcon(avatarId, callback)
	if gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId == avatarId then
		if callback then
			callback()
		end

		return
	end

	gClientToGameDelegate:AskUpdatePersonalZoneHead(PersonalZoneHeadType.System, avatarId).Callback = function (err)
		if err ~= MessageConfig.Ok then
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

function M:SendChangeBadge(badgeList, areaId, callback)
	if self:tablesEqual(self.roleInfo.reputation[areaId].badgeList, badgeList) then
		if callback then
			callback()
		end

		return
	end

	local sendList = {}

	for i = 1, #badgeList do
		if badgeList[i].hide ~= true then
			local ele = {
				AchieveId = badgeList[i].id,
				Index = i,
				CountryId = areaId
			}

			table.insert(sendList, ele)
		end
	end

	gClientToGameDelegate:AskUpdatePersonalZoneAchieveList(sendList, areaId).Callback = function (err)
		if err ~= MessageConfig.Ok then
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

function M:SendChangeSpirit(fightList, callback)
	if self:tablesEqual(self.roleInfo.fightSpirit, fightList) then
		if callback then
			callback()
		end

		return
	end

	local sendList = {}

	for i = 1, #fightList do
		if fightList[i].hide ~= true then
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
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			self.roleInfo.fightSpirit = fightList

			if callback then
				callback()
			end
		end
	end
end

function M:GetBestNpcs(fightSpirit)
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
		if fightSpirit[i].hide ~= true then
			id2SelectIndex[fightSpirit[i].id] = i
		end
	end

	local showList = {}

	for i = 1, #lingList do
		local tId = lingList[i].Tid
		local cId = gSpiritManager.fight2Cultivation[tId]

		if cId and blockDict[cId] ~= true then
			local favorInfo = favorInfos[cId] or {}
			local timeInfo = timeInfos[cId] or 0

			if filters.NpcFavorLimit <= favorInfo.favor or filters.NpcSparkDays <= timeInfo then
				local ele = {
					isUsed = false,
					tIndex = 2,
					headIcon = lingList[i].sIcon,
					name = lingList[i].Name,
					id = cId,
					favorLevel = favorInfo.favorLevel or 0,
					favorAmount = favorInfo.favorAmount or 0,
					totTime = timeInfos[cId] or 0,
					selected = id2SelectIndex[cId] ~= nil,
					selectedIndex = id2SelectIndex[cId] or 0
				}

				table.insert(showList, ele)
			end
		end
	end

	return showList
end

gHunLunManager = gHunLunManager or C_HunLunManager.new()
