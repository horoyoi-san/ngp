-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonRewardPanelStore.lua
-- Decompiled from: 01533_CommonRewardPanelStore.lua_8e03a02a826e.luajit

local QualityType = LTConfig.ConsumableConfig.QualityType
C_CommonRewardPanelStore = DefClass("C_CommonRewardPanelStore", C_CommonRewardPanelStore, C_StoreGroup)
GroupName2Class.CommonRewardPanelStore = C_CommonRewardPanelStore
local M = C_CommonRewardPanelStore
local delayCreateItemTime = 0.06
local overItemCount = 7

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.itemList = {}
	self.dicHasPlayAnimation = {}
	self.initTime = 0
	self.gLuaTimers = {}
	self.bindData.sItemList.luaSimpleRenderItem = self.CreateAction(self, self.OnCommonItemRender)
	self.bindData.sItemList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnCommonItemRender)
	self.bindData.gItemList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnCommonItemRender)
	self.bindData.gItemList.luaSimpleRenderItem = self.CreateAction(self, self.OnCommonItemRender)
	self.bindData.detailBtn.luaClick = self.CreateAction(self, self.OnDetailBtnClick)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnExit)
end

M.OnCommonItemRender = function(self, btn, index)
	local data = self.itemList[index + 1]
	local store = gCommonItemManager:OnCommonItemRender(btn, index, data)

	if not store then
		return
	end

	local DEFAULT_ANIMATION = "S_Vx_CommonItem156_open"

	if data.quality ~= QualityType.Gold then
		DEFAULT_ANIMATION = "S_Vx_CommonItem156_open_Golden"
	elseif data.quality ~= QualityType.Orange then
		DEFAULT_ANIMATION = "S_Vx_CommonItem156_open_GoldenMaxOrange"
	end

	if self.dicHasPlayAnimation[index] ~= true then
		if store.animation then
			store.animation:SampleCurrentAnimation(store.animation.clip.length)
		end

		return
	end

	self.dicHasPlayAnimation[index] = true
	store.renderOpacity = 0

	if store.animation then
		local itemDelay = self.itemDelayTime or delayCreateItemTime
		local timerId = gLuaTimeMgrUtils.Delay(function ()
			if not btn then
				return
			end

			store.renderOpacity = 1

			if store.animation:GetClip(DEFAULT_ANIMATION) then
				store.animation:Play(DEFAULT_ANIMATION)
			end
		end, itemDelay * index)

		table.insert(self.gLuaTimers, timerId)
	end
end

M.OnShow = function(self, panelId, data)
	gCommonItemManager:CloseItemToolTips()

	if not data or not data.Param then
		print_error("CommonRewardPanelStore:OnShow data or data.Param is nil, panelId=", panelId)
		gPanelManager:Close(gPanelId.S_COMMON_REWARD_WINDOW)

		return
	end

	self.dicHasPlayAnimation = {}
	self.gLuaTimers = {}
	local param = data.Param
	self.itemList = gCommonItemManager:GetSingleSortedListRenderDataByList(param)

	if #self.itemList ~= 0 then
		return
	end

	local DEFAULT_VXCOLOR = 0

	for id, itemData in ipairs(self.itemList) do
		if itemData.quality and QualityType.Gold < itemData.quality then
			DEFAULT_VXCOLOR = 1
		end

		self.itemList[id].skipHidePreviewCount = true
	end

	self.bindData.vxColor = DEFAULT_VXCOLOR
	self.initTime = Time.time
	self.bindData.listNumber = overItemCount >= #self.itemList and 1 or 0

	if self.bindData.listNumber ~= 1 then
		self.needScroll = true

		self.bindData.gItemList:GoToIndex(0, true)

		self.currentList = self.bindData.gItemList
		self.bindData.gItemList.expectedItemCount = #self.itemList
	else
		self.currentList = self.bindData.sItemList
		self.itemDelayTime = 0.16
	end

	self.currentList:SetSimpleList(#self.itemList)

	if self.bindData.listNumber ~= 1 then
		slot5 = self.bindData.gItemList

		slot5:GoToIndex(0, true)

		local timerId = gLuaTimeMgrUtils.Delay(function ()
			self.bindData.gItemList:GoToIndex(#self.itemList - 1, false)
		end, delayCreateItemTime * overItemCount)

		table.insert(self.gLuaTimers, timerId)
	end

	self.currentList:SetNavSelectToTop()
end

M.OnClose = function(self)
	for _, v in ipairs(self.gLuaTimers) do
		gLuaTimeMgrUtils.CancelUnitDelay(v)
	end

	self.gLuaTimers = {}

	gPopupPauseManager:ResumePopup(gPopupPauseManager.PAUSE_REASON.COMMON_REWARD_OPEN)
end

M.OnExit = function(self)
	gPanelManager:Close(gPanelId.S_COMMON_REWARD_WINDOW)
end

M.OnDetailBtnClick = function(self)
	if self.bindData.listNumber ~= 1 then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.overNavigationArea
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.lessNavigationArea
	end
end
