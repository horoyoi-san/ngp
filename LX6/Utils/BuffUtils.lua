-- Original chunk: @Lua\LuaFiles\LX6\Utils\BuffUtils.lua
-- Decompiled from: 00357_BuffUtils.lua_30ec9dc9b2ef.luajit

local BuffUtils = gBuffUtils or {}

BuffUtils.OnInit = function(self)
	if not self.Pid2BuffMap then
		self.Pid2BuffMap = {}
	end
end

BuffUtils.OnBeforeSwitchScene = function(self, switchType)
	self.Pid2BuffMap = {}
end

BuffUtils.OnRemoveUnit = function(pid)
	if gBuffUtils.Pid2BuffMap then
		gBuffUtils.Pid2BuffMap[pid] = {}
	end
end

BuffUtils.GetCSBuffList = function(pid)
	if gBuffUtils.Pid2BuffMap then
		return gBuffUtils.Pid2BuffMap[pid] or {}
	end

	return {}
end

BuffUtils.SyncHUDListBuffViewData = function(self, pid, _csBuffList)
	if not self.Pid2BuffMap then
		self.Pid2BuffMap = {}
	end

	if not self.Pid2BuffMap[pid] then
		self.Pid2BuffMap[pid] = {}
	end

	local csBuffList = {}

	if _csBuffList.Count then
		for i = 1, _csBuffList.Count do
			table.insert(csBuffList, _csBuffList[i - 1])
		end
	else
		csBuffList = _csBuffList
	end

	self.Pid2BuffMap[pid] = csBuffList or {}
end

BuffUtils.SyncHUDAddBuffViewData = function(self, pid, buffViewData)
	if not self.Pid2BuffMap then
		self.Pid2BuffMap = {}
	end

	if not self.Pid2BuffMap[pid] then
		self.Pid2BuffMap[pid] = {}
	end

	local csBuffList = self.Pid2BuffMap[pid]

	table.insert(csBuffList, buffViewData)
end

BuffUtils.SyncHUDRemoveBuffViewData = function(self, pid, instanceID)
	if not self.Pid2BuffMap then
		self.Pid2BuffMap = {}
	end

	if not self.Pid2BuffMap[pid] then
		self.Pid2BuffMap[pid] = {}
	end

	local csBuffList = self.Pid2BuffMap[pid]

	for idx, v in ipairs(csBuffList) do
		if v.InstanceId ~= instanceID then
			table.remove(csBuffList, idx)

			return
		end
	end
end

BuffUtils.SyncHUDUpdateBuffViewData = function(self, pid, buffViewData)
	if not self.Pid2BuffMap then
		self.Pid2BuffMap = {}
	end

	if not self.Pid2BuffMap[pid] then
		self.Pid2BuffMap[pid] = {}
	end

	local csBuffList = self.Pid2BuffMap[pid]

	for idx, v in ipairs(csBuffList) do
		if v.InstanceId ~= buffViewData.InstanceId then
			csBuffList[idx] = buffViewData

			return
		end
	end
end

BuffUtils.RefreshHUD = function(self, pid, isBoss)
	if isBoss then
		gMessageManager:SendMessage(gEventConstants.REFRESH_BOSSVIEW_BUFFS, pid)
	else
		gMessageManager:SendMessage(gEventConstants.REFRESH_HEADVIEW_BUFFS, pid)
	end
end

BuffUtils.OnBuffHideNameBar = function(self, pid, isHide)
end

BuffUtils.HasBuff = function(pid, buffID)
	return gCS.BuffUtils.HasBuff(pid, buffID)
end

BuffUtils.AddRemoveBuffHeadIcon = function(self, pid, isAdd, buffID)
	if isAdd ~= true then
		gHudMgr:AddBuffHeadIcon(pid, buffID)
	else
		gHudMgr:RemoveBuffHeadIcon(pid, buffID)
	end
end

BuffUtils.ReduceBuffTime = function(self, pid, instanceId, reduceTime)
	local serverTime = gCS.TimeManager:GetClientSeconds()
	local csBuffList = gBuffUtils.GetCSBuffList(pid)

	if csBuffList then
		for i = 1, #csBuffList do
			if csBuffList[i].InstanceId ~= instanceId then
				csBuffList[i].ExpireTime = Mathf.Max(serverTime, csBuffList[i].ExpireTime - reduceTime)
			end
		end
	end
end

gBuffUtils = BuffUtils

return BuffUtils
