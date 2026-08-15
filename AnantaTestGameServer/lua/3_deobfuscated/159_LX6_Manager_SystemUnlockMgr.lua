local SystemUnlockConfig = LTConfig.SystemUnlockConfig
C_SystemUnlockMgr = DefClass("C_SystemUnlockMgr", C_SystemUnlockMgr)
local M = C_SystemUnlockMgr

function M:ctor()
	self._unlockSystems = {}
end

function M:IsUnlock(id)
	return self._unlockSystems[id] or false
end

function M:IsUnlockGroup(ids)
	if table.isNilOrEmpty(ids) then
		return true
	end

	for i = 1, #ids do
		if not self:IsUnlock(ids[i]) then
			return false
		end
	end

	return true
end

function M:OnLogin()
	LX6.Manager.SystemUnlockMgr.Instance:ClearData()

	self._unlockSystems = {}

	for id, isUnlock in pairs(gPlayerManager.infoMinor.bindData.UnlockSystems) do
		self._unlockSystems[id] = isUnlock
	end

	for i = 0, SystemUnlockConfig.count - 1 do
		local cfg = SystemUnlockConfig.LoadAt(i)

		self:SyncUnlockStateChange(cfg.Id, false)
	end
end

function M:SetUnlockSystem(ids)
	local oldUnlockSystems = self._unlockSystems
	self._unlockSystems = {}
	local changeSystems = {}

	for i = 1, #ids do
		local id = ids[i]
		self._unlockSystems[id] = true

		if not oldUnlockSystems[id] then
			changeSystems[id] = true
		end
	end

	for id, _ in pairs(oldUnlockSystems) do
		if not self._unlockSystems[id] then
			changeSystems[id] = false
		end
	end

	for id, _ in pairs(changeSystems) do
		self:SyncUnlockStateChange(id, true)
	end
end

function M:SyncUnlockStateChange(id, sendMessage)
	local unlocked = self._unlockSystems[id]

	LX6.Manager.SystemUnlockMgr.Instance:SetUnlock(id, unlocked)

	local trigger = nil

	if unlocked then
		trigger = gSystemUnlockTrigger[id] and gSystemUnlockTrigger[id].OnUnlock
	else
		trigger = gSystemUnlockTrigger[id] and gSystemUnlockTrigger[id].OnLock
	end

	if trigger then
		local ok, err = xpcall(trigger, tolua.traceback)

		if not ok then
			print_error(err)
		end
	end

	if unlocked and sendMessage then
		self:CheckPopup(id)
	end

	if id == SystemUnlockConfig.Survey then
		gNewMailsMgr:CheckSurveyRead()
	end

	if sendMessage then
		gMessageManager:SendMessage(gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE, id)
	end
end

gSystemUnlockTrigger = {
	[SystemUnlockConfig.AirCrush] = {
		OnUnlock = function ()
			gCS.LuaUtils.ForbiddenAirRush(false)
		end,
		OnLock = function ()
			gCS.LuaUtils.ForbiddenAirRush(true)
		end
	},
	[SystemUnlockConfig.FeiSuoUnlock] = {
		OnUnlock = function ()
			gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.Unlock, false)
		end,
		OnLock = function ()
			gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.Unlock, true)
		end
	}
}

function M:CheckPopup(id)
	local cfg = SystemUnlockConfig.GetConfig(id)

	if not cfg then
		return
	end

	if cfg.PopupId and cfg.PopupId > 0 then
		local ele = {
			PopupPic = cfg.PopupPic,
			PopupName = cfg.PopupName,
			id = id
		}

		gNewPopupManager:PushPopup(cfg.PopupId, ele)
	end
end

gSystemUnlockMgr = gSystemUnlockMgr or C_SystemUnlockMgr.new()
