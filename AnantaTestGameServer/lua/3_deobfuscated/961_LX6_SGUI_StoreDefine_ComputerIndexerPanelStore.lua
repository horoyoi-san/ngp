C_ComputerIndexerPanelStore = DefClass("C_ComputerIndexerPanelStore", C_ComputerIndexerPanelStore, C_StoreGroup)
GroupName2Class.ComputerIndexerPanelStore = C_ComputerIndexerPanelStore
local M = C_ComputerIndexerPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.minButton.luaClick = self:CreateAction("OnMinClick")
	self.bindData.maxButton.luaClick = self:CreateAction("OnMaxClick")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentRenderItem")
	self.bindData.list.luaSelectedChanged = self:CreateAction("OnCategorySelectedChange")
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.folderList.luaSimpleRenderItem = self:CreateAction("OnFolderBarRenderItem")
end

function M:ShowPanel(computerId)
	self:InitModel(computerId)
	self:InitView()
end

function M:InitModel(computerId)
	self.computerId = computerId
	self.Category_Type = {
		Folder = 2,
		Fast_Visit = 1
	}
	self.Folder_Bar_Template = {
		Arrow = 1,
		Folder = 0
	}
	self.typeDataList = {
		{
			textId = 89901139,
			type = self.Category_Type.Fast_Visit,
			childTypeList = {
				{
					selected = true,
					textId = 89901141,
					type = gClientConst.Computer_File_Type.Video
				},
				{
					textId = 89900733,
					type = gClientConst.Computer_File_Type.Picture
				},
				{
					textId = 89901140,
					type = gClientConst.Computer_File_Type.Text
				}
			}
		},
		{
			textId = 89901142,
			type = self.Category_Type.Folder
		}
	}
end

function M:InitView()
	self:RefreshLeftView()
end

function M:RefreshLeftView()
	self.viewDataList = {}

	for _, typeData in ipairs(self.typeDataList) do
		if typeData.type == self.Category_Type.Fast_Visit then
			local validChildren = {}

			for _, childTypeData in ipairs(typeData.childTypeList) do
				if self:CheckHasFile(childTypeData.type) then
					table.insert(validChildren, childTypeData)
				end
			end

			if #validChildren > 0 then
				table.insert(self.viewDataList, {
					tIndex = 0,
					type = typeData.type,
					textId = typeData.textId
				})

				for _, childTypeData in ipairs(validChildren) do
					table.insert(self.viewDataList, {
						tIndex = 1,
						categoryType = typeData.type,
						type = childTypeData.type,
						textId = childTypeData.textId
					})
				end
			end
		else
			table.insert(self.viewDataList, {
				tIndex = 0,
				type = typeData.type,
				textId = typeData.textId
			})

			if typeData.type == self.Category_Type.Folder then
				local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
				local fileIdList = computerCfg.FileList

				for _, fileId in ipairs(fileIdList) do
					local isFileCanShow = self:CheckFileCanShow(fileId)

					if isFileCanShow then
						local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)

						if computerFileCfg.FileType == gClientConst.Computer_File_Type.Folder then
							table.insert(self.viewDataList, {
								tIndex = 1,
								fileId = fileId,
								categoryType = typeData.type
							})
						end
					end
				end
			end
		end
	end

	function self.bindData.list.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)

	local defaultSelectIndex = 0

	for i, data in ipairs(self.viewDataList) do
		if data.tIndex == 1 then
			defaultSelectIndex = i - 1

			break
		end
	end

	self.bindData.list:SetItemSelected(defaultSelectIndex, true)
	self:OnCategorySelectedChange()
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex == 0 then
		store.title = LTConfig.TextScriptTextConfig.GetConfig(data.textId).Text
	elseif data.tIndex == 1 then
		if data.categoryType == self.Category_Type.Fast_Visit then
			store.title = LTConfig.TextScriptTextConfig.GetConfig(data.textId).Text
			store.button.enabledTooltip = false
		elseif data.categoryType == self.Category_Type.Folder then
			local fileId = data.fileId
			local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
			store.title = computerFileCfg.FileTitle
			store.button.enabledTooltip = self:CheckEnabledToolTips()
			store.button.tooltipMode = self:GetToolTipMode()
			store.button.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderToolTips, data)
		end
	end
end

