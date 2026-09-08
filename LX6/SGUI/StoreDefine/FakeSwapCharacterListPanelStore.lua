-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FakeSwapCharacterListPanelStore.lua
-- Decompiled from: 02069_FakeSwapCharacterListPanelStore.lua_546da5d5bffe.luajit

C_FakeSwapCharacterListPanelStore = DefClass("C_FakeSwapCharacterListPanelStore", C_FakeSwapCharacterListPanelStore, C_SwapCharacterListPanelStore)
GroupName2Class.FakeSwapCharacterListPanelStore = C_FakeSwapCharacterListPanelStore
local M = C_FakeSwapCharacterListPanelStore

M.ctor = function(self)
end

M.OnShow = function(self, panelId, data)
	self.fakeSwitchCharData = gTimelineManager:FakeSwitchChar_GetUIParams()

	M.base.OnShow(self, panelId, data)
end

M.BuildCharacterData = function(self)
	table.clear(self.showSpiritSet)

	self.hasTaskRole = false

	if self.fakeSwitchCharData then
		local sourceSpiritId = self.fakeSwitchCharData.sourceSwitchCharSpiritId
		local targetSpiritId = self.fakeSwitchCharData.targetSwitchCharSpiritId
		local sourceData = {
			cfg = sourceSpiritId,
			isCurrent = true,
			disabled = false,
			isUnlock = true,
			isMain = true,
			isCase = false,
			isTemp = true,
			spiritCaseId = 0,
			isGuide = false,
			roleId = sourceSpiritId,
			taskAllow = true
		}
		self.showSpiritSet[1] = sourceData
		self.selectedChar = sourceSpiritId
		local targetData = {
			cfg = targetSpiritId,
			isCurrent = false,
			disabled = false,
			isUnlock = true,
			isMain = true,
			isCase = false,
			isTemp = true,
			spiritCaseId = 0,
			isGuide = true,
			roleId = targetSpiritId,
			taskAllow = true
		}
		self.showSpiritSet[2] = targetData
		local otherSpirits = {}
		local sexType = gPlayerManager.infoLogin.bindData.sexType

		for i = 0, LTConfig.FightSpiritConfig.count - 1 do
			local cfg = LTConfig.FightSpiritConfig.LoadAt(i)

			if cfg.Id == sourceSpiritId and cfg.Id == targetSpiritId and cfg.CanJoin then
				if cfg.Id ~= LTConfig.FightSpiritConfig.DefaultMale then
					if sexType ~= UX.Game.SexType.Male then
						table.insert(otherSpirits, cfg.Id)
					end
				elseif cfg.Id ~= LTConfig.FightSpiritConfig.DefaultFemale then
					if sexType ~= UX.Game.SexType.Female then
						table.insert(otherSpirits, cfg.Id)
					end
				else
					table.insert(otherSpirits, cfg.Id)
				end
			end
		end

		local lockCharacter = {}

		for _, id in ipairs(otherSpirits) do
			local agentId = LTConfig.FightSpiritConfig.GetConfig(id).AgentId
			local isKnow = false

			table.insert(lockCharacter, {
				["JTO|\\,"] = false,
				["\\xaf\\xb8\\xaah2\\xfb7"] = false,
				["\\xa2\\xa20\\xa5f1\\xfd8"] = false,
				cfg = id,
				isKnow = isKnow,
				agentId = agentId
			})
		end

		for _, data in ipairs(lockCharacter) do
			table.insert(self.showSpiritSet, data)
		end
	end

	self.selectedIndex = 1

	self.freeList:SetList(#self.showSpiritSet)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.RefreshSelectInfo(self, self.showSpiritSet[self.selectedIndex])
	end

	self.CalHexagonBounding(self, #self.showSpiritSet)
end

M.SwitchCharacter = function(self)
	local canSwitch = true

	if not self.needSwitch then
		canSwitch = false
	end

	if self.selectedChar ~= 0 then
		canSwitch = false
	end

	if self.fakeSwitchCharData and self.fakeSwitchCharData.targetSwitchCharSpiritId == self.selectedChar then
		canSwitch = false
	end

	if canSwitch then
		self.DoSwitchCharacter(self)
	else
		self.DoCancelSwitch(self)
	end

	self.isAskSwitch = canSwitch
end

M.DoSwitchCharacter = function(self)
	gLoadingManager:SwitchTeleport_TryCloseBlur()
	gTimelineManager:FakeSwitchChar_StopFakeSwitchChar()
	gMessageManager:SendMessage(gEventConstants.CUTSCENE_FAKE_SWITCH_CHAR)

	self.selectedChar = 0
end
