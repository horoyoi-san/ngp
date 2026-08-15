C_YanjieMyReleasePanel = DefClass("C_YanjieMyReleasePanel", C_YanjieMyReleasePanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieMyReleasePanel = C_YanjieMyReleasePanel
local M = C_YanjieMyReleasePanel

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:InitView(_)
	self.momentList = self.SubGroup.CommonNewYanjieListTemplateStore
	self.momentList.ignoreNavigate = true

	function self.momentList.GetList(pageIndex, pageCount, callback)
		gSocialNetworkUtils.GetMyReleaseMomentList(pageIndex, pageCount, callback)
	end

	self.momentList:StartRequest()
end
