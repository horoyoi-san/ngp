local GameConfig = LTConfig.GameConfig
local Time = UnityEngine.Time
local MessageConfig = LTConfig.MessageConfig
local M = {
	delayFuncMap = {},
	cds = {},
	ignoreOnce = {},
	isActive = true,
	messageBox = {},
	isQueueRunning = true,
	queueCache = {},
	currentShowNum = 0,
	BlurBgType = {
		UIOnly = 1,
		SceneOnly = 2,
		ALL = 0
	},
	EnvType = {
		Publish = 4,
		Editor = 1,
		Release = 3,
		Debug = 2
	},
	GetInstance = function (self)
		if self.instance == nil then
			local function constructor()
				local obj = {}

				setmetatable(obj, self)

				self.__index = self

				return obj
			end

			self.instance = constructor()
		end

		return self.instance
	end,
	MessageCallbackState = {
		Cancel = 1,
		Confirm = 0,
		Close = 2
	},
	OnInit = function (self)
		gMessageManager:AddMessageListener(gEventConstants.MESSAGE_CLEAR, self.ClearDelayTimeFunc)
	end,
	ClearDelayTimeFunc = function ()
		for key, value in pairs(gDisplayMessageMgr.delayFuncMap) do
			value:Stop()

			value = nil
			gDisplayMessageMgr.delayFuncMap[key] = nil
		end

		gDisplayMessageMgr.queueCache = {}
		gDisplayMessageMgr.currentShowNum = 0
	end
}

function M:ShowServerMessage(mid, args)
	local config, preference = self:GetMessageConfig(mid)

	if not config then
		return
	end

	print_notice("ShowServerMessage", mid)

	local content = nil

	if args then
		local status = nil
		status, content = pcall(self.GetContent, config.Content, unpack(args))

		if not status then
			print_error("ConfigId:", config.Id, content)

			return
		end
	else
		local status = nil
		status, content = pcall(self.GetContent, config.Content)

		if not status then
			print_error("ConfigId:", config.Id, content)

			return
		end
	end

	self:ShowContent(config, content, nil, nil, mid)
end

function M:DisplayServerMessageId_NeedCallback(mid, args, para)
	local config = MessageConfig.GetConfig(mid)

	if not config or string.is_null_or_empty(config.Content) then
		return
	end

	local isShow, btnNum = self:CheckIsSelectOrConfirm(config.DisplayMode[1])

	if not isShow then
		return
	end

	local content = nil
	local argsToPass = {
		config.Content
	}

	if args then
		for _, v in pairs(args) do
			table.insert(argsToPass, v)
		end
	end

	local status = nil
	status, content = pcall(self.GetContent, unpack(argsToPass))

	if not status then
		print_error("ConfigId:", config.Id, content)

		return
	end

	local function callback(state)
		gClientToGameDelegate:DoMessageCallback(mid, state, para).Callback = function (err)
			if err ~= MessageConfig.Ok then
				gDisplayMessageMgr:ShowMessage(err)
			end
		end
	end

	if btnNum == 1 then
		self:ShowContent(config, content, function ()
			callback(M.MessageCallbackState.Confirm)
		end, nil)
	elseif btnNum == 2 then
		self:ShowContent(config, content, function ()
			callback(M.MessageCallbackState.Confirm)
		end, function ()
			callback(M.MessageCallbackState.Cancel)
		end)
	end
end

function M:CheckIsSelectOrConfirm(msgType)
	print_debug(msgType)

	if msgType == gDisplayMessageId.SELECT or msgType == gDisplayMessageId.SELECT_FORCE or msgType == gDisplayMessageId.SELECT_WITH_CLOSE then
		return true, 2
	elseif msgType == gDisplayMessageId.CONFIRM or msgType == gDisplayMessageId.CONFIRM_FORCE then
		return true, 1
	end

	return false
end

function M:DisplayServerMessageId(mid, ...)
	if mid == 0 then
		return
	end

	print_notice("DisplayServerMessageId", mid)

	local config = self:GetMessageConfig(mid)

	if not config then
		return
	end

	if string.is_null_or_empty(config.Content) then
		return
	end

	local content = self.GetContent(config.Content, ...)

	self:ShowContent(config, content, nil, nil)
end

function M:ShowMessage(mid, rightCallback, leftCallback, ...)
	local config = self:GetMessageConfig(mid)

	if not config then
		return
	end

	local status, content = pcall(self.GetContent, config.Content, ...)

	if not status then
		print_error("ConfigId:", config.Id, content)

		return
	end

	self:ShowContent(config, content, rightCallback, leftCallback, mid)
end

