local MessageConfig = LTConfig.MessageConfig
local RaidUtils = UX.Game.RaidUtils
local M = {
	isSendingSwitchRaidRpc = false
}

function DoCallBack(callBack)
	if callBack == nil then
		return
	end

	if type(callBack) == "userdata" then
		callBack:DynamicInvoke()
	elseif type(callBack) == "function" then
		callBack()
	end
end

function M:AskEnterHouse(callBack)
	return
end

function M:AskPublicSwitchToPublicScene(raidId, mapEntranceId, successCb, failedCb)
	if not RaidUtils.CanSwitchPublicScene(raidId) then
		if failedCb then
			failedCb()
		end

		return
	end

	gUIUtils:CheckCanSwitchScene(function ()
		if self.isSendingSwitchRaidRpc then
			if failedCb then
				failedCb()
			end

			return
		end

		gCS.MyPlayerManager.PlayerUnit:StopMove()

		self.isSendingSwitchRaidRpc = true

		gClientToGameDelegate:AskPublicSwitchToPublicScene(raidId, false, mapEntranceId).Callback = function (err)
			self.isSendingSwitchRaidRpc = false

			if err == MessageConfig.Ok then
				if successCb then
					successCb()
				end
			else
				gDisplayMessageMgr:ShowMessage(err)

				if failedCb then
					failedCb()
				end
			end
		end
	end)
end

function M:AskEnterRaidByRaidId(RaidId, wayPoint, xAxis, yAxis)
	if self.isSendingSwitchRaidRpc then
		return
	end

	for i = 0, LTConfig.MapentranceConfig.count - 1 do
		local entranceConfig = LTConfig.MapentranceConfig.LoadAt(i)

		if entranceConfig.RaidId == gSceneDataMgr.CurrentRaidId and entranceConfig.JiguanRaidID == RaidId then
			self:AskEnterRaidByMapEntrance(entranceConfig.Id, wayPoint, xAxis, yAxis)

			return
		end
	end

	print_error("RpcUtils AskEnterRaidByRaidId: Cannot find raidMapEntrance by targetRaidId", RaidId, wayPoint)
end

function M:AskEnterRaidByMapEntrance(mapEntranceId, wayPoint, xAxis, yAxis)
	gLoadingManager:Quick_EnterExitRoom(mapEntranceId, function ()
		gCS.MyPlayerManager.PlayerUnit:StopMove()

		self.isSendingSwitchRaidRpc = true

		gClientToGameDelegate:AskEnterRaidByMapEntrance(mapEntranceId).Callback = function (err)
			self.isSendingSwitchRaidRpc = false

			if err == MessageConfig.Ok then
				gCS.CameraDataMgr.cinemachineManager:SetPrepareCameraXYAxis(xAxis, yAxis)
				gCS.CameraDataMgr.cinemachineManager:SetCameraXYAxisValue(xAxis, yAxis, 0)
			else
				gLoadingManager:CancelPreCover()
				gDisplayMessageMgr:ShowMessage(err)
			end
		end
	end)
end

function M:AskEnterQuestSceneRaid()
	gClientToGameDelegate:AskEnterQuestSceneRaid()
end

local CommandQueueList = {}

function M:UpdateRetryRpc()
	for _, v in pairs(CommandQueueList) do
		local CommandQueue = v

		for m, n in pairs(v) do
			self:RetryRpc(CommandQueue, m)
		end
	end
end

function M:RetryRpc(CommandQueue, funcName, isReconnect)
	if table.isNilOrEmpty(CommandQueue[funcName]) then
		if CommandQueue[funcName] then
			CommandQueue[funcName].isInvoking = nil
		end

		CommandQueue[funcName] = nil

		return
	end

	local funcInfo = CommandQueue[funcName][1]

	if funcInfo == nil then
		CommandQueue[funcName].isInvoking = nil
		CommandQueue[funcName].isWaitingReconnect = nil

		return
	end

	if CommandQueue[funcName].isWaitingReconnect and not isReconnect then
		return
	end

	if not CommandQueue[funcName].isWaitingReconnect and isReconnect then
		return
	end

	if CommandQueue[funcName].isInvoking then
		return
	end

	self:TryInvokeNextFunc(CommandQueue, funcName)
end

function M:SendLostPackAgain()
	for _, v in pairs(CommandQueueList) do
		local CommandQueue = v

		for m, n in pairs(v) do
			self:RetryRpc(CommandQueue, m, true)
		end
	end