function M:OnRenderToolTips(data, _, popup, _)
	local store = gStoreManager:GetStoreGroup(popup.Store)

	function store.onDeleteCallback()
		local rootGo = self.rootGo

		gClientToGameDelegate:AskComputerDeleteFile(self.computerId, data.fileId).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			local computerInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo.ComputerInfos[self.computerId]

			table.insert(computerInfo.DeleteFiles, data.fileId)

			if gClientUtils.NotNil(rootGo) then
				if self:CheckIsRootNode(data.fileId) then
					self:RefreshLeftView()
				elseif data.parentFileId then
					self.contentDataList = self:GetSubFileViewDataList(data.parentFileId)

					self:SetContentList()
				else
					self:OnCategorySelectedChange()
				end
			end
		end
	end
end

function M:CheckIsRootNode(targetFileId)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	for _, fileId in ipairs(computerCfg.FileList) do
		if fileId == targetFileId then
			return LTConfig.ComputerFileConfig.GetConfig(fileId).FileType == gClientConst.Computer_File_Type.Folder
		end
	end
end

function M:OnContentRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.contentDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local fileId = data.fileId
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
	store.name = computerFileCfg.FileTitle
	local iconId = nil

	if computerFileCfg.FileType == gClientConst.Computer_File_Type.Folder then
		iconId = LTConfig.ComputerConfig.FileTypeFolderIcon
	elseif computerFileCfg.FileType == gClientConst.Computer_File_Type.Picture then
		iconId = LTConfig.ComputerConfig.FileTypePictureIcon
	elseif computerFileCfg.FileType == gClientConst.Computer_File_Type.Video then
		iconId = LTConfig.ComputerConfig.FileTypeVideoIcon
	elseif computerFileCfg.FileType == gClientConst.Computer_File_Type.Text then
		iconId = LTConfig.ComputerConfig.FileTypeTextIcon
	elseif computerFileCfg.FileType == gClientConst.Computer_File_Type.PDF then
		iconId = LTConfig.ComputerConfig.FileTypePDFIcon
	end

	store.iconId = iconId or 0
	store.button.luaClick = self:CreateActionWithArgs(self.OnContentItemClick, data)
	store.button.enabledTooltip = self:CheckEnabledToolTips()
	store.button.tooltipMode = self:GetToolTipMode()
	store.button.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderToolTips, data)
end

function M:OnContentItemClick(data)
	local fileId = data.fileId
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)

	if computerFileCfg.FileType ~= gClientConst.Computer_File_Type.Folder then
		gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_SHOW, fileId)
	else
		self.bottomBarFileList = self.bottomBarFileList or {}

		table.insert(self.bottomBarFileList, data)

		self.contentDataList = self:GetSubFileViewDataList(fileId)

		for _, fileViewData in ipairs(self.contentDataList) do
			fileViewData.parentFileId = data.fileId
		end

		self.bindData.title = computerFileCfg.FileTitle

		self:SetContentList()
		self:RefreshBottomFolderBarListView()
	end
end

function M:RefreshBottomFolderBarListView()
	self.folderViewDataList = {}
	local count = #self.bottomBarFileList

	for index, fileInfo in ipairs(self.bottomBarFileList) do
		table.insert(self.folderViewDataList, {
			tIndex = self.Folder_Bar_Template.Folder,
			fileInfo = fileInfo,
			index = index
		})

		if index % 2 == 1 and index ~= count then
			table.insert(self.folderViewDataList, {
				tIndex = self.Folder_Bar_Template.Arrow
			})
		end
	end

	function self.bindData.folderList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.folderViewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.folderList:SetSimpleList(#self.folderViewDataList)
end

function M:OnFolderBarRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.folderViewDataList[luaIndex]

	if data.tIndex == self.Folder_Bar_Template.Folder then
		local fileInfo = data.fileInfo
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if fileInfo.textId then
			store.title = LTConfig.TextScriptTextConfig.GetConfig(fileInfo.textId).Text
		else
			local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileInfo.fileId)
			store.title = computerFileCfg.FileTitle
		end

		store.button.enabledTooltip = self:CheckEnabledToolTips() and fileInfo.fileId ~= nil
		store.button.tooltipMode = self:GetToolTipMode()
		store.button.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderToolTips, fileInfo)

		function store.button.luaClick()
			if fileInfo.fileId then
				local bottomBarFileList = {}

				for i = 1, data.index do
					table.insert(bottomBarFileList, self.bottomBarFileList[i])
				end

				self.bottomBarFileList = bottomBarFileList

				self:RefreshBottomFolderBarListView()

				self.contentDataList = self:GetSubFileViewDataList(fileInfo.fileId)

				self:SetContentList()
			end
		end
	end
