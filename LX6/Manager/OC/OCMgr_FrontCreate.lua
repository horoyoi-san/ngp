-- Original chunk: @Lua\LuaFiles\LX6\Manager\OC\OCMgr_FrontCreate.lua
-- Decompiled from: 02259_OCMgr_FrontCreate.lua_03bbdf614237.luajit

local TemplateConfig = LTConfig.OriginalCharacterTemplateConfig
local SexConfig = LTConfig.OriginalCharacterSexConfig
local AgeConfig = LTConfig.OriginalCharacterAgeConfig
local AIGenTemplateConfig = LTConfig.OriginalCharacterAIGenTemplateConfig
local OCConfig = LTConfig.OriginalCharacterConfig
local M = C_OCMgr

M.GetRandomList = function(self, config, listCount)
	local totalCount = config.count

	if listCount < 0 then
		return {}
	end

	if totalCount < listCount then
		local result = {}

		for i = 1, totalCount do
			result[i] = i
		end

		return result
	end

	local numbers = {}

	for i = 0, totalCount - 1 do
		local cfg = config.LoadAt(i)
		numbers[i + 1] = cfg.Id
	end

	for i = 1, listCount do
		local randomIndex = math.random(i, totalCount)
		numbers[randomIndex] = numbers[i]
		numbers[i] = numbers[randomIndex]
	end

	local result = {}

	for i = 1, listCount do
		result[i] = numbers[i]
	end

	return result
end

M.GetTemplateList = function(self, listCount)
	return self.GetRandomList(self, TemplateConfig, listCount)
end

M.GetTemplateListByCondition = function(self, sex, age, listCount)
	local totalCount = TemplateConfig.count
	local candidates = {}

	for i = 0, totalCount - 1 do
		local cfg = TemplateConfig.LoadAt(i)

		if cfg.Sex ~= sex and cfg.Age ~= age then
			table.insert(candidates, cfg.Id)
		end
	end

	if listCount > #candidates then
		return candidates
	end

	local result = {}

	for i = 1, listCount do
		local randomIndex = math.random(i, #candidates)
		candidates[randomIndex] = candidates[i]
		candidates[i] = candidates[randomIndex]
		result[i] = candidates[i]
	end

	return result
end

M.GetPersonalityTemplateListByCondition = function(self, sex, age, mustIncludeId, listCount)
	local PTC = LTConfig.OriginalCharacterPersonalityTemplateConfig
	local totalCount = PTC.count
	local candidates = {}

	for i = 0, totalCount - 1 do
		local cfg = PTC.LoadAt(i)

		if cfg.Sex ~= sex and cfg.Age ~= age then
			table.insert(candidates, cfg.Id)
		end
	end

	if not mustIncludeId then
		if listCount > #candidates then
			return candidates
		end

		local result = {}

		for i = 1, listCount do
			local randomIndex = math.random(i, #candidates)
			candidates[randomIndex] = candidates[i]
			candidates[i] = candidates[randomIndex]
			result[i] = candidates[i]
		end

		return result
	end

	local mustIncludeIndex = nil

	for i, id in ipairs(candidates) do
		if id ~= mustIncludeId then
			mustIncludeIndex = i

			break
		end
	end

	if not mustIncludeIndex then
		table.insert(candidates, mustIncludeId)

		mustIncludeIndex = #candidates
	end

	if listCount > #candidates then
		return candidates
	end

	local result = {}
	local selected = {}
	result[1] = mustIncludeId
	selected[mustIncludeId] = true
	local remaining = listCount - 1
	local pool = {}

	for i, id in ipairs(candidates) do
		if not selected[id] then
			table.insert(pool, id)
		end
	end

	for i = 1, remaining do
		if #pool ~= 0 then
			break
		end

		local randomIndex = math.random(i, #pool)
		pool[randomIndex] = pool[i]
		pool[i] = pool[randomIndex]
		result[#result + 1] = pool[i]
		selected[pool[i]] = true
	end

	return result
end

M.GetAgeList = function(self)
	local ret = {}

	for i = 0, AgeConfig.count - 1 do
		local cfg = AgeConfig.LoadAt(i)
		local ele = {
			id = cfg.Id,
			label = cfg.Name
		}

		table.insert(ret, ele)
	end

	return ret
end

M.GetSexList = function(self)
	local ret = {}

	for i = 0, SexConfig.count - 1 do
		local cfg = SexConfig.LoadAt(i)
		local ele = {
			id = cfg.Id,
			label = cfg.Name
		}
		ret[i + 1] = ele
	end

	return ret
end

M.GetNameByGen = function(self, callback)
	self.api.GenerateRandomName(function (nameRespon)
		if callback then
			callback(nameRespon.Name)
		end
	end)
end

M.GetDescByGen = function(self, calback)
	self.UpLoadBaseData(self)
	self.api.ComposePersonaIntroduction(self.personalityAndStory.desc, function (data)
		if not data then
			calback("")

			return
		end

		if calback then
			calback(data.Introduction or "")
		end
	end)
end

M.GetPersonaByInstruction = function(self, instruction, callback)
	self.api.InstructionToPersona(instruction, function (obj)
		if callback then
			callback(obj)
		end
	end)
end

M.GetAIGenPrompts = function(self)
	local raw = self.GetRandomList(self, AIGenTemplateConfig, OCConfig.AIGenTemplateNum)
	local ret = {}

	for i = 1, #raw do
		local cfg = AIGenTemplateConfig.GetConfig(raw[i])
		ret[i] = {
			id = raw[i],
			label = cfg.Name,
			prompt = cfg.Prompt
		}
	end

	return ret
end
