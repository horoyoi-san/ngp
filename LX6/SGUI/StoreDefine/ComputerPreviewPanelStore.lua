-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComputerPreviewPanelStore.lua
-- Decompiled from: 01516_ComputerPreviewPanelStore.lua_dc1d495ff102.luajit

C_ComputerPreviewPanelStore = DefClass("C_ComputerPreviewPanelStore", C_ComputerPreviewPanelStore, C_StoreGroup)
GroupName2Class.ComputerPreviewPanelStore = C_ComputerPreviewPanelStore
local M = C_ComputerPreviewPanelStore

M.OnAwake = function(self)
	self.bindData.textList.luaSimpleRenderItem = self.CreateAction(self, "OnTextRenderItem")
	self.bindData.pdfList.luaSimpleRenderItem = self.CreateAction(self, "OnPDFRenderItem")
	self.bindData.wordList.luaSimpleRenderItem = self.CreateAction(self, "OnWordRenderItem")
	self.bindData.playButton.luaClick = self.CreateAction(self, "OnPlayClick")
	self.bindData.pauseButton.luaClick = self.CreateAction(self, "OnPauseClick")
	self.bindData.minButton.luaClick = self.CreateAction(self, "OnMinClick")
	self.bindData.maxButton.luaClick = self.CreateAction(self, "OnMaxClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.leftButton.luaClick = self.CreateAction(self, "OnLeftClick")
	self.bindData.rightButton.luaClick = self.CreateAction(self, "OnRightClick")
end

M.ShowPanel = function(self, computerFileId)
	self.InitModel(self, computerFileId)

	self.File_Type_Control = {
		["N'eO"] = 2,
		["{\\xa7\\xa6\\xaa\\xb9"] = 1,
		["M-o_"] = 4,
		["\\xe9\\xd2\t6\\xf4"] = 0,
		["\\xbeL@"] = 3
	}
	self.Video_Status_Control = {
		["J.|B"] = 1,
		["}\\xaf\\xb7\\xbc\\xb3"] = 0
	}

	self.InitView(self)
end

M.InitModel = function(self, computerFileId)
	self.computerFileId = computerFileId
end

M.InitView = function(self)
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(self.computerFileId)

	if computerFileCfg.FileType ~= gClientConst.Computer_File_Type.Picture then
		self.RefreshPictureView(self)
	elseif computerFileCfg.FileType ~= gClientConst.Computer_File_Type.Video then
		self.RefreshVideoView(self)
	elseif computerFileCfg.FileType ~= gClientConst.Computer_File_Type.Text then
		self.RefreshTextView(self)
	elseif computerFileCfg.FileType ~= gClientConst.Computer_File_Type.PDF then
		self.RefreshPDFView(self)
	elseif computerFileCfg.FileType ~= gClientConst.Computer_File_Type.Word then
		self.RefreshWordView(self)
	end

	self.bindData.title = computerFileCfg.FileTitle

	gComputerUtils:AskComputerFileRead(self.computerFileId, false)
end

M.RefreshPictureView = function(self)
	self.bindData.fileTypeControl = self.File_Type_Control.Picture
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(self.computerFileId)
	self.bindData.imageId = computerFileCfg.PictureId
end

M.RefreshVideoView = function(self)
	self.bindData.fileTypeControl = self.File_Type_Control.Video

	self.bindData.videoPlayer:Init()

	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(self.computerFileId)
	self.bindData.videoStatusControl = self.Video_Status_Control.Pause

	self.bindData.videoPlayer:PlayVideo(computerFileCfg.VideoId, true, nil, )
end

M.RefreshTextView = function(self)
	self.bindData.fileTypeControl = self.File_Type_Control.Text
	self.textDataList = {
		{
			computerFileId = self.computerFileId
		}
	}

	self.bindData.textList:SetSimpleList(#self.textDataList)
end

M.RefreshWordView = function(self)
	self.bindData.fileTypeControl = self.File_Type_Control.Word
	local computerFileId = self.computerFileId
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(computerFileId)
	local textCode = computerFileCfg.TextCode
	self.textDataList = string.split(textCode, "<page>")

	self.bindData.wordList:SetSimpleList(#self.textDataList)
end

M.OnTextRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.textDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local computerFileId = data.computerFileId
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(computerFileId)
	store.content = computerFileCfg.TextCode
end

M.RefreshPDFView = function(self)
	self.bindData.fileTypeControl = self.File_Type_Control.PDF
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(self.computerFileId)
	self.pdfDataList = computerFileCfg.SubFileList

	self.bindData.pdfList:SetSimpleList(#self.pdfDataList)
end

M.OnPDFRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local id = self.pdfDataList[luaIndex]

	if id ~= nil then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.image = id
end

M.OnWordRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.textDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.content = data
end

M.OnPauseClick = function(self)
	self.bindData.videoPlayer:Pause()

	self.bindData.videoStatusControl = self.Video_Status_Control.Play
end

M.OnPlayClick = function(self)
	self.bindData.videoPlayer:Resume()

	self.bindData.videoStatusControl = self.Video_Status_Control.Pause
end

M.OnMinClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_CLOSE)
end

M.OnMaxClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_CLOSE)
end

M.OnExitClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_CLOSE)
end

M.OnDestroy = function(self)
	self.bindData.videoPlayer:Stop()
end

M.OnUpdate = function(self)
	if self.bindData.fileTypeControl ~= self.File_Type_Control.Video then
		local currentTime = self.bindData.videoPlayer:GetCurrentTime()
		local videoTotalTime = self.bindData.videoPlayer:GetDuration()
		local diffTime = videoTotalTime - currentTime

		if videoTotalTime <= 0 and diffTime < gClientConst.VideoPlayFinishThresholdTime then
			gComputerUtils:AskComputerFileRead(self.computerFileId, true)
		end
	end
end

M.OnLeftClick = function(self)
end

M.OnRightClick = function(self)
end
