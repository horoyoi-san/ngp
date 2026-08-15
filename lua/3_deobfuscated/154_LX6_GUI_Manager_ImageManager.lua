local MessageConfig = LTConfig.MessageConfig
local json = require("cjson/json")
local PersonalZoneHeadType = UX.Game.PersonalZoneHeadType
local ImageAvatarConfig = LTConfig.ImageAvatarConfig
local UXTime = LTUtils.UXTime
local M = {
	isInit = false,
	useWeed = false,
	useFP = true,
	photos = {},
	AuditStatus = {
		Passed = 1,
		Fail = -1,
		InAudit = 0,
		Report = -2,
		NotSubmit = 2
	},
	AuditStatusView = {
		Passed = 3,
		Fail = 1,
		InAudit = 2,
		Report = 4,
		NotSubmit = 0
	},
	headAvatarCache = {},
	defaultGraffito = {}
}
local UploadUrl = "https://wanproxy-web.127.net/%s/%s?complete=true&offset=0&version=1.0"
local UploadFpUrl = "https://fp.ps.netease.com/%s/file/new/"
local BaseUrl = "http://192.168.131.156:88/l18"
local NosTokenUrl, FpTokenUrl, FpTokenWithoutRoleIdUrl, AttachGraffitoUrl, FetchGraffitosUrl, DeleteGraffitoUrl, AttachAvatarUrl, SubmitAuditUrl, ReportUrl, GetImageDetailUrl, AttachCustomMusicUrl, DeleteCustomMusicUrl, FetchCustomMusicListUrl, ModifyCustomMusicNameUrl, FetchCustomMusicDetailUrl, FetchAvatarUrl, FetchAvatarsUrl, RoleId = nil

function M:Init()
	BaseUrl = gCS.LuaUtils.GetGraffitoUrl()
	NosTokenUrl = BaseUrl .. "/common/nos_token?roleId=%s&skey=%s"
	FpTokenUrl = BaseUrl .. "/common/getFpPassToken?roleId=%s&skey=%s"
	FpTokenWithoutRoleIdUrl = BaseUrl .. "/common/getFpPassTokenWithoutRoleId?time=%s&token=%s"
	AttachCustomMusicUrl = BaseUrl .. "/song/add"
	DeleteCustomMusicUrl = BaseUrl .. "/song/del"
	FetchCustomMusicListUrl = BaseUrl .. "/song/list?roleId=%s&skey=%s&targetId=%s"
	ModifyCustomMusicNameUrl = BaseUrl .. "/song/modifySongName"
	FetchCustomMusicDetailUrl = BaseUrl .. "/song/detail?roleId=%s&skey=%s&songIds=%s"
	FetchAvatarUrl = BaseUrl .. "/player/avatar?roleId=%s&skey=%s&targetId=%s"
	FetchAvatarsUrl = BaseUrl .. "/player/avatars?roleId=%s&skey=%s&targetId=%s"
	AttachAvatarUrl = BaseUrl .. "/player/avatar/update"
	RoleId = gPlayerManager.infoLogin.bindData.pid
	RoleId = ulong.tostring(RoleId)

	if not self.isInit then
		gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.OnAutoReleaseAvatar)
		gMessageManager:AddMessageListener(gEventConstants.UPDATE_HEADINFO, self.UpdateHeadInfo)
	end

	self.useWeed = gLoginManager:CheckIsTgsPack()
	self.isInit = true
end

function M:GetBaseUrl()
	return BaseUrl
end

function M:GetSKey()
	return gSKeyManager:GetCachedSKey()
end

function M:OnReceiveMyAvatar(data)
	self.avatar = data.data.avatar

	self:GetMyHeadIconInfo()
end

function M:QueryTokenByTimestamp(cb)
	local timestamp = UXTime.GetNowUnixTime()

	gClientToLoginDelegate:RequestFpPassToken(timestamp).Callback = function (err, token)
		if err ~= MessageConfig.Ok then
			print_error("QueryTokenByTimestamp", gCS.Error.GetNameById(err))

			return
		end

		if cb then
			cb(err, timestamp, token)
		end
	end
end

function M.UpdateHeadInfo(eventId, data)
	if data ~= gPlayerManager.infoLogin.bindData.pid then
		return
	end

	M:GetMyHeadIconInfo()
end

function M:GetMyHeadIconInfo()
	gClientToGameDelegate:QueryPersonalZoneHeadExtendInfo().Callback = function (err, data)
		if err == MessageConfig.Ok then
			self.myHeadIconInfo = data.PzHeadInfo
			gPlayerManager.infoLogin.bindData.infoPzHeadInfo = self.myHeadIconInfo

			gMessageManager:SendMessage(gEventConstants.UPDATE_HEADINFO_REFRESHVIEW)
		end
	end
