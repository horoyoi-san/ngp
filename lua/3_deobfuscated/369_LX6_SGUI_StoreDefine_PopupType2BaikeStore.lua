C_PopupType2BaikeStore = DefClass("C_PopupType2BaikeStore", C_PopupType2BaikeStore, C_StoreGroup)
GroupName2Class.PopupType2BaikeStore = C_PopupType2BaikeStore
local M = C_PopupType2BaikeStore

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnShow(panelId, args)
	self.panelId = panelId

	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.areaIndex = args.areaIndex
end

function M:InitView(args)
	self:StartAutoClose()

	local id = args.id
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	self.bindData.name = cityPediaCfg.Name
end

function M:StartAutoClose()
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		gPanelManager:Close(self.panelId)
	end)
end

function M:OnDestroy()
	return
end
