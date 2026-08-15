C_FansRewardPanelStore = DefClass("C_FansRewardPanelStore", C_FansRewardPanelStore, C_StoreGroup)
GroupName2Class.FansRewardPanelStore = C_FansRewardPanelStore
local M = C_FansRewardPanelStore

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

	local isUpExp = args.preExp < args.currentExp
	self.bindData.fansCount = gClientUtils.FormatWithThousandsSeparator(args.currentExp)
	self.bindData.upControl = isUpExp and 0 or 1
end

function M:StartAutoClose()
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5.5)
		gPanelManager:Close(self.m_Id)
	end)
end

function M:OnDestroy()
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
end
