local SeasonRaidConfig = LTConfig.SeasonRaidConfig
local ChaosLevelConfig = LTConfig.SeasonRaidChaosLevelConfig
local ChaosBuffConfig = LTConfig.SeasonRaidChaosBuffConfig
local ChaosItemConfig = LTConfig.SeasonRaidChaosItemConfig
local SeasonItemType = require("LX6.GUI.Season.SeasonItemType")
local SeasonRaidUtils = {
	GetMaxChaosValue = function (self)
		return SeasonRaidConfig.ChaosMaxLevel * SeasonRaidConfig.ChaosLevelMaxValue
	end,
	FindConfigByLevel = function (self, level)
		for i = 0, ChaosLevelConfig.count - 1 do
			local config = ChaosLevelConfig.LoadAt(i)

			if config.ChaosLevel == level then
				return config
			end
		end

		return nil
	end,
	IsChaosBuff = function (self, itemId)
		if itemId == nil then
			return false
		end

		return ChaosBuffConfig.GetConfig(itemId) ~= nil
	end,
	IsChaosItem = function (self, itemId)
		if itemId == nil then
			return false
		end

		return ChaosItemConfig.GetConfig(itemId) ~= nil
	end,
	SetChaosProgress = function (self, bindData, current, max)
		if max == nil then
			max = self:GetMaxChaosValue()
		end

		local level = math.floor(current / SeasonRaidConfig.ChaosLevelMaxValue)

		if SeasonRaidConfig.ChaosMaxLevel < level then
			level = SeasonRaidConfig.ChaosMaxLevel
		end

		bindData.progressValue = current / max
		bindData.progressText = gString.Format("%d/%d", gUtils:Round(current), max)
		bindData.progressIcon = SeasonRaidConfig.ChaosLevelIcons[level + 1]
	end,
	SetupCardType = function (self, cell, itemType)
		cell.ItemIconType = itemType

		if itemType == SeasonItemType.medicine then
			cell.showTag = false
			cell.showAvatar = false
			cell.isConsumableOrQiwu = true
			cell.isBuff = false
		elseif itemType == SeasonItemType.buff then
			cell.showTag = true
			cell.showAvatar = true
			cell.isConsumableOrQiwu = false
			cell.isBuff = true
		elseif itemType == SeasonItemType.qiwu then
			cell.showTag = false
			cell.showAvatar = false
			cell.isConsumableOrQiwu = true
			cell.isBuff = false
		end

		return cell
	end,
	SetupCardData = function (self, itemId, cell)
		if self:IsChaosBuff(itemId) then
			self:SetupCardType(cell, SeasonItemType.buff)

			local buffConfig = ChaosBuffConfig.GetConfig(itemId)

			if buffConfig then
				cell.name = buffConfig.Name
				cell.Quality = buffConfig.Quality
				cell.iconId = buffConfig.ImageId
				local spiritConfig = LTConfig.FightSpiritConfig.GetConfig(buffConfig.FightSpiritId)

				if spiritConfig then
					cell.avatarIconId = 0
				end

				cell.desc = buffConfig.Description
				cell.tagName = buffConfig.Tag
			end

			return SeasonItemType.buff
		elseif self:IsChaosItem(itemId) then
			self:SetupCardType(cell, SeasonItemType.qiwu)

			local itemConfig = ChaosItemConfig.GetConfig(itemId)

			if itemConfig then
				cell.name = itemConfig.Name
				cell.Quality = itemConfig.Quality
				cell.iconId = itemConfig.ImageId
				cell.desc = itemConfig.Description
			end

			return SeasonItemType.qiwu
		end
	end,
	GenerateCardTemplateData = function (self, itemId)
		local cell = {}
		local itemType = self:SetupCardData(itemId, cell)

		return cell, itemType
	end
}
gSeasonRaidUtils = SeasonRaidUtils

return SeasonRaidUtils
