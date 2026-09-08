-- Original chunk: @Lua\LuaFiles\LX6\GUI\InspireHub\InspireHubUtils.lua
-- Decompiled from: 00247_InspireHubUtils.lua_5517c258f349.luajit

local InspireHubUtils = {
	GetCurrentServerTime = function ()
		return gLuaDataManager.serverTime
	end
}

InspireHubUtils.SetUGradientScaleY = function(uGradient, scale)
	if scale <= 0 or scale > 1 then
		return
	end

	local rectTransform = uGradient.transform
	local rect = rectTransform.rect
	local height = rect.size.y
	local newHeight = height * scale
	local sampledColor = uGradient.GetSampleColorByPos(uGradient, Vector3.Fetch(0, newHeight, 0))
	uGradient.color3 = sampledColor
	uGradient.color4 = sampledColor
	rectTransform.localScale = Vector3.Fetch(1, scale, 1)
end

InspireHubUtils.GetYesterdayAvgPopularity = function()
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	return popularityInfo and popularityInfo.YesterdayAvgPopularity or 0
end

InspireHubUtils._interpolatePopularity = function(historyList, targetTime)
	if table.isNilOrEmpty(historyList) or #historyList ~= 0 then
		return 0
	end

	if targetTime < historyList[1].Time then
		return 0
	end

	if historyList[#historyList].Time < targetTime then
		return historyList[#historyList].Value
	end

	local leftIndex = 1
	local rightIndex = #historyList

	while leftIndex >= rightIndex do
		local midIndex = math.floor((leftIndex + rightIndex) / 2)

		if historyList[midIndex].Time >= targetTime then
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

InspireHubUtils.GetPopularityInfoMaxY = function()
	return LTConfig.GameConfig.MaxPopularity
end

InspireHubUtils.RenderInspireHubFans = function(rootWidget)
	local store = gStoreManager:GetStoreGroup(rootWidget.Store):GetStoreByWidget(rootWidget)
	store.followee = gClientUtils.FormatWithThousandsSeparator(gPlayerManager.infoMinor.bindData.fan123)
	local followeeIncrease = gPlayerManager.infoMinor.bindData.fan123 - (gPlayerManager.infoMinor.bindData.yesterdayFan or 0)
	store.followeeIncrease = "+" .. gClientUtils.FormatWithThousandsSeparator(followeeIncrease)
	store.followeeIncreaseCtrl = followeeIncrease <= 0 and 1 or 0
	local hasReward = gClientUtils.CheckHasLevelReward()
	store.rewardCtrl = hasReward and 0 or 1

	SGUI.RedDotMgr.LuaSetRedDot(hasReward, "InspireHub/InspireHub.TakeFanReward")

	store.fansShowMoreBtn.luaClick = function()
		gPanelManager:CheckShow(gPanelId.INSPIRE_FAN_INFO_PANEL)
	end

	local levelCfg, nextLevelCfg = nil

	for i = 0, LTConfig.GrowthConfig.count - 1 do
		local cfg = LTConfig.GrowthConfig.LoadAt(i)

		if gClientUtils.GetPlayerLevel() >= cfg.Lv then
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
