local actionHelper = require("LX6/Manager/Map/MapSubSystem/MapSubSystemActionHelper")
MapSubSystem_Boss = DefClass("MapSubSystem_Boss", MapSubSystem_Boss, MapSubSystemBase)
local M = MapSubSystem_Boss

function M:OnInit()
	self._enemyInfos = {}
end

function M:OnFlushData()
	return
end

function M:RealUpdateInfo(enemyList)
	local newEnemyIds = {}

	for i, enemyInfo in pairs(enemyList or {}) do
		if enemyInfo.Unlocked then
			if enemyInfo.RebornTime ~= 0 and enemyInfo.GetRewardTime ~= 0 then
				-- Nothing
			else
				local refreshEnemyConfig = LTConfig.RefreshEnemyConfig.GetConfig(enemyInfo.TemplateId)

				if not refreshEnemyConfig then
					-- Nothing
				else
					local agentConfig = LTConfig.AgentConfig.GetConfig(refreshEnemyConfig.EnemyId)

					if agentConfig then
						if agentConfig.EnemyClassType ~= 2 then
							-- Nothing
						else
							local systemId = refreshEnemyConfig.SystemUnlockId

							if not systemId or systemId <= 0 or gSystemUnlockMgr:IsUnlock(systemId) then
								local spoonId = enemyInfo.SpoonId
								local uxPos = enemyInfo.Position
								local worldPos = Vector3.New(uxPos.X, uxPos.Y, uxPos.Z)
								newEnemyIds[spoonId] = true
								local info = nil

								if self._enemyInfos[spoonId] then
									info = self._enemyInfos[spoonId]
								else
									info = {
										enemyId = refreshEnemyConfig.EnemyId,
										refreshEnemyId = enemyInfo.TemplateId
									}
									self._enemyInfos[spoonId] = info
									local element = MapElement.CreateLegacy(EMapElementType.Boss, spoonId, EMapSubSystemType.Boss, EMapViewMask.AllSgui, LTConfig.RaidConfig.WorldMap, enemyInfo.IndoorId)

									element:SetActions(self.NormalTraceableActions)

									element.gpsData.removeGpsRange = LTConfig.GameConfig.BossAutoRemoveGpsRange
									element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect
									element.mData.sIconId = 28005279
									element.bigMapData.scaleLevel = 2

									gMapSubSystemUtils:SetupScaleLevel(element, LTConfig.GpsConfig.ShowTypeOfBoss, LTConfig.GpsConfig.BossSIconId2)

									info.element = element
								end

								local element = info.element
								element.mData.lName = GpsLText.CreateCommonText(agentConfig, "Name")

								element:SetPosition(worldPos)
								element:SetVisible(true)
							end
						end
					end
				end
			end
		end
	end

	for spoonId, info in pairs(self._enemyInfos) do
		if not newEnemyIds[spoonId] then
			info.element:Dispose()

			self._enemyInfos[spoonId] = nil
		end
	end
end

function M:SGetTooltipInfo(id, element)
	local info = self._enemyInfos[id]

	if not info then
		return nil
	end

	local agentConfig = LTConfig.AgentConfig.GetConfig(info.enemyId)
	local refreshEnemyCfg = LTConfig.RefreshEnemyConfig.GetConfig(info.refreshEnemyId)
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
			isFirstKill = true,
			dropId = refreshEnemyCfg.FirstKillDropId
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

function M:ExecuteAction(element, action, ctx)
	actionHelper.TryExecuteTraceAction(element, action, ctx)
end

return M
