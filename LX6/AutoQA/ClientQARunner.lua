-- Original chunk: @Lua\LuaFiles\LX6\AutoQA\ClientQARunner.lua
-- Decompiled from: 00270_ClientQARunner.lua_39d9b904136d.luajit

local UXTime = LTUtils.UXTime
local GuiMgr = LX6.GUI.GuiMgr
local MessageConfig = LTConfig.MessageConfig
local UXVector3 = UX.Game.UXVector3
local GameConfig = LTConfig.GameConfig
local AutoQaFunctions = L50.Gm.AutoQaFunctions
local M = {
	updatelist = {}
}

if not rawget(_G, "ClientTestSuiteList") then
	rawset(_G, "ClientTestSuiteList", {})
end

M.DefaultScreenShotTick = 2000
M.SpecialScreenCase = {
	"F\\x8e\\x9f\\x8e\\xfd\\x9d\\xc42\\xa7\\xa1\tg^",
	"U\\xe93\\xe3\\xc6v\r\\xd4B\\x828C\\xd5\\xed"
}
M.NoScreenCase = {
	"\\xa3:\\xf9\\xb3b\t\\xf5X\\xc6\\xca&^[\\xc4\\xbd\\xdf"
}
M.DefaultRecordMemoryTick = 5000
M.DefaultRecordFPSTick = 5000
M.DefaultMonitorMemoryTick = 10000
M.MaxShotTimes = 1000
M.m_OnceFlag = false
M.DefaultTestMethodTick = 1800
M.TESTSTATUS = {
	["p{\\xe0\\x93\\xab<\\x94+\\xe8\\xcc"] = 7,
	["\\xed\\xf2981\\xc5"] = 5,
	[":i\\xb8\\xa2\\xa6e"] = 3,
	["JNh"] = 4,
	["2g\\xa5\\xbc\\xb6o"] = 1,
	["\\x99\\xbe\t\\xaeN7\\xfb7"] = 6,
	["\\xeb\\xee:37\n\\xd6"] = 2
}
M.m_CaseInfo = {}
M.BeginTag = true
M.PhotographController = {}
M.unit = {}
M.SceneMapPinArray = {}
M.CurCustomLabel = ""
M.NotRetry = false
local handler = {
	[gEventConstants.SELF_PLAYER_DEAD] = function ()
		if M.Case and M.Case.RoleDiedFunc then
			M.Case:RoleDiedFunc()
		elseif M.m_CaseInfo == nil then
			M.m_CaseInfo.m_CaseStatus = M.TESTSTATUS.RoleDied

			M.LOG_ERR("player died")
		end
	end
}

M.isFunction = function(self, aObject)
	return type(aObject) ~= "function"
end

M.isTable = function(self, aObject)
	return type(aObject) ~= "table"
end

local addListener = function(handler)
	for k, v in pairs(handler) do
		gMessageManager:AddMessageListener(k, v)
	end
end

local removeListener = function(handler)
	for k, v in pairs(handler) do
		gMessageManager:RemoveMessageListener(k, v)
	end
end

M.KickOff = function(self, pid, suiteName, caseName, luastr, retry)
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

	if retry == nil then
		self.m_CaseInfo.m_Retry = retry
	end

	print(self.m_CaseInfo.m_Retry)

	self.m_CaseInfo.luastr = luastr

	self.SendLog2ClientQARunner(self, "kicking off : " .. caseName)
	self.StartRunTestCase(self, suiteName, self.m_CaseInfo.m_CaseName, luastr)
end

M.DoStartTestPreDeal = function(self, suiteName, caseName)
end

M.DoEndTestDeal = function(self, suiteName, caseName)
end

M.StartRunTestCase = function(self, suiteName, caseName, luastr)
	self.DoStartTestPreDeal(self, suiteName, caseName)

	local caseInfo = self.m_CaseInfo

	if not caseInfo then
		return
	end

	self.LoadLuaFile(self, "ClientQAcommon.lua")
	self.LoadLuaFile(self, "ParkourCommon.lua")

	local f = loadstring(luastr)

	if f then
		self.Case = f()
		self.m_CaseInfo.m_StartTime = os.time()
		self.m_CaseInfo.m_CaseStatus = self.TESTSTATUS.RUNNING

		self.addcase(self, caseName)
		self.LOG_START(self)

		if self.Case.InitTestCase then
			self.Case:InitTestCase()
		end
	else
		self.m_CaseInfo.m_CaseStatus = self.TESTSTATUS.CANNOTLOAD

		print_error("can not load lua file")
	end
end

M.LoadLuaFile = function(self, file)
	slot2 = gClientToGameGMDelegate

	slot2:ClientToGameGmQA("AskLoadLuaFile_AutoQA4Game", file).Callback = function (err, luastr_clientqacommon)
		if err ~= MessageConfig.ServerInnerError then
			print_error("clientQAcommon.lua load fail.the server can not fine this lua file")
		else
			local f = loadstring(luastr_clientqacommon)

			if f then
				f()
			end
		end
	end
