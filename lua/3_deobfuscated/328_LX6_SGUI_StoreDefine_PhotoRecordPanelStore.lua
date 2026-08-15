local PhotoConfig = LTConfig.PhotoConfig
local Screen = UnityEngine.Screen
C_PhotoRecordPanelStore = DefClass("C_PhotoRecordPanelStore", C_PhotoRecordPanelStore, C_StoreGroup)
GroupName2Class.PhotoRecordPanelStore = C_PhotoRecordPanelStore
local M = C_PhotoRecordPanelStore

function M:ctor()
	self:GenMessageEvents()
end

function M:DefineAllVariables()
	self.isSaved = false
	self.timeStamp = nil
	self.tex = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
end

function M:OnShow(panelId, data)
	local photo = data.photo
	self.isSaved = photo.isSaved
	self.timeStamp = photo.stamp
	self.tex = Album.AlbumProxy.GetRealPhoto(self.timeStamp)

	if self.tex == nil then
		return
	end

	self.bindData.photoTex.texture = self.tex
	self.bindData.saveCtrl = self.isSaved and 0 or 1
	local date = Album.AlbumProxy.GetAlbumDay(self.timeStamp)
	self.bindData.tipsText = string.format(PhotoConfig.PhotoSavingTimePromptText, PhotoConfig.PhotoSavingTime - date)

	self:AdaptPhotoTex()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PHOTO_SAVED] = function ()
			Album.AlbumProxy.SetPhotoSaved(self.timeStamp)
			gMessageManager:SendMessage(gEventConstants.ALBUM_REFRESH_LIST)

			self.bindData.saveCtrl = 0
		end
	}
end

function M:RegisterWidget()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.downloadBtn.luaClick = self:CreateAction("OnClickDownloadBtn")
	self.bindData.deleteBtn.luaClick = self:CreateAction("OnClickDeleteBtn")
end

function M:OnClickCloseBtn()
	gPanelManager:Close(self.m_Id)
end

function M:OnClickDownloadBtn()
	local photoName = self:GeneratePhotoName()

	LX6.Utils.PhotoUtils.SavePhoto(self.tex, photoName)
end

function M:OnClickDeleteBtn()
	gPanelManager:Close(self.m_Id)
	Album.AlbumProxy.DeleteOnePhoto(self.timeStamp)
	gPanelManager:CheckShow(gPanelId.S_ALBUM_PANEL)
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
