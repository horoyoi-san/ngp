-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCCreateFinishShareStore.lua
-- Decompiled from: 00937_OCCreateFinishShareStore.lua_5371e5508275.luajit

local PhotoUtils = LX6.Utils.PhotoUtils
C_OCCreateFinishShareStore = DefClass("C_OCCreateFinishShareStore", C_OCCreateFinishShareStore, C_StoreGroup)
GroupName2Class.OCCreateFinishShareStore = C_OCCreateFinishShareStore
local M = C_OCCreateFinishShareStore

M.ctor = function(self)
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	local photo = PhotoUtils.writeCameraImage
	self.bindData.texture = photo

	self.AdaptPhotoSize(self, photo)
end

M.AdaptPhotoSize = function(self, photo)
	local imageWidget = self.bindData.photoImage

	if not imageWidget then
		return
	end

	if not self._photoDesignSize then
		local rect = imageWidget.rectTransform.rect
		local w = rect.width
		local h = rect.height

		if w > 0 or h < 0 then
			h = 1125
			w = 2000
		end

		self._photoDesignSize = Vector2.New(w, h)
	end

	if photo and photo.width <= 0 and photo.height <= 0 then
		local design = self._photoDesignSize
		imageWidget.rectTransform.sizeDelta = gTakePhotoUtils.AdaptPhotoTex(design.x, design.y, photo.width, photo.height, true)
	end
end

M.OnClose = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.saveBtn.luaClick = self.CreateAction(self, self.OnClickSaveBtn)
	self.bindData.qqShareBtn.luaClick = self.CreateAction(self, self.OnClickQqShareBtn)
	self.bindData.wxShareBtn.luaClick = self.CreateAction(self, self.OnClickWxShareBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.OnClickSaveBtn = function(self)
end

M.OnClickQqShareBtn = function(self)
end

M.OnClickWxShareBtn = function(self)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end
