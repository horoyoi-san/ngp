C_ScratchCardType3Store = DefClass("C_ScratchCardType3Store", C_ScratchCardType3Store, C_ScratchCardType1Store)
GroupName2Class.ScratchCardType3Store = C_ScratchCardType3Store
local M = C_ScratchCardType3Store

function M:GetMaxReward()
	return LTConfig.PoiGameConfig.ScratchType3MaxReward
end

function M:GetShowCount()
	return 8
end

function M:InitDataList(args)
	self.numberMultipliers = {}
	self.baseScoreList = {}
	self.gamePlayId = args.gamePlayId
	local count = LTConfig.PoiGameScratchConfig.count

	for i = 0, count - 1 do
		local scratchCfg = LTConfig.PoiGameScratchConfig.LoadAt(i)

		if scratchCfg.GameplayID == self.gamePlayId then
			if scratchCfg.Multiple > 0 then
				self.numberMultipliers[tonumber(scratchCfg.Text)] = scratchCfg.Multiple
			end

			if scratchCfg.Score > 0 then
				table.insert(self.baseScoreList, scratchCfg.Score)
			end
		end
	end

	self.dataList = self:GenerateRewardList(args.targetRewardMin, args.targetRewardMax)
end

function M:IsAllSameNumbers(itemData)
	local first = itemData.numberList[1]

	for _, num in ipairs(itemData.numberList) do
		if num ~= first then
			return false
		end
	end

	return true
end

function M:CalculateItemReward(itemData)
	if not self:IsAllSameNumbers(itemData) then
		return 0
	end

	local number = itemData.numberList[1]
	local multiplier = self.numberMultipliers[number] or 1

	return multiplier * itemData.score
end

function M:CalculateTotalReward(dataList)
	local total = 0

	for _, item in ipairs(dataList) do
		total = total + self:CalculateItemReward(item)
	end

	return total
end

function M:RandomGenerateRewardList()
	local rewardList = {}
	local showCount = self:GetShowCount()
	local totalReward = 0

	for _ = 1, showCount do
		local numberList = {
			math.random(1, 9),
			math.random(1, 9),
			math.random(1, 9)
		}
		local score = self.baseScoreList[math.random(1, #self.baseScoreList)]
		local data = {
			numberList = numberList,
			score = score
		}

		table.insert(rewardList, data)

		if self:IsAllSameNumbers(data) then
			totalReward = totalReward + self:CalculateItemReward(data)
		end
	end

	return rewardList, totalReward
end

function M:OnRenderItem(btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local data = self.dataList[luaIndex]
	local numberList = data.numberList

	function store.list.luaSimpleRenderItem(childBtn, childCsIndex)
		local childLuaIndex = childCsIndex + 1
		local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
		local number = numberList[childLuaIndex]
		childStore.iconId = self:GetNumberIconId(number)
	end

	store.money = data.score

	store.list:SetSimpleList(#numberList)

	store.isTargetControl = self:GetTargetControl(data)
	store.round = csIndex
end

function M:GetNumberIconId(number)
	local count = LTConfig.PoiGameScratchConfig.count

	for i = 0, count - 1 do
		local scratchCfg = LTConfig.PoiGameScratchConfig.LoadAt(i)

		if scratchCfg.GameplayID == self.gamePlayId and scratchCfg.Text == tostring(number) then
			return scratchCfg.SguiID
		end
	end

	return 0
end

function M:GetTargetControl(data)
	if self.bindData.stateControl == 1 then
		return self:IsAllSameNumbers(data) and 1 or 0
	else
		return 0
	end
end

function M:GetTotalReward()
	return self:CalculateTotalReward(self.dataList)
end

function M:GetRewardTipsList()
	return LTConfig.PoiGameConfig.ScratchType3RewardTipsList
end
