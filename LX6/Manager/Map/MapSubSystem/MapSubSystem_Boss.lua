-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Boss.lua
-- Decompiled from: 02339_MapSubSystem_Boss.lua_37648a49b9ed.luajit

local actionHelper = require("LX6/Manager/Map/MapSubSystem/MapSubSystemActionHelper")
MapSubSystem_Boss = DefClass("MapSubSystem_Boss", MapSubSystem_Boss, MapSubSystemBase)
local M = MapSubSystem_Boss

M.OnInit = function(self)
	self._enemyInfos = {}
end

M.OnFlushData = function(self)
end

M.SGetTooltipInfo = function(self, id, element)
	local info = self._enemyInfos[id]

	if not info then
		return nil
	end

	local agentConfig = LTConfig.AgentConfig.GetConfig(info.enemyId)
	local tooltipInfo = {
		type = EMapTooltipType.Common,
		header = {
			name = element:GetName(),
			imageId = agentConfig.SPictureId or 0,
			desc = agentConfig.Description
		},
		commonInfo = {}
	}
	local rewardList = {}
	local firstKillReward = gCommonItemManager:GetSingleSortedListRenderData({
		{
			["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = true,
			["Z\\x9e\\x9e\\xaaE"] = 0
		}
	})
	local FirstKillEnemyRecord = gPlayerManager.infoAchievement.bindData.FirstKillEnemyRecord
	local isNotFirstKill = FirstKillEnemyRecord and table.contains(FirstKillEnemyRecord, id)

	if not isNotFirstKill then
		rewardList = firstKillReward
	end

	tooltipInfo.commonInfo.legacyRewardList = rewardList

	return tooltipInfo
end

M.ExecuteAction = function(self, element, action, ctx)
	actionHelper.TryExecuteTraceAction(element, action, ctx)
end

return M
