local CommonInfoPanelUtils = {
	IsPanelShowing = false
}
local this = CommonInfoPanelUtils

function CommonInfoPanelUtils._AddCallback(origCallback, addCallback)
	if origCallback then
		return function ()
			origCallback()
			addCallback()
		end
	else
		return addCallback
	end
end

function CommonInfoPanelUtils.OpenCommonInfoPanel(data)
	if table.isNilOrEmpty(data) then
		print_error("CommonInfoPanel: data is nil or empty")

		return
	end

	local firstItem = data[1]
	local firstItemCfg = LTConfig.InformationConfig.GetConfig(firstItem and firstItem.id)

	if firstItemCfg == nil then
		print_error("@liulijun04 CommonInfoPanel: data is nil or empty", data)
	end

	local typeCfg = LTConfig.InformationTypeDefineConfig.GetConfig(firstItemCfg.Type)
	local panelId = typeCfg.PanelId
	data.panelTypeCfg = typeCfg
	data.onShowCallback = this._AddCallback(data.onShowCallback, this.OnPanelShow)
	data.onCloseCallback = this._AddCallback(data.onCloseCallback, this.OnPanelClose)

	if typeCfg.CloseUp then
		data.isCloseUpType = true
		data.onCloseCallback = this._AddCallback(data.onCloseCallback, this.OnExitCloseUp)
	end

	if typeCfg.HidePlayerDelay >= 0 then
		local tempCo = nil
		data.onShowCallback = this._AddCallback(data.onShowCallback, function ()
			tempCo = coroutine.start(function ()
				coroutine.wait(typeCfg.HidePlayerDelay)
				this.HidePlayer(true)
			end)
		end)
		data.onCloseCallback = this._AddCallback(data.onCloseCallback, function ()
			coroutine.stop(tempCo)
			this.HidePlayer(false)
		end)
	end

	if typeCfg.PlayPhoneAction then
		LX6.GUI.CommonInfoPanelUtils.ReplacePhone(firstItemCfg.Id)

		data.onShowCallback = this._AddCallback(data.onShowCallback, this.PlayPhoneAction)
		data.onCloseCallback = this._AddCallback(data.onCloseCallback, this.ExitPhoneAction)
	end

	if typeCfg.CameraFollow then
		data.onShowCallback = this._AddCallback(data.onShowCallback, this.EnableCameraFollow)
		data.onCloseCallback = this._AddCallback(data.onCloseCallback, this.DisableCameraFollow)
	end

	if typeCfg.CanMove then
		data.onShowCallback = this._AddCallback(data.onShowCallback, function ()
			return
		end)
		data.onCloseCallback = this._AddCallback(data.onCloseCallback, function ()
			return
		end)
	end

	gPanelManager:CheckShow(panelId, data)

	return panelId
end

function CommonInfoPanelUtils:OpenCommonInfoPanelCs(data)
	data = data:ToTable()

	for k, v in ipairs(data) do
		data[k] = v:ToTable()
	end

	this.OpenCommonInfoPanel(data)
end

function CommonInfoPanelUtils.OpenCommonInfoPanelWithoutTarget(data)
	data[1] = {
		id = data.id
	}
	local itemCfg = LTConfig.InformationConfig.GetConfig(data.id)
	local type = itemCfg.Type

	if type == LTConfig.InformationTypeDefineConfig.Short or type == LTConfig.InformationTypeDefineConfig.ShortCloseUp then
		local err = "CommonInfoPanel 通用信息展示: 不支持 Spoon 拉起此类型！请策划检查 Id = " .. tostring(data.id)

		print_error_without_stack(err)

		if gCS.LuaUtils.IsOnEditor then
			gDisplayMessageMgr:ShowMessageContent(err)
		end

		return
	end

	return this.OpenCommonInfoPanel(data)
end

function CommonInfoPanelUtils:OpenCommonInfoPanelWithoutTargetCs(args)
	local bookId = args[0]
	local onCloseCallback = args[1]

	local function onCloseCallbackWrap()
		onCloseCallback:DynamicInvoke()
	end

	return this.OpenCommonInfoPanelWithoutTarget({
		id = bookId,
		onCloseCallback = onCloseCallbackWrap
	})
end

function CommonInfoPanelUtils.OnExitCloseUp()
	local duration = LTConfig.InformationConfig.BanActionDuration

	if duration <= 0 then
		return
	end

	local states = {
		LTConfig.UnitStateConfig.HideBattleUISprint,
		LTConfig.UnitStateConfig.HideBattleUIJump,
		LTConfig.UnitStateConfig.ForbidChangeFightSpirit
	}

	if gCS.MyPlayerManager.PlayerUnit then
		for _, state in ipairs(states) do
			gCS.UnitStateMgr:AddClientState(gCS.MyPlayerManager.PlayerUnit.Pid, state, 999999)
		end
	end

	LX6.Manager.GameInputManager.SetDisableInput(gBanId.COMMON_INFO_PANELS, false, false, true)

	if this.resumeInputCo then
		coroutine.stop(this.resumeInputCo)
	end

	this.resumeInputCo = coroutine.start(function ()
		coroutine.wait(duration)

		if gCS.MyPlayerManager.PlayerUnit then
			for _, state in ipairs(states) do
				gCS.UnitStateMgr:RemoveClientState(gCS.MyPlayerManager.PlayerUnit.Pid, state)
			end
		end

		LX6.Manager.GameInputManager.SetEnableInput(gBanId.COMMON_INFO_PANELS)
	end)
end

local TransitionMgr = gCS.TransitionMgr

function CommonInfoPanelUtils.PlayPhoneAction()
	TransitionMgr.IsPlayPhoneAction = true
	TransitionMgr.IsExitPhoneAction = false

	gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

	TransitionMgr.showMainCube = true
end

function CommonInfoPanelUtils.ExitPhoneAction()
	TransitionMgr.IsPlayPhoneAction = false
	TransitionMgr.IsExitPhoneAction = true

	gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

	TransitionMgr.showMainCube = false

	LX6.GUI.CommonInfoPanelUtils.ReplacePhone(0)
end

function CommonInfoPanelUtils.EnableCameraFollow()
	gClientUtils.SetCameraRotateEnabled(false)
	gMessageManager:SendMessage(gEventConstants.ENABLE_CAMERA_FOLLOW, true)
end

function CommonInfoPanelUtils.DisableCameraFollow()
	gClientUtils.SetCameraRotateEnabled(true)
	gMessageManager:SendMessage(gEventConstants.ENABLE_CAMERA_FOLLOW, false)
end

function CommonInfoPanelUtils.HidePlayer(isHide)
	if gCS.MyPlayerManager.PlayerUnit then
		gCS.GuiUtils.CutSceneShowMyUnit(gCS.MyPlayerManager.PlayerUnit, not isHide, "CommonInfoPanel")
	end
end

function CommonInfoPanelUtils.OnPanelShow()
	this.IsPanelShowing = true
	L50.L50App.Scene.GamePlayUtils.commonInfoPanelShow = true

	gMainPhoneUtils.SetSGUIGlobalBarVisible(false)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_SHOW)
end

function CommonInfoPanelUtils.OnPanelClose()
	this.IsPanelShowing = false
	L50.L50App.Scene.GamePlayUtils.commonInfoPanelShow = false

	gMainPhoneUtils.SetSGUIGlobalBarVisible(true)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_HIDE)
end

gCommonInfoPanelUtils = CommonInfoPanelUtils
