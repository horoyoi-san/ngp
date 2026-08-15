local json = require("cjson/json")

if not gSKeyManager then
	local SKeyManager = {
		inited = false,
		updateRegistered = false,
		skeyErrorCodes = {
			[-3.0] = true,
			[-5.0] = true,
			[-4.0] = true,
			[-6.0] = true
		}
	}
end

function SKeyManager:GetCachedSKey()
	return self.skey
end

function SKeyManager:SetSKey(value)
	self.skey = value

	print_debug("[SKeyManager] SetSKey(" .. tostring(value) .. ")")
end

function SKeyManager:OnLogin()
	if not self.inited then
		self:Init()
	end

	local pid = gPlayerManager.infoLogin.bindData.pid
	self.roleID = ulong.tostring(pid)
end

function SKeyManager:Init()
	self.baseUrl = gCS.LuaUtils.GetGraffitoUrl()
	self.fetchAvatarUrl = self.baseUrl .. "/player/avatar?roleId=%s&skey=%s&targetId=%s"

	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, self.OnLoadingFinished)
	gTimeNotificationManager:RegisterConfigNewDay(self.OnNewDay)

	self.inited = true
end

function SKeyManager.OnLoadingFinished(eventId, switchType)
	local self = gSKeyManager

	self:GetSKeyOnLogin(1)
end

function SKeyManager:GetSKeyOnLogin(retryCount)
	if not gLuaDataManager.isNetworkAvailable then
		self:SetSKey(nil)

		if not self.updateRegistered then
			gLuaClient:RegisterDynamicUpdate("gSKeyManager", self)

			self.updateRegistered = true
		end

		return
	end

	if string.is_null_or_empty(gSKeyManager.skey) then
		gSKeyManager:QuerySkey(false, false, function (success, key)
			if success then
				gSKeyManager:CheckSkeyValid(key, 1)
			elseif retryCount > 0 then
				self:GetSKeyOnLogin(retryCount - 1)
			end
		end)
	end
end

function SKeyManager:Error(...)
	print_error("[SKeyManager] roleID", self.roleID, "skey", self.skey, ...)
end

function SKeyManager:QuerySkey(useLocalCache, useServerCache, callback)
	if useLocalCache and self.skey ~= nil then
		if callback then
			callback(true, self.skey)
		end

		return
	end

	gClientToAvatarDelegate:QuerySkey(not useServerCache).Callback = function (err, key)
		if err ~= LTConfig.MessageConfig.Ok then
			if err ~= LTConfig.MessageConfig.TimeOut and err ~= LTConfig.MessageConfig.Disconnect then
				self:Error("QuerySkey error:", gCS.Error.GetNameById(err))
			end

			if callback then
				callback(false, nil)
			end

			return
		end

		if string.is_null_or_empty(key) then
			self:Error("QuerySkey error: SKey is empty")

			if callback then
				callback(false, nil)
			end

			return
		end

		self:SetSKey(key)

		if callback then
			callback(true, key)
		end
	end
end

function SKeyManager:CheckSkeyValid(skey, retryCount)
	local url = gString.Format(self.fetchAvatarUrl, self.roleID, skey, self.roleID)

	local function httpCallback(isSuccess, data, code)
		if not isSuccess then
			self:CheckSkeyValid(self.skey, retryCount - 1)

			return
		end

		if string.is_null_or_empty(data) then
			self:Error("HttpGet", url, "failed with code", code)
			self:CheckSkeyValid(self.skey, retryCount - 1)

			return
		end

		data = json.decode(data)
		local errorCode = data.code

		if errorCode ~= 0 and self.skeyErrorCodes[errorCode] then
			if retryCount <= 0 then
				self:Error("CheckSkeyValid failed after retrying", data)

				return
			end

			self:SetSKey(nil)
			self:QuerySkey(false, false, function (success, key)
				if success then
					self:CheckSkeyValid(key, retryCount - 1)
				else
					self:Error("CheckSkeyValid failed to get a valid skey", data)
				end
			end)

			return
		end

		gImageManager:OnReceiveMyAvatar(data)
	end

	gCS.LuaUtils.HttpGet(url, httpCallback)
end

function SKeyManager:OnUpdate()
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	if string.is_null_or_empty(self.skey) then
		self:GetSKeyOnLogin(1)
	end

	gLuaClient:UnregisterDynamicUpdate("gSKeyManager")

	self.updateRegistered = false
end

function SKeyManager.OnNewDay()
	local self = gSKeyManager

	self:QuerySkey(false, false)
end

function SKeyManager:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:SetSKey(nil)

		self.roleID = nil
	end
end

gSKeyManager = SKeyManager

return SKeyManager