end

function M:SafeQueueAsk(target, funcName, cb, otherSettings, ...)
	local canCombine = false
	local reconnectSendAgainTime = false
	local dontSendWhenPanelClose = nil
	local argsCanNil = false

	if otherSettings then
		canCombine = otherSettings.canCombine
		reconnectSendAgainTime = otherSettings.reconnectSendAgainTime
		dontSendWhenPanelClose = otherSettings.dontSendWhenPanelClose
		argsCanNil = otherSettings.argsCanNil
	end

	local CommandQueue = {}

	if CommandQueueList[target] ~= nil then
		CommandQueue = CommandQueueList[target]
	else
		CommandQueueList[target] = CommandQueue
	end

	if not table.isNilOrEmpty(CommandQueue[funcName]) then
		if CommandQueue[funcName].isInvoking then
			local value = {
				funcName = funcName,
				target = target,
				Callback = cb,
				canCombine = canCombine,
				reconnectSendAgainTime = reconnectSendAgainTime,
				dontSendWhenPanelClose = dontSendWhenPanelClose,
				argsCanNil = argsCanNil,
				args = ...
			}

			table.insert(CommandQueue[funcName], value)

			return value
		else
			local value = {
				funcName = funcName,
				target = target,
				Callback = cb,
				canCombine = canCombine,
				reconnectSendAgainTime = reconnectSendAgainTime,
				dontSendWhenPanelClose = dontSendWhenPanelClose,
				argsCanNil = argsCanNil,
				args = ...
			}

			table.insert(CommandQueue[funcName], value)
			self:TryInvokeNextFunc(CommandQueue, funcName)

			return value
		end
	else
		local value = {
			funcName = funcName,
			target = target,
			Callback = cb,
			canCombine = canCombine,
			reconnectSendAgainTime = reconnectSendAgainTime,
			dontSendWhenPanelClose = dontSendWhenPanelClose,
			argsCanNil = argsCanNil,
			args = ...
		}
		CommandQueue[funcName] = {
			value
		}

		self:TryInvokeNextFunc(CommandQueue, funcName)

		return value
	end
end

function M:TryInvokeNextFunc(CommandQueue, funcName)
	if table.isNilOrEmpty(CommandQueue[funcName]) then
		if CommandQueue[funcName] then
			CommandQueue[funcName].isInvoking = nil
		end

		return
	end

	local funcInfo = CommandQueue[funcName][1]

	if funcInfo == nil then
		CommandQueue[funcName].isInvoking = nil
		CommandQueue[funcName].isWaitingReconnect = nil

		return
	end

	if funcInfo.dontSendWhenPanelClose and not gPanelManager:IsPanelShowing(funcInfo.dontSendWhenPanelClose) then
		table.remove(CommandQueue[funcName], 1)
		self:TryInvokeNextFunc(CommandQueue, funcName)

		return
	end

	if funcInfo.canCombine then
		self:CombineInvoke(CommandQueue, funcName)
	else
		self:InvokeFunc(CommandQueue, funcName)
	end
end

function M:InvokeFunc(CommandQueue, funcName)
	local funcInfo = CommandQueue[funcName][1]
	local func = funcInfo.target[funcName]

	local function callBack(err, ...)
		if funcInfo.Callback then
			funcInfo.Callback(err, ...)
		end

		if err == MessageConfig.Disconnect or err == MessageConfig.TimeOut or err == MessageConfig.PeerTimeOut then
			if funcInfo.reconnectSendAgainTime ~= nil and funcInfo.reconnectSendAgainTime and funcInfo.reconnectSendAgainTime ~= true then
				funcInfo.reconnectSendAgainTime = funcInfo.reconnectSendAgainTime - 1
			end

			local funcList = CommandQueue[funcName]
			funcList.isInvoking = nil

			if err == MessageConfig.Disconnect then
				funcList.isWaitingReconnect = true
			end

			return
		end

		table.remove(CommandQueue[funcName], 1)
		self:TryInvokeNextFunc(CommandQueue, funcName)
	end

	if not funcInfo.argsCanNil and (funcInfo.args == nil or type(funcInfo.args) == "table" and table.isNilOrEmpty(funcInfo.args)) then
		print_error("发现空数据，查看堆栈注意传入的参数是否为空,无法定位请@jzc")
		print_error("发现空数据，多输出一条info", funcInfo.args)
		callBack(MessageConfig.Ok, {})

		return
	end

	CommandQueue[funcName].isInvoking = true
	func(funcInfo.target, funcInfo.args).Callback = callBack
