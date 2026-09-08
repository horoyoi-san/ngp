-- Original chunk: @Lua\LuaFiles\LX6\Scene\SceneManager.lua
-- Decompiled from: 00678_SceneManager.lua_740cff586b66.luajit

local M = gSceneManager or {}

M.OnSyncEnterScene = function(self, enterInfo)
	local raidId = enterInfo.RaidId
	local raidInstanceId = enterInfo.InstanceId
	local activityId = enterInfo.ActivityId
	local position = enterInfo.Position
	local facing = enterInfo.Facing
	Time.timeScale = 1

	gRaidDataManager:OnEnterScene(enterInfo)
	gMapSystem:OnEnterScene(enterInfo)
	gTicketActivityManager:SetCurrentActivityId(activityId)
	gLinkManager:OnEnterScene(enterInfo)

	gRpcUtils.isSendingSwitchRaidRpc = false

	if enterInfo.CollectionRoomLoadData then
		gCollectionRoomManager:OnSyncEnterScene(enterInfo.CollectionRoomLoadData)
	end

	local switchSceneData = LX6.Scene.SwitchSceneData.New()
	switchSceneData.raidId = raidId
	switchSceneData.raidInstanceId = raidInstanceId
	switchSceneData.playerSessionId = enterInfo.PlayerSessionId
	switchSceneData.position = UX.Game.UXVector3.New(position.X, position.Y, position.Z)
	switchSceneData.facing = facing
	switchSceneData.gameplay_MatchGameId = enterInfo.MatchGameId
	switchSceneData.switchShowId = enterInfo.SwitchShowId
	switchSceneData.sectorControlId = enterInfo.SectorControlId
	switchSceneData.dynamicLayerId = enterInfo.DynamicLayerId
	switchSceneData.md5s = enterInfo.SceneSpoonMd5s
	switchSceneData.sceneSpoonNames = enterInfo.SceneSpoonNames
	switchSceneData.dungeonLoadSectorHashs = enterInfo.TombIslandIds
	local dataLayerIndices = {}

	for i = 1, #enterInfo.DataLayerIndices do
		local v = enterInfo.DataLayerIndices[i]
		local dataLayerIndex = UX.Game.DataLayerIndic.New()
		dataLayerIndex.Mode = v.Mode
		dataLayerIndex.ResourceIndices = v.ResourceIndices
		dataLayerIndex.SceneBaseIndic = v.SceneBaseIndic
		dataLayerIndex.UniverseBaseIndic = v.UniverseBaseIndic
		dataLayerIndex.RaidBaseIndic = v.RaidBaseIndic

		table.insert(dataLayerIndices, dataLayerIndex)
	end

	switchSceneData.DataLayerIndices = dataLayerIndices
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

	if enterInfo.LinkSimpleInfo then
		local linkSimpleInfo = UX.Game.LinkSimpleInfo.New()
		linkSimpleInfo.Id = enterInfo.LinkSimpleInfo.Id
		linkSimpleInfo.Mode = enterInfo.LinkSimpleInfo.Mode
		linkSimpleInfo.DeviceLevel = enterInfo.LinkSimpleInfo.DeviceLevel
		linkSimpleInfo.Tag = enterInfo.LinkSimpleInfo.Tag
		linkSimpleInfo.PublicEventId = enterInfo.LinkSimpleInfo.PublicEventId
		switchSceneData.linkSimpleInfo = linkSimpleInfo
	end

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
		switchSceneData.canSameImageLoading = loadingTypeInfo.Ripple
	end

	switchSceneData.Seamless = enterInfo.Seamless

	gGameManager:BeginSample("lua OnSyncEnterScene")
	gCS.SwitchSceneManager.OnSyncEnterScene(switchSceneData)
	gGameManager:EndSample()
end

gSceneManager = M
