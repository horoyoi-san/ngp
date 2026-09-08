-- Original chunk: @Lua\LuaFiles\LX6\GUI\Engine\PanelManager.lua
-- Decompiled from: 00163_PanelManager.lua_321874f0d1bb.luajit

local yield = coroutine.yield
local PanelMgrCsharp = LX6.Manager.PanelManager
local VisibleMode = LX6.Manager.VisibleMode
C_PanelManager = DefClass("C_PanelManager", C_PanelManager)
local M = C_PanelManager

M.ctor = function(self)
	self.currVisibleMode = 0
	self.VisibleModeDirty = false
	self.panelData = {}
	self.panelPreloadData = {}
	self.CHECK_RESULT = {
		[")f\\xbd\\xa1\\xa0j"] = 1,
		["ԭ8\\xd8?9\\xd9?û̠\r"] = 3,
		["^\\"] = 2,
		["I\nRl"] = 0
	}
	self.resultToReason = {
		[0] = "\\x81\\xcf|dVenky\r:\\xb4/i\\xa5C",
		"\\xe0\\xf2vB69\\xf1!\\xf8\\xce;\\xf6\\xd7J",
		"\\xda\\xfb\\xab\\xfdż\\x86\\x83\\x88\\x928y\\xdfUƇz\\xfb/\\xe7\n/\\xb4\\x84\\x9c\\x87\\x95\\x8c\\xb7\\xce\\xc8\\xed\\xcf1\\xde<\\xe1\\xf8\\xe1B\\xb1Dǀ\\xdb\\xe5\\x8d\\xe7\\xe3\\xfd\\x8c\\xd8\rO|\\xf1\\xbe=\\xf9\\xe8\\xceb\\xbfpƓ\\xff\\xe4\\x9b\\xee\\xef\\xe6\\x9bO\\xec\\xaa",
		"\\xe9\\xbe(\\xf9\\xf9\\xe0\\xfd\\xda\\xe3#!S\\2A^\\xe92\\xf8+y\\xfa0p9"
	}
end

M.Init = function(self)
	gCS.LuaUtils.SetEnhancedTouchSupport(true)

	PanelMgrCsharp.Instance.luaPanelMgr = self
end

M.OnBeforeSwitchScene = function(self, switchType)
end

M.Preload = function(self, panelId, data)
	self.panelPreloadData[panelId] = data

	PanelMgrCsharp.Instance:PreloadFromLua(panelId)
end

M.ReleasePreload = function(self, panelId)
	self:RemovePreloadData(panelId)
	PanelMgrCsharp.Instance:ReleasePreloadFromLua(panelId)
end

M.CheckShowInBackground = function(self, panelId, data, pos, dir, sizeWidth, sizeHeight, parent)
	if self:CheckCanPanelShow(panelId, data) == self.CHECK_RESULT.SHOW then
		return false
	end

	self.panelData[panelId] = data

	self:RemovePreloadData(panelId)
	PanelMgrCsharp.Instance:CheckShowInBackgroundFromLua(panelId, pos, dir, sizeWidth or -1, sizeHeight or -1, parent)

	return true
end

M.CheckShow = function(self, panelId, data, pos, dir, sizeWidth, sizeHeight, parent)
	if self:CheckCanPanelShow(panelId, data) == self.CHECK_RESULT.SHOW then
		return false
	end

	self.panelData[panelId] = data

	self:RemovePreloadData(panelId)
	PanelMgrCsharp.Instance:CheckShowFromLua(panelId, pos, dir, sizeWidth or -1, sizeHeight or -1, parent)

	return true
end

M.CheckShowAsync = function(self, panelId, data, pos, dir, sizeWidth, sizeHeight, parent)
	if self:CheckCanPanelShow(panelId, data) == self.CHECK_RESULT.SHOW then
		return false
	end

	self.panelData[panelId] = data

	self:RemovePreloadData(panelId)
	PanelMgrCsharp.Instance:CheckShowAsyncFromLua(panelId, pos, dir, sizeWidth or -1, sizeHeight or -1, parent)

	return true
end

M.CheckShowSync = function(self, panelId, data, pos, dir, sizeWidth, sizeHeight, parent)
	if self:CheckCanPanelShow(panelId, data) == self.CHECK_RESULT.SHOW then
		return false
	end

	self.panelData[panelId] = data

	self:RemovePreloadData(panelId)
	PanelMgrCsharp.Instance:CheckShowSyncFromLua(panelId, pos, dir, sizeWidth or -1, sizeHeight or -1, parent)

	return true
end

M.Load = function(self, panelId, data, priority, skipWait, loadCallback)
	if self:CheckCanPanelShow(panelId, data) == self.CHECK_RESULT.SHOW then
		return
	end

	if priority ~= nil then
		priority = LX6.Engine.ResourceManager.LOAD_PRIORITY.PRIORITY_LEVEL2
	end

	if not skipWait then
		yield(nil)
	end

	self.panelData[panelId] = data

	self:RemovePreloadData(panelId)

	local wait = PanelMgrCsharp.Instance:LoadFromLua(panelId, priority)

	if wait then
		yield(wait)
	end

	if loadCallback then
		loadCallback()
	end
end

M.Close = function(self, panelId, data)
	if not panelId then
		print_error("[gPanelManager] Close, panelId is nil", panelId)

		return
	end

	if not gPanelEntry:GetEntry(panelId) then
		print_error("@chenhongrui01 Cannot find panel entry " .. panelId)

		return false
	end

	self:RemovePanelData(panelId)
	PanelMgrCsharp.Instance:CloseFromLua(panelId)
end

