-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShuttlecockPlayPanelStore.lua
-- Decompiled from: 01329_ShuttlecockPlayPanelStore.lua_368fd35f338b.luajit

C_ShuttlecockPlayPanelStore = DefClass("C_ShuttlecockPlayPanelStore", C_ShuttlecockPlayPanelStore, C_StoreGroup)
GroupName2Class.ShuttlecockPlayPanelStore = C_ShuttlecockPlayPanelStore
local M = C_ShuttlecockPlayPanelStore
local QTE_PC_KEY_MAP = {
	2,
	38,
	13,
	47,
	12
}
local DUAL_QTE_ID = 1
local DUAL_BTN_IDS = {
	2,
	3
}
local DUAL_TIPS_BTN_ID = 3
local QTE_SOUND_ID = {
	["]-q_"] = 70670081,
	["\\xe9\\xde'\\xe5"] = 70670046,
	["\\#tW"] = 70670044,
	["2G\\x83\\x83\\x82M"] = 70670045
}

local _isTrickType = function(cfgType)
	return cfgType ~= 2
end

local _getQteCheckType = function()
	return gShuttlecockPlayerCharacter and gShuttlecockPlayerCharacter.QTE_CHECK_TYPE or nil
end

M.OnAwake = function(self)
end

M.OnStart = function(self)
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.qteRoots = {
		self.bindData.qteBtn1,
		self.bindData.qteBtn2,
		self.bindData.qteBtn3,
		self.bindData.qteBtn4,
		self.bindData.qteBtn5
	}

	if self.bindData.abortButton then
		self.bindData.abortButton.luaClick = self.CreateAction(self, "OnAbort")
	end

	self.btnProxies = {}
	self.btnFeedbackCos = {}

	for i, root in ipairs(self.qteRoots) do
		local proxy = self.GetQteBtnProxy(self, root)

		if proxy then
			self.btnProxies[i] = proxy

			if proxy.button then
				proxy.button.luaPress = self.CreateActionWithArgs(self, "OnQteClick", i)
				proxy.button.luaRelease = self.CreateActionWithArgs(self, "OnQteRelease", i)
				local pcKeyId = QTE_PC_KEY_MAP[i]

				if pcKeyId and proxy.button.SetPCKeyInfoWithOutTip then
					proxy.button:SetPCKeyInfoWithOutTip(pcKeyId)
				end
			end
		end
	end

	self.InitLanguageTexts(self)

	self.bindData.score.text = 0
end

M.IsDualKeyMode = function(self, qteId)
	return self.isMobile and qteId ~= DUAL_QTE_ID
end

M.OnShow = function(self, panelId, data)
	self.RegisterSingleEvent(self, gEventConstants.MINIGAME_SHUTTLECOCK_QTE_SHOW, self.CreateAction(self, "OnQteShow"))
	self.RegisterSingleEvent(self, gEventConstants.MINIGAME_SHUTTLECOCK_QTE_CHECK, self.CreateAction(self, "OnQteCheck"))

	local qte = self.bindData.qte

	if qte and qte.anim and qte.anim:GetClip("S_Vx_Shuttlecock_PlayPanel_open") then
		qte.anim:Play("S_Vx_Shuttlecock_PlayPanel_open")
	end

	self.currentQteId = nil
	self.shownQteId = nil
	self.dualPressedSet = {}

	for i = 1, 5 do
		self.ResetBtn(self, i)
	end

	self.bindData.score.text = 0

	self.RefreshPlayGoal(self)

	if self.refreshTimer then
		self.refreshTimer:Stop()
	end

	self.refreshTimer = Timer.New(function ()
		self:RefreshProgress()
	end, 0, -1, false, true)

	self.refreshTimer:Start()
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)

	if self.refreshTimer then
		self.refreshTimer:Stop()

		self.refreshTimer = nil
	end

	if self.btnFeedbackCos then
		for i = 1, 5 do
			self.StopFeedbackCo(self, i)
		end
	end
