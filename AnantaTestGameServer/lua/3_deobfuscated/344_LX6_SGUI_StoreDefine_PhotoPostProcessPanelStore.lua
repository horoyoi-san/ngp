C_PhotoPostProcessPanelStore = DefClass("C_PhotoPostProcessPanelStore", C_PhotoPostProcessPanelStore, C_StoreGroup)
GroupName2Class.PhotoPostProcessPanelStore = C_PhotoPostProcessPanelStore
local M = C_PhotoPostProcessPanelStore
local PhotoUtils = LX6.Utils.PhotoUtils
local PhotoConfig = LTConfig.PhotoConfig
local Screen = UnityEngine.Screen
local postProcessingType = {
	frame = 1,
	watermark = 2
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local CallBackDataNames = {
	"SavedCallBack",
	"ShareCallback",
	"PhotoTakenCallback",
	"QRCodeContent",
	"QRCodePath",
	"HideLogoInfo",
	"CopyCallback",
	"NieLianString",
	"IsSelfIeMode"
}

local function CheckTableAllTrue(t)
	for _, v in pairs(t) do
		if not v then
			return false
		end
	end

	return true
end

function M:ctor()
	self:GenMessageEvents()
end

function M:DefineAllVariables()
	self.needClosePhoto = false
	self.processTypesInfo = {}
	self.selectedType = postProcessingType.frame
	self.selectedFrame = 1
	self.watermarkCache = {}
	self.customTargetData = nil
	self.customTargetType = nil
	self.photoStamp = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterButtons()
	self:RegisterLists()
	LX6.GUI.GuiMgr.Instance:SetShowScenePanel(true, gPanelId.S_PHOTO_POST_PROCESS_PANEL)
end

function M:OnStart()
	self:BuildPostProcessMenu()
	self:RefreshProcessList()

	self.bindData.uidText = "UID:" .. ulong.tostring(gPlayerManager.infoBase.bindData.Pid)
end

function M:OnDestroy()
	LX6.GUI.GuiMgr.Instance:SetShowScenePanel(false, gPanelId.S_PHOTO_POST_PROCESS_PANEL)
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	for _, v in ipairs(CallBackDataNames) do
		if data[v] ~= nil then
			self[v] = data[v]
		end
	end

	self:InitShowInfo(data)
	self:HandleCustomTargetControl(data)
	gTakePhotoUtils.SetSpecifiedPanelsVisible(false)
	gTakePhotoUtils.HideUid(true)
	self:AdaptPhotoTex()
	self:TakePhoto()
end

function M:OnClose()
	gTakePhotoUtils.SetSpecifiedPanelsVisible(true)

	if self.needClosePhoto then
		gPanelManager:Close(gPanelId.S_PHOTO_PANEL)

		if not gChatUtils.IsChatPanelShowing() then
			gClientUtils.CloseMainPhonePanel()
		end
	end
end

function M:RegisterButtons()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.shareBtn.luaClick = self:CreateAction("OnShareBtnClick")
	self.bindData.downloadBtn.luaClick = self:CreateAction("OnDownloadBtnClick")
end

function M:OnCloseBtnClick()
	gPanelManager:Close(self.m_Id)

	if self.ShareCallback then
		self.ShareCallback()
	end
end

function M:OnShareBtnClick()
	if self.customTargetData then
		self:ShareToBubble(self.customTargetData)

		return
	end

	self:ShareToBubble()
end

function M:OnDownloadBtnClick()
	local photoName = self:GeneratePhotoName()
	local tex = self:GetFinalPhoto()

	PhotoUtils.SavePhoto(tex, photoName)
end

function M:RegisterLists()
	return
end

function M:OnRenderTypeTab(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("CommonShortTab"):GetStoreById(id)

	if store and data.iconId then
		store.iconId = data.iconId
	end
end

function M:OnClickTypeTab(btn, data)
	self.selectedType = data.pType

	self:RefreshProcessList()
end

function M:GamepadSelectTab(dir)
	local typeCount = #self.processTypesInfo
	local nextIndex = self.selectedType + dir

	if nextIndex == 0 then
		nextIndex = typeCount
	elseif nextIndex == typeCount + 1 then
		nextIndex = 1
	end

	local success, nextBtn = self.bindData.typeTab:TryGetChildAt(nextIndex - 1, nil)

	if success then
		nextBtn.isSelected = true

		self:OnClickTypeTab(nextBtn, self.processTypesInfo[nextIndex])
	end
end

function M:OnRenderProcessList(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	store:EnableImmediatelyCommit(true)

	if store then
		if data.pType == postProcessingType.frame then
			store.frameImg = data.iconId
		elseif data.pType == postProcessingType.watermark then
			self.watermarkCache[data.name] = btn.isSelected
			store.watermarkText = data.description
		end
	end
end

function M:OnClickProcessList(btn, data)
	if data.pType == postProcessingType.frame then
		if data.name == "defaultFrame" then
			self.bindData.frame:SetActive(false)
		else
			self.bindData.frame:SetActive(true)

			self.bindData.frameIconId = data.frameIconId
		end

		self.selectedFrame = data.index
	elseif data.pType == postProcessingType.watermark then
		self.watermarkCache[data.name] = btn.isSelected

		if not self.watermarkCache.logo and not self.watermarkCache.uid then
			self.bindData.postSetting = 0
		elseif self.watermarkCache.logo and not self.watermarkCache.uid then
			self.bindData.postSetting = 1
		elseif self.watermarkCache.uid and not self.watermarkCache.logo then
			self.bindData.postSetting = 2
		elseif self.watermarkCache.logo and self.watermarkCache.uid then
			self.bindData.postSetting = 3
		end
	end
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.MESSAGE_TAKEPHOTO2] = function ()
			gTakePhotoUtils.HideUid(false)
			self:OnTakePhoto()
		end,
		[gEventConstants.PHOTO_TASK_TARGET] = function (_, data)
			if data.Finish then
				self.needClosePhoto = true
			end
		end,
		[gEventConstants.PANEL_CLOSE] = function (_, msg)
			if msg.panelId == gPanelId.S_SOCIAL_MEDIA_RELEASE_PANEL then
				self.bindData.anim:Play("S_Vx_PhotoPostProcessPanel_back")
			end
		end
	}
end

function M:OnTakePhoto()
	self:SetTexture()
	gMessageManager:SendMessage(gEventConstants.TAKE_PHOTO)
end

function M:BuildPostProcessMenu()
	local configs = PhotoConfig.PostProcessingIcon

	for pType, config in pairs(configs) do
		local data = {
			selected = pType == postProcessingType.frame,
			iconId = config.iconId,
			pType = pType
		}

		table.insert(self.processTypesInfo, data)
	end

	self.selectedType = postProcessingType.frame

	self.bindData.typeTab:SetList(self.processTypesInfo)
end

function M:BuildPhotoFrameList()
	local listData = {}
	local configs = PhotoConfig.PhotoFramesSetting

	for i, config in ipairs(configs) do
		local data = {
			iconId = config.iconId,
			frameIconId = config.frameIconId,
			name = config.name,
			index = i,
			selected = self.selectedFrame == i,
			tIndex = 0,
			photoWidth = config.photoWidth,
			photoHeight = config.photoHeight,
			photoAspect = config.photoAspect,
			pType = postProcessingType.frame
		}

		table.insert(listData, data)
	end

	self.bindData.processList.groupType = 1

	self.bindData.processList:SetList(listData)
end

function M:BuildWatermarkList()
	local listData = {}
	local configs = PhotoConfig.WatermarkSetting

	for _, config in ipairs(configs) do
		local data = {
			name = config.name,
			tIndex = 1,
			description = config.description,
			selected = self.watermarkCache[config.name] or config.settingDefault ~= 0,
			pType = postProcessingType.watermark
		}

		table.insert(listData, data)
	end

	self.bindData.processList.groupType = 2

	self.bindData.processList:SetList(listData)
	self.bindData.processList:SetNavSelectToTop()
end

function M:RefreshProcessList()
	if self.selectedType == postProcessingType.frame then
		self:BuildPhotoFrameList()
	elseif self.selectedType == postProcessingType.watermark then
		self:BuildWatermarkList()
	end
end

function M:InitShowInfo(data)
	self.selectedFrame = data.selectedFrame

	if self.selectedFrame ~= 1 then
		self.bindData.frame:SetActive(true)

		self.bindData.frameIconId = data.selectedFrameIconId
	else
		self.bindData.frame:SetActive(false)
	end

	self.watermarkCache = data.watermarkInfo

	if not self.watermarkCache.logo and not self.watermarkCache.uid then
		self.bindData.postSetting = 0
	elseif self.watermarkCache.logo and not self.watermarkCache.uid then
		self.bindData.postSetting = 1
	elseif self.watermarkCache.uid and not self.watermarkCache.logo then
		self.bindData.postSetting = 2
	elseif self.watermarkCache.logo and self.watermarkCache.uid then
		self.bindData.postSetting = 3
	end

	self.bindData.isMainCharacter = BOOL2CTL[gSpiritManager:CheckIsMainCharacter() and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.BubbleUnlock)]
