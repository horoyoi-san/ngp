local json = require("cjson/json")
local MessageConfig = LTConfig.MessageConfig
local V3XingZheFileMgr = {
	enableEdit = true
}
local this = V3XingZheFileMgr
local requestBaseInfo, submitAvatar = nil

function V3XingZheFileMgr.Init()
	requestBaseInfo = gImageManager:GetBaseUrl() .. "/player/getProfile?roleId=%s&targetId=%s&skey=%s"
	submitAvatar = gImageManager:GetBaseUrl() .. "/player/avatar/update"
end

function V3XingZheFileMgr.RequestBaseInfo(targetId, cb)
	local skey = gSKeyManager:GetCachedSKey()

	if skey == nil then
		gSKeyManager:QuerySkey(false, false, function ()
			this.RequestBaseInfo(targetId, cb)
		end)

		return
	end

	local url = gString.Format(requestBaseInfo, this.RoleIdStr(), targetId, skey)
	local retryCount = 2

	local function callback(isSuccess, data, code)
		if not isSuccess then
			print_error("@linminghe：RequestBaseInfo", url, isSuccess, data, code)
			cb(nil)

			return
		end

		local data_lua = json.decode(data)

		if gSKeyManager.skeyErrorCodes[data_lua.code] then
			print_error("V3XingZheFileMgr.RequestBaseInfo skey error! url", url, " data_lua", data_lua, " code", code, " SKey", gSKeyManager:GetCachedSKey(), " retryCount", retryCount)

			if retryCount > 0 then
				retryCount = retryCount - 1

				gSKeyManager:QuerySkey(false, false, function ()
					skey = gSKeyManager:GetCachedSKey()
					url = gString.Format(requestBaseInfo, this.RoleIdStr(), targetId, skey)

					gCS.LuaUtils.HttpGet(url, callback)
				end)
			else
				cb(nil)
			end

			return
		elseif data_lua.code ~= 0 then
			print_error("V3XingZheFileMgr.RequestBaseInfo(" .. tostring(targetId) .. ")", isSuccess, data_lua, code)
			cb(nil)

			return
		end

		cb(data_lua.data)
	end

	gCS.LuaUtils.HttpGet(url, callback)
end

function V3XingZheFileMgr.RoleIdStr()
	return ulong.tostring(gPlayerManager.infoLogin.bindData.pid)
end

function V3XingZheFileMgr.RoleId()
	return gPlayerManager.infoLogin.bindData.pid
end

function V3XingZheFileMgr.GetMyHeadUnlockInfo()
	this.AvatarList = {}
	this.IconFrameList = {}

	gClientToGameDelegate:QueryPersonalZoneHeadExtendInfo().Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		local avatarList = data.UnlockedSystemHeadList

		if avatarList ~= nil then
			for i = 1, #avatarList do
				this.AvatarList[tostring(avatarList[i].Id)] = {
					unLock = true,
					isNew = not avatarList[i].HadInteracted
				}
			end
		end
	end
end

function V3XingZheFileMgr.SetEnableXingZhe(isClose)
	return
end

return V3XingZheFileMgr
