-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GalleryFurniturePreviewPanelStore.lua
-- Decompiled from: 01834_GalleryFurniturePreviewPanelStore.lua_823dbbcc9dca.luajit

require("LX6/Manager/Shop/MallCameraManager")

local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
C_GalleryFurniturePreviewPanelStore = DefClass("C_GalleryFurniturePreviewPanelStore", C_GalleryFurniturePreviewPanelStore, C_StoreGroup)
GroupName2Class.GalleryFurniturePreviewPanelStore = C_GalleryFurniturePreviewPanelStore
local M = C_GalleryFurniturePreviewPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.furnitureList = {}
	self.currentIndex = 1
	self.currentFurnitureId = nil
	self.currentFurniture = nil
	self.loadedFurnitureId = nil
	self.rootArea = nil
	self.modelCameraEnabled = false
	self.prevVCamera = nil
	self.fashionInfoStore = nil
	self.currentHyperLinkCallback = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.hideCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hideCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self._TeardownModel(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	data = data or {}
	self.bindData.hideCtrl = self.hideCtrlEnum.show

	self:SetCameraBtnsActive(false)

	if self.rootGo then
		self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	end

	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gGallerySceneManager:StartListenDynamicGoLoaded()

	if self.bindData.camera then
		self.bindData.camera.transform:SetParent(nil, false)
		self.bindData.camera.transform:GetChild(0).gameObject:SetActive(true)

		self.bindData.camera.transform.position = gCS.CameraDataMgr.MainCamera.transform.position
		self.bindData.camera.transform.rotation = gCS.CameraDataMgr.MainCamera.transform.rotation
	end

	self.prevVCamera = gGallerySceneManager.vCamera

	gGallerySceneManager:SetVCamera(self.bindData.VCamera)
	self:InitFashionInfoStore()

	self.furnitureList = data.furnitureListData or {}
	self.currentFurnitureId = data.furnitureId
	self.currentIndex = 1

	for i, d in ipairs(self.furnitureList) do
		if d.furnitureId ~= self.currentFurnitureId then
			self.currentIndex = i

			break
		end
	end

	if #self.furnitureList ~= 0 and self.currentFurnitureId then
		self.furnitureList = {
			{
				furnitureId = self.currentFurnitureId,
				furnitureCfg = HouseFurnitureConfig.GetConfig(self.currentFurnitureId)
			}
		}
		self.currentIndex = 1
	end

	self.RefreshCurrent(self)
	self.UpdateTipVisibility(self)
	self.PlayOpenAnimation(self)
end

M.OnClose = function(self)
	self._TeardownModel(self)
end

M._TeardownModel = function(self)
	self:DisableModelCameraControl()
	gGallerySceneManager:StopListenDynamicGoLoaded()
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)

	if self.bindData.camera and not gCS.LuaUtils.IsNull(self.bindData.camera.gameObject) then
		GameObject.Destroy(self.bindData.camera.gameObject)
	end

	if self.prevVCamera then
		gGallerySceneManager:SetVCamera(self.prevVCamera)
	else
		gGallerySceneManager:ClearAll()
	end

	self.currentFurniture = nil
	self.loadedFurnitureId = nil
end