end

function M:HandleCustomTargetControl(data)
	if not data.customTargetData or not next(data.customTargetData) or not CheckTableAllTrue(data.customTargetData) or not data.customTargetType then
		self.customTargetData = nil

		return
	end

	self.customTargetType = data.customTargetType
	self.customTargetData = data.customTargetData
	self.customTargetData.customTargetType = self.customTargetType
	self.customTargetData.IsSelfIeMode = self.IsSelfIeMode

	if self.customTargetType == gTakePhotoUtils.PhotoCustomTargetType.Npc then
		self:HandleSpiritAcquisitionAction()
	end
end

function M:HandleSpiritAcquisitionAction()
	self:SetPanelInteractable(false)

	self.EndDelay = gLuaTimeMgrUtils.Delay(function ()
		self:ShareToBubble(self.customTargetData)
		self:SetPanelInteractable(true)

		self.EndDelay = nil
	end, 1)
end

function M:TakePhoto()
	PhotoUtils.TakePhotoNew()
end

function M:SetTexture()
	local photo = PhotoUtils.writeCameraImage
	self.bindData.photoTex.texture = photo

	if self.PhotoTakenCallback then
		self.PhotoTakenCallback()
	end
end

function M:GetFinalPhoto()
	local baseTex = PhotoUtils.writeCameraImage
	local scaleSize = self.bindData.photoTex:GetTargetWidth()

	if self.selectedFrame ~= 1 then
		local frameSprite = self.bindData.frame
		local width = frameSprite:GetTargetWidth()
		local height = frameSprite:GetTargetHeight()
		local scaleX = width / scaleSize
		local scaleY = height / scaleSize
		baseTex = PhotoUtils.TextureDrawUseUImage(baseTex, frameSprite, Vector2.New(0, 0), 0, scaleX, scaleY)
	end

	if self.watermarkCache.logo then
		local logoSprite = self.bindData.logo
		local logoTransform = self.bindData.logo.transform
		local width = self.bindData.logo:GetTargetWidth()
		local height = self.bindData.logo:GetTargetHeight()
		local pos = logoTransform.localPosition
		pos = self:GetCenterPos(pos, logoSprite.rectTransform.pivot, width, height)
		local scaleX = width / scaleSize
		local scaleY = height / scaleSize
		baseTex = PhotoUtils.TextureDraw(baseTex, logoSprite.texture, Vector2.New(2 * pos.x / scaleSize, 2 * pos.y / scaleSize), logoTransform.localRotation:ToEulerAngles().z, scaleX, scaleY)
	end

	if self.watermarkCache.uid then
		local uidLabel = self.bindData.uid
		local width = uidLabel:GetTargetWidth()
		local height = uidLabel:GetTargetHeight()
		local pos = uidLabel.transform.localPosition
		baseTex = PhotoUtils.UTextDraw(baseTex, uidLabel, Vector2.New(2 * pos.x / scaleSize, 2 * pos.y / scaleSize), uidLabel.transform.localRotation:ToEulerAngles().z, 1, 1)
	end

	return baseTex
