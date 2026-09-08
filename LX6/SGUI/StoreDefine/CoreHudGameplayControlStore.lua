-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudGameplayControlStore.lua
-- Decompiled from: 01496_CoreHudGameplayControlStore.lua_ac4eb2ae2aee.luajit

C_CoreHudGameplayControlStore = DefClass("C_CoreHudGameplayControlStore", C_CoreHudGameplayControlStore, C_StoreGroup)
GroupName2Class.CoreHudGameplayControlStore = C_CoreHudGameplayControlStore
local M = C_CoreHudGameplayControlStore

M.ctor = function(self)
	self.TypeIdMap = {
		Ferris = gHUDGameplayType.FERRIS,
		DiaoChe = gHUDGameplayType.DIAO_CHE,
		HackInteract = gHUDGameplayType.HACK_INTERACT,
		PoliceEscort = gHUDGameplayType.POLICE_ESCORT,
		Telescope = gHUDGameplayType.TELESCOPE,
		RobBankDrillShelf = gHUDGameplayType.ROBBANKDRILLSHELF,
		Skate = gHUDGameplayType.SKATE,
		NiRenFighter = gHUDGameplayType.NIREN_FIGHTER
	}
	self.HasPC = {}
	self.curType = -1
	self.curTypeStore = nil
	self.curShowData = nil
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.msgEvents = {
		[gEventConstants.PLAYGROUNDSWING_END] = self.CreateAction(self, "OnGameplaySwingChange")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
	self.StopActiveGameplay(self)
end

M.OnStart = function(self)
	if self.curType <= -1 then
		self.bindData.tabRect.selectedIndex = self.curType
	end
end

M.OnLanguageChange = function(self, lang)
end

M.StartGameplayByName = function(self, name, showData)
	local type = self.TypeIdMap[name]

	self.StartGameplayByType(self, type, showData)
end

M.StartGameplayByType = function(self, type, showData)
	self.curType = type

	if self.HasPC[self.curType] then
		self.curType = self.curType + 1
	end

	self.curShowData = showData

	gCoreHudModeMgr:PushHudMode("CoreHudGameplay_" .. type, gCoreHudModeMgr.HUD_MODE.GAMEPLAY)

	if self.STATE_EnableOnce then
		self.bindData.tabRect.selectedIndex = self.curType
	end
end

M.StopGameplayByName = function(self, name)
	local type = self.TypeIdMap[name]

	self.StopGameplayByType(self, type)
end

M.StopGameplayByType = function(self, type)
	if self.HasPC[type] then
		type = type + 1
	end

	if type ~= self.curType then
		self.StopActiveGameplay(self)
	end
end

M.GetNowGameplayType = function(self)
	return self.curType
end

M.StopActiveGameplay = function(self)
	gCoreHudModeMgr:PopHudMode("CoreHudGameplay_" .. self.curType, true)

	self.curType = -1
	self.curShowData = nil

	if self.curTypeStore then
		self.curTypeStore:OnClose()

		self.curTypeStore = nil
	end

	if self.STATE_EnableOnce then
		self.bindData.tabRect.selectedIndex = self.curType
	end
end

M.OnRenderTab = function(self, index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(nil, self.curShowData)
	end
end

M.OnGameplaySwingChange = function(self, eventId, isEnd)
	if not isEnd then
		self.StartGameplayByType(self, gHUDGameplayType.SWING)
	else
		self.StopGameplayByType(self, gHUDGameplayType.SWING)
	end
end

M.OnStackHide = function(self)
	if self.curTypeStore and self.curTypeStore.OnStackHide then
		self.curTypeStore:OnStackHide()
	end
end

M.OnStackShow = function(self)
	if self.curTypeStore and self.curTypeStore.OnStackShow then
		self.curTypeStore:OnStackShow()
	end
end
