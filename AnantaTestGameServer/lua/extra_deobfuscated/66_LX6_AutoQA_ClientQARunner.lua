local UXTime = LTUtils.UXTime
local GuiMgr = LX6.GUI.GuiMgr
local MessageConfig = LTConfig.MessageConfig
local UXVector3 = UX.Game.UXVector3
local GameConfig = LTConfig.GameConfig
local AutoQaFunctions = L50.Gm.AutoQaFunctions
local DestructibleManager = LX6.Item.DestructibleMgr
local M = {
	updatelist = {}
}

if not rawget(_G, "ClientTestSuiteList") then
	rawset(_G, "ClientTestSuiteList", {})
end

M.DefaultScreenShotTick = 2000
M.SpecialScreenCase = {
	"AutoQAMainTask15",
	"AutoQANewMainTask"
}
M.NoScreenCase = {
	"AutoQAScanDesignData"
}
M.DefaultRecordMemoryTick = 5000
M.DefaultRecordFPSTick = 5000
M.DefaultMonitorMemoryTick = 10000
M.MaxShotTimes = 1000
M.m_OnceFlag = false
M.DefaultTestMethodTick = 1800
M.TESTSTATUS = {
	CANNOTLOAD = 7,
	TIMEOUT = 5,
	FAILED = 3,
	PASS = 4,
	NOTRUN = 1,
	RoleDied = 6,
	RUNNING = 2
}
M.m_CaseInfo = {}
M.BeginTag = true
M.PhotographController = {}
M.unit = {}
M.SceneMapPinArray = {}
M.CurCustomLabel = ""
M.NotRetry = false
M.IsWaitColliderLoaded = DestructibleManager.Instance.IsWaitColliderLoaded
local handler = {
	[gEventConstants.SELF_PLAYER_DEAD] = function ()
		if M.Case and M.Case.RoleDiedFunc then
			M.Case:RoleDiedFunc()
		elseif M.m_CaseInfo ~= nil then
			M.m_CaseInfo.m_CaseStatus = M.TESTSTATUS.RoleDied

			M.LOG_ERR("player died")
		end
	end
}

function M:isFunction(aObject)
	return type(aObject) == "function"
end

function M:isTable(aObject)
	return type(aObject) == "table"
end

local function addListener(handler)
	for k, v in pairs(handler) do
		gMessageManager:AddMessageListener(k, v)
	end
end

local function removeListener(handler)
	for k, v in pairs(handler) do
		gMessageManager:RemoveMessageListener(k, v)
	end
end

function M:KickOff(pid, suiteName, caseName, luastr, retry)
	M.pid = pid

	if self.BeginTag then
		addListener(handler)

		self.BeginTag = false
	end

	self.m_CaseInfo.m_SuiteName = suiteName
	self.m_CaseInfo.m_CaseName = caseName
	self.m_CaseInfo.m_CaseStatus = self.TESTSTATUS.NOTRUN
	self.m_CaseInfo.m_CreateTime = os.time()
	self.m_CaseInfo.m_StartTime = nil
	self.m_CaseInfo.m_EndTime = nil
	self.m_CaseInfo.m_Retry = false

	if retry ~= nil then
		self.m_CaseInfo.m_Retry = retry
	end

	print(self.m_CaseInfo.m_Retry)

	self.m_CaseInfo.luastr = luastr

	self:SendLog2ClientQARunner("kicking off : " .. caseName)
	self:StartRunTestCase(suiteName, self.m_CaseInfo.m_CaseName, luastr)
end

function M:DoStartTestPreDeal(suiteName, caseName)
	return
end

function M:DoEndTestDeal(suiteName, caseName)
	return
end

function M:StartRunTestCase(suiteName, caseName, luastr)
	self:DoStartTestPreDeal(suiteName, caseName)

	local caseInfo = self.m_CaseInfo

	if not caseInfo then
		return
	end

	self:LoadLuaFile("ClientQAcommon.lua")

	local f = loadstring(luastr)

	if f then
		self.Case = f()
		self.m_CaseInfo.m_StartTime = os.time()
		self.m_CaseInfo.m_CaseStatus = self.TESTSTATUS.RUNNING

		self:addcase(caseName)
		self:LOG_START()

		if self.Case.InitTestCase then
			self.Case:InitTestCase()
		end
	else
		self.m_CaseInfo.m_CaseStatus = self.TESTSTATUS.CANNOTLOAD

		print_error("can not load lua file")
	end
end

function M:LoadLuaFile(file)
	gClientToGameGMDelegate:ClientToGameGmQA("AskLoadLuaFile_AutoQA4Game", file).Callback = function (err, luastr_clientqacommon)
		if err == MessageConfig.ServerInnerError then
			print_error("clientQAcommon.lua load fail.the server can not fine this lua file")
		else
			local f = loadstring(luastr_clientqacommon)

			if f then
				f()
			end
		end
	end
