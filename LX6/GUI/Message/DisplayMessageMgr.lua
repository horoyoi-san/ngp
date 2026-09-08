-- Original chunk: @Lua\LuaFiles\LX6\GUI\Message\DisplayMessageMgr.lua
-- Decompiled from: 00168_DisplayMessageMgr.lua_5ed5f9a5abb6.luajit

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
	CONFIRM_ASYNC = "async",
	BlurBgType = {
		[")a\\xbe\\x80\\x8fX"] = 1,
		["pDigK1!"] = 2,
		["\\xafDJ"] = 0
	},
	EnvType = {
		["\\xe9\\xce7\\xf9"] = 4,
		["9L\\x98\\x9a\\x8cS"] = 1,
		["\\xeb\\xde7\\xf4"] = 3,
		["i\\xab\\xa0\\xba\\xb1"] = 2
	},
	GetInstance = function (self)
		if self.instance ~= nil then
			local constructor = function()
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
		["?I\\x9f\\x8d\\x86M"] = 1,
		["\\xfa\\xd46\\xfc"] = 0,
		["n\\xa2\\xad\\xbc\\xb3"] = 2
	},
	OnInit = function (self)
		gMessageManager:AddMessageListener(gEventConstants.MESSAGE_CLEAR, self.ClearDelayTimeFunc)
	end,
	ClearDelayTimeFunc = function ()
		for key, value in pairs(gDisplayMessageMgr.delayFuncMap) do
			value.Stop(value)

			value = nil
			gDisplayMessageMgr.delayFuncMap[key] = nil
		end

		gDisplayMessageMgr.queueCache = {}
		gDisplayMessageMgr.currentShowNum = 0
	end
}

M.ShowServerMessage = function(self, mid, args)
	local config, preference = self.GetMessageConfig(self, mid)

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

	self.ShowContent(self, config, content, nil, , mid)
end

M.DisplayServerMessageId_NeedCallback = function(self, mid, args, para)
	local config = MessageConfig.GetConfig(mid)

	if not config or string.is_null_or_empty(config.Content) then
		return
	end

	local isShow, btnNum = self.CheckIsSelectOrConfirm(self, config.DisplayMode[1])

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

	if gCS.LuaUtils.IsDebug and LTConfig.TableGetLanguage() == "CN" then
		content = "(如果下面文本中包含部分未本地化内容，可能是因为文本是服务器发的，不支持本地化，需要改成客户端 ShowMessage)\n" .. content
	end

	local callback = function(state)
		slot1 = gClientToGameDelegate

		slot1:DoMessageCallback(mid, state, para).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:ShowMessage(err)
			end
		end
	end

	if btnNum ~= 1 then
		self.ShowContent(self, config, content, function ()
			callback(M.MessageCallbackState.Confirm)
		end, nil)
	elseif btnNum ~= 2 then
		self.ShowContent(self, config, content, function ()
			callback(M.MessageCallbackState.Confirm)
		end, function ()
			callback(M.MessageCallbackState.Cancel)
		end)
	end
end

M.CheckIsSelectOrConfirm = function(self, msgType)
	print_debug(msgType)

	if msgType ~= gDisplayMessageId.SELECT or msgType ~= gDisplayMessageId.SELECT_FORCE or msgType ~= gDisplayMessageId.SELECT_WITH_CLOSE then
		return true, 2
	elseif msgType ~= gDisplayMessageId.CONFIRM or msgType ~= gDisplayMessageId.CONFIRM_FORCE then
		return true, 1
	end

	return false
end

M.DisplayServerMessageId = function(self, mid, ...)
	if mid ~= 0 then
		return
	end

	print_notice("DisplayServerMessageId", mid)

	local config = self.GetMessageConfig(self, mid)

	if not config then
		return
	end

	if string.is_null_or_empty(config.Content) then
		return
	end

	local ok, content = pcall(self.GetContent, config.Content, ...)

	if not ok then
		print_error("@linminghe DisplayServerMessageId error 参数mid", mid, ...)

		return
	end

	self.ShowContent(self, config, content, nil, )
end

M.ShowMessage = function(self, mid, rightCallback, leftCallback, ...)
	local config = self.GetMessageConfig(self, mid)

	if not config then
		return
	end

	local status, content = pcall(self.GetContent, config.Content, ...)

	if not status then
		print_error("ConfigId:", config.Id, content)

		return
	end

	self.ShowContent(self, config, content, rightCallback, leftCallback, mid)
