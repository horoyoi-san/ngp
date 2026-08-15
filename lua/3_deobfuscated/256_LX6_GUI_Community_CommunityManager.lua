local json = require("cjson/json")
local UXTime = LTUtils.UXTime
local CommunityManager = {
	enableCommunity = true,
	inited = false
}
local this = CommunityManager
local requestHotInfoUrl, requestNewInfoUrl, requestFollowInfoUrl, requestTopicListUrl, requestFollowListUrl, requestFanListUrl, requestUserInfo, requestUserDetail, requestInfoDetail, requestFirstComment, requestTopicDetail, requestMessage, requestMessagePoint, requestMoreReply, requestShieldList, requestAvatar, submitInfoUrl, submitLikeUrl, submitUnLikeUrl, submitFollow, submitUnFollow, submitDelete, submitComment, submitDeleteComment, submitLikeComment, submitUnLikeComment, submitReportInfo, submitReportComment, submitShield, submitUnShield = nil
local pageSize = 10

function CommunityManager.Init()
	requestHotInfoUrl = gImageManager:GetBaseUrl() .. "/moment/listHot?roleId=%s&page=%s&pageSize=%s&skey=%s"
	requestNewInfoUrl = gImageManager:GetBaseUrl() .. "/moment/listByServer?roleId=%s&page=%s&pageSize=%s&skey=%s"
	requestFollowInfoUrl = gImageManager:GetBaseUrl() .. "/moment/listByFollow?roleId=%s&page=%s&pageSize=%s&skey=%s"
	requestTopicListUrl = gImageManager:GetBaseUrl() .. "/topic/list?roleId=%s&skey=%s"
	requestFollowListUrl = gImageManager:GetBaseUrl() .. "/follow/list?roleId=%s&targetId=%s&page=%s&pageSize=%s&skey=%s"
	requestFanListUrl = gImageManager:GetBaseUrl() .. "/follow/listFans?roleId=%s&targetId=%s&page=%s&pageSize=%s&skey=%s"
	requestUserInfo = gImageManager:GetBaseUrl() .. "/moment/list?roleId=%s&targetId=%s&page=%s&pageSize=%s&skey=%s"
	requestUserDetail = gImageManager:GetBaseUrl() .. "/player/getProfile?roleId=%s&targetId=%s&skey=%s"
	requestInfoDetail = gImageManager:GetBaseUrl() .. "/moment/getOne?roleId=%s&momentId=%s&skey=%s"
	requestFirstComment = gImageManager:GetBaseUrl() .. "/moment/comment/list?roleId=%s&momentId=%s&sortBy=%s&page=%s&pageSize=%s&skey=%s"
	requestTopicDetail = gImageManager:GetBaseUrl() .. "/moment/listByTopic?roleId=%s&topicId=%s&orderby=%s&page=%s&pageSize=%s&skey=%s"
	requestMessage = gImageManager:GetBaseUrl() .. "/inform/get?roleId=%s&page=%s&pageSize=%s&skey=%s"
	requestMessagePoint = gImageManager:GetBaseUrl() .. "/inform/unread?roleId=%s&skey=%s"
	requestMoreReply = gImageManager:GetBaseUrl() .. "/moment/comment/subList?roleId=%s&commentId=%s&page=%s&pageSize=%s&skey=%s"
	requestShieldList = gImageManager:GetBaseUrl() .. "/black/list?roleId=%s&skey=%s"
	requestAvatar = gImageManager:GetBaseUrl() .. "/player/avatar?roleId=%s&targetId=%s&skey=%s"
	submitInfoUrl = gImageManager:GetBaseUrl() .. "/moment/add"
	submitLikeUrl = gImageManager:GetBaseUrl() .. "/moment/like"
	submitUnLikeUrl = gImageManager:GetBaseUrl() .. "/moment/cancelLike"
	submitFollow = gImageManager:GetBaseUrl() .. "/follow/add"
	submitUnFollow = gImageManager:GetBaseUrl() .. "/follow/cancel"
	submitDelete = gImageManager:GetBaseUrl() .. "/moment/del"
	submitComment = gImageManager:GetBaseUrl() .. "/moment/comment/add"
	submitDeleteComment = gImageManager:GetBaseUrl() .. "/moment/comment/del"
	submitLikeComment = gImageManager:GetBaseUrl() .. "/moment/comment/like"
	submitUnLikeComment = gImageManager:GetBaseUrl() .. "/moment/comment/cancelLike"
	submitReportInfo = gImageManager:GetBaseUrl() .. "/moment/report"
	submitReportComment = gImageManager:GetBaseUrl() .. "/moment/comment/report"
	submitShield = gImageManager:GetBaseUrl() .. "/black/add"
	submitUnShield = gImageManager:GetBaseUrl() .. "/black/remove"
	this.inited = true
