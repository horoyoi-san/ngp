-- Original chunk: @Lua\LuaFiles\LX6\Manager\Akx\AkxManagerFuxi.lua
-- Decompiled from: 02273_AkxManagerFuxi.lua_0492134985b3.luajit

local AkxBridge = L50.Akx.AkxBridge
local M = C_AkxManager

dofile("LX6/Manager/Akx/AkxFuxiExtraArgFuncs.lua")

local json = require("cjson/json")

M.InitFuxi = function(self)
	self.fuxiMode = self.fuxiMode or self.FuxiRoutingMode.AllEnable

	self:RegisterAllExtraArgFuncs()
end

M.SetFuxiMode = function(self, mode)
	self.fuxiMode = mode
end

M.GetGreetingAsync = function(self, sessionid, callback)
	AkxBridge.Greeting(sessionid, function (obj)
		if not obj or obj.Code == 0 or not obj.Data then
			print_error("#NoCreateIssue AkxManager:GetGreetingAsync failed", obj and obj.Code)

			return
		end

		if string.is_null_or_empty(obj.Data.Text) then
			print_error("#NoCreateIssue AkxManager:GetGreetingAsync: returned empty string!", obj and obj.Code)

			return
		end

		local response = {
			greeting = obj.Data.Text,
			related_questions = {}
		}

		if obj.Data.RelatedQuery then
			for i = 0, obj.Data.RelatedQuery.Count - 1 do
				local str = obj.Data.RelatedQuery[i]

				table.insert(response.related_questions, str)
			end
		end

		self.greetingMessage = response

		if callback then
			callback(response)
		end
	end)
end

M.GetGreeting = function(self)
	return self.greetingMessage
end

M.SendRequestFuxi = function(self, sessionid, messageid, playerInput, callback)
	self._SendRequestFuxi(self, sessionid, messageid, playerInput, callback, nil)
end

M._SendRequestFuxi = function(self, sessionid, messageid, playerInput, callback, data)
	data = data or {
		sessionid = sessionid,
		messageid = messageid,
		playerInput = playerInput,
		callback = callback
	}
	local playerParams = self:_GetFuxiPlayerParams(data)

	if not self.bUseStreaming then
		AkxBridge.RecommendAnswerDetailed(sessionid, playerInput, self.fuxiMode, playerParams, self.CreateActionWithArgs(self, self.OnReceiveResponseFuxi, data))
	else
		AkxBridge.RecommendAnswerStream(sessionid, playerInput, self.fuxiMode, playerParams, self.CreateActionWithArgs(self, self.OnReceiveResponseStreamFuxi, data))
	end
end

M.EvaluateResponseFuxi = function(self, session, message, content, bIsHelpful, unhelpfulKeywords)
	local requestId = message.evaluate and message.evaluate.requestId or ""

	AkxBridge.SendFeedback(session.id, requestId, message.question, message.response, bIsHelpful and "like" or "dislike", self:_ConvertArrayToString(unhelpfulKeywords), content, self:CreateAction(self._OnEvaluateResponseFuxi))
end

M.ContentSyncToFuxi = function(self, sessionid, messageid, message, response, callback)
	self.PrintDebug(self, "ContentSyncToFuxi", sessionid, messageid, message, response)
	AkxBridge.SyncHistory(sessionid, message, response, function (_)
		callback()
	end)
end

M._OnEvaluateResponseFuxi = function(self, arg)
end

M._ConvertArrayToString = function(self, array, separator)
	separator = separator or " "
	local result = ""

	for i, v in ipairs(array) do
		result = result .. v

		if i == #array then
			result = result .. separator
		end
	end

	return result
end