end

M.ShowMessageTriple = function(self, mid, rightCallback, centerCallback, leftCallback, ...)
	local config = self.GetMessageConfig(self, mid)

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
		btnConfirmCallback = rightCallback,
		btnCancelCallback = leftCallback,
		btnCenterCallback = centerCallback
	}

	self.ShowBomb(self, params)
end

M.ShowRewardList = function(self, rewardRenderDataList)
	local params = {
		msgType = gDisplayMessageId.CONFIRM,
		rewardRenderDataList = rewardRenderDataList
	}

	self.ShowBomb(self, params)
end

M.ShowInputBox = function(self, mid, rightCallback, leftCallback, isShowCopy, defaultInputText, ...)
	local config = self.GetMessageConfig(self, mid)

	if not config then
		return
	end

	local status, content = pcall(self.GetContent, config.Content, ...)

	if not status then
		print_error("ConfigId:", config.Id, content)

		return
	end

	local params = {
		["\\xd0\\xc8=1\\xe5"] = true,
		mid = mid,
		isShowCopy = isShowCopy,
		confirmBtnText = config.ModalBoxButton[1],
		cancelBtnText = config.ModalBoxButton[2],
		titleText = content,
		exceedLengthMsg = MessageConfig.GetConfig(MessageConfig.RedemptionCodeMaxLength).Content,
		exceedLength = GameConfig.RedemptionCodeMaxLength,
		btnConfirmCallback = leftCallback,
		btnCancelCallback = rightCallback,
		defaultInputText = defaultInputText
	}

	self.ShowBomb(self, params)
end

M.ShowContent = function(self, config, content, leftCallback, rightCallback, mid)
	local showCloseBtn = false

	if config.Deletable then
		log_to_popo(gString.Format("deletable message code in use code=%d", config.Id), "hzzhaojiajun", "6475613")
	end

	if not self.CheckMessageShow(self, config) then
		return
	end

	for i = 1, #config.DisplayMode do
		local msgType = config.DisplayMode[i]

		if msgType ~= gDisplayMessageId.SELECT or msgType ~= gDisplayMessageId.SELECT_FORCE or msgType ~= gDisplayMessageId.SELECT_WITH_CLOSE or msgType ~= gDisplayMessageId.SELECT_WITH_CHECKBOX or msgType ~= gDisplayMessageId.SELECT_WITH_CHECKBOX_DNOTSHOWAGAIN then
			self.ShowMessageContent(self, content, msgType, nil, leftCallback, rightCallback, config.ModalBoxButton[1], config.ModalBoxButton[2], mid, showCloseBtn, config.BlurBgType)
		elseif msgType ~= gDisplayMessageId.CONFIRM or msgType ~= gDisplayMessageId.CONFIRM_FORCE then
			self.ShowMessageContent(self, content, msgType, nil, leftCallback, rightCallback, config.ModalBoxButton[1], nil, mid, showCloseBtn, config.BlurBgType)
		else
			self.ShowMessageContent(self, content, msgType, config.HideMessageAfter, leftCallback, rightCallback, nil, , mid, showCloseBtn, config.BlurBgType)
		end
	end

	if #config.DisplayMode ~= 0 then
		self.ShowMessageContent(self, content, gDisplayMessageId.QUEUE, config.HideMessageAfter, leftCallback, rightCallback, nil, , mid, showCloseBtn, config.BlurBgType)
	end

	if config.PlayEffect and config.PlayEffect <= 0 then
		gCS.EffectMgr:PlayEffectsForUnitId(gDataSetManager.myUnit.pid, config.PlayEffect, LX6.Effect.EffectPlayTag.UI, Vector3.zero)
	end
end