end

M.EndRunTestCase = function(self)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName
	local caseInfo = self.m_CaseInfo

	if caseInfo.m_CaseStatus == self.TESTSTATUS.RUNNING and caseInfo.m_CaseStatus == self.TESTSTATUS.FAILED then
		self.SendLog2ClientQARunner(self, "EndRunTestCase failed ,because M case has ended")
	end

	caseInfo.m_EndTime = os.time()

	if caseInfo.m_CaseStatus == self.TESTSTATUS.FAILED then
		caseInfo.m_CaseStatus = self.TESTSTATUS.PASS

		M:LOG_PASS()
	else
		M:LOG_FAIL()
	end

	if caseInfo.m_CaseStatus ~= self.TESTSTATUS.PASS or caseInfo.m_Retry == false then
		if rawget(_G, caseName) then
			_G[caseName] = nil
		else
			self.LOG_WARN(self, caseName .. "此次跑测结束，但没有保存在_G中注册原表成功，可能存在读取冲突/内存不足问题，请清内存后再次尝试")
		end

		self.m_CaseInfo = {}
	end

	self.DoEndTestDeal(self, suiteName, caseName)
	self.SendLog2ClientQARunner(self, "TestCase :%s finished", caseName)
	self.removecase(self, caseName)

	if self.runFunction then
		gCoroutineManager:CancelCoroutine(self.runFunction)

		self.runFunction = nil
	end

	gClientToGameGMDelegate:ClientToGameGmQA("EndTestCase_AutoQA4Game", json.encode({
		pid = gPlayerManager.infoBase.bindData.Pid,
		suiteName = suiteName,
		caseName = caseName
	}))

	if self.m_CaseInfo.m_Retry ~= false then
		if self.NotRetry then
			self.NotRetry = false
		else
			if self.Case.RetryTestCase then
				self.Case.RetryTestCase()
			end

			self.KickOff(self, self.pid, suiteName, caseName, self.m_CaseInfo.luastr, true)
		end
	end
end

local LOG = function(level, suiteName, caseName, caseResult, szFormat, ...)
	if level == "ERR" and level ~= "CAPTURE" then
		-- Nothing
	end

	local msg = nil

	if type(szFormat) ~= "string" then
		msg = gString.Format(szFormat.gsub(szFormat, "%%,", "%%%%,"), ...)
	else
		msg = gString.Format(szFormat, ...)
	end

	caseResult = caseResult or "NULL"
	local logmsg = os.date("%Y-%m-%d %H:%M:%S")
	logmsg = logmsg .. "|" .. level .. "|" .. caseName .. "|" .. msg .. "\n"

	gCS.LuaUtils.LOG4AutoQA(level, caseName, caseName, caseResult, logmsg)
end

M.SendLog2ClientQARunner = function(self, szFormat, ...)
	local suiteName = "M"
	local caseName = "M"

	LOG("INFO", suiteName, caseName, nil, szFormat, ...)
end

M.LOG_INFO = function(self, szFormat, ...)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("INFO", suiteName, caseName, nil, szFormat, ...)
end

M.LOG_WARN = function(self, szFormat, ...)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	local logmsg = os.date("%Y-%m-%d-%H-%M-%S")

	LOG("WARN", suiteName, caseName, nil, szFormat, ...)
	self.ScreenShot(self, logmsg)
end

M.LOG_ERR = function(self, szFormat, ...)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("ERR", suiteName, caseName, nil, szFormat, ...)

	local str = L50.Gm.AutoQaFunctions.ReturnPageDownInfo()

	LOG("WARN", suiteName, caseName, nil, str, ...)
	self.ScreenShot(self, "LogErr")

	if _G[caseName] and self.m_CaseInfo then
		self.m_CaseInfo.m_CaseStatus = self.TESTSTATUS.FAILED

		M:EndRunTestCase()
	end
end

M.ClearAutoQAStatus = function(self)
	self.NotRetry = true

	self.LOG_ERR(self, "ClearAutoQAStatus")

	if self.Case and self.Case.Cancel then
		self.Case:Cancel()
	end
end

M.LOG_START = function(self)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("StartTest", suiteName, caseName, nil, "TestCaseStarted")
end

M.LOG_PASS = function(self)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("EndTest", suiteName, caseName, "Pass", "TestCaseEnded")
end

M.LOG_FAIL = function(self)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("EndTest", suiteName, caseName, "Fail", "TestCaseEnded")
end

M.LOG_BLOCK = function(self, szFormat, ...)
	local suiteName = self.m_CaseInfo.m_SuiteName
	local caseName = self.m_CaseInfo.m_CaseName

	if not suiteName or not caseName then
		return
	end

	LOG("EndTest", suiteName, caseName, "Block", szFormat, ...)
