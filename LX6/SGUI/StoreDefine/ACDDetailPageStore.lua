-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ACDDetailPageStore.lua
-- Decompiled from: 01588_ACDDetailPageStore.lua_6509c83c733b.luajit

local ACDMainConfig = LTConfig.WebpageACDMainConfig
local ResourceConfig = LTConfig.WebpageResourceConfig
C_ACDDetailPageStore = DefClass("C_ACDDetailPageStore", C_ACDDetailPageStore, C_StoreGroup)
GroupName2Class.ACDDetailPageStore = C_ACDDetailPageStore
local M = C_ACDDetailPageStore
M.AudioStatusCtl = {
	["\\xe9\\xd7*\\xf6"] = 1,
	["\\xe9\\xda*\\xf6"] = 0
}
M.AudioPlayerCtl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.btnPlay.luaClick = self.CreateAction(self, self.OnAudioBtnClicked)
	self.bindData.btnPause.luaClick = self.CreateAction(self, self.OnAudioBtnClicked)
	self.bindData.resource.luaOnPlay = self.CreateAction(self, self.OnAudioPlayOrResume)
	self.bindData.resource.luaOnResume = self.CreateAction(self, self.OnAudioPlayOrResume)
	self.bindData.resource.luaOnPause = self.CreateAction(self, self.OnAudioPauseOrStop)
	self.bindData.resource.luaOnStop = self.CreateAction(self, self.OnAudioPauseOrStop)
end

M.RefreshPage = function(self, newsId)
	local pageConfig = ACDMainConfig.GetConfig(newsId)

	if not pageConfig then
		gWebManager:GoToNotFoundPage()

		return
	end

	local resId = pageConfig.SubResources[1]

	if not resId then
		gWebManager:GoToNotFoundPage()

		return
	end

	local resConfig = ResourceConfig.GetConfig(resId)

	if not resConfig then
		gWebManager:GoToNotFoundPage()

		return
	end

	self.bindData.title.text = resConfig.Name
	self.bindData.desc1.text = resConfig.Desc

	self.bindData:Commit("bigimage", resConfig.ImageId, COMMIT_FORCE)

	self.bindData.footnote.text = ""
	self.bindData.resource.resourceId = resId
	self.bindData.showAudio = resConfig and resConfig.SoundId == 0 and self.AudioPlayerCtl.Show or self.AudioPlayerCtl.Hide

	if resConfig and resConfig.VideoId then
		self.bindData.videoresource.resourceId = resId
	end
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnAudioBtnClicked = function(self)
	self.bindData.resource:PlayOrPause()
end

M.OnAudioPlayOrResume = function(self)
	self.bindData.audioStatusCtl = self.AudioStatusCtl.Playing
end

M.OnAudioPauseOrStop = function(self)
	self.bindData.audioStatusCtl = self.AudioStatusCtl.Pausing
end
