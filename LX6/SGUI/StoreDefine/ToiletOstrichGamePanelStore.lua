-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ToiletOstrichGamePanelStore.lua
-- Decompiled from: 01369_ToiletOstrichGamePanelStore.lua_f82e00c2c5c6.luajit

C_ToiletOstrichGamePanelStore = DefClass("C_ToiletOstrichGamePanelStore", C_ToiletOstrichGamePanelStore, C_StoreGroup)
GroupName2Class.ToiletOstrichGamePanelStore = C_ToiletOstrichGamePanelStore
local M = C_ToiletOstrichGamePanelStore
local LivehouseConfig = LTConfig.LivehouseConfig
local QTE_CHECK_TYPE = {
	["\\xea\\xee7>;\\xc2"] = 2,
	["\\Tw"] = 3,
	["\\xe9\\xfe&;;\\xc5"] = 1
}
local QTE_DURATION = 2
local PERFECT_WINDOW = 0.1
local GREAT_WINDOW = 0.2
local addTime = 0.5
local generateNoteTime = 2

local _isTrickType = function(cfgType)
	return cfgType ~= 2
end

M.OnAwake = function(self)
	self.InitDefaultInfo(self)
end

M.OnStart = function(self)
	self.qteRoots = {
		self.bindData.newBtn1,
		self.bindData.newBtn2,
		self.bindData.newBtn3
	}
	self.btnProxies = {}

	for i, root in ipairs(self.qteRoots) do
		local proxy = self.GetQteBtnProxy(self, root)

		if proxy then
			self.btnProxies[i] = proxy

			if proxy.button then
				proxy.button.luaClick = self.CreateActionWithArgs(self, "OnQteClick", i)
			end
		end
	end
end

M.GetQteBtnProxy = function(self, widget)
	if not widget then
		return nil
	end

	local group = gStoreManager:GetStoreGroup("ShuttlecockQteBtnStore")

	return group and group:GetStoreByWidget(widget) or nil
end

M.OnShow = function(self, panelId, data)
	self.npcPid = data.npcPid
	self.currentScore = 0
	addTime = 0.5
	generateNoteTime = 2

	self.InitDefaultInfo(self)

	self.unit = gCS.SceneDataMgr.GetUnit(data.npcPid)

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.unit, 5755)

	self.bindData.fillAmount = 0

	for i = 1, 3 do
		self.ResetBtn(self, i)
	end
end

M.InitDefaultInfo = function(self)
	self.qteSessions = {}
	self.isPlay = false
	self.fullPoints = 100
	self.normalPerfectPoint = 20
	self.perfectPoint = 30
end

M.OnClose = function(self)
	self.npcPid = nil
	self.isPlay = false
	self.qteSessions = {}

	for i = 1, 3 do
		self.ResetBtn(self, i)
	end
end

M.OnUpdate = function(self)
	if self.isPlay ~= false then
		addTime = addTime - Time.deltaTime

		if addTime < 0 then
			self.isPlay = true

			self.CreateNewQte(self)

			addTime = 0.5
		end
	else
		generateNoteTime = generateNoteTime - Time.deltaTime

		if generateNoteTime < 0 then
			self.CreateNewQte(self)

			generateNoteTime = 2
		end

		self.RefreshQteProgress(self)
	end
end

