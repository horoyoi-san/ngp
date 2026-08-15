local M = {
	SimpleInfos = {}
}

function M:SetInfo(data)
	data.ExpireTime = gCS.TimeManager.ServerUnixTime + LTConfig.GameConfig.SimplePlayerInfoClientCacheTime
	self.SimpleInfos[tostring(data.Pid)] = data
end

function M:GetInfo(pid)
	local pid = tostring(pid)
	local cached = self.SimpleInfos[pid]

	if self:Valid(cached) then
		return cached
	end

	return nil
end

function M:Valid(cached)
	if cached == nil then
		return false
	end

	local nowTime = gCS.TimeManager.ServerUnixTime

	if cached.ExpireTime < nowTime then
		self.SimpleInfos[tostring(cached.Pid)] = nil

		return false
	end

	return true
end

function M:Clear()
	return
end

gSimplePlayerInfoManager = M