end

function M:GetToolTipMode()
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	return isMobile and 2 or 6
end

function M:CheckEnabledToolTips()
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	return computerCfg.IsDelete
end

function M:OnCategorySelectedChange()
	self.bottomBarFileList = {}
	local selectedIndex = self.bindData.list.selectedIndex
	local selectedItem = self.viewDataList[selectedIndex + 1]

	table.insert(self.bottomBarFileList, selectedItem)
	self:RefreshContentView()
	self:RefreshBottomFolderBarListView()
end

function M:RefreshContentView()
	local selectedIndex = self.bindData.list.selectedIndex
	local selectedItem = self.viewDataList[selectedIndex + 1]
	self.contentDataList = {}

	if selectedItem.tIndex == 0 then
		self.bindData.title = ""

		self:SetContentList()

		return
	end

	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	local fileIdList = computerCfg.FileList

	if selectedItem.categoryType == self.Category_Type.Fast_Visit then
		local fileType = selectedItem.type

		for _, fileId in ipairs(fileIdList) do
			local isFileCanShow = self:CheckFileCanShow(fileId)

			if isFileCanShow then
				local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)

				if computerFileCfg.FileType == fileType then
					table.insert(self.contentDataList, {
						fileId = fileId
					})
				end
			end
		end

		self.bindData.title = LTConfig.TextScriptTextConfig.GetConfig(selectedItem.textId).Text
	elseif selectedItem.categoryType == self.Category_Type.Folder then
		local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(selectedItem.fileId)
		local subFileViewList = self:GetSubFileViewDataList(selectedItem.fileId)

		array.concat(self.contentDataList, subFileViewList)

		self.bindData.title = computerFileCfg.FileTitle
	end

	self:SetContentList()
end

function M:SetContentList()
	self.contentDataList = self.contentDataList or {}

	self.bindData.contentList:SetSimpleList(#self.contentDataList)

	self.bindData.emptyControl = #self.contentDataList == 0 and 1 or 0
end

function M:GetSubFileViewDataList(fileId)
	local viewDataList = {}
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
	local subFileIdList = computerFileCfg.SubFileList

	for _, subFileId in ipairs(subFileIdList) do
		local isFileCanShow = self:CheckFileCanShow(subFileId)

		if isFileCanShow then
			table.insert(viewDataList, {
				fileId = subFileId
			})
		end
	end

	return viewDataList
end

function M:CheckFileHasUnlocked(fileId)
	local computerFileInfo = self:GetComputerFileInfo(fileId)

	return computerFileInfo ~= nil
end

function M:GetComputerFileInfo(fileId)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	return computerUnlockInfo and computerUnlockInfo.UnlockFiles and computerUnlockInfo.UnlockFiles[fileId]
end

function M:OnExitClick()
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
end

function M:OnMinClick()
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
end

function M:OnMaxClick()
	return
end

function M:OnRenderTab(_, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	store.m_Id = self.m_Id

	store:ShowPanel(self.selectedFileId)
end

function M:OnComputerPreviewClose()
	self.bindData.tabRect:SelectIndexWithClose(-1)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:CheckFileCanShow(fileId)
	if not self:CheckFileHasUnlocked(fileId) then
		return false
	end

	if self:CheckFileHasDeleted(fileId) then
		return false
	end

	return true
end

function M:CheckFileHasDeleted(targetFileId)
	local computerInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo.ComputerInfos[self.computerId]

	if computerInfo then
		for _, fileId in ipairs(computerInfo.DeleteFiles) do
			if fileId == targetFileId then
				return true
			end
		end
	end
end

function M:CheckHasFile(fileType)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	local fileIdList = computerCfg.FileList

	for _, fileId in ipairs(fileIdList) do
		local isFileCanShow = self:CheckFileCanShow(fileId)

		if isFileCanShow then
			local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)

			if computerFileCfg.FileType == fileType then
				return true
			end
		end
	end

	return false
end