end

function M:UploadNormalImage(data, cb)
	if self.useWeed then
		gCS.LuaUtils.HttpPostWeedFile(data, function (isSuccess, result, errCode)
			print_debug("[ImageManager] UploadNormalImage", isSuccess, result, errCode)

			if not isSuccess then
				cb(false, nil)
			else
				cb(true, result)
			end
		end)

		return
	end

	gSKeyManager:QuerySkey(true, true, function (success, key)
		if not success then
			return
		end

		RoleId = ulong.tostring(gPlayerManager.infoLogin.bindData.pid)

		self:GetToken(function (model)
			if model == nil or data == nil then
				cb(false, nil)
			else
				self:UploadImage(model, data, function (url)
					cb(true, url)
				end)
			end
		end)
	end)
end

function M:GetToken(cb)
	local url = gString.Format(self.useFP and FpTokenUrl or NosTokenUrl, RoleId, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, model, errCode)
		if not isSuccess then
			print_error("fp/nos token", isSuccess, model, errCode)
			cb(nil)

			return
		end

		local nosModel = json.decode(model)

		if nosModel.code ~= 0 then
			print_error("fp/nos token", isSuccess, model, errCode)
			cb(nil)

			return
		end

		cb(nosModel.data)
	end)
end

function M:GetFpToken(cb)
	if RoleId == nil then
		self:GetFPTokenWithoutRoleId(cb)
	elseif self.useFP then
		self:GetToken(cb)
	else
		print_error("GetFpToken failed useFP:", self.useFP)
	end
end

function M:GetFPTokenWithoutRoleId(cb)
	self:QueryTokenByTimestamp(function (err, timeStamp, token)
		if err == MessageConfig.Ok then
			if not FpTokenWithoutRoleIdUrl then
				FpTokenWithoutRoleIdUrl = gCS.LuaUtils.GetGraffitoUrl() .. "/common/getFpPassTokenWithoutRoleId?time=%s&token=%s"
			end

			local url = gString.Format(FpTokenWithoutRoleIdUrl, timeStamp, token)

			gCS.LuaUtils.HttpGet(url, function (isSuccess, model, errCode)
				if not isSuccess then
					print_error("FP token", isSuccess, model, errCode)
					cb(nil)

					return
				end

				local fpModel = json.decode(model)

				if fpModel.code ~= 0 then
					print_error("FP token", isSuccess, model, errCode)
					cb(nil)

					return
				end

				cb(fpModel.data)
			end)
		else
			gDisplayMessageMgr:ShowMessage(err)
		end
	end)
end

function M:UploadImage(model, data, cb)
	if self.useFP then
		local url = gString.Format(UploadFpUrl, model.project)

		gCS.LuaUtils.HttpPost(url, data, {
			Authorization = model.token
		}, function (isSuccess, result, errCode)
			if not isSuccess then
				print_error("upload image", isSuccess, result, errCode)
				cb(nil)

				return
			end

			local resultJson = json.decode(result)

			if not resultJson and not resultJson.url then
				print_error("upload image", isSuccess, result, errCode)
				cb(nil)

				return
			end

			cb(resultJson.url)
		end)
	else
		local url = gString.Format(UploadUrl, model.bucketname, model.objectname)

		gCS.LuaUtils.HttpPost(url, data, {
			["Content-Type"] = "image/png",
			["x-nos-token"] = model.token
		}, function (isSuccess, result, errCode)
			if not isSuccess then
				print_error("upload image", isSuccess, result, errCode)
				cb(nil)

				return
			end

			local fetchUrl = model.prefix .. model.objectname

			cb(fetchUrl)
		end)
	end
end

function M:GetHeadIconByHeadIconInfo(headIconInfo, sexType, isMe)
	if headIconInfo == nil then
		if sexType == UX.Game.SexType.Male or sexType == UX.Game.SexType.UnKnow then
			return PersonalZoneHeadType.System, ImageAvatarConfig.AdultMH
		else
			return PersonalZoneHeadType.System, ImageAvatarConfig.AdultFH
		end
	end

	if headIconInfo.HeadType == PersonalZoneHeadType.Custom then
		if isMe then
			if not string.is_null_or_empty(self.avatar) then
				return PersonalZoneHeadType.Custom, self.avatar
			end
		elseif not string.is_null_or_empty(headIconInfo.CustomHeadPath) then
			return PersonalZoneHeadType.Custom, headIconInfo.CustomHeadPath
		end
	end

	if headIconInfo.SystemHeadId ~= nil and not ulong.equals(headIconInfo.SystemHeadId, 0) then
		return PersonalZoneHeadType.System, headIconInfo.SystemHeadId
	end

	if sexType == UX.Game.SexType.Male or sexType == UX.Game.SexType.UnKnow then
		return PersonalZoneHeadType.System, ImageAvatarConfig.AdultMH
	else
		return PersonalZoneHeadType.System, ImageAvatarConfig.AdultFH
	end
