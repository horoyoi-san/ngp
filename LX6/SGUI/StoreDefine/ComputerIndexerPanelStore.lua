-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComputerIndexerPanelStore.lua
-- Decompiled from: 01519_ComputerIndexerPanelStore.lua_08a01806d7ab.luajit

C_ComputerIndexerPanelStore = DefClass("C_ComputerIndexerPanelStore", C_ComputerIndexerPanelStore, C_StoreGroup)
GroupName2Class.ComputerIndexerPanelStore = C_ComputerIndexerPanelStore
local M = C_ComputerIndexerPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.minButton.luaClick = self.CreateAction(self, "OnMinClick")
	self.bindData.maxButton.luaClick = self.CreateAction(self, "OnMaxClick")
	self.bindData.closeCrashButton.luaClick = self.CreateAction(self, "OnCloseCrashClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.luaSimpleFocus = self.CreateAction(self, "OnCategoryItemFocus")
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, "OnContentRenderItem")
	self.bindData.list.luaSelectedChanged = self.CreateAction(self, "OnCategorySelectedChange")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.folderList.luaSimpleRenderItem = self.CreateAction(self, "OnFolderBarRenderItem")
end

M.ShowPanel = function(self, computerId, targetFolderId)
	self.InitModel(self, computerId)
	self.InitView(self)

	if targetFolderId then
		self.OpenFolderByTargetId(self, targetFolderId)
	end
end

M.InitModel = function(self, computerId)
	self.computerId = computerId
	self.Category_Type = {
		[":G\\x9d\\x8a\\x86S"] = 2,
		["u[ݩ\\xbb>\\xb1\\xc0\\xfc"] = 1
	}
	self.Folder_Bar_Template = {
		["l\\xbc\\xb0\\xa0\\xa1"] = 1,
		[":G\\x9d\\x8a\\x86S"] = 0
	}
	self.typeDataList = {
		{
			["M\\x89\\x9a\\xaaE"] = 89901139,
			type = self.Category_Type.Fast_Visit,
			childTypeList = {
				{
					["\\xb8\\xb4\t\\xaei*\\xfb7"] = true,
					["M\\x89\\x9a\\xaaE"] = 89901141,
					type = {
						gClientConst.Computer_File_Type.Video
					}
				},
				{
					["M\\x89\\x9a\\xaaE"] = 89900733,
					type = {
						gClientConst.Computer_File_Type.Picture
					}
				},
				{
					["M\\x89\\x9a\\xaaE"] = 89901140,
					type = {
						gClientConst.Computer_File_Type.Text,
						gClientConst.Computer_File_Type.Word
					}
				},
				{
					["M\\x89\\x9a\\xaaE"] = 89901353,
					type = {
						gClientConst.Computer_File_Type.App
					}
				}
			}
		},
		{
			["M\\x89\\x9a\\xaaE"] = 89901142,
			type = self.Category_Type.Folder
		}
	}
end

M.InitView = function(self)
	self.RefreshLeftView(self)
end

M.GetDefaultCategorySelectIndex = function(self)
	if not self.viewDataList or #self.viewDataList ~= 0 then
		return -1
	end

	for i, data in ipairs(self.viewDataList) do
		if data.tIndex ~= 1 then
			return i - 1
		end
	end

	return 0
end

M.GetSelectedCategoryItem = function(self)
	if not self.viewDataList or #self.viewDataList ~= 0 then
		return -1, nil
	end

	local selectedIndex = self.bindData.list.selectedIndex

	if selectedIndex <= 0 or selectedIndex > #self.viewDataList then
		return selectedIndex, nil
	end

	return selectedIndex, self.viewDataList[selectedIndex + 1]
end

