local ConsumableConfig = LTConfig.ConsumableConfig
local StoneConfig = LTConfig.StoneConfig
local StoneStarConfig = LTConfig.StoneStarConfig
local MessageConfig = LTConfig.MessageConfig

if not gStoneManager then
	local M = {
		MaxStoneBreakthroughLevel = 4,
		quickSelectStoneType = 1,
		quickSelectOnlyUseFoods = false,
		MaxStoneStackingCardLevel = 5,
		isAnimPlaying = false,
		MaxStoneLevel = 60,
		AllStoneInfos = {},
		StoneLevelUpItemList = {},
		StoneLevelUpItemExpList = {},
		normalColor = Color.New(1, 1, 1, 0.6980392),
		previewColor = Color.New(0.9921569, 0.5450981, 0.2078431),
		StoneQualityIcon = {
			30302022,
			30302020,
			30302021,
			30302023
		},
		StoneRomanIcon = {
			30302025,
			30302026,
			30302027,
			30302028,
			30302029
		}
	}
end

M.GrowthType = {
	StackingCard = 4,
	Details = 1,
	Strengthen = 2,
	BreakThrough = 3
}
M.StrengthenItemType = {
	BaseMaterial = 2,
	Stone = 1
}
M.SpiritStoneType = {}
M.SpiritStoneTypeList = {
	"ChaoYue",
	"SanShi",
	"JingQi",
	"LingGan",
	"HuanXing"
}

setmetatable(M.SpiritStoneType, {
	__index = function (t, k)
		if k == "ChaoYue" then
			return {
				IconId = 30200071,
				IconId_Large = 30200076,
				TypeIndex = 1,
				Name = LTConfig.TextScriptTextConfig.GetConfig(89900890).Text
			}
		elseif k == "SanShi" then
			return {
				IconId = 30200070,
				IconId_Large = 30200075,
				TypeIndex = 2,
				Name = LTConfig.TextScriptTextConfig.GetConfig(89900891).Text
			}
		elseif k == "JingQi" then
			return {
				IconId = 30200069,
				IconId_Large = 30200074,
				TypeIndex = 3,
				Name = LTConfig.TextScriptTextConfig.GetConfig(89900892).Text
			}
		elseif k == "LingGan" then
			return {
				IconId = 30200072,
				IconId_Large = 30200077,
				TypeIndex = 4,
				Name = LTConfig.TextScriptTextConfig.GetConfig(89900893).Text
			}
		elseif k == "HuanXing" then
			return {
				IconId = 30200068,
				IconId_Large = 30200073,
				TypeIndex = 5,
				Name = LTConfig.TextScriptTextConfig.GetConfig(89900894).Text
			}
		end
	end
})

M.SortType = {}

function M:OnInit()
	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end

	self.StoneLevelUpItemExpList = StoneConfig.StoneLevelUpItemExp or {}
	self.StoneLevelUpItemList = StoneConfig.StoneLevelUpItem or {}

	M:RefreshStoneSortType()
end

function M:RefreshStoneSortType()
	table.clear(M.SortType)

	local sortType = {
		LTConfig.TextScriptTextConfig.GetConfig(89900128).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900223).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900369).Text
	}

	array.concat(M.SortType, sortType)
end

function M:SyncNewStone(stoneInfo)
	self.AllStoneInfos[stoneInfo.InstanceId] = stoneInfo

	gPlayerItemManager:SetPackStone({
		stoneInfo
	}, nil, nil)
end

function M:SyncStoneChanged(stoneInfo)
	self.AllStoneInfos[stoneInfo.InstanceId] = stoneInfo

	gPlayerItemManager:SetPackStone(nil, {
		stoneInfo
	}, nil)
end

function M:SyncRemoveStone(stoneInstanceId)
	self.AllStoneInfos[stoneInstanceId] = nil

	gPlayerItemManager:SetPackStone(nil, nil, {
		stoneInstanceId
	})
end

function M:AskSetSpiritStone(spiritTid, stoneId, callback)
	gClientToGameDelegate:AskSetSpiritStone(spiritTid, stoneId).Callback = function (err)
		if callback then
			callback(err)
		end
	end
end

function M:AskLockStone(stoneId, isLock, callback)
	gClientToGameDelegate:AskLockStone(stoneId, isLock).Callback = function (err)
		if err == MessageConfig.Ok then
			if isLock then
				gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900779).Text)
			else
				gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900780).Text)
			end
		end

		if callback then
			callback(err)
		end
	end