function M:ShowMessageTriple(mid, rightCallback, centerCallback, leftCallback, ...)
	local config = self:GetMessageConfig(mid)

	if not config then
		return
	end

	local status, content = pcall(self.GetContent, config.Content, ...)

	if not status then
		print_error("ConfigId:", config.Id, content)

		return
	end

	local params = {
		mid = mid,
		msgType = gDisplayMessageId.TRIPLE_SELECT,
		confirmBtnText = config.ModalBoxButton[1],
		centerBtnText = config.ModalBoxButton[2],
		cancelBtnText = config.ModalBoxButton[3],
		tips1Text = content,
		btnConfirmCallback = leftCallback,
		btnCancelCallback = rightCallback,
		btnCenterCallback = centerCallback
	}

	self:ShowBomb(params)
end

function M:ShowRewardList(rewardRenderDataList)
	local params = {
		msgType = gDisplayMessageId.CONFIRM,
		rewardRenderDataList = rewardRenderDataList
	}

	self:ShowBomb(params)
end

function M:ShowContent(config, content, leftCallback, rightCallback, mid)
	local showCloseBtn = false

	if config.Deletable then
		log_to_popo(gString.Format("deletable message code in use code=%d", config.Id), "hzzhaojiajun", "6475613")
	end

	if not self:CheckMessageShow(config) then
		return
	end

	for i = 1, #config.DisplayMode do
		local msgType = config.DisplayMode[i]

		if msgType == gDisplayMessageId.SELECT or msgType == gDisplayMessageId.SELECT_FORCE or msgType == gDisplayMessageId.SELECT_WITH_CLOSE or msgType == gDisplayMessageId.SELECT_WITH_CHECKBOX or msgType == gDisplayMessageId.SELECT_WITH_CHECKBOX_DNOTSHOWAGAIN then
			self:ShowMessageContent(content, msgType, nil, leftCallback, rightCallback, config.ModalBoxButton[1], config.ModalBoxButton[2], mid, showCloseBtn, config.BlurBgType)
		elseif msgType == gDisplayMessageId.CONFIRM or msgType == gDisplayMessageId.CONFIRM_FORCE then
			self:ShowMessageContent(content, msgType, nil, leftCallback, rightCallback, config.ModalBoxButton[1], nil, mid, showCloseBtn, config.BlurBgType)
		else
			self:ShowMessageContent(content, msgType, config.HideMessageAfter, leftCallback, rightCallback, nil, nil, mid, showCloseBtn, config.BlurBgType)
		end
	end

	if #config.DisplayMode == 0 then
		self:ShowMessageContent(content, gDisplayMessageId.QUEUE, config.HideMessageAfter, leftCallback, rightCallback, nil, nil, mid, showCloseBtn, config.BlurBgType)
	end

	if config.PlayEffect and config.PlayEffect > 0 then
		gCS.EffectMgr:PlayEffectsForUnitId(gDataSetManager.myUnit.pid, config.PlayEffect, Vector3.zero)
	end
end

function M:ShowMessageContent(content, msgType, autoHide, leftCallback, rightCallback, leftString, rightString, mid, showCloseBtn, blurBgType)
	if not self:CheckCanMsgShow(msgType, mid) then
		return
	end

	if msgType == nil then
		msgType = gDisplayMessageId.QUEUE
	end

	if gTimelineManager:IsPlayingCutscene() and msgType == gDisplayMessageId.QUEUE then
		return
	end

	if msgType == gDisplayMessageId.QUEUE then
		self:MsgEnqueue(content, autoHide)
	elseif msgType == gDisplayMessageId.SELECT_WITH_CHECKBOX_DNOTSHOWAGAIN then
		local config, preference = self:GetMessageConfig(mid)
		local checkBoxText = nil

		if config.ModalBoxButton ~= nil then
			checkBoxText = config.ModalBoxButton[3]
		end

		if checkBoxText == nil or checkBoxText == "" then
			checkBoxText = LTConfig.TextScriptTextConfig.GetConfig(89900858).Text
		end
	elseif msgType == gDisplayMessageId.SELECT_WITH_CHECKBOX then
		local config, preference = self:GetMessageConfig(mid)
		local checkBoxText = nil

		if config.ModalBoxButton ~= nil then
			checkBoxText = config.ModalBoxButton[3]
		end
	elseif msgType == gDisplayMessageId.SELECT or msgType == gDisplayMessageId.SELECT_WITH_CLOSE or msgType == gDisplayMessageId.SELECT_FORCE then
		local params = {
			mid = mid,
			msgType = msgType,
			confirmBtnText = leftString,
			cancelBtnText = rightString,
			tips1Text = content,
			btnConfirmCallback = leftCallback,
			btnCancelCallback = rightCallback,
			isShowCloseBtn = showCloseBtn
		}

		self:ShowBomb(params)

		return
	elseif msgType == gDisplayMessageId.CONFIRM or msgType == gDisplayMessageId.CONFIRM_FORCE then
		local params = {
			mid = mid,
			confirmBtnText = leftString,
			tips1Text = content,
			btnConfirmCallback = leftCallback,
			isShowCloseBtn = showCloseBtn
		}

		self:ShowBomb(params)
	end

	gMessageManager:SendMessage(gEventConstants.ON_MESSAGE_DISPLAY, {
		content,
		msgType,
		mid
	})
end