end

function M:SetHeadIcon(avatarSet, headInfo, sexType, isMe, cb, cache, size)
	local type, path = self:GetHeadIconByHeadIconInfo(headInfo, sexType, isMe)
	avatarSet.isShowTexIcon = type == PersonalZoneHeadType.Custom
	avatarSet.frameTypeId = headInfo.HeadBox

	if type == PersonalZoneHeadType.System then
		avatarSet.headSpriteName = ""
		avatarSet.headSpriteId = tonumber(path)
	end

	local imgSize = gLuaEnum.DefaultHeadIconSize.largeSize_128

	if size then
		imgSize = size
	end

	if type == PersonalZoneHeadType.Custom then
		if cache and not gCS.LuaUtils.IsNull(cache[path]) then
			avatarSet.textureObj = cache[path]

			if cb then
				cb(cache[path], path)
			end

			return
		end

		gCS.GuiUtils.GetImageInCacheWWW(path, function (tex)
			avatarSet.textureObj = tex

			if cb then
				cb(tex, path)
			end
		end, imgSize)
	end
end

function M:SetHeadIconAutoRelease(avatarSet, headInfo, sexType, isMe, panelId, size, cb)
	local type, path = self:GetHeadIconByHeadIconInfo(headInfo, sexType, isMe)
	avatarSet.isShowTexIcon = type == PersonalZoneHeadType.Custom
	avatarSet.frameTypeId = headInfo ~= nil and headInfo.HeadBox or 0
	local imgSize = gLuaEnum.DefaultHeadIconSize.largeSize_128

	if size then
		imgSize = size
	end

	if type == PersonalZoneHeadType.System then
		avatarSet.headSpriteName = ""
		avatarSet.headSpriteId = tonumber(path)

		if cb then
			cb()
		end
	end

	if type == PersonalZoneHeadType.Custom then
		if not self.headAvatarCache[panelId] then
			self.headAvatarCache[panelId] = {}
		end

		local cache = self.headAvatarCache[panelId]

		if cache then
			if cache[path] then
				if not gCS.LuaUtils.IsNull(cache[path][imgSize]) then
					avatarSet.textureObj = cache[path][imgSize]

					return
				else
					for i, v in pairs(cache[path]) do
						if self:CanUseSize(imgSize, i) then
							avatarSet.textureObj = cache[path][imgSize]

							return
						end
					end
				end
			else
				cache[path] = {}
			end
		end

		local cacheKey = panelId

		gCS.GuiUtils.GetImageInCacheWWW(path, function (tex)
			avatarSet.textureObj = tex
			self.headAvatarCache[cacheKey][path][imgSize] = tex

			if cb then
				cb()
			end
		end, imgSize)
	end
end

function M:CanUseSize(tryGetSize, cacheSize)
	if gLuaEnum.DefaultHeadIconSize.minSize_32 <= tryGetSize and tryGetSize <= gLuaEnum.DefaultHeadIconSize.xlSize_512 and gLuaEnum.DefaultHeadIconSize.minSize_32 <= cacheSize and cacheSize <= gLuaEnum.DefaultHeadIconSize.xlSize_512 and tryGetSize <= cacheSize then
		return true
	end
end

function M.OnAutoReleaseAvatar(eventId, data)
	local panelId = data

	if M.headAvatarCache[panelId] then
		local panelAvatarCache = M.headAvatarCache[panelId]

		for i, v in pairs(panelAvatarCache) do
			for k, j in pairs(v) do
				UnityEngine.GameObject.Destroy(j)
			end
		end

		M.headAvatarCache[panelId] = nil
	end
end

function M:RequestAddMusic(index, name, data, cb)
	self:RequestAddData(AttachCustomMusicUrl, {
		index = index,
		songName = name
	}, data, function (result, params, url, id)
		cb(result, url, id)
	end)
end

function M:RequestModifyMusicName(index, name, cb)
	self:RequestUpdateInfo(ModifyCustomMusicNameUrl, {
		index = index,
		songName = name
	}, cb)
end

function M:RequestDeleteMusic(index, cb)
	self:RequestUpdateInfo(DeleteCustomMusicUrl, {
		index = index
	}, cb)
end

function M:RequestGetMusicList(checkCacheCb, cb)
	return
end

function M:RequestAddData(attachUrl, params, data, cb)
	self:GetToken(function (model)
		if model == nil or data == nil then
			cb(false, params)

			return
		end

		self:UploadData(model, data, function (url)
			if url == nil then
				cb(false, params)

				return
			end

			local preParams = {
				roleId = tostring(gPlayerManager.infoLogin.bindData.pid),
				skey = gSKeyManager:GetCachedSKey()
			}

			self:AttachData(attachUrl, table.combine(preParams, params, {
				url = url
			}), function (id)
				cb(true, params, url, id)
			end)
		end)
	end)
