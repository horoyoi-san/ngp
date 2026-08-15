C_CommonFansLevelUpPanel = DefClass("C_CommonFansLevelUpPanel", C_CommonFansLevelUpPanel, C_StoreGroup)
GroupName2Class.CommonFansLevelUpPanel = C_CommonFansLevelUpPanel
local M = C_CommonFansLevelUpPanel

function M:OnAwake()
	return
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.areaIndex = args and args.areaIndex
end

function M:InitView(args)
	self:StartAutoClose()
	self:RefreshPanelView(args)
end

function M:RefreshPanelView(args)
	local preExp, currentExp = nil

	if args and args.data then
		preExp = args.data.preExp
		currentExp = args.data.currentExp
	else
		preExp = args.preExp or 0
		currentExp = args.currentExp or 0
	end

	local fansLevelUp = self.bindData.fansLevelUp
	local fansLevelUpStore = gStoreManager:GetStoreGroup(fansLevelUp.Store):GetStoreByWidget(fansLevelUp)

	gClientUtils.ShowCommonScrollNumber(fansLevelUpStore.scrollNumberWidget, preExp, currentExp)
end

function M:StartAutoClose()
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5.5)
		gPanelManager:Close(self.m_Id)
	end)
end

function M:OnRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.number = data.number
end

function M:OnDestroy()
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
end