end

M.OnDestroy = function(self)
end

M.GetQteBtnProxy = function(self, widget)
	if not widget then
		return nil
	end

	local group = gStoreManager:GetStoreGroup("ShuttlecockQteBtnStore")

	return group and group:GetStoreByWidget(widget) or nil
end

M.InitLanguageTexts = function(self)
end

M.OnQteClick = function(self, qteId)
	local game = gShuttlecockGameManager.currentGame

	if not game then
		return
	end

	if self.IsDualKeyMode(self, self.currentQteId) then
		if qteId == DUAL_BTN_IDS[1] and qteId == DUAL_BTN_IDS[2] then
			return
		end

		self.dualPressedSet = self.dualPressedSet or {}
		self.dualPressedSet[qteId] = true

		if self.dualPressedSet[DUAL_BTN_IDS[1]] and self.dualPressedSet[DUAL_BTN_IDS[2]] then
			game.ExecuteQteKeyDown(game, DUAL_QTE_ID)
		end

		return
	end

	local r = self.lastRender

	if r and r.qteId ~= qteId then
		local uiHit = r.windowEnd and r.windowEnd < r.amount and r.amount > r.windowBegin
		local uiPerfect = r.windowEnd_Perfect and r.windowEnd_Perfect < r.amount and r.amount > r.windowBegin_Perfect

		print_debug("[ShuttlecockQTE]UIClick", string.format("qteId=%s uiAmount=%.4f uiQteTime=%.4f maxQteTime=%s needShowQte=%s qteShowTime=%s renderFrame=%s clickFrame=%s | succWin[%.4f,%.4f] perfWin[%.4f,%.4f] => uiHit=%s uiPerfect=%s", tostring(qteId), r.amount, r.qteTime, tostring(r.maxQteTime), tostring(r.needShowQte), tostring(r.qteShowTime), tostring(r.frame), tostring(Time.frameCount), r.windowEnd or -1, r.windowBegin or -1, r.windowEnd_Perfect or -1, r.windowBegin_Perfect or -1, tostring(uiHit), tostring(uiPerfect)))
	else
		print_debug("[ShuttlecockQTE]UIClick", string.format("qteId=%s 无匹配 UI 渲染缓存(lastRenderQteId=%s)，进度环可能还没开始刷新", tostring(qteId), tostring(r and r.qteId)))
	end

	game.ExecuteQteKeyDown(game, qteId)
end

M.OnQteRelease = function(self, qteId)
	if self.IsDualKeyMode(self, self.currentQteId) and self.dualPressedSet then
		self.dualPressedSet[qteId] = false
	end
end

M.OnAbort = function(self)
	local game = gShuttlecockGameManager.currentGame

	if not game then
		return
	end

	gShuttlecockGameManager:ExitGameCs()
end

M.OnQteShow = function(self, _, params)
	self.shownQteId = nil
	self.dualPressedSet = {}

	self.RefreshQteNode(self, params.qteId)
end

M.OnQteCheck = function(self, _, params)
	self.RefreshQteNode(self, params.qteId, params.qteType, params.qteCfgType, params.score)
end

M.ResetBtn = function(self, i)
	local p = self.btnProxies and self.btnProxies[i]

	if not p then
		return
	end

	self.StopFeedbackCo(self, i)
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

M.UpdateBtnProgress = function(self, i, currentAmount, pc)
	local p = self.btnProxies and self.btnProxies[i]

	if not p then
		return
	end

	p.progressW.fillAmount = currentAmount
	local qteWindowEnd = pc.qteWindowEnd

	if not qteWindowEnd then
		return
	end

	local qteWindowBegin = pc.qteWindowBegin
	local qteWindowEnd_Perfect = pc.qteWindowEnd_Perfect
	local qteWindowBegin_Perfect = pc.qteWindowBegin_Perfect
	local cfgType = pc.currentQteConfig and pc.currentQteConfig.Type or 1
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
	if self.shownQteId ~= i then
		return
	end

	self.shownQteId = i
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

