C_BowlingSettleTechPanelStore = DefClass("C_BowlingSettleTechPanelStore", C_BowlingSettleTechPanelStore, C_StoreGroup)
GroupName2Class.BowlingSettleTechPanelStore = C_BowlingSettleTechPanelStore
local M = C_BowlingSettleTechPanelStore

function M:OnAwake()
	return
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self:ClearPlayerScore()

	if data and data.settleData then
		self:RefreshScoreBoardComplete(data.settleData)
	end
end

function M:OnClose()
	return
end

function M:ClearPlayerScore()
	self.bindData.S1.gameObject:SetActive(false)
	self.bindData.S2.gameObject:SetActive(false)
	self.bindData.S3.gameObject:SetActive(false)
	self.bindData.S4.gameObject:SetActive(false)
	self.bindData.S5.gameObject:SetActive(false)
	self.bindData.S6.gameObject:SetActive(false)
	self.bindData.S7.gameObject:SetActive(false)
	self.bindData.S8.gameObject:SetActive(false)
	self.bindData.S9.gameObject:SetActive(false)
	self.bindData.S10.gameObject:SetActive(false)
end

function M:RefreshScoreBoardComplete(settleData)
	if not settleData then
		return
	end

	if not settleData.completedPatterns then
		return
	end

	self:RefreshScoreBoardPlayer(settleData.completedPatterns)
end

function M:RefreshScoreBoardPlayer(completedPatterns)
	if not completedPatterns then
		return
	end

	for i, succ in ipairs(completedPatterns) do
		local pn = "S" .. tostring(succ)

		if self.bindData[pn] and gClientUtils.NotNil(self.bindData[pn].gameObject) then
			self.bindData[pn].gameObject:SetActive(true)
		end
	end
end