function M:ShowMessageContentDebug(content)
	if gCS.LuaUtils.IsPublish then
		return
	end

	self:ShowMessageContent(content)
end

function M:ShowMessExplain(mid, callback)
	gPanelManager:CheckShow(gPanelId.AGE_WARN_PANEL, {
		id = mid,
		callback = callback
	})
end

function M:CheckCanMsgShow(msgType, mid)
	if not self.isActive then
		if mid and array.contains(GameConfig.PreRaidCanShowMsgWhiteList, mid) then
			return true
		end

		if msgType == gDisplayMessageId.QUEUE then
			return false
		end
	end

	return true
end

function M:OnBeforeSwitchScene(switchType)
	self.ClearDelayTimeFunc()

	if gSwitchSceneType.Image <= switchType then
		self:SetState(true)
	end
end

function M:SetState(isActive)
	self.isActive = isActive
end

function M:MsgEnqueue(message, autoHideTime)
	if gLuaUIMgr.commonQueueMessage then
		gLuaUIMgr.commonQueueMessage:ShowAutoHideMessage(message, autoHideTime)
	end
end

function M:HideMessage(mid)
	local config = MessageConfig.GetConfig(mid)

	for i = 1, #config.DisplayMode do
		local msgType = config.DisplayMode[i]

		self:HideMessageType(msgType)
	end
end

function M:HideMessageType(msgType)
	if msgType == nil then
		msgType = gDisplayMessageId.SELECT
	end

	if msgType == gDisplayMessageId.SELECT or msgType == gDisplayMessageId.SELECT_FORCE then
		self:CloseBombAll()
	elseif msgType == gDisplayMessageId.CONFIRM or msgType == gDisplayMessageId.CONFIRM_FORCE then
		self:CloseBombAll()
	elseif msgType == gDisplayMessageId.CONFIRMNOBUTTON then
		gLuaUIMgr.commonBombBox.Hide()
	end
end

function M:GetMessageConfig(mid)
	local config = MessageConfig.GetConfig(mid)

	if not config then
		if mid ~= nil then
			print_error("DisplayServerMessageId error not found err=", gCS.Error.GetNameById(mid))
		else
			print_error("DisplayServerMessageId error not found 可能策划删表了，展开浏览详情")
		end

		return nil
	end

	if self:InCD(mid, config.CD) == true then
		return
	end

	self.cds[mid] = Time.time

	if self:IsIgnoreOnce(mid) then
		return
	end

	return config
end

function M.GetContent(prototype, ...)
	if prototype == nil or string.len(prototype) == 0 then
		return ""
	else
		return gString.Format(prototype, ...)
	end
end

function M:InCD(mid, cd)
	if cd ~= 0 and self.cds[mid] ~= nil then
		local last = self.cds[mid]

		return cd > Time.time - last
	else
		return false
	end
end

function M:IsIgnoreOnce(mid)
	if self.ignoreOnce[mid] then
		self.ignoreOnce[mid] = nil

		return true
	end

	return false
end

M.MESSAGE_PANELS = {
	[gPanelId.WAITING_MSG] = true
}
M.BombStack = {}

function M:ShowBomb(params)
	table.insert(M.BombStack, params)
	gPanelManager:CheckShow(gPanelId.S_COMMON_BOMB_PANEL, params)
end

function M:CloseBomb()
	table.remove(M.BombStack)

	if #M.BombStack > 0 then
		gPanelManager:CheckShow(gPanelId.S_COMMON_BOMB_PANEL, M.BombStack[#M.BombStack])

		return
	end

	gPanelManager:Close(gPanelId.S_COMMON_BOMB_PANEL)
end

function M:CloseBombAll()
	M.BombStack = {}

	gPanelManager:Close(gPanelId.S_COMMON_BOMB_PANEL)
end

function M:CheckMessageShow(cfg)
	if cfg.DisplayMode[1] == gDisplayMessageId.DEBUG then
		print_warn("CheckMessageShow cfg.DisplayMode == gDisplayMessageId.DEBUG")
		print_warn(cfg.Content)

		return false
	end

	if cfg.DisplayMode[1] ~= gDisplayMessageId.QUEUE then
		return true
	end

	if not cfg or not cfg.EffectiveVersion then
		print_warn("message 未显示 = ", cfg.Content)

		return false
	end

	local show = false

	for _, value in pairs(cfg.EffectiveVersion) do
		show = self:CheckEnv(value)

		if show then
			return true
		end
	end

	print_warn("message 未显示 = ", cfg.Content)

	return show
end

function M:CheckEnv(value)
	if value == self.EnvType.Editor then
		return gCS.LuaUtils.IsOnEditor
	elseif value == self.EnvType.Publish then
		return gCS.LuaUtils.IsPublish
	elseif value == self.EnvType.Debug then
		return gCS.LuaUtils.IsDebug
	elseif value == self.EnvType.Release then
		return not gCS.LuaUtils.IsDebug
	end

	return false
end

gDisplayMessageMgr = M:GetInstance()
