-- Original chunk: @Lua\LuaFiles\LX6\GUI\Manager\AliOssManager.lua
-- Decompiled from: 00156_AliOssManager.lua_b83f53459a5a.luajit

C_AliOssManager = DefClass("C_AliOssManager", C_AliOssManager, nil)
local M = C_AliOssManager

M.ctor = function(self)
	self.reviewImageMap = {}
end

M.UploadFile = function(self, objectName, byteArray, contentType, publicRead, callback)
	publicRead = publicRead == false

	LX6.Utils.AliOssManager.Instance:UploadFile(objectName, byteArray, contentType, publicRead, callback)
end

M.DownloadPersonalFile = function(self, objectName, callback)
	LX6.Utils.AliOssManager.Instance:DownloadPersonalFile(objectName, callback)
end

M.DownloadCommonFile = function(self, objectName, callback)
	LX6.Utils.AliOssManager.Instance:DownloadCommonFile(objectName, callback)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.reviewImageMap = {}
	end
end

M.UploadImage = function(self, source, data, publicRead, callBack)
	if not source ~= nil then
		print_error("@linminghe Source Error")

		if callBack then
			callBack(false)
		end
	end

	if data ~= nil or data.Length ~= 0 then
		print_error("@linminghe UploadImage Error bytes is nil or empty")

		if callBack then
			callBack(false)
		end

		return
	end

	local objectName = string.format("%s_%s_%s.jpg", source, os.time(), math.random(1000, 9999))

	self:UploadFile(objectName, data, nil, publicRead, function (isSuccess, finalObjectName)
		if isSuccess and not publicRead then
			self.reviewImageMap[finalObjectName] = gClientConst.ReviewStatus.Reviewing
		end

		if callBack then
			callBack(isSuccess, finalObjectName)
		end
	end)
end

M.GetSpeechPresignedUrl = function(self, source, callback)
	local objectName = string.format("%s_%s_%s.wav", source, os.time(), math.random(1000, 9999))

	LX6.Utils.AliOssManager.Instance:GetSpeechPresignedUrl(objectName, function (presignedUrl, objectKey)
		if callback then
			callback(presignedUrl, objectKey)
		end
	end)
end

M.DownloadFileFromUrl = function(self, url, callback)
	LX6.Utils.AliOssManager.Instance:DownloadFileFromUrl(url, callback)
end

M.GetReviewStatus = function(self, objectName, callback)
	if self.reviewImageMap[objectName] then
		callback(self.reviewImageMap[objectName])

		return
	end

	LX6.Utils.AliOssManager.Instance:CheckFileExists(objectName, function (responseCode)
		if responseCode ~= 403 then
			return gClientConst.ReviewStatus.Rejected
		else
			callback(nil)
		end
	end)
end

M.CheckFileExists = function(self, objectName, callback)
	LX6.Utils.AliOssManager.Instance:CheckFileExists(objectName, function (responseCode)
		if callback then
			callback(responseCode ~= 200)
		end
	end)
end

M.SyncImageModeration = function(self, imageModerationResult)
	local objectName = imageModerationResult.ObjectKey
	local reviewStatus = imageModerationResult.Pass and gClientConst.ReviewStatus.Approved or gClientConst.ReviewStatus.Rejected
	self.reviewImageMap[objectName] = reviewStatus

	gMessageManager:SendMessage(gEventConstants.ON_IMAGE_MODERATION_SYNC, {
		objectName = objectName,
		reviewStatus = reviewStatus
	})
end

gAliOssManager = gAliOssManager or C_AliOssManager.new()
