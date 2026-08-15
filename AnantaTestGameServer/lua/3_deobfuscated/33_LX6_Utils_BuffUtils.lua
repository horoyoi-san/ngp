local BuffUtils = gBuffUtils or {}

function BuffUtils:OnInit()
	if not self.Pid2BuffMap then
		self.Pid2BuffMap = {}
	end
end

function BuffUtils:OnBeforeSwitchScene(switchType)
	self.Pid2BuffMap = {}
end

function BuffUtils.OnRemoveUnit(pid)
	if gBuffUtils.Pid2BuffMap then
		gBuffUtils.Pid2BuffMap[pid] = {}
	end
end

function BuffUtils.GetCSBuffList(pid)
	if gBuffUtils.Pid2BuffMap then
		return gBuffUtils.Pid2BuffMap[pid] or {}
	end

	return {}
end

function BuffUtils:SyncHUDListBuffViewData(pid, _csBuffList)
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

function BuffUtils:SyncHUDAddBuffViewData(pid, buffViewData)
	if not self.Pid2BuffMap then
		self.Pid2BuffMap = {}
	end

	if not self.Pid2BuffMap[pid] then
		self.Pid2BuffMap[pid] = {}
	end

	local csBuffList = self.Pid2BuffMap[pid]

	table.insert(csBuffList, buffViewData)
end

function BuffUtils:SyncHUDRemoveBuffViewData(pid, instanceID)
	if not self.Pid2BuffMap then
		self.Pid2BuffMap = {}
	end

	if not self.Pid2BuffMap[pid] then
		self.Pid2BuffMap[pid] = {}
	end

	local csBuffList = self.Pid2BuffMap[pid]

	for idx, v in ipairs(csBuffList) do
		if v.InstanceId == instanceID then
			table.remove(csBuffList, idx)

			return
		end
	end
end

function BuffUtils:SyncHUDUpdateBuffViewData(pid, buffViewData)
	if not self.Pid2BuffMap then
		self.Pid2BuffMap = {}
	end

	if not self.Pid2BuffMap[pid] then
		self.Pid2BuffMap[pid] = {}
	end

	local csBuffList = self.Pid2BuffMap[pid]

	for idx, v in ipairs(csBuffList) do
		if v.InstanceId == buffViewData.InstanceId then
			csBuffList[idx] = buffViewData

			return
		end
	end
end

function BuffUtils:RefreshHUD(pid, isBoss)
	if isBoss then
		gMessageManager:SendMessage(gEventConstants.REFRESH_BOSSVIEW_BUFFS, pid)
	else
		gMessageManager:SendMessage(gEventConstants.REFRESH_HEADVIEW_BUFFS, pid)
	end
end

function BuffUtils:OnBuffHideNameBar(pid, isHide)
	return
end

function BuffUtils.HasBuff(pid, buffID)
	return gCS.BuffUtils.HasBuff(pid, buffID)
end

function BuffUtils:AddRemoveBuffHeadIcon(pid, isAdd, buffID)
	if isAdd == true then
		gHudMgr:AddBuffHeadIcon(pid, buffID)
	else
		gHudMgr:RemoveBuffHeadIcon(pid, buffID)
	end
end

function BuffUtils:ReduceBuffTime(pid, instanceId, reduceTime)
	local serverTime = gCS.TimeManager:GetClientSeconds()
	local csBuffList = gBuffUtils.GetCSBuffList(pid)

	if csBuffList then
		for i = 1, #csBuffList do
			if csBuffList[i].InstanceId == instanceId then
				csBuffList[i].ExpireTime = Mathf.Max(serverTime, csBuffList[i].ExpireTime - reduceTime)
			end
		end
	end
end

gBuffUtils = BuffUtils

return BuffUtils
