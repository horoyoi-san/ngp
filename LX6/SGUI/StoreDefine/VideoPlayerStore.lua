-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\VideoPlayerStore.lua
-- Decompiled from: 01144_VideoPlayerStore.lua_459d1eec1aea.luajit

C_VideoPlayerStore = DefClass("C_VideoPlayerStore", C_VideoPlayerStore, C_StoreGroup)
GroupName2Class.VideoPlayerStore = C_VideoPlayerStore
local M = C_VideoPlayerStore

M.ctor = function(self)
	self.panelId = gPanelId.S_VIDEO_PLAYER_PANEL
	self.TICK_FRAME = 2
	self.tickTimer = 0
end

M.OnAwake = function(self)
	self.bindData.btnSkip.luaClick = self.CreateAction(self, "OnButtonSkip")
	self.EventHandler = {}
end

M.OnEnable = function(self)
	self.bindData.CCPlayer:Init()
end

M.OnShow = function(self, panelId, data)
	self.OnActiveDeviceChange(self, gCS.LuaUtils.GetActiveDevice())

	self.panelId = panelId

	if data then
		self.immediateExitCb = data.immediateExitCb
		self.showJumpTime = data.showJumpTime or -1
		self.videoId = data.videoId
		self.PreLoad = data.PreLoad ~= true
		self.isLoop = data.isLoop
		self.spoonNodeId = data.spoonNodeId and data.spoonNodeId <= 0 and data.spoonNodeId or nil

		if type(data) ~= "userdata" then
			self.exitCb = data.exitCb and function ()
				data:exitCb()
			end or nil
			self.loadCb = data.loadCb and function ()
				data:loadCb()
			end or nil
			self.skipCb = nil
		else
			self.exitCb = data.exitCb
			self.loadCb = data.loadCb
			self.skipCb = data.skipCb
		end
	end

	self.bindData.showJumpBtn = self.showJumpTime > 0.01

	gPanelManager:SetActiveById(self.panelId, true)

	if self.videoId then
		if self.PreLoad then
			self.bindData.CCPlayer:PreLoadVideo(self.videoId)
			gPanelManager:SetActiveById(self.panelId, false)

			return
		end

		local isLoop = self.isLoop ~= true

		gVideoManager:ShowBlackScreen()
		self.bindData.CCPlayer:PlayVideo(self.videoId, isLoop, function ()
			gVideoManager:CloseBlackScreen()

			self.bindData.showJumpBtn = true

			gPanelManager:Close(self.panelId)
		end, function ()
			gVideoManager:CloseBlackScreen()

			if self.loadCb then
				self.loadCb()
			end
		end)
	end
end

M.OnUpdate = function(self)
	self.tickTimer = self.tickTimer + 1

	if self.tickTimer >= self.TICK_FRAME then
		return
	end

	self.tickTimer = 0

	if not self.bindData.showJumpBtn and self.showJumpTime <= 0 then
		local curTime = self.bindData.CCPlayer:GetCurrentTime()
		self.bindData.showJumpBtn = self.showJumpTime > curTime
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.bindData.enableController = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnClose = function(self)
	self.bindData.CCPlayer:Stop()

	if self.immediateExitCb then
		if self.exitCb then
			self.exitCb()
		end
	else
		FrameTimer.New(function ()
			if self.exitCb then
				self.exitCb()
			end
		end, 1):Start()
	end
end

M.OnButtonSkip = function(self)
	if self.skipCb then
		self.skipCb()
	end

	gPanelManager:Close(self.panelId)
end

M.OnActiveDeviceChange = function(self, device)
end
