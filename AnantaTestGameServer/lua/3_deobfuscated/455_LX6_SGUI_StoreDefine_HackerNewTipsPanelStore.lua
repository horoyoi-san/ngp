C_HackerNewTipsPanelStore = DefClass("C_HackerNewTipsPanelStore", C_HackerNewTipsPanelStore, C_StoreGroup)
GroupName2Class.HackerNewTipsPanelStore = C_HackerNewTipsPanelStore
local M = C_HackerNewTipsPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.hitBtn.luaClick = self:CreateAction("OnHitBtnClick")
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self.timer = nil
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.areaIndex = data and data.areaIndex

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self.timer = Timer.New(function ()
		self.timer = nil

		gPanelManager:Close(panelId)
	end, 3):Start()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnHitBtnClick()
	gPanelManager:CheckShow(gPanelId.HACKER_MAIN_PANEL)
	gPanelManager:Close(gPanelId.HACKER_NEW_TIPS_PANEL)
end