M.HideBtn = function(self, i)
	local p = self.btnProxies and self.btnProxies[i]

	if p and p.button then
		p.button.gameObject:SetActive(false)
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

	root.anim:Play(animName)
end

M.PlayCheckResult = function(self, qteId, qteType, qteCfgType, score)
	self.PlayQteResultSound(self, qteType, qteCfgType)

	if self.IsDualKeyMode(self, qteId) then
		self._RenderCheckResultOnBtn(self, DUAL_BTN_IDS[1], qteType, qteCfgType, score, true)
		self._RenderCheckResultOnBtn(self, DUAL_BTN_IDS[2], qteType, qteCfgType, score, false)
	else
		self._RenderCheckResultOnBtn(self, qteId, qteType, qteCfgType, score, false)
	end
end

M.PlayQteResultSound = function(self, qteType, qteCfgType)
	local QTE_CHECK_TYPE = _getQteCheckType()

	if not QTE_CHECK_TYPE then
		return
	end

	local soundId = nil

	if qteType ~= QTE_CHECK_TYPE.PERFECT then
		soundId = _isTrickType(qteCfgType) and QTE_SOUND_ID.Gold or QTE_SOUND_ID.Perfect
	elseif qteType ~= QTE_CHECK_TYPE.SUCCESS then
		soundId = QTE_SOUND_ID.Normal
	elseif qteType ~= QTE_CHECK_TYPE.FAIL or qteType ~= QTE_CHECK_TYPE.ERROR then
		soundId = QTE_SOUND_ID.Fail
	end

	if soundId then
		gSoundMgr:PlaySoundByTid(soundId)
	end
end

M._RenderCheckResultOnBtn = function(self, i, qteType, qteCfgType, score, hideTipsOnly)
	local p = self.btnProxies and self.btnProxies[i]

	if not p then
		return
	end

	local QTE_CHECK_TYPE = _getQteCheckType()

	if not QTE_CHECK_TYPE then
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
	elseif qteType ~= QTE_CHECK_TYPE.FAIL or qteType ~= QTE_CHECK_TYPE.ERROR then
		resultAnimName = "S_Vx_Shuttlecock_QteBtn_defeated_ani"
	end

	self.PlayQteBtnAnim(self, i, resultAnimName)
	self.ResetTips(self, p)

	p.missCtrl = 0

	if p.tipsOutline then
		p.tipsOutline.gameObject:SetActive(false)
	end

	if hideTipsOnly then
		return
	end

	local scoreText = self.BuildScoreSpriteText(self, score)

	if qteType ~= QTE_CHECK_TYPE.PERFECT then
		if _isTrickType(qteCfgType) then
			if p.tipsY then
				p.tipsY.gameObject:SetActive(true)

				p.tipsY.text = scoreText
			end
		elseif p.tipsG then
			p.tipsG.gameObject:SetActive(true)

			p.tipsG.text = scoreText
		end

		if p.tipsOutline then
			p.tipsOutline.gameObject:SetActive(true)

			p.tipsOutline.text = scoreText
		end
	elseif qteType ~= QTE_CHECK_TYPE.SUCCESS then
		if p.tipsW then
			p.tipsW.gameObject:SetActive(true)

			p.tipsW.text = scoreText
		end

		if p.tipsOutline then
			p.tipsOutline.gameObject:SetActive(true)

			p.tipsOutline.text = scoreText
		end
	elseif qteType ~= QTE_CHECK_TYPE.FAIL or qteType ~= QTE_CHECK_TYPE.ERROR then
		p.missCtrl = 1

		if p.tipsP then
			p.tipsP.gameObject:SetActive(true)

			p.tipsP.text = ShuttlecockConfig.GetLanguageContent(10007)
		end
	end

	self.StopFeedbackCo(self, i)