M.ShowMessageContent = function(self, content, msgType, autoHide, leftCallback, rightCallback, leftString, rightString, mid, showCloseBtn, blurBgType)
	if not self.CheckCanMsgShow(self, msgType, mid) then
		return
	end

	if msgType ~= nil then
		msgType = gDisplayMessageId.QUEUE
	end

	if gTimelineManager:IsPlayingCutscene() and msgType ~= gDisplayMessageId.QUEUE then
		return
	end

	if msgType ~= gDisplayMessageId.QUEUE then
		self.MsgEnqueue(self, content, autoHide)
	elseif msgType ~= gDisplayMessageId.SELECT_WITH_CHECKBOX_DNOTSHOWAGAIN then
		local config, preference = self.GetMessageConfig(self, mid)
		local checkBoxText = nil

		if config.ModalBoxButton == nil then
			checkBoxText = config.ModalBoxButton[3]
		end

		if checkBoxText ~= nil or checkBoxText ~= "" then
			checkBoxText = LTConfig.TextScriptTextConfig.GetConfig(89900858).Text
		end
	elseif msgType ~= gDisplayMessageId.SELECT_WITH_CHECKBOX then
		local config, preference = self.GetMessageConfig(self, mid)
		local checkBoxText = nil

		if config.ModalBoxButton == nil then
			checkBoxText = config.ModalBoxButton[3]
		end
	elseif msgType ~= gDisplayMessageId.SELECT or msgType ~= gDisplayMessageId.SELECT_WITH_CLOSE or msgType ~= gDisplayMessageId.SELECT_FORCE then
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

		self.ShowBomb(self, params)

		return
	elseif msgType ~= gDisplayMessageId.CONFIRM or msgType ~= gDisplayMessageId.CONFIRM_FORCE then
		local params = {
			mid = mid,
			msgType = msgType,
			confirmBtnText = leftString,
			tips1Text = content,
			btnConfirmCallback = leftCallback,
			isShowCloseBtn = showCloseBtn
		}

		self.ShowBomb(self, params)
	end

	gMessageManager:SendMessage(gEventConstants.ON_MESSAGE_DISPLAY, {
		content,
		msgType,
		mid
	})
end

M.ShowMessageContentDebug = function(self, content)
	if gCS.LuaUtils.IsPublish then
		return
	end

	self.ShowMessageContent(self, content)
end

M.ShowMessExplain = function(self, mid, callback)
	gPanelManager:CheckShow(gPanelId.AGE_WARN_PANEL, {
		id = mid,
		callback = callback
	})
end

M.ShowMessExplainSub = function(self, mid, callback)
	gPanelManager:CheckShow(gPanelId.ITEM_INFO_ONLY_TEXT_PANEL, {
		id = mid,
		closeCallback = callback
	})
end

M.CheckCanMsgShow = function(self, msgType, mid)
	if not self.isActive then
		if mid and array.contains(GameConfig.PreRaidCanShowMsgWhiteList, mid) then
			return true
		end

		if msgType ~= gDisplayMessageId.QUEUE then
			return false
		end
	end

	return true
end

M.OnBeforeSwitchScene = function(self, switchType)
	self.ClearDelayTimeFunc()

	if gSwitchSceneType.SameImage < switchType then
		self.SetState(self, true)
	end
end

M.SetState = function(self, isActive)
	self.isActive = isActive
end

M.MsgEnqueue = function(self, message, autoHideTime)
	if gLuaUIMgr.commonQueueMessage then
		gLuaUIMgr.commonQueueMessage:ShowAutoHideMessage(message, autoHideTime)
	end
end

M.HideMessage = function(self, mid)
	local config = MessageConfig.GetConfig(mid)

	for i = 1, #config.DisplayMode do
		local msgType = config.DisplayMode[i]

		self.HideMessageType(self, msgType)
	end
end

M.HideMessageType = function(self, msgType)
	if msgType ~= nil then
		msgType = gDisplayMessageId.SELECT
	end

	if msgType ~= gDisplayMessageId.SELECT or msgType ~= gDisplayMessageId.SELECT_FORCE then
		self.CloseBombAll(self)
	elseif msgType ~= gDisplayMessageId.CONFIRM or msgType ~= gDisplayMessageId.CONFIRM_FORCE then
		self.CloseBombAll(self)
	elseif msgType ~= gDisplayMessageId.CONFIRMNOBUTTON then
		gLuaUIMgr.commonBombBox.Hide()
	end
end

