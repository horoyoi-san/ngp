C_PalmKingStartPanelStore = DefClass("C_PalmKingStartPanelStore", C_PalmKingStartPanelStore, C_StoreGroup)
GroupName2Class.PalmKingStartPanelStore = C_PalmKingStartPanelStore
local M = C_PalmKingStartPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.Btn1.luaClick = self:CreateAction("OnBtn1Click")
	self.bindData.Btn2.luaClick = self:CreateAction("OnBtn2Click")
	self.bindData.Btn3.luaClick = self:CreateAction("OnBtn3Click")
	self.bindData.Btn4.luaClick = self:CreateAction("OnBtn4Click")
end

function M:OnShow(panelId, data)
	self.panelId = panelId

	if data and data[3] then
		self.data3 = data[3]
	end
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnBtn1Click()
	self.slapAIId = 100

	self:OpenPalmKing()
end

function M:OnBtn2Click()
	self.slapAIId = 101

	self:OpenPalmKing()
end

function M:OnBtn3Click()
	self.slapAIId = 102

	self:OpenPalmKing()
end

function M:OnBtn4Click()
	self.slapAIId = 103

	self:OpenPalmKing()
end

function M:OpenPalmKing()
	local panelParams = {
		[3] = self.data3,
		slapAIId = self.slapAIId
	}

	gPanelManager:CheckShow(gPanelId.S_PALM_KING_PANEL, panelParams)
	gPanelManager:Close(self.panelId)
end

function M:OnBackBtnClick()
	gPalmKingAction:ReturnToPosition()
	gPanelManager:Close(self.panelId)
end