end

function M:EndRunTestCase()
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName
	local caseInfo = self.m_CaseInfo

	if caseInfo.m_CaseStatus ~= self.TESTSTATUS.RUNNING and caseInfo.m_CaseStatus ~= self.TESTSTATUS.FAILED then
		self:SendLog2ClientQARunner("EndRunTestCase failed ,because M case has ended")
	end

	caseInfo.m_EndTime = os.time()

	if caseInfo.m_CaseStatus ~= self.TESTSTATUS.FAILED then
		caseInfo.m_CaseStatus = self.TESTSTATUS.PASS

		M:LOG_PASS()
	else
		M:LOG_FAIL()
	end

	if caseInfo.m_CaseStatus == self.TESTSTATUS.PASS or caseInfo.m_Retry ~= false then
		if rawget(_G, caseName) then
			_G[caseName] = nil
		else
			self:LOG_WARN(caseName .. "此次跑测结束，但没有保存在_G中注册原表成功，可能存在读取冲突/内存不足问题，请清内存后再次尝试")
		end

		self.m_CaseInfo = {}
	end

	self:DoEndTestDeal(suiteName, caseName)
	self:SendLog2ClientQARunner("TestCase :%s finished", caseName)
	self:removecase(caseName)

	if self.runFunction then
		gCoroutineManager:CancelCoroutine(self.runFunction)

		self.runFunction = nil
	end

	gClientToGameGMDelegate:ClientToGameGmQA("EndTestCase_AutoQA4Game", json.encode({
		pid = gPlayerManager.infoBase.bindData.Pid,
		suiteName = suiteName,
		caseName = caseName
	}))

	if self.m_CaseInfo.m_Retry == false then
		if self.NotRetry then
			self.NotRetry = false
		else
			if self.Case.RetryTestCase then
				self.Case.RetryTestCase()
			end

			self:KickOff(self.pid, suiteName, caseName, self.m_CaseInfo.luastr, true)
		end
	end
end

local function LOG(level, suiteName, caseName, caseResult, szFormat, ...)
	if level ~= "ERR" and level == "CAPTURE" then
		-- Nothing
	end

	local msg = nil

	if type(szFormat) == "string" then
		msg = gString.Format(szFormat:gsub("%%,", "%%%%,"), ...)
	else
		msg = gString.Format(szFormat, ...)
	end

	caseResult = caseResult or "NULL"
	local logmsg = os.date("%Y-%m-%d %H:%M:%S")
	logmsg = logmsg .. "|" .. level .. "|" .. caseName .. "|" .. msg .. "\n"
end

function M:SendLog2ClientQARunner(szFormat, ...)
	local suiteName = "M"
	local caseName = "M"

	LOG("INFO", suiteName, caseName, nil, szFormat, ...)
end

function M:LOG_INFO(szFormat, ...)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("INFO", suiteName, caseName, nil, szFormat, ...)
end

function M:LOG_WARN(szFormat, ...)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	local logmsg = os.date("%Y-%m-%d-%H-%M-%S")

	LOG("WARN", suiteName, caseName, nil, szFormat, ...)
	self:ScreenShot(logmsg)
end

function M:LOG_ERR(szFormat, ...)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("ERR", suiteName, caseName, nil, szFormat, ...)

	local str = L50.Gm.AutoQaFunctions.ReturnPageDownInfo()

	LOG("WARN", suiteName, caseName, nil, str, ...)
	self:ScreenShot("LogErr")

	if _G[caseName] and self.m_CaseInfo then
		self.m_CaseInfo.m_CaseStatus = self.TESTSTATUS.FAILED

		M:EndRunTestCase()
	end
end

function M:ClearAutoQAStatus()
	self.NotRetry = true

	self:LOG_ERR("ClearAutoQAStatus")

	if self.Case and self.Case.Cancel then
		self.Case:Cancel()
	end
end

function M:LOG_START()
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("StartTest", suiteName, caseName, nil, "TestCaseStarted")
end

function M:LOG_PASS()
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("EndTest", suiteName, caseName, "Pass", "TestCaseEnded")
end

function M:LOG_FAIL()
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("EndTest", suiteName, caseName, "Fail", "TestCaseEnded")
end

function M:LOG_BLOCK(szFormat, ...)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("EndTest", suiteName, caseName, "Block", szFormat, ...)
end

function M:LOG_OTHER(szFormat, exten, append, ...)
	if append == nil then
		append = true
	end

	local filename = self.m_CaseInfo.m_SuiteName .. "_" .. exten

	if not filename or not szFormat then
		return
	end

	gCS.LuaUtils.WirteInfo4AutoQA(filename, szFormat, append)
