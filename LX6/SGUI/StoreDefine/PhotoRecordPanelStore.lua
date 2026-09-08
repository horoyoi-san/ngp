-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhotoRecordPanelStore.lua
-- Decompiled from: 00840_PhotoRecordPanelStore.lua_77fa420842db.luajit

local PhotoConfig = LTConfig.PhotoConfig
C_PhotoRecordPanelStore = DefClass("C_PhotoRecordPanelStore", C_PhotoRecordPanelStore, C_StoreGroup)
GroupName2Class.PhotoRecordPanelStore = C_PhotoRecordPanelStore
local M = C_PhotoRecordPanelStore

M.ctor = function(self)
	self.GenMessageEvents(self)
end

M.DefineAllVariables = function(self)
	self.isSaved = false
	self.timeStamp = nil
	self.tex = nil
	self.photoList = nil
	self.photoIndex = 0
	self.photoDesignW = nil
	self.photoDesignH = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.CachePhotoDesignSize(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	self.photoList = data.photoList
	self.photoIndex = data.photoIndex or 0

	self:RefreshPhoto(data.photo)
end

M.CachePhotoDesignSize = function(self)
	self.photoDesignW = self.bindData.photoTex:GetTargetWidth()
	self.photoDesignH = self.bindData.photoTex:GetTargetHeight()
end

M.RefreshPhoto = function(self, photo)
	local data = photo or self.photoList and self.photoList[self.photoIndex]

	if not data then
		return
	end

	self.isSaved = data.isSaved
	self.timeStamp = data.stamp
	self.tex = Album.AlbumProxy.GetRealPhoto(self.timeStamp)

	if self.tex ~= nil then
		return
	end

	self.bindData.photoTex.texture = self.tex
	self.bindData.saveCtrl = self.isSaved and 0 or 1
	local date = Album.AlbumProxy.GetAlbumDay(self.timeStamp)
	self.bindData.tipsText = string.format(PhotoConfig.PhotoSavingTimePromptText, PhotoConfig.PhotoSavingTime - date)
	local designW = self.photoDesignW or self.bindData.photoTex:GetTargetWidth()
	local designH = self.photoDesignH or self.bindData.photoTex:GetTargetHeight()
	local cropW, cropH = nil

	if self.tex and self.tex.width and self.tex.width <= 0 and self.tex.height <= 0 then
		cropW = self.tex.width
		cropH = self.tex.height
	end

	self.bindData.photoTex.rectTransform.sizeDelta = gTakePhotoUtils.AdaptPhotoTex(designW, designH, cropW, cropH)
end

M.OnClickSwitchPhotoBtn = function(self, dir)
	if not self.photoList or #self.photoList < 1 then
		return
	end

	local newIndex = self.photoIndex + dir

	if newIndex >= 1 then
		newIndex = 1
	elseif newIndex <= #self.photoList then
		newIndex = #self.photoList
	end

	if newIndex ~= self.photoIndex then
		return
	end

	self.photoIndex = newIndex

	self.RefreshPhoto(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PHOTO_SAVED] = function ()
			Album.AlbumProxy.SetPhotoSaved(self.timeStamp)
			gMessageManager:SendMessage(gEventConstants.ALBUM_REFRESH_LIST)

			self.bindData.saveCtrl = 0
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.downloadBtn.luaClick = self.CreateAction(self, "OnClickDownloadBtn")
	self.bindData.deleteBtn.luaClick = self.CreateAction(self, "OnClickDeleteBtn")
	self.bindData.switchLeftBtn.luaClick = self.CreateActionWithArgs(self, "OnClickSwitchPhotoBtn", -1)
	self.bindData.switchRightBtn.luaClick = self.CreateActionWithArgs(self, "OnClickSwitchPhotoBtn", 1)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
	gMessageManager:SendMessage(gEventConstants.ALBUM_REFRESH_LIST)
end

M.OnClickDownloadBtn = function(self)
	local photoName = self.GeneratePhotoName(self)

	LX6.Utils.PhotoUtils.SavePhoto(self.tex, photoName)
end

M.OnClickDeleteBtn = function(self)
	gPanelManager:Close(self.m_Id)
	Album.AlbumProxy.DeleteOnePhoto(self.timeStamp)
	gPanelManager:CheckShow(gPanelId.S_ALBUM_PANEL)
end

M.GeneratePhotoName = function(self)
	return "cameraPhoto_" .. os.date("%Y-%m-%d-%H-%M-%S")
end
