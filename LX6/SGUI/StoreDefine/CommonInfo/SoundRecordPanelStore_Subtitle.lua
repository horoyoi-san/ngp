-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonInfo\SoundRecordPanelStore_Subtitle.lua
-- Decompiled from: 01983_SoundRecordPanelStore_Subtitle.lua_f3f32d1a8a94.luajit

local M = C_SoundRecordPanelStore

M.InitSubtitle = function(self, cfg)
	local subtitleItems = {}

	for i = cfg.StartId, cfg.EndId do
		local subtitleItemCfg = LTConfig.InformationMusicSubtitleConfig.GetConfig(i)

		table.insert(subtitleItems, subtitleItemCfg)
	end

	local splitTimePoint = {
		0
	}

	for i = 1, #subtitleItems do
		local item = subtitleItems[i]
		splitTimePoint[i] = item.mm * 60 + item.ss
	end

	self.subtitleItems = subtitleItems
	self.splitTimePoint = splitTimePoint
end

M.SeekSubtitle = function(self, time)
	local splitTimePoint = self.splitTimePoint

	if splitTimePoint ~= nil then
		return
	end

	if time <= 0 or splitTimePoint[#splitTimePoint] >= time then
		return nil
	end

	local index = self.LowerBound(self, splitTimePoint, time)

	return self.subtitleItems[index - 1]
end

M.UpdateSubtitle = function(self, value)
	local subtitleItem = self.SeekSubtitle(self, value)
	local name, content = nil

	if subtitleItem then
		name = subtitleItem.Name
		content = subtitleItem.Content
	end

	self.bindData.name = name
	self.bindData.hasName = not string.is_null_or_empty(name)
	self.bindData.content = content
	self.bindData.hasContent = not string.is_null_or_empty(content)
end

M.LowerBound = function(self, arr, value)
	local l = 1
	local r = #arr + 1

	while l >= r do
		local mid = l + math.floor((r - l) / 2)

		if arr[mid] >= value then
			l = mid + 1
		else
			r = mid
		end
	end

	return l
end