end

function M:ShowLogInClient()
	removeListener(handler)

	self.BeginTag = true
	local now = UXTime.UnixTimeToDateTime(gCS.TimeManager.ServerUnixTime)
	local str = now.Year .. now.Month .. now.Day .. now.Hour

	LOG("INFO", "EndTest", "EndTest", "EndTest", str)
end

function M:ScreenShot(name)
	local caseName = self.m_CaseInfo.m_CaseName

	L50.Gm.AutoQaFunctions.AutoQA_ScreenShot(caseName, name)
end

function M:addcase(case)
	if _G[case] and _G[case].OnUpdate then
		local lastDotime = Time.time

		self.updatelist[case] = function ()
			if Time.time > lastDotime + 2 then
				lastDotime = Time.time

				_G[case]:OnUpdate()
			end
		end

		return
	end

	print_error("no OnUpdate function")
end

function M:removecase(case)
	if self.updatelist[case] then
		self.updatelist[case] = nil
	end
end

function M:OnUpdate()
	if self.updatelist then
		for k, v in pairs(self.updatelist) do
			if v then
				v()
			end
		end
	end
end

function M:DoFunction(fun, overtime)
	if not self.runFunction then
		self.runFunction = gCoroutineManager:StartCoroutine(fun)
	elseif self.runFunction.isDone then
		print_error("lua file exist syntax error")
		print_error(self.runFunction.wait)
		self:LOG_ERR(self.runFunction.wait)
		self:LOG_ERR("the case find syntax error")
	elseif os.time() > self.m_CaseInfo.m_StartTime + overtime then
		print_error("the case run overtime")

		if self.Case and self.Case.OvertimeFunc then
			self.Case:OvertimeFunc()
		end

		self:LOG_ERR("the case run over time")
	end
end

function M:ChangeBeautifyType(CurIndices)
	self.PhotographController:SelectBeautifyType(CurIndices)
end

function M:GetNowInteractiveAction()
	return gCS.MyPlayerManager.PlayerUnit.State.nowInteractiveAction
end

function M:SetLookAtTargetPos(target, time)
	gCS.CameraDataMgr.cinemachineManager:SetCurrentFreelookRotateToTargetByTime(target, time)
end

function M:AutoAddMapPin(operate)
	local mapId = 23300888
	local markType = 0
	local markScale = 0.92198581
	local count = 0

	if operate == "one" then
		return self:AskPutMapPin(mapId, 785, 0.6, 1637, markType, markScale)
	else
		while gPlayerManager.infoMinor.bindData.MapPins.Count < GameConfig.MapPinMaxCount do
			local x = math.random(666, 2208)
			local y = math.random(10, 20)
			local z = math.random(1260, 2004)

			self:AskPutMapPin(mapId, x, y, z, markType, markScale)

			count = count + 1

			if count > 200 then
				break
			end
		end
	end
end

function M:AskPutMapPin(mapId, x, y, z, markType, markScale)
	local ret = ""

	gClientToGameDelegate:AskPutMapPin(mapId, UXVector3.New(x, y, z), markType).Callback = function (err, id)
		if err == MessageConfig.Ok then
			gMapSubSystem_Pin:AddMapPinClient(mapId, Vector3.New(x, y, z), markType, id)
		end

		ret = id

		table.insert(self.SceneMapPinArray, {
			MapIcon = 25600427,
			id = id,
			pos = Vector2.New(0, 0),
			markType = markType,
			worldPos = Vector3.New(x, y, z),
			UnitMarkScale = Vector3.New(markScale, markScale, markScale)
		})
	end

	return ret
end

function M:RemovePinClient(id, operate)
	gClientToGameDelegate:AskRemoveMapPin(id).Callback = function (err)
		if err == MessageConfig.Ok then
			if operate == "one" then
				gMapSubSystem_Pin:RemovePinClient(id)
			else
				for i = 1, #self.SceneMapPinArray do
					gMapSubSystem_Pin:RemovePinClient(self.SceneMapPinArray[i].id)
				end
			end
		end
	end
end

function M:SetEcsMode(status)
	DestructibleManager.Instance:SetEcsMode(status)
end

function M:CheckIsMoved(id)
	DestructibleManager.Instance:CheckIsMoved(id)
end

function M:TryGetDestructibleDebugJumpStr(destructId)
	DestructibleManager.Instance:TryGetDestructibleDebugJumpStr(destructId)
end

function M:GetMayMoveDestructible()
	return DestructibleManager.Instance.GetMayMoveDestructible()
end

gClientQARunner = M

return gClientQARunner