end

function M:GetCenterPos(pos, pivot, width, height)
	return pos + Vector3.New(-width * (pivot.x - 0.5), -height * (pivot.y - 0.5), 0)
end

function M:GeneratePhotoName()
	return "cameraPhoto_" .. os.date("%Y-%m-%d-%H-%M-%S")
end

function M:AdaptPhotoTex()
	local screenX = Screen.width
	local screenY = Screen.height
	local texX = self.bindData.photoTex:GetTargetWidth()
	local texY = self.bindData.photoTex:GetTargetHeight()
	local ratio = texX / texY
	local sRatio = screenX / screenY

	if ratio < sRatio then
		texY = texX / sRatio
	else
		texX = texY * sRatio
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.photoTex.rectTransform.sizeDelta = Vector2.New(texX * 0.68, texY * 0.68)
	else
		self.bindData.photoTex.rectTransform.sizeDelta = Vector2.New(texX, texY)
	end
end

function M:ShareToBubble(params)
	local tex = self:GetFinalPhoto()

	if gCS.LuaUtils.IsType(tex, typeof(UnityEngine.RenderTexture)) then
		tex = PhotoUtils.RT2Texture2D(tex, true, 0, 0, tex.width, tex.height)
	end

	if gCS.LuaUtils.IsType(tex, typeof(UnityEngine.Texture2D)) then
		gPanelManager:CheckShow(gPanelId.S_SOCIAL_MEDIA_RELEASE_PANEL, {
			texture = tex,
			params = params
		})
	else
		print_error("tex is not Texture2D or RenderTexture")
	end
end

function M:SetPanelInteractable(enable)
	self.bindData.closeBtn:SetActive(enable)
	self.bindData.shareBtn:SetActive(enable)
	self.bindData.downloadBtn:SetActive(enable)
end
