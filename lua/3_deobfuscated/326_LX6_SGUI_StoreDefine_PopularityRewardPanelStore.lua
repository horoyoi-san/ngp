C_PopularityRewardPanelStore = DefClass("C_PopularityRewardPanelStore", C_PopularityRewardPanelStore, C_StoreGroup)
GroupName2Class.PopularityRewardPanelStore = C_PopularityRewardPanelStore
local M = C_PopularityRewardPanelStore

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.areaIndex = args and args.areaIndex
end

function M:InitView(args)
	self:StartAutoClose()

	local popularityAdd = args.popularityAdd
	self.bindData.popularityValue = args.incrementTotalLeftMoney
	self.bindData.popularityControl = self:GetPopularityControlValue(popularityAdd)
end

function M:StartAutoClose()
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5.5)
		gPanelManager:Close(self.m_Id)
	end)
end

function M:GetPopularityControlValue(popularityAdd)
	local rangePointList = LTConfig.TuiteConfig.PopularityRangePoint

	for i = 1, #rangePointList - 1 do
		if rangePointList[i] <= popularityAdd and popularityAdd < rangePointList[i + 1] then
			return i - 1
		end
	end

	return 3
end

function M:OnDestroy()
	return
end
