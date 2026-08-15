C_ComputerPreviewPanelStore = DefClass("C_ComputerPreviewPanelStore", C_ComputerPreviewPanelStore, C_StoreGroup)
GroupName2Class.ComputerPreviewPanelStore = C_ComputerPreviewPanelStore
local M = C_ComputerPreviewPanelStore

function M:OnAwake()
	self.bindData.textList.luaSimpleRenderItem = self:CreateAction("OnTextRenderItem")
	self.bindData.pdfList.luaSimpleRenderItem = self:CreateAction("OnPDFRenderItem")
	self.bindData.playButton.luaClick = self:CreateAction("OnPlayClick")
	self.bindData.pauseButton.luaClick = self:CreateAction("OnPauseClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.leftButton.luaClick = self:CreateAction("OnLeftClick")
	self.bindData.rightButton.luaClick = self:CreateAction("OnRightClick")
end

function M:ShowPanel(computerFileId)
	self:InitModel(computerFileId)

	self.File_Type_Control = {
		Video = 1,
		Picture = 0,
		Text = 2,
		PDF = 3
	}
	self.Video_Status_Control = {
		Play = 1,
		Pause = 0
	}

	self:InitView()
end

function M:InitModel(computerFileId)
	self.computerFileId = computerFileId
end

function M:InitView()
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(self.computerFileId)

	if computerFileCfg.FileType == gClientConst.Computer_File_Type.Picture then
		self:RefreshPictureView()
	elseif computerFileCfg.FileType == gClientConst.Computer_File_Type.Video then
		self:RefreshVideoView()
	elseif computerFileCfg.FileType == gClientConst.Computer_File_Type.Text then
		self:RefreshTextView()
	elseif computerFileCfg.FileType == gClientConst.Computer_File_Type.PDF then
		self:RefreshPDFView()
	end

	self.bindData.title = computerFileCfg.FileTitle

	self:AskComputerFileRead(false)
end

function M:AskComputerFileRead(isVideoFinish)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_FILE_READ, {
		fileId = self.computerFileId,
		isVideoFinish = isVideoFinish
	})

	gClientToGameDelegate:AskComputerFileRead(self.computerFileId, isVideoFinish).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

function M:RefreshPictureView()
	self.bindData.fileTypeControl = self.File_Type_Control.Picture
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(self.computerFileId)
	self.bindData.imageId = computerFileCfg.PictureId
end

function M:RefreshVideoView()
	self.bindData.fileTypeControl = self.File_Type_Control.Video

	self.bindData.videoPlayer:Init()

	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(self.computerFileId)
	self.bindData.videoStatusControl = self.Video_Status_Control.Pause

	self.bindData.videoPlayer:PlayVideo(computerFileCfg.VideoId, true, nil, nil)
end

function M:RefreshTextView()
	self.bindData.fileTypeControl = self.File_Type_Control.Text
	self.textDataList = {
		{
			computerFileId = self.computerFileId
		}
	}

	self.bindData.textList:SetSimpleList(#self.textDataList)
end

function M:OnTextRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.textDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local computerFileId = data.computerFileId
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(computerFileId)
	store.content = computerFileCfg.TextCode
end

function M:RefreshPDFView()
	self.bindData.fileTypeControl = self.File_Type_Control.PDF
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(self.computerFileId)
	self.pdfDataList = computerFileCfg.SubFileList

	self.bindData.pdfList:SetSimpleList(#self.pdfDataList)
end

function M:OnPDFRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local id = self.pdfDataList[luaIndex]

	if id == nil then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.image = id
end

function M:OnPauseClick()
	self.bindData.videoPlayer:Pause()

	self.bindData.videoStatusControl = self.Video_Status_Control.Play
end

function M:OnPlayClick()
	self.bindData.videoPlayer:Resume()

	self.bindData.videoStatusControl = self.Video_Status_Control.Pause
end

function M:OnExitClick()
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_CLOSE)
end

function M:OnDestroy()
	self.bindData.videoPlayer:Stop()
end

function M:OnUpdate()
	if self.bindData.fileTypeControl == self.File_Type_Control.Video then
		local currentTime = self.bindData.videoPlayer:GetCurrentTime()
		local videoTotalTime = self.bindData.videoPlayer:GetDuration()
		local diffTime = videoTotalTime - currentTime

		if videoTotalTime > 0 and diffTime <= gClientConst.VideoPlayFinishThresholdTime then
			self:AskComputerFileRead(true)
		end
	end
end

function M:OnLeftClick()
	return
end

function M:OnRightClick()
	return
end