end

function CommunityManager.RequestHotInfo(page, cb)
	local url = gString.Format(requestHotInfoUrl, this.RoleId(), page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestHotInfo", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestHotInfo", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestNewInfo(page, cb)
	local url = gString.Format(requestNewInfoUrl, this.RoleId(), page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestNewInfo", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestNewInfo", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestFollowInfo(page, cb)
	local url = gString.Format(requestFollowInfoUrl, this.RoleId(), page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestFollowInfo", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestFollowInfo", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestFollowList(id, page, cb)
	local url = gString.Format(requestFollowListUrl, this.RoleId(), id, page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestFollowList", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestFollowList", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestFanList(id, page, cb)
	local url = gString.Format(requestFanListUrl, this.RoleId(), id, page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestFanList", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestFanList", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitLike(id, cb)
	gCS.LuaUtils.HttpPost(submitLikeUrl, {
		roleId = this.RoleId(),
		momentId = id,
		skey = gSKeyManager:GetCachedSKey()
	}, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitLike", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitLike", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitUnLike(id, cb)
	gCS.LuaUtils.HttpPost(submitUnLikeUrl, {
		roleId = this.RoleId(),
		momentId = id,
		skey = gSKeyManager:GetCachedSKey()
	}, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitUnLike", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitUnLike", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitInfo(imgList, text, cb)
	gCS.LuaUtils.HttpPost(submitInfoUrl, {
		authorityType = 1,
		imgList = imgList,
		roleId = this.RoleId(),
		text = text,
		skey = gSKeyManager:GetCachedSKey()
	}, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitInfo", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			cb(data_lua)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitFollow(id, cb)
	gCS.LuaUtils.HttpPost(submitFollow, {
		roleId = this.RoleId(),
		targetId = id,
		skey = gSKeyManager:GetCachedSKey()
	}, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitFollow", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitFollow", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitUnFollow(id, cb)
	gCS.LuaUtils.HttpPost(submitUnFollow, {
		roleId = this.RoleId(),
		targetId = id,
		skey = gSKeyManager:GetCachedSKey()
	}, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitUnFollow", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitUnFollow", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestTopicListInfo(cb)
	local url = gString.Format(requestTopicListUrl, this.RoleId(), gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestTopicListInfo", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestTopicListInfo", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestUserInfo(id, page, cb)
	local url = gString.Format(requestUserInfo, this.RoleId(), id, page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestUserInfo", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestUserInfo", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestUserDetail(id, cb)
	local url = gString.Format(requestUserDetail, this.RoleId(), id, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestUserDetail", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestUserDetail", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitDelete(id, cb)
	gCS.LuaUtils.HttpPost(submitDelete, {
		roleId = this.RoleId(),
		momentId = id,
		skey = gSKeyManager:GetCachedSKey()
	}, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitDelete", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitDelete", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestInfoDetail(id, cb)
	local url = gString.Format(requestInfoDetail, this.RoleId(), id, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestInfoDetail", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			cb(data_lua.code)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestFirstComment(id, page, cb)
	local url = gString.Format(requestFirstComment, this.RoleId(), id, "hot", page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestFirstComment", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestFirstComment", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitComment(id, replyId, text, cb)
	local bs = {
		roleId = this.RoleId(),
		momentId = id,
		text = text,
		skey = gSKeyManager:GetCachedSKey()
	}

	if replyId ~= "" then
		bs.replyCommentId = replyId
	end

	gCS.LuaUtils.HttpPost(submitComment, bs, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitComment", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			cb(data_lua)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitDeleteComment(id, cb)
	local bs = {
		roleId = this.RoleId(),
		commentId = id,
		skey = gSKeyManager:GetCachedSKey()
	}

	gCS.LuaUtils.HttpPost(submitDeleteComment, bs, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitDeleteComment", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitDeleteComment", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitLikeComment(id, cb)
	local bs = {
		roleId = this.RoleId(),
		commentId = id,
		skey = gSKeyManager:GetCachedSKey()
	}

	gCS.LuaUtils.HttpPost(submitLikeComment, bs, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitLikeComment", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitLikeComment", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitUnLikeComment(id, cb)
	local bs = {
		roleId = this.RoleId(),
		commentId = id,
		skey = gSKeyManager:GetCachedSKey()
	}

	gCS.LuaUtils.HttpPost(submitUnLikeComment, bs, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitUnLikeComment", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitUnLikeComment", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestTopicDetail(id, page, cb)
	local url = gString.Format(requestTopicDetail, this.RoleId(), id, "new", page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestTopicDetail", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestTopicDetail", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestMessage(page, cb)
	local url = gString.Format(requestMessage, this.RoleId(), page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestMessage", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestMessage", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestMessagePoint(cb)
	if not this.inited then
		this.Init()
	end

	local url = gString.Format(requestMessagePoint, this.RoleId(), gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_warn("小白：RequestMessagePoint", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_warn("小白：RequestMessagePoint", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestMoreReply(id, page, cb)
	local url = gString.Format(requestMoreReply, this.RoleId(), id, page, pageSize, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestMoreReply", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestMoreReply", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitReportInfo(type, reason, momentId, cb)
	local bs = {
		roleId = this.RoleId(),
		type = type,
		reason = reason,
		momentId = momentId,
		skey = gSKeyManager:GetCachedSKey()
	}

	gCS.LuaUtils.HttpPost(submitReportInfo, bs, function (isSuccess, data, code)
		local data_lua = json.decode(data)

		if not isSuccess then
			print_error("小白：SubmitReportInfo", isSuccess, data, code)
			cb(nil)

			return
		end

		if data_lua.code ~= 0 then
			print_error("小白：SubmitReportInfo", isSuccess, data, code)
			cb(data_lua.code, data_lua.data.left)

			return
		end

		cb(data_lua.code)
	end)
end

function CommunityManager.SubmitReportComment(type, reason, commentId, cb)
	local bs = {
		roleId = this.RoleId(),
		type = type,
		reason = reason,
		commentId = commentId,
		skey = gSKeyManager:GetCachedSKey()
	}

	gCS.LuaUtils.HttpPost(submitReportComment, bs, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitReportComment", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitReportComment", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SubmitShield(targetId, cb)
	local bs = {
		roleId = this.RoleId(),
		targetId = targetId,
		skey = gSKeyManager:GetCachedSKey()
	}

	gCS.LuaUtils.HttpPost(submitShield, bs, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：SubmitShield", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：SubmitShield", isSuccess, data, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.RequestShieldList(cb)
	local url = gString.Format(requestShieldList, this.RoleId(), gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestShieldList", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestShieldList", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end)
end

function CommunityManager.SetEnableCommunity(isOpen)
	this.enableCommunity = isOpen
end

function CommunityManager.RequestAvatar(roleId, cb)
	local url = gString.Format(requestAvatar, this.RoleId(), roleId, gSKeyManager:GetCachedSKey())

	gCS.LuaUtils.HttpGet(url, function (isSuccess, data, code)
		if not isSuccess then
			print_error("小白：RequestAvatar", isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if data_lua.code ~= 0 then
			print_error("小白：RequestAvatar", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data.avatar)
	end)
end

function CommunityManager.SetServers(servers)
	this.servers = servers
end

function CommunityManager.IsMe(id)
	return this.RoleId() == tostring(id)
end

function CommunityManager.RoleId()
	return tostring(gPlayerManager.infoLogin.bindData.pid)
end

function CommunityManager.GetInfoTime(time)
	if not time then
		return LTConfig.TextScriptTextConfig.GetConfig(89900152).Text
	end

	local deltSecond = UXTime.GetNowUnixTime() - math.floor(time / 1000)
	local daySecond = 86400

	if deltSecond >= 0 then
		if deltSecond < 60 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900153).Text
		elseif deltSecond < 3600 then
			return math.floor(deltSecond / 60) .. LTConfig.TextScriptTextConfig.GetConfig(89900154).Text
		elseif deltSecond < daySecond then
			return math.floor(deltSecond / 3600) .. LTConfig.TextScriptTextConfig.GetConfig(89900155).Text
		end
	end

	return this.DateFormat("%d-%d-%d", time)
end

function CommunityManager.DateFormat(format, time)
	local date = UXTime.UnixTimeToDateTime(math.floor(time / 1000))

	return gString.Format(format, date.Year, date.Month, date.Day)
end

return CommunityManager
