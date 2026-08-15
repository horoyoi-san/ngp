local FashionConfig = LTConfig.FashionConfig
local FashionBaseConfig = LTConfig.FashionBaseConfig
local UXVector3 = UX.Game.UXVector3
local MassHideType = UX.Game.MassHideType
local LayerConstants = LX6.Constants.LayerConstants
gDressCamera = gDressCamera or {}
local M = gDressCamera
M.FashionShotCamNameMap = {
	ClothShot = "ClothShotCam",
	GloveShot = "GloveShotCam",
	BottomShot = "BottomShotCam",
	HeadShot = "HeadShotCam",
	ShoeShot = "ShoeShotCam",
	FullShot = "FullShotCam"
}

function M:GetShotTypeByFashionType(type)
	local FashionShopShotType = FashionConfig.FashionShopShotType

	for i = 1, #FashionShopShotType do
		if FashionShopShotType[i].type == type then
			return FashionShopShotType[i].Shot
		end
	end
end

function M:GetShotTypeByFashionPart(part)
	local FashionShopTabShot = FashionConfig.FashionShopTabShot

	for i = 1, #FashionShopTabShot do
		if FashionShopTabShot[i].part == part then
			return FashionShopTabShot[i].Shot
		end
	end
end

function M:SetFullSlotShotCamera()
	local shotType = gDressCamera:GetShotTypeByFashionType(gDressManager.DRESS_TYPE.ShareMin)

	self:EnableFashionShotCamera(shotType, "buyDressPanel")
end

function M:EnableFashionShotCamera(shotType, cmRegisterName)
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm(cmRegisterName)

	if not cmRegister then
		return
	end

	local bodyType = gDressManager.CurrentSpiritInfo.CameraBodyType

	if bodyType == nil then
		print_error("获取bodyType失败,spritId = " .. gDressManager.CurrentSpiritId)

		return
	end

	local cfg = FashionBaseConfig.GetConfig(bodyType)
	local playerTrans = gCS.MyPlayerManager.PlayerUnit.PlayerObj
	local shotCfg = cfg[shotType]

	if not shotCfg then
		return
	end

	local worldPos = playerTrans:TransformPoint(shotCfg.offsetx, shotCfg.offsety, shotCfg.offsetz)
	local dir = Quaternion.Euler(shotCfg.eulerx, shotCfg.eulery, shotCfg.eulerz) * Vector3.forward
	local worldEuler = Quaternion.LookRotation(playerTrans:TransformDirection(dir)).eulerAngles
	local cm = cmRegister:GetVcamByName(self.FashionShotCamNameMap[shotType])

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFixCameraData(cm.gameObject, worldPos, worldEuler, shotCfg.fov)
	cmRegister:EnableVCamera(self.FashionShotCamNameMap[shotType], LX6.Cinemachine.EVcamPriority.Panel)
end

function M:SetCameraHide(hide, panelId)
	if hide then
		gCS.CameraDataMgr:SetMainCameraCullingMask(panelId, LayerConstants.MainCameraLayerWithoutNpcEnemyDestructible)
	else
		gCS.CameraDataMgr:RevertMainCameraCullingMask(panelId)
	end
end

function M:CreateHiddenArea()
	local cameraAreaUid = 0
	local pos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local isSuccess, tempUid = AetherAI.Systems.HiddenArea.AetherHiddenAreaManager.Instance:CreateHiddenAreaClient(UXVector3.New(pos.x, pos.y, pos.z), UXVector3.New(100, 100, 100), UXVector3.New(0, 0, 0), MassHideType.ECSVehicle + MassHideType.StaticECSVehicles + MassHideType.TaskSpawnedVehicle + MassHideType.DriveVehicle, cameraAreaUid)

	if isSuccess then
		cameraAreaUid = tempUid
		self.cameraAreaUid = cameraAreaUid
	end
end

function M:RemoveHiddenArea()
	if self.cameraAreaUid then
		AetherAI.Systems.HiddenArea.AetherHiddenAreaManager.Instance:RemoveHiddenAreaClient(self.cameraAreaUid)

		self.cameraAreaUid = nil
	end
end

gDressCamera = M
