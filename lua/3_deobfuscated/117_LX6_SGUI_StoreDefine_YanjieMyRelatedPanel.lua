C_YanjieMyRelatedPanel = DefClass("C_YanjieMyRelatedPanel", C_YanjieMyRelatedPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieMyRelatedPanel = C_YanjieMyRelatedPanel
local M = C_YanjieMyRelatedPanel

function M:ctor()
	return
end

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
end

function M:InitView(_)
	self.momentList = self.SubGroup.CommonNewYanjieListTemplateStore
	self.momentList.ignoreNavigate = true

	function self.momentList.GetList(pageIndex, pageCount, callback)
		gSocialNetworkUtils.GetMyRelatedMomentList(pageIndex, pageCount, callback)
	end

	self.momentList:StartRequest()
end

function M:OnCategoryChange(_, categoryId)
	if self.categoryId == categoryId then
		return
	end

	self.categoryId = categoryId

	self.momentList:ClearAndRefreshData()
end
