local M = gSceneManager or {}

function M:OnSyncEnterScene(enterInfo)
	local raidId = enterInfo.RaidId
	local raidInstanceId = enterInfo.InstanceId
	local activityId = enterInfo.ActivityId
	local position = enterInfo.Position
	local facing = enterInfo.Facing
	local spoonLevels = enterInfo.SpoonLevels
	local spoonMd5s = enterInfo.SpoonMd5s
	Time.timeScale = 1

	gRaidDataManager:OnEnterScene(enterInfo)
	gMapSystem:OnEnterScene(enterInfo)
	gTicketActivityManager:SetCurrentActivityId(activityId)

	gRpcUtils.isSendingSwitchRaidRpc = false
	gLuaDataManager.SpoonMd5s = spoonMd5s
	gLuaDataManager.SpoonLevels = spoonLevels
	local switchSceneData = LX6.Scene.SwitchSceneData.New()
	switchSceneData.raidId = raidId
	switchSceneData.raidInstanceId = raidInstanceId
	switchSceneData.playerSessionId = enterInfo.PlayerSessionId
	switchSceneData.position = UX.Game.UXVector3.New(position.X, position.Y, position.Z)
	switchSceneData.facing = facing
	switchSceneData.gameplay_MatchGameId = enterInfo.MatchGameId
	switchSceneData.switchShowId = enterInfo.SwitchShowId
	switchSceneData.sectorControlId = enterInfo.SectorControlId
	switchSceneData.levels = enterInfo.SpoonLevels
	switchSceneData.md5s = enterInfo.SpoonMd5s
	local spiritsInfo = {}

	for i = 1, #enterInfo.Spirits do
		local v = enterInfo.Spirits[i]
		local data = UX.Game.SpiritInitData.New()
		data.Id = v.Id
		data.TemplateId = v.TemplateId
		data.IsActive = v.IsActive
		data.WeaponTemplateId = v.WeaponTemplateId

		table.insert(spiritsInfo, data)
	end

	switchSceneData.spirits = spiritsInfo
	local gridInfo = enterInfo.GridInfo
	local minX = 0
	local minZ = 0

	if gridInfo then
		minZ = gridInfo.MinZ
		minX = gridInfo.MinX
	end

	switchSceneData.sceneMinX = minX
	switchSceneData.sceneMinZ = minZ

	if enterInfo.LoadingType then
		local loadingTypeInfo = enterInfo.LoadingType
		local pIds = {}

		if loadingTypeInfo.Members then
			for i = 1, #loadingTypeInfo.Members do
				local v = loadingTypeInfo.Members[i]

				table.insert(pIds, v)
			end
		end

		switchSceneData.loadingType = loadingTypeInfo.Type
		switchSceneData.linkPIds = pIds
	end

	gCS.SwitchSceneManager.OnSyncEnterScene(switchSceneData)
end

gSceneManager = M
