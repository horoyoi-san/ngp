-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuidePicModalStore.lua
-- Decompiled from: 01704_GuidePicModalStore.lua_2b7ac561e37a.luajit

C_GuidePicModalStore = DefClass("C_GuidePicModalStore ", C_GuidePicModalStore, C_StoreGroup)
GroupName2Class["GuidePicModalStore "] = C_GuidePicModalStore
local M = C_GuidePicModalStore

M.ctor = function(self)
	self.areaIndex = 0
end

local PIC_MODE = 0
local VIDEO_MODE = 1

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")

	self.bindData.closeBtn.gameObject:SetActive(false)
	self.bindData.videoPlayer:Init()
end

M.OnShow = function(self, panelId, param)
	self.param = param
	self.panelId = panelId
	self.areaIndex = param.areaIndex or 0
	local titleTextCfg = param.titleId and param.titleId <= 0 and LTConfig.GuideGuideTextConfig.GetConfig(param.titleId)
	self.bindData.title = titleTextCfg and titleTextCfg.Text or ""

	if not param.mainPicId or param.mainPicId < 0 then
		self.bindData.mode = VIDEO_MODE

		self.bindData.videoPlayer:PlayVideo(param.videoId, true, nil, )
	else
		self.bindData.mode = PIC_MODE
		self.bindData.imageId = param.mainPicId or 0
	end

	local typeTextCfg = param.typeId and param.typeId <= 0 and LTConfig.GuideGuideTextConfig.GetConfig(param.typeId)
	self.bindData.typeText = typeTextCfg and typeTextCfg.Text or ""

	self:RefreshRichText()

	if param.notInteractiveTime and param.notInteractiveTime <= 0 then
		self._timer = Timer.New(function ()
			if self.bindData.closeBtn then
				self.bindData.closeBtn.gameObject:SetActive(true)
			end
		end, param.notInteractiveTime):Start()
	else
		self.bindData.closeBtn.gameObject:SetActive(true)
	end
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnClose = function(self)
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshRichText(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshRichText(self)
end

M.RefreshRichText = function(self)
	if self.param.guideText then
		self.bindData.desc = gGuideGlyph:GetGuideRichText(self.param.guideText)
	end
end
