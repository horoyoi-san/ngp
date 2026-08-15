local SceneConfig = LTConfig.SceneConfig
local RaidConfig = LTConfig.RaidConfig
gMapTransformHelper = {}
local M = gMapTransformHelper
M._mappingDatas = {}

function M:GetMapLayoutData(areaId)
	local cfg = nil
	local raidId, indoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)

	if indoorId > 0 then
		cfg = LTConfig.IndoorConfig.GetConfig(indoorId)
	else
		local raidCfg = RaidConfig.GetConfig(raidId)

		if raidCfg then
			cfg = SceneConfig.GetConfig(raidCfg.SceneId)
		end
	end

	local sizeData = cfg and cfg.MiniMapPic
	local anchors = cfg and cfg.MiniMapPos

	if not sizeData or #sizeData < 3 or not anchors or #anchors < 8 then
		local raid888Cfg = LTConfig.RaidConfig.GetConfig(LTConfig.RaidConfig.WorldMap)
		local sceneCfg = SceneConfig.GetConfig(raid888Cfg.SceneId)
		sizeData = sceneCfg.MiniMapPic
		anchors = sceneCfg.MiniMapPos
	end

	local mappingData = {
		texWidth = sizeData[2],
		texHeight = sizeData[3],
		texCenter = {
			x = sizeData[2] * 0.5,
			y = sizeData[3] * 0.5
		},
		anchors = {
			worldStart = {
				x = anchors[1],
				z = anchors[2]
			},
			worldEnd = {
				x = anchors[3],
				z = anchors[4]
			},
			texStart = {
				x = anchors[5],
				y = anchors[6]
			},
			texEnd = {
				x = anchors[7],
				y = anchors[8]
			}
		}
	}
	mappingData.scaleWorld2Tex = {
		x = (mappingData.anchors.texEnd.x - mappingData.anchors.texStart.x) / (mappingData.anchors.worldEnd.x - mappingData.anchors.worldStart.x),
		y = (mappingData.anchors.texEnd.y - mappingData.anchors.texStart.y) / (mappingData.anchors.worldEnd.z - mappingData.anchors.worldStart.z)
	}

	print_debug("GetMapLayoutData areaId:", areaId, "texWidth:", mappingData.texWidth, "texHeight:", mappingData.texHeight, "worldStart:", mappingData.anchors.worldStart.x, mappingData.anchors.worldStart.z, "worldEnd:", mappingData.anchors.worldEnd.x, mappingData.anchors.worldEnd.z, "texStart:", mappingData.anchors.texStart.x, mappingData.anchors.texStart.y, "texEnd:", mappingData.anchors.texEnd.x, mappingData.anchors.texEnd.y)

	return mappingData
end

function M:WorldPosXZ2TexPosXY(worldPosX, worldPosZ, areaId)
	local mappingData = self._mappingDatas[areaId]

	if not mappingData then
		mappingData = self:GetMapLayoutData(areaId)
		self._mappingDatas[areaId] = mappingData
	end

	local x = (worldPosX - mappingData.anchors.worldStart.x) * mappingData.scaleWorld2Tex.x + mappingData.anchors.texStart.x - mappingData.texCenter.x
	local y = (worldPosZ - mappingData.anchors.worldStart.z) * mappingData.scaleWorld2Tex.y + mappingData.anchors.texStart.y - mappingData.texCenter.y

	return x, y
end

function M:TransformWorldPosToTexPos(worldPos, areaId, outVec2)
	if not worldPos then
		print_warn("@sunwei gMapTransformHelper:TransformWorldPosToTexPos worldPos is nil")

		return Vector2.zero
	end

	if not worldPos.x or not worldPos.z then
		print_error("@sunwei gMapTransformHelper:TransformWorldPosToTexPos worldPos is not Vector3")

		return Vector2.zero
	end

	local mappingData = self._mappingDatas[areaId]

	if not mappingData then
		mappingData = self:GetMapLayoutData(areaId)
		self._mappingDatas[areaId] = mappingData
	end

	local x = (worldPos.x - mappingData.anchors.worldStart.x) * mappingData.scaleWorld2Tex.x + mappingData.anchors.texStart.x - mappingData.texCenter.x
	local y = (worldPos.z - mappingData.anchors.worldStart.z) * mappingData.scaleWorld2Tex.y + mappingData.anchors.texStart.y - mappingData.texCenter.y

	if outVec2 then
		outVec2.x = x
		outVec2.y = y

		return outVec2
	else
		return Vector2.New(x, y)
	end
end

function M:TransformTexPosToWorldPos(texPos, areaId, ignoreLandCheck)
	local mappingData = self._mappingDatas[areaId]

	if not mappingData then
		mappingData = self:GetMapLayoutData(areaId)
		self._mappingDatas[areaId] = mappingData
	end

	local x = (texPos.x + mappingData.texCenter.x - mappingData.anchors.texStart.x) / mappingData.scaleWorld2Tex.x + mappingData.anchors.worldStart.x
	local z = (texPos.y + mappingData.texCenter.y - mappingData.anchors.texStart.y) / mappingData.scaleWorld2Tex.y + mappingData.anchors.worldStart.z

	if ignoreLandCheck then
		return Vector3.New(x, 0, z)
	else
		return gUIUtils:GetPhysicsLandPosByXZ(Vector3.New(x, 0, z))
	end
end

function M:Align(movingT, localPos, targetT)
	local offset = movingT:TransformVector(localPos)
	movingT.position = targetT.position - offset
end