end

M.LOG_OTHER = function(self, szFormat, exten, append, ...)
	if append ~= nil then
		append = true
	end

	local filename = self.m_CaseInfo.m_SuiteName .. "_" .. exten

	if not filename or not szFormat then
		return
	end

	gCS.LuaUtils.WirteInfo4AutoQA(filename, szFormat, append)
end

M.ShowLogInClient = function(self)
	removeListener(handler)

	self.BeginTag = true
	local now = UXTime.UnixTimeToDateTime(gCS.TimeManager.ServerUnixTime)
	local str = now.Year .. now.Month .. now.Day .. now.Hour

	LOG("INFO", "EndTest", "EndTest", "EndTest", str)
end

M.ScreenShot = function(self, name)
	local caseName = self.m_CaseInfo.m_CaseName

	L50.Gm.AutoQaFunctions.AutoQA_ScreenShot(caseName, name)
end

M.addcase = function(self, case)
	if _G[case] and _G[case].OnUpdate then
		local lastDotime = Time.time

		self.updatelist[case] = function ()
			if Time.time <= lastDotime + 2 then
				lastDotime = Time.time

				_G[case]:OnUpdate()
			end
		end

		return
	end

	print_error("no OnUpdate function")
end

M.removecase = function(self, case)
	if self.updatelist[case] then
		self.updatelist[case] = nil
	end
end

M.OnUpdate = function(self)
	if self.updatelist then
		for k, v in pairs(self.updatelist) do
			if v then
				v()
			end
		end
	end
end

M.DoFunction = function(self, fun, overtime)
	if not self.runFunction then
		self.runFunction = gCoroutineManager:StartCoroutine(fun)
	elseif self.runFunction.isDone then
		print_error("lua file exist syntax error")
		print_error(self.runFunction.wait)
		self.LOG_ERR(self, self.runFunction.wait)
		self.LOG_ERR(self, "the case find syntax error")
	elseif os.time() <= self.m_CaseInfo.m_StartTime + overtime then
		print_error("the case run overtime")

		if self.Case and self.Case.OvertimeFunc then
			self.Case:OvertimeFunc()
		end

		self.LOG_ERR(self, "the case run over time")
	end
end

M.ChangeBeautifyType = function(self, CurIndices)
	self.PhotographController:SelectBeautifyType(CurIndices)
end

M.GetNowInteractiveAction = function(self)
	return gCS.MyPlayerManager.PlayerUnit.State.nowInteractiveAction
end

M.SetLookAtTargetPos = function(self, target, time)
	gCS.CameraDataMgr.cinemachineManager:SetCurrentFreelookRotateToTargetByTime(target, time)
end

M.AutoAddMapPin = function(self, operate)
	local mapId = 23300888
	local markType = 0
	local markScale = 0.92198581
	local count = 0

	if operate ~= "one" then
		return self.AskPutMapPin(self, mapId, 785, 0.6, 1637, markType, markScale)
	else
		while gPlayerManager.infoMinor.bindData.MapPins.Count >= GameConfig.MapPinMaxCount do
			local x = math.random(666, 2208)
			local y = math.random(10, 20)
			local z = math.random(1260, 2004)

			self.AskPutMapPin(self, mapId, x, y, z, markType, markScale)

			count = count + 1

			if count <= 200 then
				break
			end
		end
	end
end

M.AskPutMapPin = function(self, mapId, x, y, z, markType, markScale)
	local ret = ""
	slot8 = gClientToGameDelegate

	slot8:AskPutMapPin(mapId, UXVector3.New(x, y, z), markType).Callback = function (err, id)
		if err ~= MessageConfig.Ok then
			gMapSubSystem_Pin:AddMapPinClient(mapId, Vector3.New(x, y, z), markType, id)
		end

		ret = id

		table.insert(self.SceneMapPinArray, {
			["\\xf4\\xda4+\\xff"] = 25600427,
			id = id,
			pos = Vector2.New(0, 0),
			markType = markType,
			worldPos = Vector3.New(x, y, z),
			UnitMarkScale = Vector3.New(markScale, markScale, markScale)
		})
	end

	return ret
end

M.RemovePinClient = function(self, id, operate)
	slot3 = gClientToGameDelegate

	slot3:AskRemoveMapPin(id).Callback = function (err)
		if err ~= MessageConfig.Ok then
			if operate ~= "one" then
				gMapSubSystem_Pin:RemovePinClient(id)
			else
				for i = 1, #self.SceneMapPinArray do
					gMapSubSystem_Pin:RemovePinClient(self.SceneMapPinArray[i].id)
				end
			end
		end
	end
end

M.SetEcsMode = function(self, status)
end

M.CheckIsMoved = function(self, id)
end

M.TryGetDestructibleDebugJumpStr = function(self, destructId)
end

M.GetMayMoveDestructible = function(self)
end

gClientQARunner = M

return gClientQARunner