M.RefreshLeftView = function(self)
	self.viewDataList = {}

	for _, typeData in ipairs(self.typeDataList) do
		if typeData.type ~= self.Category_Type.Fast_Visit then
			local validChildren = {}

			for _, childTypeData in ipairs(typeData.childTypeList) do
				if self.CheckHasFile(self, childTypeData.type) then
					table.insert(validChildren, childTypeData)
				end
			end

			if #validChildren <= 0 then
				table.insert(self.viewDataList, {
					["a\\x9f\\x8a\\x86Y"] = 0,
					type = typeData.type,
					textId = typeData.textId
				})

				for _, childTypeData in ipairs(validChildren) do
					table.insert(self.viewDataList, {
						["a\\x9f\\x8a\\x86Y"] = 1,
						categoryType = typeData.type,
						type = childTypeData.type,
						textId = childTypeData.textId
					})
				end
			end
		else
			table.insert(self.viewDataList, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				type = typeData.type,
				textId = typeData.textId
			})

			if typeData.type ~= self.Category_Type.Folder then
				local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
				local fileIdList = computerCfg.FileList

				for _, fileId in ipairs(fileIdList) do
					local isFileCanShow = self.CheckFileCanShow(self, fileId)

					if isFileCanShow then
						local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)

						if computerFileCfg.FileType ~= gClientConst.Computer_File_Type.Folder then
							table.insert(self.viewDataList, {
								["a\\x9f\\x8a\\x86Y"] = 1,
								fileId = fileId,
								categoryType = typeData.type
							})
						end
					end
				end
			end
		end
	end

	self.bindData.list.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList and self.viewDataList[luaIndex]

		return data and data.tIndex or 0
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)

	if #self.viewDataList ~= 0 then
		self.bindData.title = ""
		self.bottomBarFileList = {}
		self.contentDataList = {}

		self.SetContentList(self)
		self.RefreshBottomFolderBarListView(self)

		return
	end

	local defaultSelectIndex = self:GetDefaultCategorySelectIndex()

	self.bindData.list:SelectItem(defaultSelectIndex, false)
	self:OnCategorySelectedChange()
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex ~= 0 then
		store.title = LTConfig.TextScriptTextConfig.GetConfig(data.textId).Text
	elseif data.tIndex ~= 1 then
		if data.categoryType ~= self.Category_Type.Fast_Visit then
			store.title = LTConfig.TextScriptTextConfig.GetConfig(data.textId).Text
			store.button.enabledTooltip = false
		elseif data.categoryType ~= self.Category_Type.Folder then
			local fileId = data.fileId
			local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
			store.title = computerFileCfg.FileTitle
			store.button.enabledTooltip = self.CheckEnabledToolTips(self)
			store.button.tooltipMode = self.GetToolTipMode(self)
			store.button.luaRenderTooltip = self.CreateActionWithArgs(self, self.OnRenderToolTips, data)
		end
	end
end

M.OnCategoryItemFocus = function(self, _, csIndex)
	if SGUI.UNavigationMgr.Inst.CurNavigationMode == SGUI.NavigationMode.DPad then
		return
	end

	if self.viewDataList[csIndex + 1] then
		self.bindData.list:SelectItem(csIndex, false)
		self:OnCategorySelectedChange()
	end
end

M.OnRenderToolTips = function(self, data, _, popup, _)
	slot5 = gStoreManager
	local store = slot5:GetStoreGroup(popup.Store)

	store.onDeleteCallback = function()
		local rootGo = self.rootGo
		slot1 = gClientToGameDelegate

		slot1:AskComputerDeleteFile(self.computerId, data.fileId).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
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

M.CheckIsRootNode = function(self, targetFileId)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	for _, fileId in ipairs(computerCfg.FileList) do
		if fileId ~= targetFileId then
			return LTConfig.ComputerFileConfig.GetConfig(fileId).FileType ~= gClientConst.Computer_File_Type.Folder
		end
	end
end

M.OnContentRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.contentDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local fileId = data.fileId
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
	store.name = computerFileCfg.FileTitle
	local iconId = gComputerUtils:GetFileIconId(computerFileCfg.FileType)
	store.iconId = iconId or 0
	store.button.luaClick = self:CreateActionWithArgs(self.OnContentItemClick, data)
	store.button.enabledTooltip = self:CheckEnabledToolTips()
	store.button.tooltipMode = self:GetToolTipMode()
	store.button.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderToolTips, data)