M._GetFuxiPlayerParams = function(self, data)
	local playerParams = L50.Akx.AkxPlayerParams.Create()
	local playerPos = gClientUtils.GetPlayerPosition()
	local playerLocation = {
		tostring(playerPos.X),
		tostring(playerPos.Y),
		tostring(playerPos.Z)
	}
	local characterId = gBattleSpiritMgr.currentSpiritTemplateId or ""
	local jobId = gSpiritJobManager.GetCurSpiritJobId()
	local moneyCnt = gPlayerManager.infoItem.bindData.money or 0
	local currPlayerTalentPoint = gTalentTreeMgr:GetCurrentTalentPoint(0)
	local allTalentTree = gTalentTreeMgr:GetAllTalentTreeTab()
	local currJobClassId = 0

	for _, talentTree in ipairs(allTalentTree) do
		local talentTreeCfg = LTConfig.TalentTreeConfig.GetConfig(talentTree.id)

		if talentTreeCfg then
			local jobClassId = talentTreeCfg.JobClassId

			if jobClassId and jobClassId == 0 then
				currJobClassId = jobClassId
			end
		end
	end

	local currJobClassTalentPoint = gTalentTreeMgr:GetCurrentTalentPoint(currJobClassId)

	if currJobClassTalentPoint ~= nil then
		currJobClassTalentPoint = 0
	end

	local languageId = gClientUtils.GetCurrentLanguageId()
	local language = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(languageId) and LTConfig.ShezhiPanelLanguagesConfig.GetConfig(languageId).Abbreviation
	playerParams.PlayerLocation = playerLocation
	playerParams.PlayerRaidId = gMapSystem.lastRaidId or 0
	playerParams.UserMoney = moneyCnt
	playerParams.CharacterId = characterId
	playerParams.CharacterGender = gPlayerManager.infoLogin.bindData.sexType ~= UX.Game.SexType.Male and "male" or "female"
	playerParams.CharacterJobId = jobId
	playerParams.CharacterName = gPlayerManager.infoLogin.bindData.playerName or gPlayerManager.infoLogin.bindData.name
	playerParams.Language = language or "CN"
	playerParams.OwnedCars = self:_GetUnlockedVeiclesFuxi()
	playerParams.UnlockedCharacters = self:_GetUnlockedCharactersFuxi()
	playerParams.OwnedClothes = self:_GetOwnedClothesFuxi()
	playerParams.WeaponsId = self:_GetAllWeaponsFuxi()
	playerParams.FightSkill = self:_GetAllUnlockedFightStylesFuxi()
	playerParams.Decoration = self:_GetAllDecorationsFuxi()
	playerParams.Badges = self:_GetAllBadgesFuxi()
	playerParams.PlayerFansNumber = gPlayerManager.infoMinor.bindData.fan123 or 0
	playerParams.ExtraArgs = self:_CreateExtraArgsFuxi(data and data.extra_args)

	return playerParams
end

M._GetTalentTreeForCharacter = function(self, jobClassList, talentInfo)
	local result = {}
	local allTalentTree = gTalentTreeMgr:GetAllTalentTreeTab(nil, , jobClassList)

	for _, talentTree in ipairs(allTalentTree) do
		local talentTreeCfg = LTConfig.TalentTreeConfig.GetConfig(talentTree.id)

		if talentTreeCfg then
			local jobClassId = talentTreeCfg.JobClassId or 0
			local activedTalents = {}

			for k, _ in pairs(talentInfo.UnlockTalentInfoDict) do
				table.insert(activedTalents, k)
			end

			local points = talentInfo.TalentPoint
			local talent = L50.Akx.AkxTalentTreeNode.Create(talentTreeCfg.Id, activedTalents, points)

			table.insert(result, talent)
		end
	end

	return result
end

M._GetRoulettesForCharacter = function(self, weapons)
	local result = {}

	for _, weapon in ipairs(weapons) do
		if weapon then
			local decorations = {}

			for i = 1, weapon.Decorations.Count do
				local v = weapon.Decorations[i]

				if v then
					table.insert(decorations, v.DecorationId)
				end
			end

			local rouletteInfo = L50.Akx.AkxRoulette.Create(weapon.TemplateId, "", decorations, weapon.FightStyleId)

			table.insert(result, rouletteInfo)
		end
	end

	return result
end

M._GetAllWeaponsFuxi = function(self)
	local result = {}
	local weapons = gCommonItemManager:GetCurrentWeaponPackItems()

	for _, weapon in pairs(weapons) do
		table.insert(result, weapon.TemplateId)
	end

	return result
