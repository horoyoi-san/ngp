gMapUIUtils = gMapUIUtils or {}
local M = gMapUIUtils

function M.GetMapConfig(raidId, indoorId)
	local mapCfg = {
		scaleData = {}
	}
	local mapSize, anchors = nil

	if indoorId > 0 then
		local indoorCfg = LTConfig.IndoorConfig.GetConfig(indoorId)
		mapCfg.scaleData.minScale = indoorCfg.MapMinRate
		mapCfg.scaleData.maxScale = indoorCfg.MapMaxRate
		mapCfg.unifiedMapImageId = indoorCfg.SMapName
		mapCfg.extraUnifiedMapInfo = indoorCfg.ExtraMapResInfo
		mapCfg.mapSize = Vector2.New(indoorCfg.MiniMapPic[2], indoorCfg.MiniMapPic[3])
		mapSize = indoorCfg.MiniMapPic
		anchors = indoorCfg.MiniMapPos
	else
		local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

		if raidCfg == nil then
			raidCfg = LTConfig.RaidConfig.GetConfig(LTConfig.RaidConfig.WorldMap)
		end

		local sceneCfg = LTConfig.SceneConfig.GetConfig(raidCfg.SceneId)
		mapCfg.scaleData.minScale = sceneCfg.MapMinRate
		mapCfg.scaleData.maxScale = sceneCfg.MapMaxRate
		mapCfg.mapSize = Vector2.New(sceneCfg.MiniMapPic[2], sceneCfg.MiniMapPic[3])
		mapCfg.unifiedMapImageId = sceneCfg.SMapName
		mapSize = sceneCfg.MiniMapPic
		anchors = sceneCfg.MiniMapPos
	end

	if not mapSize or #mapSize ~= 3 or not anchors or #anchors ~= 8 then
		mapCfg.scaleTex2World = Vector2.New(1, 1)
		mapCfg.scaleWorld2Tex = Vector2.New(1, 1)
	else
		mapCfg.scaleTex2World = Vector2.New((anchors[3] - anchors[1]) / (anchors[7] - anchors[5]), (anchors[4] - anchors[2]) / (anchors[8] - anchors[6]))
		mapCfg.scaleWorld2Tex = Vector2.New((anchors[7] - anchors[5]) / (anchors[3] - anchors[1]), (anchors[8] - anchors[6]) / (anchors[4] - anchors[2]))
	end

	return mapCfg
end

function M.HasConfig(raidId, indoorId)
	if indoorId > 0 then
		local indoorCfg = LTConfig.IndoorConfig.GetConfig(indoorId)

		return indoorCfg ~= nil
	else
		local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

		if raidCfg == nil then
			raidCfg = LTConfig.RaidConfig.GetConfig(LTConfig.RaidConfig.WorldMap)
		end

		local sceneCfg = LTConfig.SceneConfig.GetConfig(raidCfg.SceneId)

		return sceneCfg ~= nil
	end
end

function M.GetElementActionName(action)
	local actionCfg = LTConfig.GpsMapActionConfig.GetConfig(action)

	if actionCfg then
		return actionCfg.ActionName
	else
		return "Action Not Found"
	end
end
