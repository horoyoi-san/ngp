-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShowPhotoPanelStore.lua
-- Decompiled from: 01327_ShowPhotoPanelStore.lua_6d329faefb27.luajit

C_ShowPhotoPanelStore = DefClass("C_ShowPhotoPanelStore", C_ShowPhotoPanelStore, C_StoreGroup)
GroupName2Class.ShowPhotoPanelStore = C_ShowPhotoPanelStore
local M = C_ShowPhotoPanelStore

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnCloseBtnClick)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId

	if data.imageId then
		local cfg = LTConfig.SguiImageConfig.GetConfig(data.imageId)
		local url = cfg.ImgPath
		slot5 = self.bindData.rawImage

		slot5:SetUrlWithCallback(url, function ()
			gCS.LuaUtils.SetImageExpandSizePreserveAspect(self.bindData.imageSizeNode.rectTransform, self.bindData.rawImage.texture, self.bindData.rawImage.rectTransform)
		end)
	elseif data.texture then
		self.bindData.photoImgTex = data.texture

		gCS.LuaUtils.SetImageExpandSizePreserveAspect(self.bindData.imageSizeNode.rectTransform, data.texture, self.bindData.rawImage.rectTransform)
	else
		print_error("[ShowPhotoPanelStore] no image data", data)
	end

	if data.textId then
		local textCfg = LTConfig.TextScriptTextConfig.GetConfig(data.textId)

		if not textCfg then
			print_error("[ShowPhotoPanelStore] can not find text, Id=", data.textId)
		else
			self.bindData.photoText = gClientUtils.RichTextToPlain(textCfg.Text)
		end
	elseif data.text then
		self.bindData.photoText = data.text
	else
		self.bindData.photoText = ""
	end
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(self.panelId)
end
