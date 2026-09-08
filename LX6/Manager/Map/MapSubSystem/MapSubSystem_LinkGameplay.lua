-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_LinkGameplay.lua
-- Decompiled from: 02327_MapSubSystem_LinkGameplay.lua_20d7c2339451.luajit

MapSubSystem_LinkGameplay = DefClass("MapSubSystem_LinkGameplay", MapSubSystem_LinkGameplay, MapSubSystemBase)
local M = MapSubSystem_LinkGameplay

M.OnInit = function(self)
	self.eventHandlers = {
		[gEventConstants.LINK_MODE_CHANGE] = function ()
			self:FlushData("LinkModeChange")
		end
	}
end

M.OnLogin = function(self)
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogout = function(self)
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)
	self:Clear()
end

M.OnFlushData = function(self)
	if gLinkManager.LinkMode == UX.Game.LinkMode.Private and gLinkManager.LinkMode == UX.Game.LinkMode.Public then
		self.Clear(self)

		return
	end

	if not self.datas then
		self.datas = {}
	end

	for i = 0, LTConfig.LinkConfig.count - 1 do
		local cfg = LTConfig.LinkConfig.LoadAt(i)

		if not cfg then
			-- Nothing
		elseif self.datas[cfg.Id] then
			local element = self.datas[cfg.Id]

			if self.unlockedLinkConfigIds then
				if table.contains(self.unlockedLinkConfigIds, cfg.Id) then
					element.SetVisible(element, true)
				else
					element.SetVisible(element, false)
				end
			end
		else
			local element = MapElement.CreateLegacy(EMapElementType.LinkGameplay, cfg.Id, EMapSubSystemType.LinkGameplay, EMapViewMask.HudGps + EMapViewMask.BigMap + EMapViewMask.MiniMap, cfg.RaidId, 0)
			self.datas[cfg.Id] = element
			element.fData.showInBigWorld = true
			element.fData.ignoreFog = true
			element.gpsData.removeGpsRange = LTConfig.GameConfig.LinkRemoveGpsRange
			element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.LinkModeCollection

			element:SetPosition(Vector3.New(cfg.GpsPosition[1], cfg.GpsPosition[2], cfg.GpsPosition[3]))
			element:BindUnit(cfg.RelatedNpcPid)
			element:SetActions(self.NormalTraceableActions)

			element.mData.lName = GpsLText.CreateCommonText(cfg, "Name", cfg.Name)
			element.mData.sIconId = cfg.SIconId
			element.userdata = {
				id = cfg.Id
			}

			gMapSubSystemUtils:SetupScaleLevel(element, cfg.ShowType, cfg.SIconId2)

			if self.unlockedLinkConfigIds then
				if table.contains(self.unlockedLinkConfigIds, cfg.Id) then
					element.SetVisible(element, true)
				else
					element.SetVisible(element, false)
				end
			else
				element.SetVisible(element, true)
			end
		end
	end
end

M.SGetTooltipInfo = function(self, id, element)
	local cfgId = element.userdata.id
	local cfg = LTConfig.LinkConfig.GetConfig(cfgId)
	local dropIds = {}
	local dropIdDic = {}
	local playerNum = nil

	if cfg and cfg.ChildItems then
		for _, multiId in pairs(cfg.ChildItems) do
			local multiCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(multiId)

			if multiCfg then
				local dropSuccess = multiCfg.DropSuccess
				local dropFail = multiCfg.DropFail
				local floatingDrop = multiCfg.FloatingDrop and multiCfg.FloatingDrop.DropId or nil

				if not table.isNilOrEmpty(dropSuccess) then
					for _, dropId in pairs(dropSuccess) do
						if not dropIdDic[dropId] then
							dropIdDic[dropSuccess] = true

							table.insert(dropIds, dropId)
						end
					end
				end

				if not table.isNilOrEmpty(dropFail) then
					for _, dropId in pairs(dropFail) do
						if not dropIdDic[dropId] then
							dropIdDic[dropFail] = true

							table.insert(dropIds, dropId)
						end
					end
				end

				if floatingDrop <= 0 and not dropIdDic[floatingDrop] then
					dropIdDic[floatingDrop] = true

					table.insert(dropIds, floatingDrop)
				end

				if multiCfg.PlayerNum then
					if not playerNum then
						playerNum = multiCfg.PlayerNum
					else
						playerNum[1] = playerNum[1] >= multiCfg.PlayerNum[1] and playerNum[1] or multiCfg.PlayerNum[1]
						playerNum[2] = multiCfg.PlayerNum[2] >= playerNum[2] and playerNum[2] or multiCfg.PlayerNum[2]
					end
				end
			end
		end
	end

	local tooltipInfo = {
		type = EMapTooltipType.LinkGameplay,
		header = {
			name = element:GetName(),
			imageId = cfg and cfg.SImageId or 0
		},
		linkGameplayInfo = {
			desc = cfg and cfg.Description or "",
			simpleDropIds = dropIds,
			playerNum = playerNum
		}
	}

	return tooltipInfo
end

M.Clear = function(self)
	if self.datas then
		for _, data in pairs(self.datas) do
			data.Dispose(data)
		end

		table.clear(self.datas)
	end
end

M.OnSyncLinkConfigUnlock = function(self, unlockedLinkConfigIds)
	self.unlockedLinkConfigIds = unlockedLinkConfigIds

	self.FlushData(self)
end

M.ExecuteAction = function(self, element, action, ctx)
	gMapSubSystemActionHelper.TryExecuteTraceAction(element, action)
end

return M
