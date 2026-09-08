-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_ElementList.lua
-- Decompiled from: 00997_NewMapPanelStore_ElementList.lua_6dd6a3b4a1f1.luajit

local NavMgr = SGUI.UNavigationMgr
local TextConfig = LTConfig.TextCommonTextConfig
local TaxiManager = LX6.Drive.GamePlay.TaxiSystemManager.Instance
local M = C_NewMapPanelStore

M.ShowElementList = function(self)
	self.showElementList = true

	self.bindData.elementListRootWidget:SetActive(true)

	self.bindData.mainOnlyNavArea.enabled = false
	NavMgr.Inst.CurrentActiveArea = self.elementListPanel.navArea
	local comp = self.comps[EBigMapComponentType.GameTipVisibility]

	if comp and comp.actived then
		comp.actived = false

		comp.OnInactive(comp)
	end

	self.elementInfos = {}
	local shouldSelectIndex = -1
	local curTargetName = nil

	for id, info in pairs(self._id2ElementInfo) do
		local element = info and info.element

		if element then
			local tmpIsCurTarget = 0

			if element.subSystemType ~= EMapSubSystemType.TaxiDest and element.id ~= TaxiManager.CurrentDestinationUid then
				tmpIsCurTarget = 1
				curTargetName = element.GetName(element)
			end

			table.insert(self.elementInfos, {
				gpsId = element.gpsId,
				name = element:GetName(),
				iconId = element.fData.listIconId or self:GetIconId(element),
				tmpIsCurTarget = tmpIsCurTarget,
				taxiId = element.userdata and element.userdata.taxiId or 0
			})

			if self.attachedTooltipId ~= id then
				shouldSelectIndex = #self.elementInfos
			end
		end
	end

	self.elementListPanel.clickTooltipAction = self:CreateAction("OnClickTooltipActionDelegate", self)

	self.elementListPanel.list:SetSimpleList(#self.elementInfos)

	if TaxiManager.HasDestination then
		self.elementListPanel.dest = curTargetName
	else
		self.elementListPanel.dest = TextConfig.GetConfig(74002804).Text
	end

	if shouldSelectIndex <= 0 then
		self.elementListPanel.list:SetItemSelected(shouldSelectIndex - 1, false)

		if not TaxiManager.HasDestination then
			self.elementListPanel.dest = self.elementInfos[shouldSelectIndex].name
		end
	end
end

M.HideElementList = function(self)
	if self.showElementList then
		self.SetSelected(self, nil)
	end

	self.showElementList = false
	local oldSelected = self.elementListPanel.list.selectedIndex

	if oldSelected and oldSelected > 0 then
		self.elementListPanel.list:SetItemSelected(oldSelected, false)
	end

	self.bindData.elementListRootWidget:SetActive(false)

	self.bindData.mainOnlyNavArea.enabled = true
	local comp = self.comps[EBigMapComponentType.GameTipVisibility]

	if comp then
		comp.actived = false

		self.ResolveComponentActiveState(self, EBigMapComponentType.GameTipVisibility)
	end
end

M.OnSimpleRenderElementListItem = function(self, btn, csIndex)
	local data = self.elementInfos and self.elementInfos[csIndex + 1] or {}
	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
	store.name = data.name
	store.icon = data.iconId
	store.tmpIsCurTarget = data.tmpIsCurTarget

	if data.taxiId and data.taxiId <= 0 then
		local cfg = LTConfig.TaxiNavigationConfig.GetConfig(data.taxiId)

		if cfg then
			local score = cfg.Score[1]
			local commentCount = cfg.Score[2]
			store.score = string.format("%.1f", score)
			store.starFill = score / 5
			store.commentCount = "(" .. commentCount .. ")"
			store.desc = cfg.Decs
		end
	end
end

M.OnSimpleClickELementListItem = function(self, btn, index)
	local oldSelected = self.elementListPanel.list.selectedIndex

	if oldSelected ~= index then
		return
	end

	local data = self.elementInfos and self.elementInfos[index + 1] or {}

	if not TaxiManager.HasDestination then
		self.elementListPanel.dest = data.name
	end

	self.ClearScheduleOperation(self)
	self.ScheduleOperation(self, self.OperationType.WaitSelect, {
		gpsId = data.gpsId,
		source = EBigMapSelectSource.TaxiListPanel
	})

	if oldSelected and oldSelected > 0 then
		self.elementListPanel.list:SetItemSelected(oldSelected, false)
	end

	self.elementListPanel.list:SetItemSelected(index, true)
end

M.OnClickTooltipActionDelegate = function(self, gpsId)
	self.compRefs.Tooltip:PretendClickTooltip()
end