M.GetMessageConfig = function(self, mid)
	local config = MessageConfig.GetConfig(mid)

	if not config then
		if mid == nil then
			print_error("DisplayServerMessageId error not found err=", gCS.Error.GetNameById(mid))
		else
			print_error("DisplayServerMessageId error not found 可能策划删表了，展开浏览详情")
		end

		return nil
	end

	if self.InCD(self, mid, config.CD) ~= true then
		return
	end

	self.cds[mid] = Time.time

	if self.IsIgnoreOnce(self, mid) then
		return
	end

	return config
end

M.GetContent = function(prototype, ...)
	if prototype ~= nil or string.len(prototype) ~= 0 then
		return ""
	else
		return gString.Format(prototype, ...)
	end
end

M.InCD = function(self, mid, cd)
	if cd == 0 and self.cds[mid] == nil then
		local last = self.cds[mid]

		return cd >= Time.time - last
	else
		return false
	end
end

M.IsIgnoreOnce = function(self, mid)
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
M.MiddleWindowActive = false

M.IsMiddleWindowSupported = function(self, msgType)
	if msgType ~= gDisplayMessageId.CONFIRM or msgType ~= gDisplayMessageId.CONFIRM_FORCE or msgType ~= gDisplayMessageId.SELECT or msgType ~= gDisplayMessageId.SELECT_FORCE or msgType ~= gDisplayMessageId.SELECT_WITH_CLOSE then
		return true
	end

	return false
end

M.ShowMiddleWindow = function(self, params)
	M.MiddleWindowActive = true

	gPanelManager:CheckShow(gPanelId.COMMON_WINDOW_MIDDLE, params)
end

M.CloseMiddleWindow = function(self)
	M.MiddleWindowActive = false

	gPanelManager:Close(gPanelId.COMMON_WINDOW_MIDDLE)

	if #M.BombStack <= 0 then
		gPanelManager:CheckShow(gPanelId.S_COMMON_BOMB_PANEL, M.BombStack[#M.BombStack])
	end
end

M.ShowBomb = function(self, params)
	if gCS.LuaUtils.IsNonMobileAdaptive() and params.msgType and self.IsMiddleWindowSupported(self, params.msgType) and not params.isInput and table.isNilOrEmpty(params.costItemList) then
		self.ShowMiddleWindow(self, params)

		return
	end

	table.insert(M.BombStack, params)
	gCommonItemManager:CloseItemToolTips()
	gPanelManager:CheckShow(gPanelId.S_COMMON_BOMB_PANEL, params)
end

M.CloseBomb = function(self)
	if M.MiddleWindowActive then
		self.CloseMiddleWindow(self)

		return
	end

	table.remove(M.BombStack)

	if #M.BombStack <= 0 then
		gPanelManager:CheckShow(gPanelId.S_COMMON_BOMB_PANEL, M.BombStack[#M.BombStack])

		return
	end

	gPanelManager:Close(gPanelId.S_COMMON_BOMB_PANEL)
end

M.CloseBombAll = function(self)
	M.BombStack = {}
	M.MiddleWindowActive = false

	gPanelManager:Close(gPanelId.COMMON_WINDOW_MIDDLE)
	gPanelManager:Close(gPanelId.S_COMMON_BOMB_PANEL)
end

M.CheckMessageShow = function(self, cfg)
	if cfg.DisplayMode[1] ~= gDisplayMessageId.DEBUG then
		print_warn("CheckMessageShow cfg.DisplayMode == gDisplayMessageId.DEBUG")
		print_warn(cfg.Content)

		return false
	end

	if cfg.DisplayMode[1] == gDisplayMessageId.QUEUE then
		return true
	end

	if not cfg or not cfg.EffectiveVersion then
		print_warn("message 未显示 = ", cfg.Content)

		return false
	end

	local show = false

	for _, value in pairs(cfg.EffectiveVersion) do
		show = self.CheckEnv(self, value)

		if show then
			return true
		end
	end

	print_warn("message 未显示 = ", cfg.Content)

	return show
end

M.CheckEnv = function(self, value)
	if value ~= self.EnvType.Editor then
		return gCS.LuaUtils.IsOnEditor
	elseif value ~= self.EnvType.Publish then
		return gCS.LuaUtils.IsPublish
	elseif value ~= self.EnvType.Debug then
		return gCS.LuaUtils.IsDebug
	elseif value ~= self.EnvType.Release then
		return not gCS.LuaUtils.IsDebug
	end

	return false
end

gDisplayMessageMgr = M.GetInstance(M)