end

M.OnContentItemClick = function(self, data)
	local fileId = data.fileId
	local corruptedFileId = LTConfig.ComputerConfig.CorruptedFileId

	if array.contains(corruptedFileId, fileId) then
		self.bindData.showCrashControl = 1
		local crashContext = LTConfig.ComputerConfig.CorruptedFileContext
		self.bindData.crashContent = crashContext

		return
	end

	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)

	if computerFileCfg.FileType == gClientConst.Computer_File_Type.Folder then
		gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_SHOW, fileId)
	else
		self.OpenFolder(self, data)
	end
end

M.OpenFolder = function(self, data)
	local fileId = data.fileId
	self.bottomBarFileList = self.bottomBarFileList or {}

	table.insert(self.bottomBarFileList, data)

	self.contentDataList = self:GetSubFileViewDataList(fileId)

	for _, fileViewData in ipairs(self.contentDataList) do
		fileViewData.parentFileId = fileId
	end

	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
	self.bindData.title = computerFileCfg.FileTitle

	self.SetContentList(self)
	self.RefreshBottomFolderBarListView(self)
end

M.OpenFolderByTargetId = function(self, targetFolderId)
	local targetIndex, targetData = nil

	for index, data in ipairs(self.viewDataList) do
		if data.fileId ~= targetFolderId then
			targetIndex = index
			targetData = data

			break
		end
	end

	if not targetData then
		for index, data in ipairs(self.viewDataList) do
			if data.fileId and data.categoryType ~= self.Category_Type.Folder then
				local foundData = self.FindFileViewDataInFolder(self, data.fileId, targetFolderId)

				if foundData then
					targetIndex = index
					targetData = foundData

					break
				end
			end
		end
	end

	if not targetIndex then
		return
	end

	self.bindData.list:SelectItem(targetIndex - 1, false)
	self:OpenFolder(targetData)
end

M.FindFileViewDataInFolder = function(self, folderId, targetFileId)
	local subFileViewList = self.GetSubFileViewDataList(self, folderId)

	for _, subFileData in ipairs(subFileViewList) do
		if subFileData.fileId ~= targetFileId then
			return subFileData
		end

		local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(subFileData.fileId)

		if computerFileCfg.FileType ~= gClientConst.Computer_File_Type.Folder then
			local foundData = self.FindFileViewDataInFolder(self, subFileData.fileId, targetFileId)

			if foundData then
				return foundData
			end
		end
	end

	return nil
end

M.RefreshBottomFolderBarListView = function(self)
	self.folderViewDataList = {}
	local count = #self.bottomBarFileList

	for index, fileInfo in ipairs(self.bottomBarFileList) do
		table.insert(self.folderViewDataList, {
			tIndex = self.Folder_Bar_Template.Folder,
			fileInfo = fileInfo,
			index = index
		})

		if index % 2 ~= 1 and index == count then
			table.insert(self.folderViewDataList, {
				tIndex = self.Folder_Bar_Template.Arrow
			})
		end
	end

	self.bindData.folderList.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.folderViewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.folderList:SetSimpleList(#self.folderViewDataList)
end

M.OnFolderBarRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.folderViewDataList[luaIndex]

	if data.tIndex ~= self.Folder_Bar_Template.Folder then
		local fileInfo = data.fileInfo
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if fileInfo.textId then
			store.title = LTConfig.TextScriptTextConfig.GetConfig(fileInfo.textId).Text
		else
			local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileInfo.fileId)
			store.title = computerFileCfg.FileTitle
		end

		store.button.enabledTooltip = self:CheckEnabledToolTips() and fileInfo.fileId == nil
		store.button.tooltipMode = self:GetToolTipMode()
		store.button.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderToolTips, fileInfo)

		store.button.luaClick = function()
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

M.GetToolTipMode = function(self)
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	return isMobile and 2 or 6
end

M.CheckEnabledToolTips = function(self)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	return computerCfg.IsDelete
end

