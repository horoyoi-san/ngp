C_YanjieNewCollectionPanel = DefClass("C_YanjieNewCollectionPanel", C_YanjieNewCollectionPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewCollectionPanel = C_YanjieNewCollectionPanel
local M = C_YanjieNewCollectionPanel

function M:OnAwake()
	return
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_YANJIE_CATEGORY_CHANGE] = self:CreateAction("OnCategoryChange")
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.CollectPage)
end

function M:InitView(_)
	self.momentList = self.SubGroup.CommonNewYanjieListTemplateStore
	self.momentList.ignoreNavigate = true

	function self.momentList.GetList(pageIndex, pageCount, callback)
		gSocialNetworkUtils.GetCollectionList(0, pageIndex, pageCount, callback)
	end

	self.momentList:StartRequest()
end

function M:OnEnable()
	if gClientUtils.IsNil(self.parentNav) then
		self.parentNav = self.rootWidget.transform.parent:GetComponentInParent(typeof(SGUI.UNavigationArea))
	end

	self.bindData.navArea.leftNav = self.parentNav
	self.parentNav.rightNav = self.bindData.navArea

	if self.bindData.bEnableOnce then
		if gClientUtils.NotNil(self.bindData.navArea.CurrentActiveContent) then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navArea
		end
	else
		self.bindData.bEnableOnce = true
	end
end

function M:OnDisable()
	self.parentNav.rightNav = nil
end
