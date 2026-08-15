local panelConfig = LTConfig.PanelConfig
GroupName2Id = GroupName2Id or {}
Id2GroupName = Id2GroupName or {}
local M = {
	OnInit = function (self)
		for i = 0, panelConfig.count - 1 do
			local cfg = panelConfig.LoadAt(i)

			if cfg.storeName then
				GroupName2Id[cfg.storeName] = cfg.Id
				Id2GroupName[cfg.Id] = cfg.storeName
			end
		end
	end,
	GetEntry = function (self, panelId)
		return panelConfig.GetConfig(panelId) or {}
	end
}
gPanelEntry = M
