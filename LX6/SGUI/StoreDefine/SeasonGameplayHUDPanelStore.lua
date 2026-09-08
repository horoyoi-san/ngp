-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SeasonGameplayHUDPanelStore.lua
-- Decompiled from: 00877_SeasonGameplayHUDPanelStore.lua_942b9870dfc1.luajit

local SeasonRaidConfig = LTConfig.SeasonRaidConfig
local AreaConfig = LTConfig.SeasonRaidAreaConfig
local AreaTargetConfig = LTConfig.SeasonRaidAreaTargetConfig
C_SeasonGameplayHUDPanelStore = DefClass("C_SeasonGameplayHUDPanelStore", C_SeasonGameplayHUDPanelStore, C_StoreGroup)
GroupName2Class.SeasonGameplayHUDPanelStore = C_SeasonGameplayHUDPanelStore
local M = C_SeasonGameplayHUDPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.targets = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterButtons(self)
	self.RegisterLists(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	gSeasonRaidUtils:SetChaosProgress(self.bindData, 0)
	self:PlayChaosLevelUpShow(gSeasonDataMgr.chaosLevel)
	self:RefreshAreaTargets(gSeasonDataMgr.currentAreaId)
end

M.RegisterButtons = function(self)
	self.bindData.packageBtn.luaClick = self.CreateAction(self, "OnPackageBtnClick")
	self.bindData.characterBtn.luaClick = self.CreateAction(self, "OnCharacterBtnClick")
end

M.OnPackageBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.S_SEASON_PACKAGE_PANEL)
end

M.OnCharacterBtnClick = function(self)
end

M.RegisterLists = function(self)
	self.bindData.targetList.luaRenderItem = self.CreateAction(self, "OnRenderTargetList")
end

M.OnRenderTargetList = function(self, btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SeasonEntranceTemplate"):GetStoreById(id)

	if store then
		store.stateCtrl = data.isFinished and 0 or 1
		store.targetText = data.content
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SEASON_RAID_CHAOS_CHANGED] = function (eventId, inData)
			local data = inData

			if data.hasValueChanged then
				gSeasonRaidUtils:SetChaosProgress(self.bindData, 0)
			end

			if data.hasLevelChanged then
				self:PlayChaosLevelUpShow(data.level)
			end
		end,
		[gEventConstants.SEASON_RAID_AREA_TARGETS_CHANGED] = function (eventId, inData)
			self:RefreshAreaTargets(gSeasonDataMgr.currentAreaId)
		end
	}
end

M.PlayChaosLevelUpShow = function(self, newLevel)
	self.bindData.warningCtrl = 1
	local levelConfig = gSeasonRaidUtils:FindConfigByLevel(newLevel)

	if levelConfig then
		self.bindData.warningText = levelConfig.Description
	else
		print_error(gString.Format("未找到相应的混厄等级配置：%d", newLevel))

		self.bindData.warningText = ""
	end

	if self.chaosLevelUpTimer and self.chaosLevelUpTimer.running then
		self.chaosLevelUpTimer:Stop()
	end

	self.chaosLevelUpTimer = Timer.New(function ()
		self:PlayChaosLevelUpHide()
	end, SeasonRaidConfig.ChaosLevelUpTipDuration, false, false, false)

	self.chaosLevelUpTimer:Start()
end

M.PlayChaosLevelUpHide = function(self)
	self.bindData.warningCtrl = 0

	if self.chaosLevelUpTimer and self.chaosLevelUpTimer.running then
		self.chaosLevelUpTimer:Stop()
	end

	self.chaosLevelUpTimer = nil
end

M.RefreshAreaTargets = function(self, areaId)
	table.clear(self.targets)

	if areaId <= 0 then
		local areaConfig = AreaConfig.GetConfig(areaId)

		if not areaConfig then
			print_error(gString.Format("Cannot find SeasonRaidAreaConfig(%s)", tostring(areaId)))

			self.bindData.targetTitleText = ""
		else
			self.bindData.targetTitleText = areaConfig.Description

			for _, areaTargetId in ipairs(areaConfig.AreaTarget) do
				local areaTargetConfig = AreaTargetConfig.GetConfig(areaTargetId)

				if areaTargetConfig == nil then
					local isFinished = areaTargetConfig.Counter > gSeasonDataMgr:GetTargetCount(areaTargetConfig.Id)
					local data = {
						isFinished = isFinished,
						content = areaTargetConfig.Description
					}

					table.insert(self.targets, data)
				else
					print_error(gString.Format("Cannot find SeasonRaidAreaTargetConfig(%s)", tostring(areaTargetId)))
				end
			end
		end
	end

	self.bindData.targetList:SetList(self.targets)
end
