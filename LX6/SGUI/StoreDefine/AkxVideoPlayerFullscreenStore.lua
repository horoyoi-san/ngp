-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AkxVideoPlayerFullscreenStore.lua
-- Decompiled from: 01606_AkxVideoPlayerFullscreenStore.lua_9450c9259f5a.luajit

C_AkxVideoPlayerFullscreenStore = DefClass("C_AkxVideoPlayerFullscreenStore", C_AkxVideoPlayerFullscreenStore, C_StoreGroup)
GroupName2Class.AkxVideoPlayerFullscreenStore = C_AkxVideoPlayerFullscreenStore
local M = C_AkxVideoPlayerFullscreenStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.btnClose.luaClick = self.CreateAction(self, self.Close)
	self.bindData.videoPlayer.luaOnStop = self.CreateAction(self, self.OnVideoPlayerStop)
end

M.OnEnable = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnShow = function(self, panelId, data)
	if data and data.videoId then
		self.bindData.videoPlayer.videoId = data.videoId
	end

	if data and data.videoUrl then
		self.bindData.videoPlayer.url = data.videoUrl
	end

	local bAutoLoad = true
	local bAutoPlayWhenReady = true
	local bIsLoop = false
	local bAutoCloseWhenEnd = true

	if data and data.autoLoad == nil then
		bAutoLoad = data.autoLoad
	end

	if data and data.autoPlayWhenReady == nil then
		bAutoPlayWhenReady = data.autoPlayWhenReady
	end

	if data and data.isLoop == nil then
		bIsLoop = data.isLoop
	end

	if data and data.autoCloseWhenEnd == nil then
		bAutoCloseWhenEnd = data.autoCloseWhenEnd
	end

	self.bAutoCloseWhenEnd = bAutoCloseWhenEnd
	self.bindData.videoPlayer.autoLoad = bAutoLoad
	self.bindData.videoPlayer.autoPlayWhenReady = bAutoPlayWhenReady
	self.bindData.videoPlayer.loopPlay = bIsLoop
end

M.Close = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnVideoPlayerStop = function(self)
	if self.bAutoCloseWhenEnd then
		self.Close(self)
	end
end

M.OnActiveDeviceChange = function(self, device)
end