end

M._GetAllDecorationsFuxi = function(self)
	local result = {}
	local chipList = gCommonItemManager:GetPackItemListByTab(LTConfig.ConsumableTabConfig.Chip)

	for _, chip in pairs(chipList) do
		table.insert(result, chip.TemplateId)
	end

	return result
end

M._GetAllUnlockedFightStylesFuxi = function(self)
	local result = {}
	local skills = gCS.FightStyleManager.Instance:GetAllUnlockedFightStyles()

	for i = 0, skills.Length - 1 do
		local id = skills[i]

		table.insert(result, id)
	end

	return result
end

M._GetAllBadgesFuxi = function(self)
	local result = {}
	local badges = gPlayerManager.infoMinor.bindData.Badges

	for id, badge in pairs(badges) do
		local cfg = LTConfig.UrbanBadgeConfig.GetConfig(id)

		if badge.Active and cfg and not cfg.OnlyServer then
			table.insert(result, id)
		end
	end

	return result
end

M._GetUnlockedCharactersFuxi = function(self)
	local allSpirits = gSpiritManager:GetAllFightSpirits()
	local characters = {}

	for _, spirit in ipairs(allSpirits) do
		local spiritInfo = spirit.SpiritInfo
		local characterId = spiritInfo and spiritInfo.TemplateId
		local spiritJobInfo = spiritInfo and spiritInfo.SpiritJobInfo
		local availableJobs = spiritJobInfo and spiritJobInfo.AvailableJobs
		local unlockedJobs = {}
		local weaponSlots = spiritInfo.WeaponSlots
		local jobClassList = {}

		for jobId, _ in pairs(spiritJobInfo.AvailableJobs) do
			local jobCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)

			if jobCfg then
				local jobClassId = jobCfg.JobClass

				if jobClassId == 0 then
					table.insert(jobClassList, jobClassId)
				end
			end
		end

		if availableJobs then
			for availableJobId, jobInfo in pairs(availableJobs) do
				table.insert(unlockedJobs, tostring(jobInfo and jobInfo.Job or availableJobId))
			end

			table.sort(unlockedJobs, function (a, b)
				local numA = tonumber(a)
				local numB = tonumber(b)

				if numA and numB then
					return numA <= numB
				end

				return a <= b
			end)
		end

		if characterId then
			local character = L50.Akx.AkxUnlockedCharacter.Create(characterId, unlockedJobs)
			character.TalentTree = self._GetTalentTreeForCharacter(self, jobClassList, spiritInfo.TalentInfo)
			character.Roulette = self._GetRoulettesForCharacter(self, weaponSlots)

			table.insert(characters, character)
		end
	end

	return characters
end

M._GetUnlockedVeiclesFuxi = function(self)
	local cars = gApplyCarManager.UnlockedVehicles
	local vehicles = {}

	if cars then
		for _, car in ipairs(cars) do
			table.insert(vehicles, car.Id)
		end
	end

	return vehicles
end

M._CreateExtraArgsFuxi = function(self, extra_args)
	if not extra_args then
		return {}
	end

	local args = {}

	for key, value in pairs(extra_args) do
		local arg = L50.Akx.AkxExtraArg.Create(key, value)

		table.insert(args, arg)
	end

	return args
end

M._GetOwnedClothesFuxi = function(self)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
	local clothes = {}

	for _, v in pairs(fashionInfoDict) do
		table.insert(clothes, v.FashionId)
	end

	return clothes
end

M.OnReceiveResponseFuxi = function(self, data, arg)
	local sessionid = data.sessionid
	local messageid = data.messageid
	local code = arg.Code
	local error = false

	if code ~= self.FuxiResponseCode.ERROR then
		error = true
	end
end