M.OnCategorySelectedChange = function(self)
	self.bottomBarFileList = {}
	local _, selectedItem = self.GetSelectedCategoryItem(self)

	if not selectedItem then
		return
	end

	table.insert(self.bottomBarFileList, selectedItem)
	self.RefreshContentView(self)
	self.RefreshBottomFolderBarListView(self)
end

M.RefreshContentView = function(self)
	local _, selectedItem = self.GetSelectedCategoryItem(self)

	if not selectedItem then
		return
	end

	self.contentDataList = {}

	if selectedItem.tIndex ~= 0 then
		self.bindData.title = ""

		self.SetContentList(self)

		return
	end

	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	local fileIdList = computerCfg.FileList

	if selectedItem.categoryType ~= self.Category_Type.Fast_Visit then
		local fileType = selectedItem.type

		for _, fileId in ipairs(fileIdList) do
			local isFileCanShow = self.CheckFileCanShow(self, fileId)

			if isFileCanShow then
				local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
				local cfgFileType = computerFileCfg.FileType

				if array.contains(fileType, cfgFileType) then
					table.insert(self.contentDataList, {
						fileId = fileId
					})
				end
			end
		end

		self.bindData.title = LTConfig.TextScriptTextConfig.GetConfig(selectedItem.textId).Text
	elseif selectedItem.categoryType ~= self.Category_Type.Folder then
		local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(selectedItem.fileId)
		local subFileViewList = self.GetSubFileViewDataList(self, selectedItem.fileId)

		array.concat(self.contentDataList, subFileViewList)

		self.bindData.title = computerFileCfg.FileTitle
	end

	self.SetContentList(self)
end

M.SetContentList = function(self)
	self.contentDataList = self.contentDataList or {}

	self.bindData.contentList:SetSimpleList(#self.contentDataList)

	self.bindData.emptyControl = #self.contentDataList ~= 0 and 1 or 0
end

M.GetSubFileViewDataList = function(self, fileId)
	local viewDataList = {}
	local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
	local subFileIdList = computerFileCfg.SubFileList

	for _, subFileId in ipairs(subFileIdList) do
		local isFileCanShow = self.CheckFileCanShow(self, subFileId)

		if isFileCanShow then
			table.insert(viewDataList, {
				fileId = subFileId
			})
		end
	end

	return viewDataList
end

M.CheckFileHasUnlocked = function(self, fileId)
	local computerFileInfo = self:GetComputerFileInfo(fileId)

	return computerFileInfo == nil
end

M.GetComputerFileInfo = function(self, fileId)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	return computerUnlockInfo and computerUnlockInfo.UnlockFiles and computerUnlockInfo.UnlockFiles[fileId]
end

M.OnExitClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
end

M.OnMinClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
end

M.OnMaxClick = function(self)
end

M.OnCloseCrashClick = function(self)
	self.bindData.showCrashControl = 0
end

M.OnRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	store.m_Id = self.m_Id

	store:ShowPanel(self.selectedFileId)
end

M.OnComputerPreviewClose = function(self)
	self.bindData.tabRect:SelectIndexWithClose(-1)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.CheckFileCanShow = function(self, fileId)
	if not self.CheckFileHasUnlocked(self, fileId) then
		return false
	end

	if self.CheckFileHasDeleted(self, fileId) then
		return false
	end

	return true
end

M.CheckFileHasDeleted = function(self, targetFileId)
	local computerInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo.ComputerInfos[self.computerId]

	if computerInfo then
		for _, fileId in ipairs(computerInfo.DeleteFiles) do
			if fileId ~= targetFileId then
				return true
			end
		end
	end
end

M.CheckHasFile = function(self, fileType)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	local fileIdList = computerCfg.FileList

	for _, fileId in ipairs(fileIdList) do
		local isFileCanShow = self.CheckFileCanShow(self, fileId)

		if isFileCanShow then
			local computerFileCfg = LTConfig.ComputerFileConfig.GetConfig(fileId)
			local cfgFileType = computerFileCfg.FileType

			if array.contains(fileType, cfgFileType) then
				return true
			end
		end
	end

	return false
end