end

M.StopFeedbackCo = function(self, i)
	if self.btnFeedbackCos and self.btnFeedbackCos[i] then
		coroutine.stop(self.btnFeedbackCos[i])

		self.btnFeedbackCos[i] = nil
	end
end

M.BuildScoreSpriteText = function(self, score)
	return "+" .. tostring(score)
end

M.RefreshQteNode = function(self, qteId, qteType, qteCfgType)
	local game = gShuttlecockGameManager.currentGame
	local pc = game and game.playerCharacter

	if not pc then
		return
	end

	self.currentQteId = qteId

	if qteType then
		print_debug("[ShuttlecockQTE]UIResult", string.format("qteId=%s qteType=%s qteCfgType=%s frame=%s", tostring(qteId), tostring(qteType), tostring(qteCfgType), tostring(Time.frameCount)))

		local score = pc.currentQteConfig and pc.currentQteConfig.Score or 0

		self:PlayCheckResult(qteId, qteType, qteCfgType, score)
	end

	self.bindData.score.text = pc.totalScore
end

M.RefreshProgress = function(self)
	self:RefreshPlayGoal()

	local game = gShuttlecockGameManager.currentGame
	local pc = game and game.playerCharacter

	if not pc or not self.currentQteId then
		return
	end

	if pc.CheckShowQte(pc) and self.shownQteId == self.currentQteId then
		local cfgType = pc.currentQteConfig and pc.currentQteConfig.Type or 1

		if self:IsDualKeyMode(self.currentQteId) then
			for _, btnId in ipairs(DUAL_BTN_IDS) do
				self.ShowProgress(self, btnId, pc.qteWindowSize, pc.qteWindowEnd, pc.qteWindowPerfectSize, pc.qteWindowEnd_Perfect, cfgType)
			end

			self.ShowBtn(self, DUAL_BTN_IDS[1])
			self.ShowBtn(self, DUAL_BTN_IDS[2])

			self.shownQteId = self.currentQteId
		else
			self.ShowProgress(self, self.currentQteId, pc.qteWindowSize, pc.qteWindowEnd, pc.qteWindowPerfectSize, pc.qteWindowEnd_Perfect, cfgType)
			self.ShowBtn(self, self.currentQteId)
		end
	end

	if not pc.maxQteTime then
		return
	end

	local currentAmount = pc.qteTime / pc.maxQteTime

	if self.IsDualKeyMode(self, self.currentQteId) then
		self.UpdateBtnProgress(self, DUAL_BTN_IDS[1], currentAmount, pc)
		self.UpdateBtnProgress(self, DUAL_BTN_IDS[2], currentAmount, pc)
	else
		self.UpdateBtnProgress(self, self.currentQteId, currentAmount, pc)
	end

	self.lastRender = {
		qteId = self.currentQteId,
		amount = currentAmount,
		qteTime = pc.qteTime,
		maxQteTime = pc.maxQteTime,
		windowBegin = pc.qteWindowBegin,
		windowEnd = pc.qteWindowEnd,
		windowBegin_Perfect = pc.qteWindowBegin_Perfect,
		windowEnd_Perfect = pc.qteWindowEnd_Perfect,
		needShowQte = pc.needShowQte,
		qteShowTime = pc.qteShowTime,
		frame = Time.frameCount
	}
end

M.RefreshPlayGoal = function(self)
	local game = gShuttlecockGameManager.currentGame

	if not game or game.gameStatus == gBaseMiniGame.GAME_STATUS.START then
		return
	end

	local winType = game.GetWinType(game)
	local winArgs = game.GetWinArgs(game)

	if not winType then
		return
	end

	local getter = ShuttlecockConfig.WinProgressGetters[winType]
	local current = getter and getter(game) or 0
	self.bindData.goalProgress.text = current .. "/" .. winArgs
end