end

function M:RequestUpdateInfo(updateUrl, infos, cb)
	local preParams = {
		roleId = RoleId,
		skey = gSKeyManager:GetCachedSKey()
	}

	gCS.LuaUtils.HttpPost(updateUrl, table.combine(preParams, infos), function (isSuccess, data, code)
		if not isSuccess then
			print_error("RequestUpdateInfo", isSuccess, data, code)
			cb(nil)

			return
		end

		local model = json.decode(data)

		if model.code ~= 0 then
			print_error("RequestUpdateInfo", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data)
	end)
end

function M:UploadData(model, data, cb)
	if self.useFP then
		local url = gString.Format(UploadFpUrl, model.project)

		gCS.LuaUtils.HttpPost(url, data, {
			Authorization = model.token
		}, function (isSuccess, result, errCode)
			if not isSuccess then
				print_error("UploadData", isSuccess, result, errCode)
				cb(nil)

				return
			end

			local resultJson = json.decode(result)

			if not resultJson and not resultJson.url then
				print_error("UploadData", isSuccess, result, errCode)
				cb(nil)

				return
			end

			cb(resultJson.url)
		end)
	else
		local url = gString.Format(UploadUrl, model.bucketname, model.objectname)

		gCS.LuaUtils.HttpPost(url, data, {
			["Content-Type"] = "image/png",
			["x-nos-token"] = model.token
		}, function (isSuccess, result, errCode)
			if not isSuccess then
				print_error("UploadData", isSuccess, result, errCode)
				cb(nil)

				return
			end

			local fetchUrl = model.prefix .. model.objectname

			cb(fetchUrl)
		end)
	end
end

function M:DownloadData(url, cb)
	gCS.LuaUtils.HttpGetRaw(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("DownloadData", isSuccess, code)
			cb(nil)

			return
		end

		cb(data)
	end)
end

function M:AttachData(attachUrl, params, cb)
	gCS.LuaUtils.HttpPost(attachUrl, params, function (isSuccess, data, code)
		if not isSuccess then
			print_error("attach data", isSuccess, data, code)
			cb(nil)

			return
		end

		local model = json.decode(data)

		if model.code ~= 0 then
			print_error("attach data", isSuccess, model, code)
			cb(nil)

			return
		end

		local id = model.data.id

		cb(id)
	end)
end

function M:FetchData(fetchUrl, checkCacheCb, cb)
	gCS.LuaUtils.HttpGet(fetchUrl, function (isSuccess, data, code)
		if not isSuccess then
			print_error("FetchData:", fetchUrl, isSuccess, data, code)
			cb(nil)

			return
		end

		local model = json.decode(data)

		if model.code ~= 0 then
			print_error("FetchData", fetchUrl, isSuccess, model, code)
			cb(nil)

			return
		end

		local list = model.data.list

		for i = 1, #list do
			local cacheData = checkCacheCb and checkCacheCb(list[i].id)

			if cacheData then
				cb(cacheData, list[i])
			elseif not string.is_null_or_empty(list[i].url) then
				self:DownloadData(list[i].url, function (data)
					cb(data, list[i])
				end)
			end
		end
	end)
end

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	RoleId = nil
	self.graffitoList = {}
	self.graffitoId2InfoList = {}
	self.avatar = nil
	self.myHeadIconInfo = nil
	self.photos = {}
end

function M:GetWWWImageInCache(url, isVideo, cb, size)
	if string.is_null_or_empty(url) then
		return
	end

	local isThumbnail = size ~= nil
	size = not size and "full" or gString.Format("%d*%d", size.x, size.y)

	if not self.imgTexCache then
		self.imgTexCache = {}
	end

	if not self.imgTexCache[url] then
		self.imgTexCache[url] = {}
	end

	if not self.imgTexCache[url][size] then
		self.imgTexCache[url][size] = {}
	end

	local cacheData = self.imgTexCache[url][size]

	if self.imgTexCache[url][size] and self.imgTexCache[url][size].count and self.imgTexCache[url][size].tex ~= nil then
		cacheData.count = cacheData.count + 1

		if cb then
			cb(cacheData.tex, url)
		end
	else
		gCS.GuiUtils.GetImageInCacheWWW(url, function (tex)
			if not tex then
				print_error("@linminghe GetImageInCacheWWW error call back texture is null", url)

				return
			end

			cacheData.tex = tex
			cacheData.count = cacheData.count or 1

			if cb then
				cb(tex, url)
			end
		end, 0, isThumbnail, size, isVideo)
	end
end

gImageManager = M
