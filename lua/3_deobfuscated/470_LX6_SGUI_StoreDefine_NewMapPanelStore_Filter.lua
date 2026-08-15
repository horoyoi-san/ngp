dofile("LX6/Manager/Map/Utils/BigMapComps/FilterMenu/FilterMenuCore")

local M = C_NewMapPanelStore

function M:InitFilter()
	local filterMode = gCS.LuaUtils.IsNonMobileAdaptive() and ENewMapFilterMode.Exclusive or ENewMapFilterMode.Multiple
	local groupToggleMode = gCS.LuaUtils.IsNonMobileAdaptive() and ENewMapFilterGroupToggleMode.Toggle or ENewMapFilterGroupToggleMode.ActiveAllTime
	local showNonTagElements = not gCS.LuaUtils.IsNonMobileAdaptive()
	self._filterCore = C_NewMap_FilterLogicCore.new(filterMode, showNonTagElements, groupToggleMode, self)
end

function M:PostInitFilter()
	self._filterCore:RefreshFilterFsm()
end

function M:ApplyFilter()
	local enableFilter = self._filterCore:GetFilterState()

	for id, _ in pairs(self._id2ElementInfo) do
		self:CheckElementFilter(id, enableFilter)
	end

	if self.attachedTooltipId then
		local info = self._id2ElementInfo[self.attachedTooltipId]

		if info then
			local visible = info.showMask >= info.hideMask and info.showMask ~= 0

			if not visible then
				self:SetSelected(nil)
			end
		end
	end

	if self.compRefs and self.compRefs.RightTopFilterList then
		self.compRefs.RightTopFilterList:MarkRefreshList()
	end
end

local PIN_GROUP_ID = LTConfig.GpsFilterGroupConfig.PinGroup
local PIN_TAG_ID = LTConfig.GpsFilterTagConfig.Pin

function M:FilterAllowPin()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return self.fsms[5].currentState == EBigMapFSMState.Filter_Disable
	else
		return self._filterCore:CheckTagEnabled(PIN_GROUP_ID, PIN_TAG_ID)
	end
end

local BEST_FRIEND_TAG = LTConfig.GpsFilterTagConfig.Npc

function M:CheckElementFilter(id, enableFilter)
	local viewItem = self.mapView:GetItemInfo(id)

	if viewItem and viewItem.interestSourceCount > 0 then
		self:ClearHideMask(id, EBigMapElementHideMask.Filter)

		return
	end

	local result = false

	if enableFilter == nil then
		enableFilter = self._filterCore:GetFilterState()
	end

	local filterTag1, filterTag2 = self:GetFilterTag(id)

	if enableFilter then
		result = self._filterCore:CheckFilter(id, filterTag1, filterTag2)
	end

	local filterInvisible = false

	if not enableFilter then
		if filterTag1 == BEST_FRIEND_TAG or filterTag2 == BEST_FRIEND_TAG then
			self:ClearShowMask(id, EBigMapElementShowMask.Filter)
			self:SetHideMask(id, EBigMapElementHideMask.Filter)

			filterInvisible = true
		else
			self:ClearShowMask(id, EBigMapElementShowMask.Filter)
			self:ClearHideMask(id, EBigMapElementHideMask.Filter)
		end
	elseif result then
		self:SetShowMask(id, EBigMapElementShowMask.Filter)
		self:ClearHideMask(id, EBigMapElementHideMask.Filter)
	else
		self:ClearShowMask(id, EBigMapElementShowMask.Filter)
		self:SetHideMask(id, EBigMapElementHideMask.Filter)

		filterInvisible = true
	end

	if filterInvisible and id == self._chooseAnimTargetId then
		self:CancelChooseAnim()
	end
end
