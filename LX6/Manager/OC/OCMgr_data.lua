-- Original chunk: @Lua\LuaFiles\LX6\Manager\OC\OCMgr_data.lua
-- Decompiled from: 02258_OCMgr_data.lua_9989cccd358b.luajit

local SexConfig = LTConfig.OriginalCharacterSexConfig
local AgeConfig = LTConfig.OriginalCharacterAgeConfig
local TemplateIPConfig = LTConfig.OriginalCharacterTemplateIPConfig
local OCTemplateConfig = LTConfig.OriginalCharacterTemplateConfig
local OCPersonalityTemplateConfig = LTConfig.OriginalCharacterPersonalityTemplateConfig
local MBTIConfig = LTConfig.OriginalCharacterMBTIConfig
local MessageConfig = LTConfig.MessageConfig
local M = C_OCMgr

M.OnInitData = function(self)
	self.baseData = {
		["t#p^"] = "",
		["\\x8foc"] = 2,
		["\\x9dm~"] = 2
	}
	self.isMeikaGrandpa = false
	self.voiceTab = {
		["\\xd5\\xd26\\xe8"] = 0,
		["\\xac\\xb4\\xaex?\\xea6"] = 1,
		["y-mB"] = 2
	}
	self.toneTab = {
		["w+s^"] = 1,
		["\\xa4\\xb7\\xa2i7\\xff?"] = 0
	}
	self.personalityAndStory = {
		["^\\xba\\xad\\xbd\\xaf"] = "",
		["~'nX"] = "",
		labels = {},
		backGroundDetails = {},
		personalityDetails = {}
	}
	self.chatSettings = {
		["^\\xba\\xbb\\xa3\\xb3"] = "",
		["@\\x9e\\xa7\\x82L"] = "",
		["\\x9dm~"] = "",
		["}s\\xa0vX\\xbb\\xfdIYrw\\"] = "",
		["\\xa8\\xb0\t\\xa7D?\\xf36"] = ""
	}
	self.hobbyData = {}
	self.MBTIId = nil
	self.IpId = nil
	self.confirmVoice = nil
	self.recommendVoice = 0
	self.officialVoiceList = self.GetOfficialTones(self)

	self.InitMixVoice(self)

	self.preGeneratePersonality = false
	self.lastGreetingTime = nil

	self.SetupDataSync(self)
end

M.CreateSyncProxy = function(self, initTable, syncMap)
	local proxy = {}

	for k, v in pairs(initTable) do
		proxy[k] = v
	end

	setmetatable(proxy, {
		__index = function (t, k)
			return rawget(t, k)
		end,
		__newindex = function (t, k, v)
			local old = rawget(t, k)

			if old ~= v then
				return
			end

			rawset(t, k, v)

			local sync = syncMap[k]

			if sync then
				sync(v)
			end
		end
	})

	return proxy
end

M._GetSexName = function(self)
	local cfg = SexConfig.GetConfig(self.baseData.sex)

	return cfg and cfg.Name or ""
end

M._GetAgeName = function(self)
	local cfg = AgeConfig.GetConfig(self.baseData.age)

	return cfg and cfg.Name or ""
end

M.SetupDataSync = function(self)
	local api = self.api
	self.baseData = self:CreateSyncProxy(self.baseData, {
		name = function (v)
			api.RegisterNpcName(v)
		end,
		sex = function (v)
			api.SetNpcGender(self:_GetSexName())
			api.SetNpcBodyType(self:GetBodyType())
		end,
		age = function (v)
			api.SetNpcAge(self:_GetAgeName())
			api.SetNpcBodyType(self:GetBodyType())
		end
	})
	self.personalityAndStory = self:CreateSyncProxy(self.personalityAndStory, {
		desc = function (v)
			api.RegisterNpcInfoIntroduction(v)
			api.SetNpcIdentity(v)
			api.SetNpcPersonalityDesc(v)
		end,
		labels = function (v)
			api.SetNpcPersonalityLabels(v)
		end,
		story = function (v)
			api.SetNpcStory(v)
		end
	})

	api.SetNpcId(ulong.tostring(self.npcId))
	api.RegisterNpcName(self.baseData.name)
	api.SetNpcGender(self:_GetSexName())
	api.SetNpcAge(self:_GetAgeName())
	api.SetNpcBodyType(self:GetBodyType())
	api.RegisterNpcInfoIntroduction(self.personalityAndStory.desc or "")
	api.SetNpcIdentity(self.personalityAndStory.desc or "")
	api.SetNpcPersonalityDesc(self.personalityAndStory.desc or "")
	api.SetNpcPersonalityLabels(self.personalityAndStory.labels or {})
	api.SetNpcStory(self.personalityAndStory.story or "")
