C_VideoPlayerStore = DefClass("C_VideoPlayerStore", C_VideoPlayerStore, C_StoreGroup)
GroupName2Class.VideoPlayerStore = C_VideoPlayerStore
local M = C_VideoPlayerStore

function M:ctor()
	self.panelId = gPanelId.S_VIDEO_PLAYER_PANEL
	self.TICK_FRAME = 2
	self.tickTimer = 0
end

function M:OnAwake()
	self.bindData.btnSkip.luaClick = self:CreateAction("OnButtonSkip")
	self.EventHandler = {}
end

function M:OnEnable()
	self.bindData.CCPlayer:Init()
end

function M:OnShow(panelId, data)
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.panelId = panelId
	self.immediateExitCb = data.immediateExitCb
	self.exitCb = data.exitCb
	self.loadCb = data.loadCb

	if data and data.exitCb and type(data) == "userdata" then
		function self.exitCb()
			data:exitCb()
		end
	end

	if data and data.endCb and type(data) == "userdata" then
		function self.endCb()
			data:endCb()
		end
	end

	if data and data.loadCb and type(data) == "userdata" then
		function self.loadCb()
			data:loadCb()
		end
	end

	if data and data.spoonNodeId and data.spoonNodeId > 0 then
		self.spoonNodeId = data.spoonNodeId
	end

	self.showJumpTime = data.showJumpTime or -1
	self.bindData.showJumpBtn = self.showJumpTime <= 0.01

	gPanelManager:SetActiveById(self.panelId, true)

	if data.videoId then
		self.PreLoad = data.PreLoad == true

		if self.PreLoad then
			self.bindData.CCPlayer:PreLoadVideo(data.videoId)
			gPanelManager:SetActiveById(self.panelId, false)

			return
		end

		local isLoop = data.isLoop == true

		gVideoManager:ShowBlackScreen()
		self.bindData.CCPlayer:PlayVideo(data.videoId, isLoop, function ()
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

function M:OnUpdate()
	self.tickTimer = self.tickTimer + 1

	if self.tickTimer < self.TICK_FRAME then
		return
	end

	self.tickTimer = 0

	if not self.bindData.showJumpBtn and self.showJumpTime > 0 then
		local curTime = self.bindData.CCPlayer:GetCurrentTime()
		self.bindData.showJumpBtn = self.showJumpTime <= curTime
	end
end

function M:OnActiveDeviceChange(device)
	self.bindData.enableController = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnClose()
	self.bindData.CCPlayer:Stop()

	if self.endCb then
		self.endCb()
	end

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

function M:OnButtonSkip()
	if self.spoonNodeId then
		-- Nothing
	end

	gPanelManager:Close(self.panelId)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
