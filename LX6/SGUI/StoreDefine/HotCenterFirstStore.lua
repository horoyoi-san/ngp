-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterFirstStore.lua
-- Decompiled from: 01725_HotCenterFirstStore.lua_b7646eefd5f0.luajit

C_HotCenterFirstStore = DefClass("C_HotCenterFirstStore", C_HotCenterFirstStore, C_StoreGroup)
GroupName2Class.HotCenterFirstStore = C_HotCenterFirstStore
local M = C_HotCenterFirstStore
local SECTION_TOP = 0
local SECTION_RECOMMEND = 1
local SECTION_RANK = 2
local MAIN_MODE_SWITCH_ANIM_NAME = "S_vx_HotCenterHome_Change01"
local MAIN_CITY_CHANGE_ANIM_NAME = "S_vx_HotCenterHome_Change01_2"

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.curCountryId = nil
	self.sectionData = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	if self.rootWidget and self.rootWidget.anim then
		self.rootWidget.anim:Play()
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_HOT_CENTER_HOME_DYNAMIC_DATA_REFRESH] = self.CreateAction(self, "OnHomeDynamicDataRefresh")
	}
end

M.RegisterWidget = function(self)
	if not self.bindData.list then
		return
	end

	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetSectionTIndex")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSectionItem")
	self.bindData.list.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderSectionItem")
end

M.ShowPanel = function(self, data)
	self.curCountryId = data and data.countryId

	self:RefreshSectionData(data)
	self:RefreshSectionList()

	if data and data.playMainModeSwitchAnim then
		self.PlayRootAnim(self, MAIN_MODE_SWITCH_ANIM_NAME)
	end
end

M.RefreshSectionData = function(self, data)
	local playCityChangeAnim = data and data.playCityChangeAnim
	local playMainModeSwitchAnim = data and data.playMainModeSwitchAnim
	self.sectionData = {
		{
			tIndex = SECTION_TOP,
			countryId = self.curCountryId,
			mainType = gClientConst.HotCenterType.Main,
			playCityChangeAnim = playCityChangeAnim,
			playMainModeSwitchAnim = playMainModeSwitchAnim
		},
		{
			tIndex = SECTION_RECOMMEND,
			countryId = self.curCountryId,
			playCityChangeAnim = playCityChangeAnim,
			playMainModeSwitchAnim = playMainModeSwitchAnim
		},
		{
			tIndex = SECTION_RANK,
			countryId = self.curCountryId
		}
	}
end

M.RefreshSectionList = function(self)
	if self.bindData.list then
		self.bindData.list:SetSimpleList(#self.sectionData)
	end
end

M.OnGetSectionTIndex = function(self, index)
	local data = self.sectionData[index + 1]

	return data and data.tIndex or SECTION_TOP
end

M.OnSimpleRenderSectionItem = function(self, widget, index)
	local data = self.sectionData[index + 1]

	if not data then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget and storeGroup:GetStoreByWidget(widget)

	if store and store.ShowPanel then
		store.ShowPanel(store, data)

		return
	end

	if storeGroup.ShowPanel then
		storeGroup.ShowPanel(storeGroup, data)
	end
end

M.OnHomeDynamicDataRefresh = function(self, eventId, args)
	if args and args.countryId and args.countryId == self.curCountryId then
		return
	end

	self.RefreshSectionData(self)
	self.RefreshSectionList(self)
end

M.PlayMainCityChangeAnim = function(self)
	self.PlayRootAnim(self, MAIN_CITY_CHANGE_ANIM_NAME)
end

M.PlayRootAnim = function(self, animName)
	if not self.rootWidget or not self.rootWidget.anim then
		return
	end

	local anim = self.rootWidget.anim

	anim.SampleCurrentAnimation(anim, 1000)
	anim.Play(anim, animName)
	anim.SampleCurrentAnimation(anim, 0)
end