end

M.GetBodyType = function(self)
	local cfg = AgeConfig.GetConfig(self.baseData.age)

	if not cfg then
		return 1
	end

	if self.baseData.sex ~= SexConfig.Male then
		return cfg.Male
	elseif self.baseData.sex ~= SexConfig.Female then
		return cfg.Female
	end

	return cfg.Genderless
end

M.UpLoadBaseData = function(self)
	local AgeCfg = AgeConfig.GetConfig(self.baseData.age)
	local sexCfg = SexConfig.GetConfig(self.baseData.sex)
	local age = AgeCfg and AgeCfg.Name or ""
	local gender = sexCfg and sexCfg.Name or ""
	local bodyType = self:GetBodyType()

	self.api.RegisterNpcInfoBase(ulong.tostring(self.npcId), self.baseData.name, gender, age, self.personalityAndStory.desc or "", bodyType)
end

M.CheckOCName = function(self, text)
	return gClientUtils.CheckNameFormat(text, LTConfig.GameConfig.PlayerNameMinLength, LTConfig.GameConfig.PlayerNameMaxLength)
end

M.EnsureDefaultVoice = function(self)
	if self.confirmVoice then
		local valid = false
		slot2 = ipairs
		slot4 = self.mineVoiceList or {}

		for _, v in slot2(slot4) do
			if v.speechId ~= self.confirmVoice.speechId then
				valid = true

				break
			end
		end

		if not valid then
			self.confirmVoice = nil
		end
	end

	slot1 = ipairs
	slot3 = self.officialVoiceList or {}

	for _, v in slot1(slot3) do
		if v.index ~= -1 then
			self.confirmVoice = v

			break
		end
	end

	if not self.confirmVoice then
		return false
	end

	return true
end

