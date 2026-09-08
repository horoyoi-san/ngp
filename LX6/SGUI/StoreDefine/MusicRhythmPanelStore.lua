-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MusicRhythmPanelStore.lua
-- Decompiled from: 01046_MusicRhythmPanelStore.lua_3b82402afc6b.luajit

C_MusicRhythmPanelStore = DefClass("C_MusicRhythmPanelStore", C_MusicRhythmPanelStore, C_StoreGroup)
GroupName2Class.MusicRhythmPanelStore = C_MusicRhythmPanelStore
local GameObject = UnityEngine.GameObject
local M = C_MusicRhythmPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.successEnum = {
		["\\xca\\xce7\\xe2"] = 0,
		["|#tW"] = 1
	}
	self.stageEnum = {
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1,
		["\\xaf\\xb4\\xaa2\\xeaa"] = 2,
		["\\xaf\\xb4\\xaa2\\xeag"] = 4,
		["\\xaf\\xb4\\xaa2\\xea`"] = 3
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.successEnum = nil
	self.stageEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.closeAction = self:CreateAction("OnCloseMusicRhythmPanel")

	gMessageManager:AddMessageListener(gEventConstants.MUSIC_RHYTHM_CLOSE, self.bindData.closeAction)

	data = data:ToTable()
	local levels = {}

	for i, id in ipairs(data.ids:ToTable()) do
		local cfg = LTConfig.PuzzleRhythmGameConfig.GetConfig(id)

		if cfg then
			levels[i] = {
				mistakeNum = cfg.MistakeNum,
				missNum = cfg.MissNum,
				niceTime = cfg.JudgeTimes[1],
				goodTime = cfg.JudgeTimes[2],
				angleList = cfg.PointAngle,
				signalList = cfg.SignalData,
				startPos = Vector3.New(cfg.DotData[1], cfg.DotData[2], 0),
				id = id,
				lineProportion = cfg.LineProportion
			}
		else
			levels[i] = {}

			print_error("MusicRhythmPanelStore 配置错误，请策划检查", id)
		end
	end

	self.data = {
		pid = data.pid,
		timeLimitRate = data.timeLimitRate,
		audioId = data.audioId,
		levels = levels,
		relatePids = data.relatePids and data.relatePids:ToTable() or {}
	}
	self.btns = {}
	self.missPoints = {}
	self.lines = {}
	self.cueList = {}
	self.clickList = {}

	self:SetLevel(1)

	self.bindData.clickBtn.luaClick = self:CreateAction("OnClickBtn")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickClose")
	self.bindData.resetBtn.luaClick = self:CreateAction("OnClickReset")

	self.bindData.temp.gameObject:SetActive(false)
	self.bindData.temp:Find(self.Effect.Nice).gameObject:SetActive(false)
	self.bindData.temp:Find(self.Effect.Good).gameObject:SetActive(false)
	self.bindData.temp:Find(self.Effect.Error).gameObject:SetActive(false)
	self.bindData.lineTemp.gameObject:SetActive(false)
	self.bindData.missTemp.gameObject:SetActive(false)
	self:SetNpcActionOccupy(true)
end

M.OnClose = function(self)
	if self.soundNid then
		gSoundMgr:StopSoundByNid(self.soundNid)

		self.soundNid = nil
	end

	self.SetNpcActionOccupy(self, false)
end

M.OnUpdate = function(self)
	if self.curStage ~= self.Stage.ListenReady and self.ReadyTime < gLogicTime.time - self.stageStartTime then
		self.SetStage(self, self.Stage.Listen)
	end

	self.RefreshMovePoint(self)
	self.CheckMissingCues(self)
end

M.CheckMissingCues = function(self)
	if self.curStage == self.Stage.Play then
		return
	end

	local curTime = gLogicTime.time - self.stageStartTime
	local goodTime = self.data.levels[self.curLevel].goodTime

	for _, cue in ipairs(self.cueList) do
		if not cue.missSignalSent and cue.result ~= self.Effect.None and curTime <= cue.time + goodTime then
			cue.missSignalSent = true

			self.SendStateTreeSignal(self, self.StateSignal.clickFail)
		end
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.Stage = {
	["J.|B"] = 3,
	["0A\\x82\\x9a\\x86O"] = 1,
	[".M\\x82\\x9b\\x8fU"] = 4,
	["\\xb3=3+}\\x93s\\xdc6\\xae\\xa0"] = 0,
	["sKmp|!"] = 2
}
M.Effect = {
	["T+~^"] = "T+~^",
	["h\\xbc\\xb0\\xa0\\xa4"] = "W+nH",
	["]-r_"] = "]-r_",
	["T-s^"] = "T-s^"
}
M.CueType = {
	["X'|O"] = "T-i^",
	["J.|B"] = "\\x98\\xa5\\xb9~\\xf07",
	["0A\\x82\\x9a\\x86O"] = "oN}K4<",
	[".M\\x82\\x9b\\x8fU"] = "\\xabfb",
	["\\xb3=3+}\\x93s\\xdc6\\xae\\xa0"] = "0A\\x82\\x9a\\x86O",
	["sKmp|!"] = "~\\xba\\xa3\\xbd\\xa2"
}
M.ReadyTime = 3
M.ResultTime = 3
M.debugLog = false
M.debugSuccess = false

M.SetLevel = function(self, level)
	if self.debugLog then
		print_error("SetLevel", level)
	end

	self.curLevel = level

	self.SetStage(self, self.Stage.ListenReady)
	self.ClearAllBtnData(self, true)
end

M.RefreshMovePoint = function(self)
	if self.curStage ~= self.Stage.Play then
		for i = 1, #self.cueList do
			if gLogicTime.time - self.stageStartTime >= self.cueList[i].time then
				if i ~= 1 then
					local rate = 1 - (gLogicTime.time - self.stageStartTime) / self.cueList[1].time
					local localPos = self.btns[1].transform.localPosition + (self.bindData.tlRoot.localPosition - (self.bindData.root.localPosition + self.btns[1].transform.localPosition)) * rate
					self.bindData.tipPoint.localPosition = localPos

					break
				end

				if self.debugLog then
					local rate = (gLogicTime.time - self.stageStartTime - self.cueList[i - 1].time) / (self.cueList[i].time - self.cueList[i - 1].time)
					self.bindData.tipPoint.localPosition = self.btns[i].transform.localPosition * rate + self.btns[i - 1].transform.localPosition * (1 - rate)

					break
				end

				break
				break
			end
		end
	end
end

M.SetStage = function(self, stage)
	if self.debugLog then
		print_error("SetStage", stage)
	end

	if self.curStage ~= self.Stage.Play then
		if stage ~= self.Stage.ListenReady then
			if not self.CheckSuccess(self) then
				self.curStage = self.Stage.Result
				self.bindData.stage = self.Stage.Result

				self.OnFail(self)

				return
			end
		elseif stage ~= self.Stage.Result then
			if self.CheckSuccess(self) then
				self.OnSuccess(self)
			else
				self.OnFail(self)
			end

			self.curStage = stage
			self.bindData.stage = stage

			return
		end
	end

	self.curCueCount = 0
	self.curStage = stage
	self.bindData.stage = stage
	self.stageStartTime = gLogicTime.time

	if self.curLevel ~= 1 and stage ~= self.Stage.Listen then
		slot2 = gSoundMgr
		self.soundNid = slot2:PlaySoundByTid(self.data.audioId, nil, , , function ()
			self:OnAudioEnd()
		end, nil, , function (playingID, cueName)
			self:OnAudioCue(playingID, cueName)
		end)
	end

	if stage ~= self.Stage.ListenReady then
		self.SendStateTreeSignal(self, self.StateSignal.listenReady)
	elseif stage ~= self.Stage.Listen then
		self.SendStateTreeSignal(self, self.StateSignal.listen)
	elseif stage ~= self.Stage.PlayReady then
		self.SendStateTreeSignal(self, self.StateSignal.playReady)
	elseif stage ~= self.Stage.Play then
		self.SendStateTreeSignal(self, self.StateSignal.play)
	end
end

M.SetNextLevel = function(self)
	self.SetLevel(self, self.curLevel + 1)
end

M.OnSuccess = function(self)
	self:SendStateTreeSignal(self.StateSignal.exit, 1)

	self.bindData.success = 0
	slot1 = gSpoonClientMgr

	slot1:ReleaseContextEvent(self.data.pid, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.MUSIC_RHYTHM, {
		0
	})
	gLuaTimeMgrUtils.Delay(function ()
		self:DelayClose()
	end, self.ResultTime)
end

M.OnFail = function(self)
	self:SendStateTreeSignal(self.StateSignal.exit, 2)

	self.bindData.success = 1
	self.isFail = true

	gSpoonClientMgr:ReleaseContextEvent(self.data.pid, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.MUSIC_RHYTHM, {
		1
	})

	if self.soundNid then
		gSoundMgr:StopSoundByNid(self.soundNid)

		self.soundNid = nil
	end

	gLuaTimeMgrUtils.Delay(function ()
		self:DelayClose()
	end, self.ResultTime)
end

M.ClearAllBtnData = function(self)
	for i, v in ipairs(self.btns) do
		if v then
			GameObject.Destroy(v)
		end
	end

	table.clear(self.btns)

	for i, v in ipairs(self.missPoints) do
		if v then
			GameObject.Destroy(v)
		end
	end

	table.clear(self.missPoints)

	for i, v in ipairs(self.lines) do
		if v then
			GameObject.Destroy(v)
		end
	end

	table.clear(self.lines)
	table.clear(self.clickList)
	table.clear(self.cueList)

	self.missNum = 0
end

M.AddBtn = function(self)
	local index = #self.btns + 1
	local angleList = self.data.levels[self.curLevel].angleList
	local pos = nil

	if index ~= 1 then
		pos = self.data.levels[self.curLevel].startPos
		self.data.levels[self.curLevel].posList = {
			pos
		}
	else
		local posList = self.data.levels[self.curLevel].posList
		local length = (Time.time - self.lastBtnTime) * self.data.levels[self.curLevel].lineProportion
		local angle = 0

		if angleList[index - 1] then
			angle = angleList[index - 1] * math.pi / 180
		else
			print_error("配置有误，角度信息长度不足，索引：" .. index)
		end

		pos = self.lastBtnPos + Vector3.New(math.cos(angle), math.sin(angle), 0) * length

		table.insert(posList, pos)
	end

	self.lastBtnTime = Time.time
	self.lastBtnPos = pos
	local obj = GameObject.Instantiate(self.bindData.temp.gameObject)

	obj.transform:SetParent(self.bindData.temp.parent)

	obj.transform.localPosition = pos
	obj.transform.localScale = Vector3.one

	obj:SetActive(true)
	table.insert(self.btns, obj)

	local line = GameObject.Instantiate(self.bindData.lineTemp.gameObject)
	local endPos = nil

	if index == 1 then
		endPos = self.btns[index - 1].transform.localPosition - obj.transform.localPosition
	else
		endPos = self.bindData.tlRoot.localPosition - (self.bindData.root.localPosition + self.btns[index].transform.localPosition)
	end

	line.transform:SetParent(self.bindData.lineTemp.parent)

	line.transform.localPosition = obj.transform.localPosition
	line.transform.localScale = Vector3.one
	local spline = line:GetComponent(typeof(SGUI.USpline))

	table.insert(self.lines, line)
	line:SetActive(true)
	spline:RemovePointAt(1)
	spline:AddPoint(endPos.x, endPos.y, 4, true, 0, 0)
	spline:SetPointPos(1, endPos)
end

M.SetBtnEffect = function(self, obj, effect)
	if self.debugLog then
		print_error("SetBtnEffect", effect)
	end

	if effect ~= self.Effect.None then
		self.SendStateTreeSignal(self, self.StateSignal.clickEmpty)
	elseif effect ~= self.Effect.Error then
		self.SendStateTreeSignal(self, self.StateSignal.clickEmpty)
	else
		self.SendStateTreeSignal(self, self.StateSignal.clickSuccess)
	end

	if effect ~= self.Effect.None then
		effect = self.Effect.Error
	end

	local node = obj.transform:Find(effect).gameObject

	node:SetActive(true)
end

M.OnClickBtn = function(self)
	if self.curStage == self.Stage.Play then
		return
	end

	local data = {
		time = gLogicTime.time - self.stageStartTime,
		result = self.Effect.None
	}

	table.insert(self.clickList, data)
	self.CheckBtnEffect(self)

	if self.debugLog then
		print_error("点击", #self.clickList)
	end
end

M.OnClickReset = function(self)
	self.ClearAllBtnData(self, true)
	self.SetLevel(self, 1)

	if self.soundNid then
		gSoundMgr:StopSoundByNid(self.soundNid)

		self.soundNid = nil
	end

	self.isFail = false
end

M.OnClickClose = function(self)
	if self.bindData.isClosing then
		return
	end

	if self.soundNid then
		gSoundMgr:StopSoundByNid(self.soundNid)

		self.soundNid = nil
	end

	self.SendStateTreeSignal(self, self.StateSignal.exit, 3)
	self.DelayClose(self)
end

M.OnAudioCue = function(self, playingID, cueName)
	if self.debugLog then
		print_error("OnAudioCue", cueName)
	end

	if cueName ~= self.CueType.ListenReady then
		self.SetNextLevel(self)
	elseif cueName ~= self.CueType.Listen then
		self.SetStage(self, self.Stage.Listen)
	elseif cueName ~= self.CueType.PlayReady then
		self.SetStage(self, self.Stage.PlayReady)
	elseif cueName ~= self.CueType.Play then
		self.SetStage(self, self.Stage.Play)
	elseif cueName ~= self.CueType.Result then
		self.SetStage(self, self.Stage.Result)
	elseif cueName ~= self.CueType.Beat then
		self.SendStateTreeSignal(self, self.StateSignal.onCue)
		self.OnTriggerSignal(self)

		if self.curStage ~= self.Stage.Listen then
			self.AddBtn(self)

			local data = {
				time = gLogicTime.time - self.stageStartTime,
				result = self.Effect.None
			}

			if self.debugLog then
				print_error(data.time)
			end

			table.insert(self.cueList, data)
		end
	end
end

M.OnTriggerSignal = function(self)
	self.curCueCount = self.curCueCount + 1
	local signal = self.data.levels[self.curLevel].signalList[self.curCueCount]

	if signal then
		gSpoonClientMgr:ReleaseContextEvent(self.data.pid, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.MUSIC_RHYTHM, {
			2,
			signal
		})
	end
end

M.OnAudioEnd = function(self)
	self.soundNid = nil
end

M.CheckSuccess = function(self)
	if self.debugSuccess then
		return true
	end

	local errNum = 0
	local niceNum = 0
	local goodNum = 0
	local missNum = 0

	for i, v in ipairs(self.clickList) do
		if v.result ~= self.Effect.Error or v.result ~= self.Effect.None then
			errNum = errNum + 1
		end
	end

	for i, v in ipairs(self.cueList) do
		if v.result ~= self.Effect.Good then
			goodNum = goodNum + 1
		elseif v.result ~= self.Effect.Nice then
			niceNum = niceNum + 1
		elseif v.result ~= self.Effect.None then
			missNum = missNum + 1
		end
	end

	return errNum < self.data.levels[self.curLevel].mistakeNum and missNum > self.data.levels[self.curLevel].missNum
end

M.CheckBtnEffect = function(self)
	if self.ClickIsEnd(self) then
		return
	end

	local curClick = self.clickList[#self.clickList]
	local lastCue, nextCue, index = nil

	for i, v in ipairs(self.cueList) do
		if curClick.time >= v.time then
			lastCue = self.cueList[i - 1]
			nextCue = v
			index = i

			break
		end
	end

	if not nextCue then
		index = #self.cueList
		lastCue = self.cueList[index]
	end

	local inLastTime = lastCue and curClick.time - lastCue.time <= self.data.levels[self.curLevel].goodTime
	local inNextTime = nextCue and nextCue.time - curClick.time <= self.data.levels[self.curLevel].goodTime

	if inLastTime and lastCue.result ~= self.Effect.None then
		local inNiceTime = curClick.time - lastCue.time <= self.data.levels[self.curLevel].niceTime
		curClick.result = inNiceTime and self.Effect.Nice or self.Effect.Good
		lastCue.result = inNiceTime and self.Effect.Nice or self.Effect.Good

		self:SetBtnEffect(self.btns[index - 1], curClick.result)
	elseif inNextTime and nextCue.result ~= self.Effect.None then
		local inNiceTime = nextCue.time - curClick.time <= self.data.levels[self.curLevel].niceTime
		curClick.result = inNiceTime and self.Effect.Nice or self.Effect.Good
		nextCue.result = inNiceTime and self.Effect.Nice or self.Effect.Good

		self:SetBtnEffect(self.btns[index], curClick.result)
	else
		curClick.result = self.Effect.Error

		if lastCue and lastCue.result ~= self.Effect.None then
			lastCue.result = self.Effect.Error

			self.SetBtnEffect(self, self.btns[index - 1], curClick.result)
		end

		if lastCue and nextCue then
			local rate = (curClick.time - lastCue.time) / (nextCue.time - lastCue.time)
			local pos = self.btns[index - 1].transform.localPosition + (self.btns[index].transform.localPosition - self.btns[index - 1].transform.localPosition) * rate

			self.AddMissPoint(self, pos)
		elseif lastCue then
			local rate = (curClick.time - lastCue.time) / 1
			local pos = self.btns[index - 1].transform.localPosition + Vector3.right * rate * 200

			self.AddMissPoint(self, pos)
		elseif nextCue then
			local rate = (nextCue.time - curClick.time) / 1
			local pos = self.btns[index].transform.localPosition - Vector3.right * rate * 200

			self.AddMissPoint(self, pos)
		end
	end
end

M.AddMissPoint = function(self, pos)
	self.SendStateTreeSignal(self, self.StateSignal.clickEmpty)

	if self.debugLog then
		print_error("AddMissPoint")
	end

	local obj = GameObject.Instantiate(self.bindData.missTemp.gameObject)

	obj.transform:SetParent(self.bindData.missTemp.parent)

	obj.transform.localPosition = pos
	obj.transform.localScale = Vector3.one

	obj:SetActive(true)
	table.insert(self.missPoints, obj)
end

M.ClickIsEnd = function(self)
	if self.data.levels[self.curLevel].goodTime >= gLogicTime.time - self.stageStartTime - self.cueList[#self.cueList].time then
		return true
	end

	return false
end

M.StateSignal = {
	["B\\xa0\\x81\\xba\\xb3"] = 11604,
	["A\\x82\\x9a\\x86O"] = 11604,
	["j.|B"] = 11604,
	[":tO"] = 11602,
	["lz\\xa5tG\\x81\\xe7Dim_"] = 11605,
	["@KejE84"] = 11606,
	["PVǾ\\x8f-\\xb5\\xdd\\xf1"] = 11607,
	["\\x93=3+}\\x93s\\xdc6\\xae\\xa0"] = 11603,
	["SKmp|!"] = 11603
}

M.SendStateTreeSignal = function(self, type, param)
	param = param or self:GetSignalParamByType(type)

	if self.debugLog then
		print_error("SendStateTreeSignal", type, param)
	end

	if param then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, type, param)
	else
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, type)
	end
end

M.GetSignalParamByType = function(self, type)
	local list = nil

	if type ~= self.StateSignal.clickFail then
		list = LTConfig.GameConfig.MusicMiniGameFailSignalWeight
	elseif type ~= self.StateSignal.clickEmpty then
		list = LTConfig.GameConfig.MusicMiniGameMissSignalWeight
	elseif type ~= self.StateSignal.clickSuccess then
		list = LTConfig.GameConfig.MusicMiniGameSuccessSignalWeight
	else
		return nil
	end

	local r = math.random()
	local sum = 0

	for i, data in ipairs(list) do
		sum = sum + data.weight

		if r < sum then
			return data.param
		end
	end

	return list[#list].param
end

M.SetNpcActionOccupy = function(self, open)
	for i, v in ipairs(self.data.relatePids) do
		slot7 = gClientToGameSceneDelegate

		slot7:AskSetMusicPlayNpc(v, open).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
				print_error("AskSetMusicPlayNpc", v, open)
			end
		end
	end
end

M.DelayClose = function(self)
	if self.bindData.isClosing then
		return
	end

	self.bindData.isClosing = true
	local clip = self.bindData.anim:GetClip("S_Vx_MusicRhythmPanel_CLOSE")

	self.bindData.anim:Play("S_Vx_MusicRhythmPanel_CLOSE")
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.MUSIC_RHYTHM)
	end, clip.length, nil, , true)
	gMessageManager:RemoveMessageListener(gEventConstants.MUSIC_RHYTHM_CLOSE, self.bindData.closeAction)
end

M.OnCloseMusicRhythmPanel = function(self)
	self.DelayClose(self)
end
