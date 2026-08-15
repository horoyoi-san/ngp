C_GuidePicModalStore = DefClass("C_GuidePicModalStore ", C_GuidePicModalStore, C_StoreGroup)
GroupName2Class["GuidePicModalStore "] = C_GuidePicModalStore
local M = C_GuidePicModalStore

function M:ctor()
	self.areaIndex = 0
end

local PIC_MODE = 0
local VIDEO_MODE = 1

function M:OnAwake()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")

	self.bindData.closeBtn.gameObject:SetActive(false)
	self.bindData.videoPlayer:Init()
end

function M:OnShow(panelId, param)
	self.param = param
	self.panelId = panelId
	self.areaIndex = param.areaIndex or 0
	local titleTextCfg = param.titleId and param.titleId > 0 and LTConfig.GuideGuideTextConfig.GetConfig(param.titleId)
	self.bindData.title = titleTextCfg and titleTextCfg.Text or ""

	if not param.mainPicId or param.mainPicId <= 0 then
		self.bindData.mode = VIDEO_MODE

		self.bindData.videoPlayer:PlayVideo(param.videoId, true, nil, nil)
	else
		self.bindData.mode = PIC_MODE
		self.bindData.imageId = param.mainPicId or 0
	end

	local typeTextCfg = param.typeId and param.typeId > 0 and LTConfig.GuideGuideTextConfig.GetConfig(param.typeId)
	self.bindData.typeText = typeTextCfg and typeTextCfg.Text or ""

	self:RefreshRichText()

	if param.notInteractiveTime and param.notInteractiveTime > 0 then
		self._timer = Timer.New(function ()
			if self.bindData.closeBtn then
				self.bindData.closeBtn.gameObject:SetActive(true)
			end
		end, param.notInteractiveTime):Start()
	else
		self.bindData.closeBtn.gameObject:SetActive(true)
	end
end

function M:OnCloseBtnClick()
	gPanelManager:Close(self.panelId)
end

function M:OnClose()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

function M:OnActiveDeviceChange(device)
	self:RefreshRichText()
end

function M:OnLanguageChange(lang)
	self:RefreshRichText()
end

function M:RefreshRichText()
	if self.param.guideText then
		self.bindData.desc = gGuideGlyph:GetGuideRichText(self.param.guideText)
	end
end
