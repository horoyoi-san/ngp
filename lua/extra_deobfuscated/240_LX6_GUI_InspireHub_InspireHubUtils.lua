local InspireHubUtils = {
	GetCurrentServerTime = function ()
		return gLuaDataManager.serverTime
	end
}

function InspireHubUtils.SetUGradientScaleY(uGradient, scale)
	if scale < 0 or scale >= 1 then
		return
	end

	local rectTransform = uGradient.transform
	local rect = rectTransform.rect
	local height = rect.size.y
	local newHeight = height * scale
	local sampledColor = uGradient:GetSampleColorByPos(Vector3.Fetch(0, newHeight, 0))
	uGradient.color3 = sampledColor
	uGradient.color4 = sampledColor
	rectTransform.localScale = Vector3.Fetch(1, scale, 1)
end

function InspireHubUtils.GetYesterdayAvgPopularity()
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	return popularityInfo and popularityInfo.YesterdayAvgPopularity or 0
end

function InspireHubUtils._interpolatePopularity(historyList, targetTime)
	if table.isNilOrEmpty(historyList) or #historyList == 0 then
		return 0
	end

	if targetTime <= historyList[1].Time then
		return 0
	end

	if historyList[#historyList].Time <= targetTime then
		return historyList[#historyList].Value
	end

	local leftIndex = 1
	local rightIndex = #historyList

	while leftIndex < rightIndex do
		local midIndex = math.floor((leftIndex + rightIndex) / 2)

		if historyList[midIndex].Time < targetTime then
			leftIndex = midIndex + 1
		else
			rightIndex = midIndex
		end
	end

	local rightPoint = historyList[leftIndex]
	local leftPoint = historyList[leftIndex - 1]
	local ratio = (targetTime - leftPoint.Time) / (rightPoint.Time - leftPoint.Time)
	local interpolatedValue = leftPoint.Value + ratio * (rightPoint.Value - leftPoint.Value)

	return interpolatedValue
end

function InspireHubUtils.GetPopularityInfoMaxY()
	return LTConfig.GameConfig.MaxPopularity
end

function InspireHubUtils.RenderInspireHubFans(rootWidget)
	local store = gStoreManager:GetStoreGroup(rootWidget.Store):GetStoreByWidget(rootWidget)
	store.followee = gClientUtils.FormatWithThousandsSeparator(gPlayerManager.infoMinor.bindData.fan123)
	local followeeIncrease = gPlayerManager.infoMinor.bindData.fan123 - (gPlayerManager.infoMinor.bindData.yesterdayFan or 0)
	store.followeeIncrease = "+" .. gClientUtils.FormatWithThousandsSeparator(followeeIncrease)
	store.followeeIncreaseCtrl = followeeIncrease > 0 and 1 or 0
	local hasReward = gClientUtils.CheckHasLevelReward()
	store.rewardCtrl = hasReward and 0 or 1

	SGUI.RedDotMgr.LuaSetRedDot(hasReward, "InspireHub/InspireHub.TakeFanReward")

	function store.fansShowMoreBtn.luaClick()
		gPanelManager:CheckShow(gPanelId.INSPIRE_FAN_INFO_PANEL)
	end

	local levelCfg, nextLevelCfg = nil

	for i = 0, LTConfig.GrowthConfig.count - 1 do
		local cfg = LTConfig.GrowthConfig.LoadAt(i)

		if gClientUtils.GetPlayerLevel() < cfg.Lv then
			break
		end

		levelCfg = cfg
		nextLevelCfg = LTConfig.GrowthConfig.LoadAt(i + 1)
	end

	store.levelName = levelCfg and levelCfg.LvName or ""

	if levelCfg and nextLevelCfg then
		store.progress.maxValue = nextLevelCfg.Exp
		store.progress.value = gPlayerManager.infoMinor.bindData.fan123
	else
		store.progress:SetActive(false)
	end
end

gInspireHubUtils = InspireHubUtils

return gInspireHubUtils