M.Destroy = function(self, panelId, data)
	self:RemovePanelData(panelId)
	self:RemovePreloadData(panelId)
	PanelMgrCsharp.Instance:CloseFromLua(panelId, true, true)
end

M.ClearAll = function(self)
	PanelMgrCsharp.Instance:ClearAll()
end

M.SetActiveById = function(self, id, visible)
	PanelMgrCsharp.SetPanelInBackground(id, not visible)
end

M.SetPanelStackBlock = function(self, id, block)
	PanelMgrCsharp.SetPanelStackBlock(id, block)
end

M.IsPanelShowing = function(self, panelId)
	return PanelMgrCsharp.Instance:GetUIShowState(panelId)
end

M.IsPanelVisible = function(self, panelId)
	return PanelMgrCsharp.IsPanelVisible(panelId)
end

M.CloseAllFront = function(self)
	PanelMgrCsharp.Instance:CloseAllFront()
end

M.SyncVisibleMode = function(self, mode)
	self.currVisibleMode = mode
end

M.SyncVisibleModeDirty = function(self, dirty)
	self.VisibleModeDirty = dirty
end

M.CheckVisibleModeDirty = function(self)
	return self.VisibleModeDirty
end

M.VisibleModeAll = function(self)
	return self.currVisibleMode ~= VisibleMode.All
end

M.VisibleModeHUD = function(self)
	return self.currVisibleMode > VisibleMode.HUD
end

M.VisibleModeFront = function(self)
	return self.currVisibleMode > VisibleMode.Front
end

M.VisibleModeNotice = function(self)
	return self.currVisibleMode > VisibleMode.Notice
end

M.SwitchPanelContext = function(self, panel, contextId)
	PanelMgrCsharp.SwitchPanelContext(panel, contextId)
end

M.SwitchContextPart = function(self, contextId, part, ctxDef, transition)
	PanelMgrCsharp.SwitchContextPart(contextId, part, ctxDef, transition or 0)
end

M.DisableSpecialController = function(self)
	self.specialControllerDisableCount = (self.specialControllerDisableCount or 0) + 1

	if self.specialControllerDisableCount ~= 1 then
		self:SwitchContextPart(LTConfig.InputUIContextConfig.UICoreHUD_Exploration, "SpecialController", "Def_None")
	end
end

M.EnableSpecialController = function(self)
	self.specialControllerDisableCount = math.max(0, (self.specialControllerDisableCount or 0) - 1)

	if self.specialControllerDisableCount ~= 0 then
		self:SwitchContextPart(LTConfig.InputUIContextConfig.UICoreHUD_Exploration, "SpecialController", "Def_GamepadSpecial")
	end
end

M.PushPanelContext = function(self, panel, contextId)
	PanelMgrCsharp.PushPanelContext(panel, contextId)
end

M.PopPanelContext = function(self, panel, contextId)
	PanelMgrCsharp.PopPanelContext(panel, contextId)
end

M.HasFullscreen = function(self)
	return PanelMgrCsharp.Instance:HasFullscreen()
end

M.HasFullscreenLayer = function(self, layer)
	return PanelMgrCsharp.Instance:HasFullscreenLayer(layer)
end

M.IsLayerActive = function(self, layer)
	return PanelMgrCsharp.Instance:IsLayerActive(layer)
end

M.SetLoadDataFromCs = function(self, panel, data)
	if self:CheckCanPanelShow(panel, data) == self.CHECK_RESULT.SHOW then
		return false
	end

	self.panelData[panel] = data

	return true
end

M.RemovePanelData = function(self, panelId)
	local data = self.panelData[panelId]
	self.panelData[panelId] = nil

	return data
end

M.RemovePreloadData = function(self, panelId)
	local data = self.panelPreloadData[panelId]
	self.panelPreloadData[panelId] = nil

	return data
end

M.CheckCanPanelShow = function(self, id, data)
	if not self:CheckPanelUnlock(id, data) then
		return self.CHECK_RESULT.UNLOCK
	end

	if not self:CheckPanelShowInDead(id, false) then
		return self.CHECK_RESULT.DEAD
	end

	if not gSwitchFunctionManager:CheckEnable(id) then
		return self.CHECK_RESULT.SWITCH_DISABLE
	end

	return self.CHECK_RESULT.SHOW
end

M.CheckPanelShowInDead = function(self, panelID)
	if not gCS.SceneDataMgr.IsRaidEnd and gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene and gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.IsDead then
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

M.CheckPanelUnlock = function(self, id, data)
	if not gClientUtils.CheckPanelSystemUnlocked(id) then
		return false
	end

	if not gPhonePanelRuleCheckManager:CheckPanelCanShow(id, data) then
		return false
	end

	return true
end

M.ResultToReason = function(self, result)
	return self.resultToReason[result] or "异常结果,无法翻译,result=" .. result
end

M.SetVisibleMode = function(self, type, mode)
	PanelMgrCsharp.SetVisibleMode(type, mode)
end

M.RemoveVisibleMode = function(self, type)
	PanelMgrCsharp.RemoveVisibleMode(type)
end

M.SetVisibleModeForPanel = function(self, panelId, mode)
	PanelMgrCsharp.SetVisibleModeForPanel(panelId, mode)
end

M.RemoveVisibleModeForPanel = function(self, panelId)
	PanelMgrCsharp.RemoveVisibleModeForPanel(panelId)
end

M.AddPS5StoreIconPanel = function(self, panelId)
	PanelMgrCsharp.Instance:AddPS5StoreIconPanel(panelId)
end

M.RemovePS5StoreIconPanel = function(self, panelId)
	PanelMgrCsharp.Instance:RemovePS5StoreIconPanel(panelId)
end

gPanelManager = gPanelManager or C_PanelManager.new()
