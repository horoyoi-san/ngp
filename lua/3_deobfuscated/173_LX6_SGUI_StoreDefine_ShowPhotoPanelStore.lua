C_ShowPhotoPanelStore = DefClass("C_ShowPhotoPanelStore", C_ShowPhotoPanelStore, C_StoreGroup)
GroupName2Class.ShowPhotoPanelStore = C_ShowPhotoPanelStore
local M = C_ShowPhotoPanelStore

function M:OnAwake()
	self.bindData.closeBtn.luaClick = self:CreateAction(self.OnCloseBtnClick)
end

function M:OnShow(panelId, data)
	self.panelId = panelId

	if data.imageId then
		local cfg = LTConfig.SguiImageConfig.GetConfig(data.imageId)
		local url = cfg.ImgPath

		self.bindData.rawImage:SetUrlWithCallback(url, function ()
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

function M:OnCloseBtnClick()
	gPanelManager:Close(self.panelId)
end
