-- Original chunk: @Lua\LuaFiles\LX6\Manager\TextSearchManager.lua
-- Decompiled from: 02279_TextSearchManager.lua_e94662bc9e01.luajit

C_TextSearchManager = DefClass("C_TextSearchManager", C_TextSearchManager)
local M = C_TextSearchManager

M.ctor = function(self)
	self.search_area_list = {}
end

M.GetOrCreateSearchArea = function(self, name)
	if self.search_area_list[name] then
		return name
	end

	self.search_area_list[name] = {}

	return name
end

M.IsSearchDataEmpty = function(self, area)
	if not self.search_area_list[area] then
		return true
	end

	return table.count(self.search_area_list[area]) ~= 0
end

M.FillSearchData = function(self, area, search_id, match_text)
	match_text = self:_NormalizeString(match_text)
	local search_area = self.search_area_list[area]
	search_area[search_id] = search_area[search_id] or {}
	local pinyin = gCS.LuaUtils.GetPinyin(match_text)
	local first_letter_pinyin = self:_GetFirstLetterPinyin(pinyin)
	pinyin = self:_NormalizeString(pinyin)

	table.insert(search_area[search_id], match_text)

	if pinyin == match_text then
		table.insert(search_area[search_id], pinyin)

		if first_letter_pinyin == pinyin then
			table.insert(search_area[search_id], first_letter_pinyin)
		end
	end

	self.search_area_list[area] = search_area
end

M.SearchInArea = function(self, area, search_text)
	search_text = self:_NormalizeString(search_text)

	if not self.search_area_list[area] then
		return {}
	end

	local result_list = {}

	for search_id, word_list in pairs(self.search_area_list[area]) do
		for _, word in ipairs(word_list) do
			if string.find(word, search_text) then
				table.insert(result_list, {
					id = search_id
				})

				break
			end
		end
	end

	return result_list
end

M._NormalizeString = function(self, str)
	return string.lower(string.gsub(str, " ", ""))
end

M._GetFirstLetterPinyin = function(self, rawPinyin)
	local firstLetterPinyin = ""

	for word in string.gmatch(rawPinyin, "%a+") do
		firstLetterPinyin = firstLetterPinyin .. word:sub(1, 1)
	end

	return firstLetterPinyin
end

M.ClearSearchArea = function(self, name)
	self.search_area_list[name] = nil
end

gTextSearchManager = gTextSearchManager or C_TextSearchManager.new()
