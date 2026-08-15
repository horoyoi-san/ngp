local yield = coroutine.yield
local PanelMgrCsharp = LX6.Manager.PanelManager
local VisibleMode = LX6.Manager.VisibleMode
C_PanelManager = DefClass("C_PanelManager", C_PanelManager)
local M = C_PanelManager

function M:ctor()
	self.currVisibleMode = 0
	self.panelData = {}
	self.CHECK_RESULT = {
		UNLOCK = 1,
		DEAD = 2,
		SHOW = 0
	}
	self.resultToReason = {
		[0] = "界面正常打开",
		"界面未解锁!",
		"玩家死亡,可通过改配置流程,或者配置界面tag处理该特殊情况。"
	}
end

function M:Init()
	gCS.LuaUtils.SetEnhancedTouchSupport(true)

	PanelMgrCsharp.Instance.luaPanelMgr = self
end

function M:OnBeforeSwitchScene(switchType)
	return
end

function M:Preload(panelId)
	PanelMgrCsharp.Instance:Preload(panelId)
end

function M:ReleasePreload(panelId)
	PanelMgrCsharp.Instance:ReleasePreload(panelId)
end

function M:CheckShowInBackground(panelId, data, pos, dir, sizeWidth, sizeHeight)
	self.panelData[panelId] = data

	PanelMgrCsharp.Instance:CheckShowInBackgroundFromLua(panelId, pos, dir, sizeWidth or -1, sizeHeight or -1)

	return true
end

function M:CheckShow(panelId, data, pos, dir, sizeWidth, sizeHeight)
	if self:CheckCanPanelShow(panelId, data) ~= self.CHECK_RESULT.SHOW then
		return false
	end

	self.panelData[panelId] = data

	PanelMgrCsharp.Instance:CheckShowFromLua(panelId, pos, dir, sizeWidth or -1, sizeHeight or -1)

	return true
end

function M:CheckShowAsync(panelId, data, pos, dir, sizeWidth, sizeHeight)
	if self:CheckCanPanelShow(panelId, data) ~= self.CHECK_RESULT.SHOW then
		return false
	end

	self.panelData[panelId] = data

	PanelMgrCsharp.Instance:CheckShowAsyncFromLua(panelId, pos, dir, sizeWidth or -1, sizeHeight or -1)

	return true
end

function M:CheckShowSync(panelId, data, pos, dir, sizeWidth, sizeHeight)
	if self:CheckCanPanelShow(panelId, data) ~= self.CHECK_RESULT.SHOW then
		return false
	end

	self.panelData[panelId] = data

	PanelMgrCsharp.Instance:CheckShowSyncFromLua(panelId, pos, dir, sizeWidth or -1, sizeHeight or -1)

	return true
end

function M:Load(panelId, data, priority, skipWait, loadCallback)
	if priority == nil then
		priority = LX6.Engine.ResourceManager.LOAD_PRIORITY.PRIORITY_LEVEL2
	end

	if not skipWait then
		yield(nil)
	end

	self.panelData[panelId] = data
	local wait = PanelMgrCsharp.Instance:LoadFromLua(panelId, priority)

	if wait then
		yield(wait)
	end

	if loadCallback then
		loadCallback()
	end
end

function M:Close(panelId, data)
	if not gPanelEntry:GetEntry(panelId) then
		print_error("@chenhongrui01 Cannot find panel entry " .. panelId)

		return false
	end

	self:RemovePanelData(panelId)
	PanelMgrCsharp.Instance:CloseFromLua(panelId)
end

function M:Destroy(panelId, data)
	self:RemovePanelData(panelId)
	PanelMgrCsharp.Instance:CloseFromLua(panelId, true)
end

function M:ClearAll()
	PanelMgrCsharp.Instance:ClearAll()
end

function M:SetActiveById(id, visible)
	PanelMgrCsharp.SetPanelInBackground(id, not visible)