M.PlayOpenAnimation = function(self)
	if self.bindData.anim then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "s_vx_BaikeFashionPreviewPanel_open")
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.UpdateTipVisibility(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
end

M.InitFashionInfoStore = function(self)
	self.fashionInfoStore = gStoreManager:GetStoreGroup(self.bindData.baikeFashionInfoTemplate.Store):GetStoreByWidget(self.bindData.baikeFashionInfoTemplate)

	if self.fashionInfoStore and self.fashionInfoStore.jumpToGetBtn then
		self.fashionInfoStore.jumpToGetBtn.luaClick = self.CreateAction(self, "OnClickJumpToGetBtn")
	end
end

M.UpdateFurnitureInfo = function(self, cfg)
	if not self.fashionInfoStore or not cfg then
		return
	end

	self.fashionInfoStore.nameText = cfg.Name or ""
	self.fashionInfoStore.desText = cfg.Desc or ""
	self.fashionInfoStore.logoIconId = cfg.FurnitureIcon or 0
	local score = cfg.CollectionScore or 0
	self.fashionInfoStore.pointText = tostring(score)
	self.fashionInfoStore.pointActive = score >= 0
	local hyperLinkId = cfg.HypeLinkID
	local isOwned = gHouseManager and gHouseManager:IsFurnitureOwned(cfg.Id) or false

	if isOwned then
		self.fashionInfoStore.jumpToGetBtn.gameObject:SetActive(false)
	else
		self.fashionInfoStore.jumpToGetBtn.gameObject:SetActive(true)

		if not hyperLinkId or hyperLinkId ~= 0 then
			self.fashionInfoStore.jumpToGetText = LTConfig.CityPediaConfig.EmptyAcquisitionHintText or ""
			self.currentHyperLinkCallback = nil
			self.fashionInfoStore.jumpToGetBtn.interactable = false
			self.fashionInfoStore.ctrlerGetActive = false
		else
			local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

			if hyperLinkInfo then
				self.fashionInfoStore.jumpToGetText = hyperLinkInfo.text or ""
				self.currentHyperLinkCallback = hyperLinkInfo.callback
				local linkCfg = LTConfig.HyperLinkConfig.GetConfig(hyperLinkId)
				local incomeId = linkCfg and linkCfg.IncomeId or 0
				self.fashionInfoStore.jumpToGetBtn.interactable = incomeId == 0
				self.fashionInfoStore.ctrlerGetActive = incomeId == 0
			else
				self.fashionInfoStore.jumpToGetText = LTConfig.CityPediaConfig.EmptyAcquisitionHintText or ""
				self.currentHyperLinkCallback = nil
				self.fashionInfoStore.jumpToGetBtn.interactable = false
				self.fashionInfoStore.ctrlerGetActive = false
			end
		end
	end
end

M.RefreshCurrent = function(self)
	local data = self.furnitureList[self.currentIndex]

	if not data then
		return
	end

	self.currentFurnitureId = data.furnitureId
	local cfg = data.furnitureCfg or HouseFurnitureConfig.GetConfig(data.furnitureId)
	local subType = cfg and cfg.SubType
	local isMaterial = subType and gFurnitureUtils and gFurnitureUtils:IsTexSubType(subType)

	self:UpdateFurnitureInfo(cfg)

	if isMaterial then
		self:DisableModelCameraControl()
		gGallerySceneManager:ClearFurnitureModel()
		self:SetCameraBtnsActive(false)
	else
		self.LoadFurnitureModel(self, data.furnitureId)
	end
end

M.LoadFurnitureModel = function(self, furnitureId)
	if not furnitureId or furnitureId ~= 0 then
		self.ClearModel(self)

		return
	end

	gGallerySceneManager:PreviewFurniture(furnitureId, {
		onLoaded = function (go)
			self.currentFurniture = go
			self.loadedFurnitureId = furnitureId

			self:UpdateModelCameraControl()
			self:SetCameraBtnsActive(true)
		end
	})
end

M.UpdateModelCameraControl = function(self)
	local params = self.BuildModelCameraParams(self)

	if not params then
		self.DisableModelCameraControl(self)

		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, true, params)

	self.modelCameraEnabled = true
end

M.BuildModelCameraParams = function(self)
	local go = gGallerySceneManager.currentFurniture

	if not go or gCS.LuaUtils.IsNull(go) then
		return nil
	end

	local vCamera = gGallerySceneManager.vCamera

	if not vCamera then
		return nil
	end

	local cameraControlConfig = gGallerySceneManager:BuildGalleryCameraControlConfig(gGallerySceneManager.LoadingType.Character)

	return {
		["AFb[A\n="] = false,
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = vCamera,
		modelRoot = go.transform,
		cameraOffsetRange = cameraControlConfig.yOffsetRange,
		cameraOffset = Vector3.New(0, 0, 0),
		cameraControlConfig = cameraControlConfig
	}
end

M.DisableModelCameraControl = function(self)
	if not self.modelCameraEnabled then
		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, false)

	self.modelCameraEnabled = false
end

M.SetCameraBtnsActive = function(self, value)
	if self.bindData.cameraBtns then
		self.bindData.cameraBtns.gameObject:SetActive(value ~= true)
	end
end

M.ClearModel = function(self)
	gGallerySceneManager:ClearFurnitureModel()

	self.currentFurniture = nil
	self.loadedFurnitureId = nil

	self:SetCameraBtnsActive(false)
end

M.UpdateTipVisibility = function(self)
	local isGamepad = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	if isGamepad then
		self.bindData.tipVisibility = 1
	else
		local isHide = self.bindData.hideCtrl ~= self.hideCtrlEnum.hide
		self.bindData.tipVisibility = isHide and 0 or 1
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnClickNavBtn", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnClickNavBtn", 1)
	self.bindData.hideBtn.luaClick = self.CreateAction(self, "OnClickHideBtn")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickNavBtn = function(self, direction)
	local count = #self.furnitureList

	if count < 1 then
		return
	end

	local targetIndex = self.currentIndex + direction

	if targetIndex >= 1 then
		targetIndex = count
	elseif count >= targetIndex then
		targetIndex = 1
	end

	self.currentIndex = targetIndex

	self.RefreshCurrent(self)
end

M.OnClickHideBtn = function(self)
	if self.bindData.hideCtrl ~= self.hideCtrlEnum.hide then
		self.bindData.hideCtrl = self.hideCtrlEnum.show
	else
		self.bindData.hideCtrl = self.hideCtrlEnum.hide
	end

	self.UpdateTipVisibility(self)
end

M.OnClickJumpToGetBtn = function(self)
	if self.currentHyperLinkCallback then
		self.currentHyperLinkCallback()
	end
end
