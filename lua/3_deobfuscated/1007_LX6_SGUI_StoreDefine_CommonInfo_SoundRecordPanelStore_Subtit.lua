local M = C_SoundRecordPanelStore

function M:InitSubtitle(cfg)
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

function M:SeekSubtitle(time)
	local splitTimePoint = self.splitTimePoint

	if splitTimePoint == nil then
		return
	end

	if time < 0 or splitTimePoint[#splitTimePoint] < time then
		return nil
	end

	local index = self:LowerBound(splitTimePoint, time)

	return self.subtitleItems[index - 1]
end

function M:UpdateSubtitle(value)
	local subtitleItem = self:SeekSubtitle(value)
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

function M:LowerBound(arr, value)
	local l = 1
	local r = #arr + 1

	while l < r do
		local mid = l + math.floor((r - l) / 2)

		if arr[mid] < value then
			l = mid + 1
		else
			r = mid
		end
	end

	return l
end
