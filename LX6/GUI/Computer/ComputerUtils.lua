-- Original chunk: @Lua\LuaFiles\LX6\GUI\Computer\ComputerUtils.lua
-- Decompiled from: 00543_ComputerUtils.lua_4d0e0130bd19.luajit

local M = gComputerUtils or {}

M.GetComputerFileInfo = function(self, fileId)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	return computerUnlockInfo and computerUnlockInfo.UnlockFiles and computerUnlockInfo.UnlockFiles[fileId]
end

M.CheckFileHasUnlocked = function(self, fileId)
	local computerFileInfo = self:GetComputerFileInfo(fileId)

	return computerFileInfo == nil
end

M.CheckFileHasDeleted = function(self, computerId, targetFileId)
	local computerInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo.ComputerInfos[computerId]

	if computerInfo then
		for _, fileId in ipairs(computerInfo.DeleteFiles) do
			if fileId ~= targetFileId then
				return true
			end
		end
	end

	return false
end

M.CheckFileCanShow = function(self, computerId, fileId)
	if not self:CheckFileHasUnlocked(fileId) then
		return false
	end

	if self:CheckFileHasDeleted(computerId, fileId) then
		return false
	end

	return true
end

M.GetFileIconId = function(self, fileType)
	local iconId = nil

	if fileType ~= gClientConst.Computer_File_Type.Folder then
		iconId = LTConfig.ComputerConfig.FileTypeFolderIcon
	elseif fileType ~= gClientConst.Computer_File_Type.Picture then
		iconId = LTConfig.ComputerConfig.FileTypePictureIcon
	elseif fileType ~= gClientConst.Computer_File_Type.Video then
		iconId = LTConfig.ComputerConfig.FileTypeVideoIcon
	elseif fileType ~= gClientConst.Computer_File_Type.Text then
		iconId = LTConfig.ComputerConfig.FileTypeTextIcon
	elseif fileType ~= gClientConst.Computer_File_Type.PDF then
		iconId = LTConfig.ComputerConfig.FileTypePDFIcon
	elseif fileType ~= gClientConst.Computer_File_Type.App then
		iconId = LTConfig.ComputerConfig.FileAppIcon
	elseif fileType ~= gClientConst.Computer_File_Type.Word then
		iconId = LTConfig.ComputerConfig.FileAppIcon
	end

	return iconId or 0
end

M.AskComputerFileRead = function(self, computerFileId, isVideoFinish)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_FILE_READ, {
		fileId = computerFileId,
		isVideoFinish = isVideoFinish
	})

	gClientToGameDelegate:AskComputerFileRead(computerFileId, isVideoFinish).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.GetComputerEmailInfo = function(self, emailId)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	return computerUnlockInfo and computerUnlockInfo.UnlockEmails and computerUnlockInfo.UnlockEmails[emailId]
end

M.CheckEmailHasUnlocked = function(self, emailId)
	local computerEmailInfo = self:GetComputerEmailInfo(emailId)

	return computerEmailInfo == nil
end

M.CheckEmailHasDeleted = function(self, computerId, targetEmailId)
	local computerInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo.ComputerInfos[computerId]

	if computerInfo then
		for _, emailId in ipairs(computerInfo.DeleteEmails) do
			if emailId ~= targetEmailId then
				return true
			end
		end
	end

	return false
end

M.CheckEmailCanShow = function(self, computerId, emailId)
	if not self:CheckEmailHasUnlocked(emailId) then
		return false
	end

	if self:CheckEmailHasDeleted(computerId, emailId) then
		return false
	end

	return true
end

M.CheckEmailHasRead = function(self, emailId)
	local computerEmailInfo = self:GetComputerEmailInfo(emailId)

	return computerEmailInfo and computerEmailInfo.IsRead or false
end

gComputerUtils = M