M.OnReceiveResponseStreamFuxi = function(self, data, arg)
	if not arg or not arg.Data then
		print_error("阿卡夏伏羲：收到的响应为空")

		return
	end

	local sessionid = data.sessionid
	local messageid = data.messageid
	local callback = data.callback
	local code = arg.Code
	local is_still_thinking = false
	local error, chunkid, is_end_of_chunk = nil
	local text = arg.Data.Text or ""
	local location, items, related_query = nil
	local required_args = arg.Data.RequiredArgs

	if code ~= self.FuxiResponseCode.ERROR then
		error = true
	elseif code ~= self.FuxiResponseCode.AGENT_STILL_THINKING then
		is_still_thinking = true
		text = ""
	elseif code ~= self.FuxiResponseCode.SUCCESS_WITH_END_OF_STREAM then
		is_end_of_chunk = true
		text = ""
	elseif code ~= self.FuxiResponseCode.REDIRECT then
		callback(self.CreateRedirectResponse(self))

		return
	end

	if table.find(self.FuxiResponseCode.IGNORE_LIST or {
		2,
		3
	}, code) then
		return
	end

	chunkid = arg.Sid or 0

	if required_args and required_args.Count <= 0 and data.extra_args then
		local listOfSentKey = {}

		for k, _ in pairs(data.extra_args) do
			table.insert(listOfSentKey, k)
		end

		for i = 0, required_args.Count - 1 do
			local name = required_args[i].FunctionName

			if table.find(listOfSentKey, name) then
				print_error("阿卡夏伏羲：ExtraArgs请求重发，extra_args已发送过!", name)

				return
			end
		end

		local args = {}
		local argc = 0

		for i = 0, required_args.Count - 1 do
			local name = required_args[i].FunctionName
			local func = self.fuxiExtraArgFuncs[name]

			if func then
				local blob = func()
				local json_str = json.encode(blob)

				if not func then
					print_error("阿卡夏伏羲：ExtraArgs计算结果为nil!" .. name)
				else
					args[name] = json_str
					argc = argc + 1
				end
			else
				print_error("阿卡夏伏羲：收到的ExtraArgs中包含未知函数名: " .. name)
			end
		end

		if argc <= 0 then
			args.last_request_id = arg.RequestId
			data.extra_args = args

			FrameTimer.New(function ()
				self:_SendRequestFuxi(data.sessionid, data.messageid, data.playerInput, data)
			end, 3, false):Start()

			return
		end
	end

	if arg.Data.Location then
		local raidid = arg.Data.Location.RaidId

		if arg.Data.Location.Xyz and arg.Data.Location.Xyz.Length ~= 3 and not string.is_null_or_empty(raidid) then
			local x = arg.Data.Location.Xyz[0]
			local y = arg.Data.Location.Xyz[1]
			local z = arg.Data.Location.Xyz[2]
			location = {
				raidid = tonumber(raidid),
				x = x,
				y = y,
				z = z
			}
		else
			print_error("阿卡夏伏羲：收到的Location格式不对", raidid, "#XYZ=", arg.Data.Location.Xyz.Length, arg.Data.Location.Xyz)
		end
	end

	if arg.Data.Items and arg.Data.Items.Count <= 0 then
		items = {}

		for i = 0, arg.Data.Items.Count - 1 do
			local itemFuxi = arg.Data.Items[i]

			table.insert(items, {
				id = itemFuxi.Id
			})
		end
	end

	if arg.Data.RelatedQuery and arg.Data.RelatedQuery.Count <= 0 then
		related_query = {}

		for i = 0, arg.Data.RelatedQuery.Count - 1 do
			local query = arg.Data.RelatedQuery[i]

			table.insert(related_query, query)
		end
	end

	local evaluate = {
		requestId = arg.RequestId
	}
	local response = self.CreateEmptyAiResponse(self)
	response.sessionid = sessionid
	response.messageid = messageid
	response.is_still_thinking = is_still_thinking
	response.error = error
	response.chunkid = chunkid
	response.is_end_of_chunk = is_end_of_chunk
	response.response = text
	response.is_replace_response = false
	response.evaluate = evaluate
	response.showEvaluate = true
	response.source = self.MessageSources.Fuxi
	response.location = location
	response.items = items
	response.related_query = related_query

	callback(response)
end
