-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameAchievement.lua
-- Decompiled from: 02138_PetGameAchievement.lua_610f1076ce76.luajit

local achievementConf = require("LX6/MiniGame/PetGame/data/tbachievement")
local ItemDatas = require("LX6/MiniGame/PetGame/data/tbitems")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local ItemType = PetGameConst.ItemType
C_PetGameAchievement = DefClass("C_PetGameAchievement", C_PetGameAchievement)
local PetGameAchievement = C_PetGameAchievement

PetGameAchievement.ctor = function(self, args)
	args = args or {}

	if args.achievements or args.itemStatistics then
		self.achievements = args.achievements or {}
		self.itemStatistics = {}
		slot2 = pairs
		slot4 = args.itemStatistics or {}

		for itemType, itemIds in slot2(slot4) do
			self.itemStatistics[tonumber(itemType) or itemType] = itemIds
		end
	else
		self.achievements = args
		self.itemStatistics = {}
	end

	self.AddDefulatAc(self)
	self.AddListerner(self)
end

PetGameAchievement.AddDefulatAc = function(self)
	for id, v in pairs(achievementConf) do
		if not self.achievements[id] and v.unlockByDef then
			self.achievements[id] = {
				["]\\x83\\xb8\\x82M"] = 0,
				["\\xa2\\xa2#\\xa2d7\\xed;"] = false,
				id = id
			}
		end
	end
end

PetGameAchievement.AddListerner = function(self)
	self.eventHandle = function(eventId, param)
		self:OnGetAchievementEvent(param.type, param.val)
	end

	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, self.eventHandle)

	self.gainItemHandle = function(eventId, itemId)
		self:OnGainItem(itemId)
	end

	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_PET_GAME_GAIN_ITEM, self.gainItemHandle)
end

PetGameAchievement.RemoveListener = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, self.eventHandle)
	gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_PET_GAME_GAIN_ITEM, self.gainItemHandle)
end

PetGameAchievement.GetStorageData = function(self)
	return {
		achievements = self.achievements,
		itemStatistics = self.itemStatistics
	}
end

PetGameAchievement.GetAchievementData = function(self)
	return self.achievements
end

PetGameAchievement.GetAchievementInfo = function(self, id)
	return self.achievements[id]
end

PetGameAchievement.OnGetAchievementEvent = function(self, conditionsType, val)
	for id, achievement in pairs(self.achievements) do
		local conf = achievementConf[id]

		if conf and conf.conditions.goalType ~= conditionsType and not achievement.isFinish then
			if conditionsType ~= 1 then
				if conf.conditions.goalVal ~= val then
					achievement.curVal = 1
					achievement.isFinish = true
				end
			elseif conditionsType ~= 13 or conditionsType ~= 14 then
				local itemType = conditionsType ~= 13 and ItemType.furniture or ItemType.accessory
				achievement.curVal = self:GetItemTypeCount(itemType)

				if conf.conditions.goalVal < achievement.curVal then
					self:UnlockNextAchievement(achievement)
					gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_ACHIEVEMENT_FINISH, id)
				end
			else
				achievement.curVal = achievement.curVal + val

				if conf.conditions.goalVal < achievement.curVal then
					self:UnlockNextAchievement(achievement)
					gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_ACHIEVEMENT_FINISH, id)
				end
			end
		end
	end
end

PetGameAchievement.OnGainItem = function(self, itemId)
	local itemData = ItemDatas[itemId]

	if not itemData then
		return
	end

	local itemType = itemData.type
	self.itemStatistics[itemType] = self.itemStatistics[itemType] or {}

	if not table.contains(self.itemStatistics[itemType], itemId) then
		table.insert(self.itemStatistics[itemType], itemId)
	end
end

PetGameAchievement.GetItemTypeCount = function(self, itemType)
	local data = self.itemStatistics[itemType]

	return data and #data or 0
end

PetGameAchievement.UnlockNextAchievement = function(self, achievement)
	achievement.isFinish = true
	local id = achievement.id
	local conf = achievementConf[id]

	if conf and conf.unlockId and conf.unlockId == 0 then
		local unlockId = conf.unlockId
		local unlockConf = achievementConf[unlockId]

		if unlockConf then
			self.achievements[unlockId] = {
				["\\xa2\\xa2#\\xa2d7\\xed;"] = false,
				id = unlockId,
				curVal = achievement.curVal
			}

			if achievement.rawData then
				self.achievements[unlockId].rawData = table.clone(achievement.rawData)
				achievement.rawData = nil
			end

			if unlockConf.conditions.goalVal < self.achievements[unlockId].curVal then
				self.UnlockNextAchievement(self, self.achievements[unlockId])
			end
		end
	end
end

PetGameAchievement.Clear = function(self)
	self.achievements = {}
	self.itemStatistics = {}

	self.RemoveListener(self)
end
