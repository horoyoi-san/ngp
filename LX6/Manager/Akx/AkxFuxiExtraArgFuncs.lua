-- Original chunk: @Lua\LuaFiles\LX6\Manager\Akx\AkxFuxiExtraArgFuncs.lua
-- Decompiled from: 02274_AkxFuxiExtraArgFuncs.lua_d224c6098007.luajit

local M = C_AkxManager

M.RegisterAllExtraArgFuncs = function(self)
	self.fuxiExtraArgFuncs = {
		get_player_fans_number = function ()
			local blob = {
				fan = tostring(gPlayerManager.infoMinor.bindData.fan123),
				fan12 = tostring(gPlayerManager.infoMinor.bindData.fan12),
				fan123 = tostring(gPlayerManager.infoMinor.bindData.fan123),
				yesterday_fan = tostring(gPlayerManager.infoMinor.bindData.yesterdayFan),
				stage_lv = tostring(gPlayerManager.infoMinor.bindData.level)
			}

			return blob
		end,
		get_player_badges = function ()
			local blob = {
				badges = {}
			}
			local badges = gPlayerManager.infoMinor.bindData.Badges

			for id, badge in pairs(badges) do
				local cfg = LTConfig.UrbanBadgeConfig.GetConfig(id)

				if badge.Active and cfg and not cfg.OnlyServer then
					local blobBadge = {
						id = id,
						name = cfg.Name,
						type = self:_ConvertBadgeTypeToStr(cfg.Type)
					}

					table.insert(blob.badges, blobBadge)
				end
			end

			return blob
		end,
		get_player_talents = function ()
			local blob = {
				talents = {}
			}
			local talents = gTalentTreeMgr:GetCurrentTalentDict(0)

			for _, talentInfo in pairs(talents) do
				local id = talentInfo.TalentId
				local cfg = LTConfig.TalentTreeTalentConfig.GetConfig(id)
				local blobTalent = {
					id = id,
					name = cfg.Name
				}

				table.insert(blob.talents, blobTalent)
			end

			return blob
		end
	}
end

M._ConvertBadgeTypeToStr = function(self, type)
	if type ~= LTConfig.UrbanBadgeConfig.TypeType.Common then
		return "Common"
	elseif type ~= LTConfig.UrbanBadgeConfig.TypeType.FightSpirit then
		return "FightSpirit"
	elseif type ~= LTConfig.UrbanBadgeConfig.TypeType.Job then
		return "Job"
	end

	return "Unknown"
end
