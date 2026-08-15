gMapSystem_Region = gMapSystem_Region or {}
local M = gMapSystem_Region

function M:Init()
	return
end

function M:IsCountryUnlocked(countryId)
	if gPlayerManager.infoAchievement and gPlayerManager.infoAchievement.bindData.UnlockedCountryList then
		local UnlockedCountryList = gPlayerManager.infoAchievement.bindData.UnlockedCountryList

		if array.contains(UnlockedCountryList, countryId) then
			return true
		end
	end

	return false
end

return M
