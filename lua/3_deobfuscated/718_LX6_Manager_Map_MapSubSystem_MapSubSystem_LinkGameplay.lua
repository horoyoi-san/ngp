MapSubSystem_LinkGameplay = DefClass("MapSubSystem_LinkGameplay", MapSubSystem_LinkGameplay, MapSubSystemBase)
local M = MapSubSystem_LinkGameplay

function M:OnInit()
	self.eventHandlers = {
		[gEventConstants.LINK_MODE_CHANGE] = function ()
			self:FlushData("LinkModeChange")
		end
	}
end

function M:OnLogin()
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:OnLogout()
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)
	self:Clear()
end

function M:OnFlushData()
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Private and gLinkManager.LinkMode ~= UX.Game.LinkMode.Public then
		self:Clear()

		return
	end

	if not self.datas then
		self.datas = {}
	end

	for i = 0, LTConfig.LinkConfig.count - 1 do
		local cfg = LTConfig.LinkConfig.LoadAt(i)

		if cfg then
			if not self.datas[cfg.Id] then
				local element = MapElement.CreateLegacy(EMapElementType.LinkGameplay, cfg.Id, EMapSubSystemType.LinkGameplay, EMapViewMask.HudGps + EMapViewMask.BigMap + EMapViewMask.MiniMap, cfg.RaidId, 0)
				self.datas[cfg.Id] = element
				element.fData.showInBigWorld = true
				element.fData.ignoreFog = true
				element.gpsData.removeGpsRange = LTConfig.GameConfig.LinkRemoveGpsRange
				element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.LinkModeCollection

				element:SetPosition(Vector3.New(cfg.GpsPosition[1], cfg.GpsPosition[2], cfg.GpsPosition[3]))
				element:BindUnit(cfg.RelatedNpcPid)
				element:SetActions(self.NormalTraceableActions)
				element:SetVisible(true)

				element.mData.lName = GpsLText.CreateCommonText(cfg, "Name", cfg.Name)
				element.mData.sIconId = cfg.SIconId
				element.userdata = {
					id = cfg.Id
				}

				gMapSubSystemUtils:SetupScaleLevel(element, cfg.ShowType, cfg.SIconId2)
			end
		end
	end
end

function M:SGetTooltipInfo(id, element)
	local cfgId = element.userdata.id
	local cfg = LTConfig.LinkConfig.GetConfig(cfgId)
	local tooltipInfo = {
		type = EMapTooltipType.Common,
		header = {
			name = element:GetName(),
			imageId = cfg and cfg.SImageId or 0
		},
		commonInfo = {
			desc = cfg and cfg.Description or ""
		}
	}

	return tooltipInfo
end

function M:Clear()
	if self.datas then
		for _, data in pairs(self.datas) do
			data:Dispose()
		end

		table.clear(self.datas)
	end
end

function M:ExecuteAction(element, action, ctx)
	gMapSubSystemActionHelper.TryExecuteTraceAction(element, action)
end

return M