end

function M:CombineInvoke(CommandQueue, funcName)
	local funcList = CommandQueue[funcName]
	local funcInfo = CommandQueue[funcName][1]

	if #funcList == 1 then
		self:InvokeFunc(CommandQueue, funcName)

		return
	end

	local toCombineList = {}

	for i = 1, #funcList do
		if funcList[i].canCombine then
			table.insert(toCombineList, i)
		end
	end

	local argCombine = {}
	local CombineMap = {}

	for i = 1, #toCombineList do
		local Idx = toCombineList[i]
		local funcInfo = funcList[Idx]
		local args = funcInfo.args

		if args ~= nil then
			for j, k in ipairs(args) do
				if CombineMap[tostring(k)] == nil then
					CombineMap[tostring(k)] = {
						original = k
					}
				end

				table.insert(CombineMap[tostring(k)], {
					toCombineListIdx = i,
					argsId = j
				})
			end
		end
	end

	local dataPack = {}

	for _, v in pairs(CombineMap) do
		local dataIdx = 0

		for i = 1, #argCombine do
			if argCombine[i] == v.original then
				dataIdx = i

				break
			end
		end

		if dataIdx == 0 then
			table.insert(argCombine, v.original)

			dataIdx = #argCombine
		end

		for _, value in ipairs(v) do
			if dataPack[value.toCombineListIdx] == nil then
				dataPack[value.toCombineListIdx] = {}
			end

			dataPack[value.toCombineListIdx][value.argsId] = dataIdx
		end
	end

	funcList.isInvoking = true
	local func = funcInfo.target[funcName]

	local function callBack(err, data)
		local packData = self:PackData(data, dataPack)

		for toCombineListIdx, funcListId in ipairs(toCombineList) do
			local unPackData = packData[toCombineListIdx]
			local funcInfo = funcList[funcListId]

			if funcInfo ~= nil then
				if funcInfo.Callback then
					funcInfo.Callback(err, unPackData)
				else
					print_error(funcInfo, "callback 不存在，请联系Jzc Debug")
				end
			else
				print_error(funcName, funcListId, "不存在，请联系Jzc Debug")
			end
		end

		if err == MessageConfig.Disconnect or err == MessageConfig.TimeOut or err == MessageConfig.PeerTimeOut then
			for i = #toCombineList, 1, -1 do
				local funcInfo = CommandQueue[funcName][i]

				if funcInfo.reconnectSendAgainTime == nil or funcInfo.reconnectSendAgainTime == false or funcInfo.reconnectSendAgainTime <= 0 then
					table.remove(CommandQueue[funcName], toCombineList[i])
				elseif funcInfo.reconnectSendAgainTime ~= true and funcInfo.reconnectSendAgainTime > 0 then
					funcInfo.reconnectSendAgainTime = funcInfo.reconnectSendAgainTime - 1
				end
			end

			local funcList = CommandQueue[funcName]
			funcList.isInvoking = nil

			if err == MessageConfig.Disconnect then
				funcList.isWaitingReconnect = true
			end

			return
		end

		for i = #toCombineList, 1, -1 do
			table.remove(CommandQueue[funcName], toCombineList[i])
		end

		self:TryInvokeNextFunc(CommandQueue, funcName)
	end

	if table.isNilOrEmpty(argCombine) then
		print_error("发现空数据，查看堆栈注意传入的参数是否为空,无法定位请@jzc")
		print_error("发现空数据，多输出一条info", funcInfo.args, funcName)
		callBack(MessageConfig.Ok, {})

		return
	end

	func(funcInfo.target, argCombine).Callback = callBack
end

function M:PackData(cbData, packMap)
	for dataIdx = 1, #packMap do
		local argsList = packMap[dataIdx]

		for argId = 1, #argsList do
			local cbDataId = argsList[argId]
			local argCbData = cbData[cbDataId]
			packMap[dataIdx][argId] = argCbData
		end
	end

	if table.isNilOrEmpty(packMap) then
		if cbData == nil then
			return {}
		end

		return cbData
	end

	return packMap
end

gRpcUtils = M