end

function M:IsPanelShowing(panelId)
	return PanelMgrCsharp.Instance:GetUIShowState(panelId)
end

function M:IsPanelVisible(panelId)
	return PanelMgrCsharp.IsPanelVisible(panelId)
end

function M:CloseAllFront()
	PanelMgrCsharp.Instance:CloseAllFront()
end

function M:SyncVisibleMode(mode)
	self.currVisibleMode = mode
end

function M:VisibleModeAll()
	return self.currVisibleMode == VisibleMode.All
end

function M:VisibleModeHUD()
	return self.currVisibleMode <= VisibleMode.HUD
end

function M:VisibleModeFront()
	return self.currVisibleMode <= VisibleMode.Front
end

function M:VisibleModeNotice()
	return self.currVisibleMode <= VisibleMode.Notice
end

function M:SwitchPanelContext(panel, contextId)
	PanelMgrCsharp.SwitchPanelContext(panel, contextId)
end

function M:SwitchContextPart(contextId, part, ctxDef, transition)
	PanelMgrCsharp.SwitchContextPart(contextId, part, ctxDef, transition or 0)
end

function M:PushPanelContext(panel, contextId)
	PanelMgrCsharp.PushPanelContext(panel, contextId)
end

function M:PopPanelContext(panel, contextId)
	PanelMgrCsharp.PopPanelContext(panel, contextId)
end

function M:HasFullscreen()
	return PanelMgrCsharp.Instance:HasFullscreen()
end

function M:HasFullscreenLayer(layer)
	return PanelMgrCsharp.Instance:HasFullscreenLayer(layer)
end

function M:IsLayerActive(layer)
	return PanelMgrCsharp.Instance:IsLayerActive(layer)
end

function M:SetLoadDataFromCs(panel, data)
	if self:CheckCanPanelShow(panel, data) ~= self.CHECK_RESULT.SHOW then
		return false
	end

	self.panelData[panel] = data

	return true
end

function M:RemovePanelData(panelId)
	local data = self.panelData[panelId]
	self.panelData[panelId] = nil

	return data
end

function M:CheckCanPanelShow(id, data)
	if not self:CheckPanelUnlock(id, data) then
		return self.CHECK_RESULT.UNLOCK
	end

	if not self:CheckPanelShowInDead(id, false) then
		return self.CHECK_RESULT.DEAD
	end

	return self.CHECK_RESULT.SHOW
end

function M:CheckPanelShowInDead(panelID)
	if not gCS.SceneDataMgr.IsRaidEnd and gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene and gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.IsDead then
		local entry = gPanelEntry:GetEntry(panelID)

		if not entry then
			print_error("Cannot find panel entry, panelId = ", panelID)

			return false
		end

		if gPanelTags.HasFlag(entry.tags, LTConfig.PanelConfig.tagsType.DeadAvailable) then
			return true
		end

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.DieTouchFailed)

		return false
	end

	return true
end

function M:CheckPanelUnlock(id, data)
	if not gClientUtils.CheckPanelSystemUnlocked(id) then
		return false
	end

	if not gPhonePanelRuleCheckManager:CheckPanelCanShow(id, data) then
		return false
	end

	return true
end

function M:ResultToReason(result)
	return self.resultToReason[result] or "异常结果,无法翻译,result=" .. result
end

function M:SetVisibleMode(type, mode)
	PanelMgrCsharp.SetVisibleMode(type, mode)
end

function M:RemoveVisibleMode(type)
	PanelMgrCsharp.RemoveVisibleMode(type)
end

function M:SetVisibleModeForPanel(panelId, mode)
	PanelMgrCsharp.SetVisibleModeForPanel(panelId, mode)
end

function M:RemoveVisibleModeForPanel(panelId)
	PanelMgrCsharp.RemoveVisibleModeForPanel(panelId)
end

gPanelManager = gPanelManager or C_PanelManager.new()
