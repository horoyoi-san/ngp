local NavMgr = SGUI.UNavigationMgr
local TextConfig = LTConfig.TextCommonTextConfig
local M = C_NewMapPanelStore

function M:ShowElementList()
	self.showElementList = true

	self.bindData.elementListRootWidget:SetActive(true)

	self.bindData.mainOnlyNavArea.enabled = false
	NavMgr.Inst.CurrentActiveArea = self.elementListPanel.navArea
	local elementInfos = {}
	local shouldSelectIndex = -1
	local curTargetName = nil

	for id, info in pairs(self._id2ElementInfo) do
		local element = info and info.element

		if element then
			local tmpIsCurTarget = 0

			if element.subSystemType == EMapSubSystemType.TaxiDest and element.id == gTaxiManager.CurrentDestinationUid then
				tmpIsCurTarget = 1
				curTargetName = element:GetName()
			end

			table.insert(elementInfos, {
				gpsId = element.gpsId,
				name = element:GetName(),
				iconId = element.fData.listIconId or self:GetIconId(element),
				tmpIsCurTarget = tmpIsCurTarget,
				taxiId = element.userdata and element.userdata.taxiId or 0
			})

			if self.attachedTooltipId == id then
				shouldSelectIndex = #elementInfos
			end
		end
	end

	self.elementListPanel.clickTooltipAction = self:CreateAction("OnClickTooltipActionDelegate", self)

	self.elementListPanel.list:SetList(elementInfos)

	if gTaxiManager.CurrentDestinationUid ~= nil then
		self.elementListPanel.dest = curTargetName
	else
		self.elementListPanel.dest = TextConfig.GetConfig(74002804).Text
	end

	if shouldSelectIndex > 0 then
		self.elementListPanel.list:SelectItem(shouldSelectIndex - 1, false)

		if gTaxiManager.CurrentDestinationUid == nil then
			self.elementListPanel.dest = elementInfos[shouldSelectIndex].name
		end
	end
end

function M:HideElementList()
	if self.showElementList then
		self:SetSelected(nil)
	end

	self.showElementList = false

	self.bindData.elementListRootWidget:SetActive(false)

	self.bindData.mainOnlyNavArea.enabled = true
end

function M:OnRenderElementListItem(btn, csIndex, data)
	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
	store.name = data.name
	store.icon = data.iconId
	store.tmpIsCurTarget = data.tmpIsCurTarget

	if data.taxiId and data.taxiId > 0 then
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

function M:OnClickELementListItem(btn, data)
	if gTaxiManager.CurrentDestinationUid == nil then
		self.elementListPanel.dest = data.name
	end

	self:ClearScheduleOperation()
	self:ScheduleOperation(self.OperationType.WaitSelect, {
		gpsId = data.gpsId,
		source = EBigMapSelectSource.TaxiListPanel
	})
end

function M:OnClickTooltipActionDelegate(gpsId)
	self.compRefs.Tooltip:PretendClickTooltip()
end