M.PrepareVoiceForChat = function(self, callback)
	self:Log("[PrepareVoiceForChat] 开始", "preparing=", self._preparingVoice, "callback=", callback == nil)

	if self._preparingVoice then
		self:Log("[PrepareVoiceForChat] 已在准备中，加入等待队列")

		self._prepareVoiceCallbacks = self._prepareVoiceCallbacks or {}

		if callback then
			table.insert(self._prepareVoiceCallbacks, callback)
		end

		return
	end

	local finish = function(success)
		self:Log("[PrepareVoiceForChat] finish", "success=", success, "queued=", #(self._prepareVoiceCallbacks or {}))

		self._preparingVoice = false
		local callbacks = self._prepareVoiceCallbacks or {}
		self._prepareVoiceCallbacks = nil

		if callback then
			callback(success)
		end

		for _, cb in ipairs(callbacks) do
			if cb then
				cb(success)
			end
		end
	end

	local hasVoice = self:EnsureDefaultVoice()

	self:Log("[PrepareVoiceForChat] EnsureDefaultVoice 完成", "hasVoice=", hasVoice, "confirmVoice=", self.confirmVoice and self.confirmVoice.name or "nil")

	if not hasVoice then
		finish(false)

		return
	end

	local voice = self.confirmVoice

	local onReady = function(success)
		self:Log("[PrepareVoiceForChat] AddToMineTone 回调", "success=", success, "voice=", voice and voice.name or "nil")

		if not success then
			finish(false)

			return
		end

		self.confirmVoice = voice

		self:AddToMixVoice(voice)

		slot1 = self

		slot1:Log("[PrepareVoiceForChat] 开始 AskBindOCSpeech", "mixCount=", #(self.mixVoiceList or {}))
		self:AskBindOCSpeech(function (err)
			self:Log("[PrepareVoiceForChat] AskBindOCSpeech 回调", "err=", err)
			finish(err ~= MessageConfig.Ok)
		end)
	end

	self._preparingVoice = true
	local exists = false
	slot7 = ipairs
	slot9 = self.mineVoiceList or {}

	for _, v in slot7(slot9) do
		if v ~= voice and v._speechReady == false then
			exists = true

			break
		end
	end

	self:Log("[PrepareVoiceForChat] 检查音色状态", "exists=", exists, "voice=", voice and voice.name or "nil", "speechReady=", voice and voice._speechReady)

	if exists then
		onReady(true)
	else
		self.Log(self, "[PrepareVoiceForChat] 开始 AddToMineTone", "voice=", voice.name)
		self.AddToMineTone(self, voice, onReady)
	end
end

M.SetPersonalityAndBackGround = function(self, desc, labels, story)
	if not self.EnsureDefaultVoice(self) then
		return false
	end

	local ocId = self.npcId

	if ocId and not ulong.equals(ocId, ulong.zero) and self.ocInfo and self.ocInfo.OCInfoDict and self.ocInfo.OCInfoDict[ocId] then
		return true
	end

	self.api.FlushNpcPerInfo(self.confirmVoice.name, function (success)
		if not success then
			return
		end

		self.ocInfo = self.ocInfo or {}
		self.ocInfo.OCInfoDict = self.ocInfo.OCInfoDict or {}
		local sexCfg = SexConfig.GetConfig(self.baseData.sex)
		local ageCfg = AgeConfig.GetConfig(self.baseData.age)
		self.ocInfo.OCInfoDict[ocId] = {
			OCId = ocId,
			name = self.baseData.name,
			gender = sexCfg and sexCfg.Name or "",
			age = ageCfg and ageCfg.Name or "",
			SelectBodyTypeId = self:GetBodyType()
		}
	end)

	return true
end

M.UpdateBackgroundDetail = function(self, detailId, content)
	if string.is_null_or_empty(content) then
		self.personalityAndStory.backGroundDetails[detailId] = nil
	else
		self.personalityAndStory.backGroundDetails[detailId] = content
	end
end

M.UpdatePersonalityDetail = function(self, detailId, content)
	if string.is_null_or_empty(content) then
		self.personalityAndStory.personalityDetails[detailId] = nil
	else
		self.personalityAndStory.personalityDetails[detailId] = content
	end
end

M.GetPersonalityDetail = function(self, detailId)
	return self.personalityAndStory.personalityDetails[detailId] or ""
end

M.GetBackgroundDetail = function(self, detailId)
	return self.personalityAndStory.backGroundDetails[detailId] or ""
end

M.PreGeneratePersonality = function(self, index)
	if index == 3 then
		return
	end

	if self.preGeneratePersonality or self.IpId then
		return
	end

	self.preGeneratePersonality = true

	self.ComposePersonaBackground(self, self.personalityAndStory.desc, self.personalityAndStory.story, function (bgData)
		if not bgData then
			print_error("身世背景生成失败")
		else
			self.personalityAndStory.story = bgData.Background or ""
		end

		gMessageManager:SendMessage(gEventConstants.OC_DATA_REFRESH)
	end)
end

M.ConvertPersonaToData = function(self, persona)
	if persona.IpId then
		self.ConvertToIP(self, persona.IpId)
	else
		self.baseData.age = persona.Age
		self.baseData.sex = persona.Gender
		self.personalityAndStory.desc = persona.Identity

		self.SwitchModel(self)
	end

	gMessageManager:SendMessage(gEventConstants.OC_DATA_REFRESH)
end

M.ConvertToIP = function(self, ipId)
	local cfg = TemplateIPConfig.GetConfig(ipId)

	if not cfg then
		return
	end

	self.IpId = ipId
	self.baseData.age = cfg.Age
	self.personalityAndStory.desc = cfg.Desc
	self.baseData.name = cfg.Name
	self.baseData.sex = cfg.Sex

	self.SwitchModel(self)
	self.OnChangeChatStyle(self, cfg.SpeakingStyle)

	if cfg.VoiceFiles then
		self.AddRecommend(self, cfg.VoiceFiles)
	end
end

M.OnChangeTemplate = function(self, templateId)
	local cfg = OCTemplateConfig.GetConfig(templateId)

	if not cfg then
		return
	end

	self.currentTemplateId = templateId
	self.baseData.age = cfg.Age
	self.baseData.sex = cfg.Sex

	self.SwitchTemplateModel(self, templateId)

	local pCfg = OCPersonalityTemplateConfig.GetConfig(cfg.PersonalityTemplate)

	if pCfg then
		self.OnChangeRelation(self, pCfg.Relationship)
		self.OnChangeChatStyle(self, pCfg.SpeakingStyle)
	end

	gMessageManager:SendMessage(gEventConstants.OC_DATA_REFRESH)
end

M.OnChangeRelation = function(self, relationShip)
	self.chatSettings.relationShip = relationShip

	self.api.RegisterNpcInfoRelationship(relationShip)
end

M.OnChangeCallName = function(self, callName)
	self.chatSettings.callName = callName

	self.api.RegisterNpcInfoAddressToPlayer(callName)
end

M.OnChangeChatStyle = function(self, style)
	self.chatSettings.style = style

	self.api.RegisterNpcInfoSpeakingStyle(style)
end

M.OnChanageWhoIam = function(self, whoIam)
	if self.isMeikaGrandpa then
		return
	end

	self.chatSettings.whoIam = whoIam

	self.api.RegisterPlayerInfoIdentity(whoIam)
end

M.OnChangeSelfSex = function(self, sex)
	self.chatSettings.sex = sex

	self.api.RegisterPlayerInfoGender(sex)
end

M.ComposePersonaIntroduction = function(self, introduction, callback)
	self.api.ComposePersonaIntroduction(introduction, function (data)
		if callback then
			callback(data)
		end
	end)
end

M.ComposePersonaBackground = function(self, introduction, background, callback)
	self.api.ComposePersonaBackground(introduction, background, function (data)
		if callback then
			callback(data)
		end
	end)
end

M.ComposePersonaBackgroundFromQARecords = function(self, introduction, qaRecords, callback)
	local questions = {}
	local answers = {}

	for _, qa in ipairs(qaRecords) do
		table.insert(questions, qa.Question)
		table.insert(answers, qa.Answer)
	end

	self.api.ComposePersonaBackgroundFromQARecordsForLua(introduction, questions, answers, function (data)
		if callback then
			callback(data)
		end
	end)
end

M.ClearMeikaGrandpaMode = function(self)
	self.isMeikaGrandpa = false
end

M.ImageToCharacter = function(self, imageUrl, outputs, callback)
	self.api.ImageToCharacter(imageUrl, outputs, function (data)
		if callback then
			callback(data)
		end
	end)
end

M.TextToCharacter = function(self, text, outputs, callback)
	self.api.TextToCharacter(text, outputs, function (data)
		if callback then
			callback(data)
		end
	end)
end

M.CheckHasRelANdName = function(self)
	return not string.is_null_or_empty(self.chatSettings.relationShip) and not string.is_null_or_empty(self.chatSettings.callName)
end

M.SubmitAllData = function(self, callback)
	self.api.SetNpcId(ulong.tostring(self.npcId))
	self.SetPersonalityAndBackGround(self, self.personalityAndStory.desc, self.personalityAndStory.labels, self.personalityAndStory.story)

	if not table.isNilOrEmpty(self.mixVoiceList) then
		self.AskBindOCSpeech(self, function (bindErr)
			if callback then
				callback(bindErr ~= MessageConfig.Ok)
			end
		end)
	elseif callback then
		callback(true)
	end
end

M.GetMBTI = function(self)
	if self.MBTIId then
		return MBTIConfig.GetConfig(self.MBTIId)
	end

	local first = MBTIConfig.LoadAt(0)

	if first then
		self.SetMBTIId(self, first.Id)

		return MBTIConfig.GetConfig(self.MBTIId)
	end

	return nil
end

M.SetMBTIId = function(self, id)
	if self.MBTIId ~= id then
		return
	end

	self.MBTIId = id

	if not id then
		return
	end

	local cfg = MBTIConfig.GetConfig(id)

	self.api.RegisterNpcInfoMbti(cfg and cfg.MBTI or "")
end

M.AddPersonalityLabel = function(self, label)
	if not label then
		return
	end

	local labels = self.personalityAndStory.labels

	if #labels > 3 then
		return
	end

	table.insert(labels, label)
	self.api.SetNpcPersonalityLabels(labels)
end

M.RemovePersonalityLabel = function(self, label)
	if not label then
		return
	end

	local labels = self.personalityAndStory.labels

	for i, v in ipairs(labels) do
		if v ~= label then
			table.remove(labels, i)
			self.api.SetNpcPersonalityLabels(labels)

			return
		end
	end
end
