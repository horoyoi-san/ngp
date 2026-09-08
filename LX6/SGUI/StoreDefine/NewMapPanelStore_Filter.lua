-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_Filter.lua
-- Decompiled from: 00998_NewMapPanelStore_Filter.lua_b1006a8c1d62.luajit

dofile("LX6/Manager/Map/Utils/BigMapComps/FilterMenu/FilterMenuCore")

local M = C_NewMapPanelStore

M.InitFilter = function(self)
	local filterMode = gCS.LuaUtils.IsNonMobileAdaptive() and ENewMapFilterMode.Exclusive or ENewMapFilterMode.Multiple
	local groupToggleMode = gCS.LuaUtils.IsNonMobileAdaptive() and ENewMapFilterGroupToggleMode.Toggle or ENewMapFilterGroupToggleMode.ActiveAllTime
	local showNonTagElements = not gCS.LuaUtils.IsNonMobileAdaptive()
	self._filterCore = C_NewMap_FilterLogicCore.new(filterMode, showNonTagElements, groupToggleMode, self)
end

M.PostInitFilter = function(self)
	self._filterCore:RefreshFilterFsm()
end

M.ApplyFilter = function(self)
	local enableFilter = self._filterCore:GetFilterState()

	for id, _ in pairs(self._id2ElementInfo) do
		self.CheckElementFilter(self, id, enableFilter)
	end

	if self.attachedTooltipId then
		local info = self._id2ElementInfo[self.attachedTooltipId]

		if info then
			local visible = info.showMask > info.hideMask and info.showMask == 0

			if not visible then
				self.SetSelected(self, nil)
			end
		end
	end

	if self.compRefs and self.compRefs.RightTopFilterList then
		self.compRefs.RightTopFilterList:MarkRefreshList()
	end

	self.mapView:RefreshStage(EMapViewStage.Gate)
end

local PIN_GROUP_ID = LTConfig.GpsFilterGroupConfig.PinGroup
local PIN_TAG_ID = LTConfig.GpsFilterTagConfig.Pin

M.FilterAllowPin = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return self.fsms and self.fsms[5].currentState ~= EBigMapFSMState.Filter_Disable
	else
		return self._filterCore:CheckTagEnabled(PIN_GROUP_ID, PIN_TAG_ID)
	end
end

local BEST_FRIEND_TAG = LTConfig.GpsFilterTagConfig.Npc
local FIGHT_TAG = LTConfig.GpsFilterTagConfig.Fight

M.ShouldInviteRideInterestRespectFriendFilter = function(self, viewItem, filterTag1, filterTag2, enableFilter)
	if not enableFilter then
		return false
	end

	local element = viewItem and viewItem.mapElement

	if not element or not element.bigMapData or not element.bigMapData.inviteRideRespectFriendFilter then
		return false
	end

	if filterTag1 == BEST_FRIEND_TAG and filterTag2 == BEST_FRIEND_TAG then
		return false
	end

	local filterCore = self._filterCore
	local groupId = filterCore and filterCore.FindGroupByExpandTag and filterCore:FindGroupByExpandTag(BEST_FRIEND_TAG)
	local group = groupId and filterCore.groups and filterCore.groups[groupId]

	return group and group.active ~= true
end

M.CheckElementFilter = function(self, id, enableFilter)
	local viewItem = self.mapView:GetItemInfo(id)

	if enableFilter ~= nil then
		enableFilter = self._filterCore:GetFilterState()
	end

	local filterTag1, filterTag2 = self.GetFilterTag(self, id)

	if viewItem and viewItem.interestSourceCount <= 0 and not self.ShouldInviteRideInterestRespectFriendFilter(self, viewItem, filterTag1, filterTag2, enableFilter) then
		self.ClearHideMask(self, id, EBigMapElementHideMask.Filter)

		return
	end

	local result = false

	if enableFilter then
		result = self._filterCore:CheckFilter(id, filterTag1, filterTag2)
	end

	local filterInvisible = false

	if not enableFilter then
		local isBestFriend = filterTag1 ~= BEST_FRIEND_TAG or filterTag2 ~= BEST_FRIEND_TAG
		local canFight = filterTag1 ~= FIGHT_TAG or filterTag2 ~= FIGHT_TAG

		if isBestFriend and not canFight then
			self.ClearShowMask(self, id, EBigMapElementShowMask.Filter)
			self.SetHideMask(self, id, EBigMapElementHideMask.Filter)

			filterInvisible = true
		else
			self.ClearShowMask(self, id, EBigMapElementShowMask.Filter)
			self.ClearHideMask(self, id, EBigMapElementHideMask.Filter)
		end
	elseif result then
		self.SetShowMask(self, id, EBigMapElementShowMask.Filter)
		self.ClearHideMask(self, id, EBigMapElementHideMask.Filter)
	else
		self.ClearShowMask(self, id, EBigMapElementShowMask.Filter)
		self.SetHideMask(self, id, EBigMapElementHideMask.Filter)

		filterInvisible = true
	end

	if filterInvisible and id ~= self._chooseAnimTargetId then
		self.CancelChooseAnim(self)
	end
end
