C_GuideBT_CheckBigMapSelect = DefClass("C_GuideBT_CheckBigMapSelect", C_GuideBT_CheckBigMapSelect, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckBigMapSelect

function M:OnCreate()
	self.mapStore = gStoreManager:GetStoreGroup("NewMapPanelStore")
end

function M:Eval()
	if not self.mapStore then
		self.mapStore = gStoreManager:GetStoreGroup("NewMapPanelStore")
	end

	self.isGpsIdMatch.val = self.mapStore and self.mapStore.selectedGpsId and self.mapStore.selectedGpsId == self.gpsId:Eval()
end
