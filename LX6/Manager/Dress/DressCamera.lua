-- Original chunk: @Lua\LuaFiles\LX6\Manager\Dress\DressCamera.lua
-- Decompiled from: 00532_DressCamera.lua_f12bb9d5f7cc.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionBaseConfig = LTConfig.FashionBaseConfig
local UXVector3 = UX.Game.UXVector3
local MassHideType = UX.Game.MassHideType
local LayerConstants = LX6.Constants.LayerConstants
gDressCamera = gDressCamera or {}
local M = gDressCamera
M.FashionShotCamNameMap = {
	["`Kc}F-,"] = "`Kc}F-,",
	["dKcK-,"] = "dKcK-,",
	["qUک\\x8b\\x8b\\xc6\\xfc"] = "qUک\\x8b\\x8b\\xc6\\xfc",
	["\\x83\\xb4\\xafY6\\xf1'"] = "\\x83\\xb4\\xafY6\\xf1'",
	["\\x98\\xb9\n\\xaeY6\\xf1'"] = "\\x98\\xb9\n\\xaeY6\\xf1'",
	["\\x8d\\xa4\t\\xa7Y6\\xf1'"] = "\\x8d\\xa4\t\\xa7Y6\\xf1'"
}

M.GetShotTypeByFashionType = function(self, type)
	local FashionShopShotType = FashionConfig.FashionShopShotType

	for i = 1, #FashionShopShotType do
		if FashionShopShotType[i].type ~= type then
			return FashionShopShotType[i].Shot
		end
	end
end

M.GetShotTypeByFashionPart = function(self, part)
	local FashionShopTabShot = FashionConfig.FashionShopTabShot

	for i = 1, #FashionShopTabShot do
		if FashionShopTabShot[i].part ~= part then
			return FashionShopTabShot[i].Shot
		end
	end
end

M.SetFullSlotShotCamera = function(self)
	local shotType = gDressCamera:GetShotTypeByFashionType(gDressManager.DRESS_TYPE.ShareMin)

	self:EnableFashionShotCamera(shotType)
end

M.EnableFashionShotCamera = function(self, shotType, spiritInfo)
	if not spiritInfo then
		local ctx = gDressManager:GetSpiritContext()
		spiritInfo = ctx and ctx.spiritInfo
	end

	if not spiritInfo then
		return
	end

	local bodyType = spiritInfo.CameraBodyType

	if bodyType ~= nil then
		print_error("获取bodyType失败, spritId = " .. spiritInfo.Id, spiritInfo.Name)

		return
	end

	local cfg = FashionBaseConfig.GetConfig(bodyType)

	if not cfg then
		print_error("读取bodyType配置失败, spritId = " .. spiritInfo.Id, spiritInfo.Name)

		return
	end

	local shotCfg = cfg[shotType]

	if not shotCfg then
		return
	end

	gMessageManager:SendMessage(gEventConstants.FASHION_CAM_SET_TYPE, self.FashionShotCamNameMap[shotType])
end

M.SetCameraHide = function(self, hide, panelId, isDressForm)
	if hide then
		local layer = nil

		if isDressForm then
			layer = LayerConstants.MainCameraLayersWithoutPlayer
		else
			local isInDoor = gMapSystem.lastIndoorId == 0
			layer = isInDoor and LayerConstants.MainCameraLayerWithoutNpcEnemy or LayerConstants.MainCameraLayerWithoutNpcEnemyDestructible
		end

		gCS.CameraDataMgr:SetMainCameraCullingMask(panelId, layer)
	else
		gCS.CameraDataMgr:RevertMainCameraCullingMask(panelId)
	end
end

M.CreateHiddenArea = function(self)
	local cameraAreaUid = 0
	local pos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local isSuccess, tempUid = AetherAI.Systems.HiddenArea.AetherHiddenAreaManager.Instance:CreateHiddenAreaClient(UXVector3.New(pos.x, pos.y, pos.z), UXVector3.New(100, 100, 100), UXVector3.New(0, 0, 0), MassHideType.ECSVehicle + MassHideType.StaticECSVehicles + MassHideType.TaskSpawnedVehicle + MassHideType.DriveVehicle, cameraAreaUid)

	if isSuccess then
		cameraAreaUid = tempUid
		self.cameraAreaUid = cameraAreaUid
	end
end

M.RemoveHiddenArea = function(self)
	if self.cameraAreaUid then
		AetherAI.Systems.HiddenArea.AetherHiddenAreaManager.Instance:RemoveHiddenAreaClient(self.cameraAreaUid)

		self.cameraAreaUid = nil
	end
end

gDressCamera = M