M.CreateNewQte = function(self)
	local freeBtns = {}

	for i = 1, 3 do
		if not self.qteSessions[i] then
			freeBtns[#freeBtns + 1] = i
		end
	end

	if #freeBtns ~= 0 then
		return
	end

	local i = freeBtns[math.random(1, #freeBtns)]
	local session = {
		["~b\\xa9@E\\xbc\\xf6H}_pH"] = 0,
		["\\x93;\\xe8\\x8bZ&\\xc2T\\xed\\xe0'.gY\\xd8'\\xb9\\xc8"] = 0,
		qteTime = QTE_DURATION,
		maxQteTime = QTE_DURATION,
		qteWindowBegin = GREAT_WINDOW,
		qteWindowBegin_Perfect = PERFECT_WINDOW,
		currentQteConfig = {
			["N;m^"] = 1
		}
	}
	self.qteSessions[i] = session

	self.ShowProgress(self, i, session.qteWindowBegin, session.qteWindowEnd, session.qteWindowBegin_Perfect, session.qteWindowEnd_Perfect, 1)
	self.ShowBtn(self, i)
end

M.RefreshQteProgress = function(self)
	for i, session in pairs(self.qteSessions) do
		session.qteTime = session.qteTime - Time.deltaTime
		local currentAmount = session.qteTime / session.maxQteTime

		self.UpdateBtnProgress(self, i, currentAmount, session)

		if session.qteTime < 0 then
			self.qteSessions[i] = nil

			self.OnQteJudge(self, i, QTE_CHECK_TYPE.FAIL)

			if not self.isPlay then
				return
			end
		end
	end
end

M.OnQteClick = function(self, i)
	if not self.isPlay then
		return
	end

	gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, 901 + i * 2)

	local session = self.qteSessions[i]

	if not session then
		return
	end

	self.qteSessions[i] = nil
	local currentAmount = session.qteTime / session.maxQteTime
	local qteType = nil

	if session.qteWindowEnd_Perfect < currentAmount and currentAmount < session.qteWindowBegin_Perfect then
		qteType = QTE_CHECK_TYPE.PERFECT
	elseif session.qteWindowEnd < currentAmount and currentAmount < session.qteWindowBegin then
		qteType = QTE_CHECK_TYPE.SUCCESS
	else
		qteType = QTE_CHECK_TYPE.FAIL
	end

	self.OnQteJudge(self, i, qteType)
end

M.OnQteJudge = function(self, i, qteType)
	self.PlayCheckResult(self, i, qteType, 1)

	if qteType ~= QTE_CHECK_TYPE.SUCCESS then
		self.AddScore(self, self.normalPerfectPoint)
	elseif qteType ~= QTE_CHECK_TYPE.PERFECT then
		self.AddScore(self, self.perfectPoint)
	else
		self.DecreaseScore(self, self.normalPerfectPoint)
	end

	self.bindData.fillAmount = self.currentScore / 100 or 0

	if self:CheckSuccess(self.currentScore) then
		self.GameEnd(self, true)
	elseif self.CheckFail(self, self.currentScore) then
		self.GameEnd(self, false)
	end
end

M.ResetBtn = function(self, i)
	local p = self.btnProxies and self.btnProxies[i]

	if not p then
		return
	end

	self.ResetTips(self, p)

	if p.tipsOutline then
		p.tipsOutline.gameObject:SetActive(false)
	end

	if p.progressW then
		p.progressW.gameObject:SetActive(false)
	end

	if p.progressG then
		p.progressG.gameObject:SetActive(false)
	end

	if p.progressGPerfect then
		p.progressGPerfect.gameObject:SetActive(false)
	end

	if p.progressP then
		p.progressP.gameObject:SetActive(false)
	end

	if p.progressPPerfect then
		p.progressPPerfect.gameObject:SetActive(false)
	end

	if p.pointer then
		p.pointer.gameObject:SetActive(false)
	end

	if p.button then
		p.button.gameObject:SetActive(false)
	end
end

M.ResetTips = function(self, p)
	if p.tipsW then
		p.tipsW.gameObject:SetActive(false)
	end

	if p.tipsY then
		p.tipsY.gameObject:SetActive(false)
	end

	if p.tipsP then
		p.tipsP.gameObject:SetActive(false)
	end

	if p.tipsG then
		p.tipsG.gameObject:SetActive(false)
	end
end

M.ShowProgress = function(self, i, qteWindowSize, qteWindowEnd, qteWindowPerfectSize, qteWindowEnd_Perfect, cfgType)
	local p = self.btnProxies and self.btnProxies[i]

	if not p then
		return
	end

	p.missCtrl = 0

	self.ResetTips(self, p)

	if _isTrickType(cfgType) then
		p.progressG.gameObject:SetActive(false)
		p.progressGPerfect.gameObject:SetActive(false)
		p.progressP.gameObject:SetActive(true)

		p.progressP.fillAmount = qteWindowSize
		p.progressP.transform.localRotation = Quaternion.Euler(0, 0, -qteWindowEnd * 360)

		p.progressPPerfect.gameObject:SetActive(true)

		p.progressPPerfect.fillAmount = qteWindowPerfectSize
		p.progressPPerfect.transform.localRotation = Quaternion.Euler(0, 0, -qteWindowEnd_Perfect * 360)
	else
		p.progressP.gameObject:SetActive(false)
		p.progressPPerfect.gameObject:SetActive(false)
		p.progressG.gameObject:SetActive(true)

		p.progressG.fillAmount = qteWindowSize
		p.progressG.transform.localRotation = Quaternion.Euler(0, 0, -qteWindowEnd * 360)

		p.progressGPerfect.gameObject:SetActive(true)

		p.progressGPerfect.fillAmount = qteWindowPerfectSize
		p.progressGPerfect.transform.localRotation = Quaternion.Euler(0, 0, -qteWindowEnd_Perfect * 360)
	end

	p.progressW.gameObject:SetActive(true)

	if p.pointer then
		p.pointer.gameObject:SetActive(true)

		p.pointer.localRotation = Quaternion.Euler(0, 0, -90)
	end
end

M.UpdateBtnProgress = function(self, i, currentAmount, session)
	local p = self.btnProxies and self.btnProxies[i]

	if not p then
		return
	end

	p.progressW.fillAmount = currentAmount
	local qteWindowEnd = session.qteWindowEnd

	if not qteWindowEnd then
		return
	end

	local qteWindowBegin = session.qteWindowBegin
	local qteWindowEnd_Perfect = session.qteWindowEnd_Perfect
	local qteWindowBegin_Perfect = session.qteWindowBegin_Perfect
	local cfgType = session.currentQteConfig and session.currentQteConfig.Type or 1
	local progressBar = _isTrickType(cfgType) and p.progressP or p.progressG
	local progressBar_Perfect = _isTrickType(cfgType) and p.progressPPerfect or p.progressGPerfect

	if currentAmount < qteWindowBegin then
		progressBar.fillAmount = currentAmount < qteWindowEnd and 0 or currentAmount - qteWindowEnd
	end

	if currentAmount < qteWindowBegin_Perfect then
		progressBar_Perfect.fillAmount = currentAmount < qteWindowEnd_Perfect and 0 or currentAmount - qteWindowEnd_Perfect
	end

	if p.pointer then
		p.pointer.localRotation = Quaternion.Euler(0, 0, -90 + (1 - currentAmount) * 360)
	end
end

M.ShowBtn = function(self, i)
	local root = self.qteRoots and self.qteRoots[i]

	if root and root.anim then
		root.anim:SampleCurrentAnimation(1000)
	end

	local p = self.btnProxies and self.btnProxies[i]

	if p and p.button then
		if not p.button.gameObject.activeSelf then
			p.button.gameObject:SetActive(true)
		else
			self.PlayQteBtnAnim(self, i, "S_Vx_Shuttlecock_PlayPanel_QteBtn_open_ani")
		end
	end
end

M.HideProgress = function(self, i)
	local p = self.btnProxies and self.btnProxies[i]

	if not p then
		return
	end

	if p.progressW then
		p.progressW.gameObject:SetActive(false)
	end

	if p.progressG then
		p.progressG.gameObject:SetActive(false)
	end

	if p.progressGPerfect then
		p.progressGPerfect.gameObject:SetActive(false)
	end

	if p.progressP then
		p.progressP.gameObject:SetActive(false)
	end

	if p.progressPPerfect then
		p.progressPPerfect.gameObject:SetActive(false)
	end

	if p.pointer then
		p.pointer.gameObject:SetActive(false)
	end
end

M.PlayQteBtnAnim = function(self, i, animName)
	local root = self.qteRoots and self.qteRoots[i]

	if root and root.anim then
		root.anim:Play(animName)
	end
end

M.PlayCheckResult = function(self, i, qteType, qteCfgType)
	self.PlayQteResultSound(self, qteType)
	self._RenderCheckResultOnBtn(self, i, qteType, qteCfgType)
end

M.PlayQteResultSound = function(self, qteType)
	if qteType ~= QTE_CHECK_TYPE.PERFECT then
		self.PlayNoteSound(self, gMusicGameManager.SoundType.Perfect)
	elseif qteType ~= QTE_CHECK_TYPE.SUCCESS then
		self.PlayNoteSound(self, gMusicGameManager.SoundType.Great)
	elseif qteType ~= QTE_CHECK_TYPE.FAIL then
		self.PlayNoteSound(self, gMusicGameManager.SoundType.Miss)
	end
end

M._RenderCheckResultOnBtn = function(self, i, qteType, qteCfgType)
	local p = self.btnProxies and self.btnProxies[i]

	if not p then
		return
	end

	self.HideProgress(self, i)

	local resultAnimName = nil

	if qteType ~= QTE_CHECK_TYPE.PERFECT or qteType ~= QTE_CHECK_TYPE.SUCCESS then
		if _isTrickType(qteCfgType) then
			resultAnimName = "S_Vx_Shuttlecock_QteBtn_120_ani"
		else
			resultAnimName = "S_Vx_Shuttlecock_QteBtn_50_ani"
		end
	elseif qteType ~= QTE_CHECK_TYPE.FAIL then
		resultAnimName = "S_Vx_Shuttlecock_QteBtn_defeated_ani"
	end

	self.PlayQteBtnAnim(self, i, resultAnimName)
	self.ResetTips(self, p)

	if p.tipsOutline then
		p.tipsOutline.gameObject:SetActive(false)
	end

	p.missCtrl = qteType ~= QTE_CHECK_TYPE.FAIL and 1 or 0
end

M.GameEnd = function(self, isSuccess)
	print_debug("Toilet GameEnd", isSuccess)

	self.isPlay = false

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnToiletGameFinish, {
		npcPid = self.npcPid,
		result = isSuccess
	})
	gMiniGameDataManager:SetToiletNpcResult(self.npcPid, isSuccess)

	local unit = gCS.SceneDataMgr.GetUnit(self.npcPid)

	if isSuccess then
		if unit then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, 5753)
		end
	else
		gCS.BaseUnitUtils.DismountCheckScore()

		if unit then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, 5754)
		end

		gClientToGameSceneDelegate:AskToiletOstrichFlee(self.npcPid)
	end

	gPanelManager:Close(gPanelId.TOILET_OSTRICH_GAME_PANEL)
end

M.CheckSuccess = function(self, points)
	return points < 100
end

M.CheckFail = function(self, points)
	return points <= -99999 and points > 0
end

M.PlayNoteSound = function(self, soundType)
	if soundType ~= gMusicGameManager.SoundType.Perfect then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
	end

	local noteSound = LivehouseConfig.NoteSound[soundType]

	if noteSound then
		gSoundMgr:PlaySoundByTid(noteSound.soundID)
	end
end

M.AddScore = function(self, points)
	self.currentScore = math.min(self.currentScore + points, 100)
end

M.DecreaseScore = function(self, points)
	self.currentScore = math.max(0, self.currentScore - points)
end