end

function M:NumFormat(type, num)
	local result = num
	local NumFormat = string.sub(type, 1, 1)
	local NumDecimal = string.sub(type, 2, 2)

	if NumFormat == "p" or NumFormat == "P" then
		result = gUIUtils:GetPreciseDecimalStr(num * 100, NumDecimal) .. "%"
	elseif NumFormat == "f" or NumFormat == "F" then
		result = gUIUtils:GetPreciseDecimalStr(num, NumDecimal)
	else
		result = tostring(num)
	end

	return result
end

function M:GetStackingCardDes(stackingCardId, stackingCardLevel)
	local stackingCardCfg = StoneStarConfig.GetConfig(stackingCardId)
	local paramList = self:GetStackingCardParamList(stackingCardId, stackingCardLevel)
	local paramTypeList = stackingCardCfg.StarUpParametersType or {}

	if #paramList ~= #paramTypeList then
		print_error("StoneManager GetStackingCardDes paramList length ~= paramTypeList length,stoneStarId:" .. stackingCardId)

		return
	end

	for i = 1, #paramTypeList do
		local type = paramTypeList[i]
		paramList[i] = self:NumFormat(type, paramList[i])
	end

	if #paramList == 0 then
		return stackingCardCfg.Description
	else
		return gString.Format(stackingCardCfg.Description, unpack(paramList))
	end
end

function M:GetStackingCardParamList(stackingCardId, stackingCardLevel)
	local stackingCardCfg = StoneStarConfig.GetConfig(stackingCardId)
	local starLevelParamList = stackingCardCfg.StarUpBuffParams
	local paramKey = "Level" .. stackingCardLevel
	local paramList = {}

	if starLevelParamList then
		for i = 1, #starLevelParamList do
			table.insert(paramList, starLevelParamList[i][paramKey])
		end
	end

	return paramList
end

function M.DefaultSort(a, b)
	if not a.QualityValue or not b.QualityValue or a.QualityValue == b.QualityValue then
		if not a.stoneLevel or not b.stoneLevel or a.stoneLevel == b.stoneLevel then
			if not a.star or not b.star or a.star == b.star then
				if a.isEquiped == true and b.isEquiped ~= true then
					return true
				elseif a.isEquiped ~= true and b.isEquiped == true then
					return false
				else
					return a.templateId < b.templateId
				end
			else
				return b.star < a.star
			end
		else
			return b.stoneLevel < a.stoneLevel
		end
	else
		return b.QualityValue < a.QualityValue
	end
end

function M.SortByQualityDesc(a, b)
	if a.QualityValue == b.QualityValue then
		return M.DefaultSort(a, b)
	else
		return b.QualityValue < a.QualityValue
	end
end

function M.SortByQualityAsc(a, b)
	if a.QualityValue == b.QualityValue then
		return M.DefaultSort(a, b)
	else
		return a.QualityValue < b.QualityValue
	end
end

function M.SortByLevelDesc(a, b)
	if a.stoneLevel == b.stoneLevel then
		return M.DefaultSort(a, b)
	else
		return b.stoneLevel < a.stoneLevel
	end
end

function M.SortByLevelAsc(a, b)
	if a.stoneLevel == b.stoneLevel then
		return M.DefaultSort(a, b)
	else
		return a.stoneLevel < b.stoneLevel
	end
end

function M.SortByEquippedDesc(a, b)
	if a.isEquiped == b.isEquiped then
		return M.DefaultSort(a, b)
	else
		return a.isEquiped == true
	end
end

function M.SortByEquippedAsc(a, b)
	if a.isEquiped == b.isEquiped then
		return M.DefaultSort(a, b)
	else
		return a.isEquiped == false
	end
end

function M.GetConsumableConfig(stoneId)
	local stoneCfg = LTConfig.StoneConfig.GetConfig(stoneId)
	local consumableId = stoneCfg and stoneCfg.ConsumableId

	return LTConfig.ConsumableConfig.GetConfig(consumableId)
end

function M.GetStoneQuality(stoneId)
	local consuableCfg = M.GetConsumableConfig(stoneId)

	return consuableCfg and consuableCfg.Quality
end

M.EventHandler = {
	[gEventConstants.LANGUAGE_CHANGE] = function (eventId, data)
		M:RefreshStoneSortType()
	end
}
gStoneManager = M
