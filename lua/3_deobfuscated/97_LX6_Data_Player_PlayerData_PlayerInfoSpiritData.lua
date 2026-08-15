C_PlayerInfoSpiritData = DefClass("C_PlayerInfoSpiritData", C_PlayerInfoSpiritData, C_PlayerDataBase)
local M = C_PlayerInfoSpiritData

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template
	t.spiritFragmentPoint = info.InfoSpirit.FragmentPoints
	t.SpecificFragmentCount = info.InfoSpirit.SpecificFragmentCount
	t.CommonFragmentCount = {
		0,
		info.InfoSpirit.CommonBlueFragmentCount,
		0,
		info.InfoSpirit.CommonPurpleFragmentCount,
		info.InfoSpirit.CommonGoldFragmentCount
	}
	t.AvailableSkinParts = info.InfoSpirit.AvailableSkinParts
	gBattlePetsMgr.petDataDic = {}

	if info.InfoSpirit.InfoPokemon.AllPokemons then
		for i = 1, info.InfoSpirit.InfoPokemon.AllPokemons.Count do
			local item = info.InfoSpirit.InfoPokemon.AllPokemons[i]
			gBattlePetsMgr.petDataDic[item.Id] = item
		end

		gBattlePetsMgr:SyncQuickSummonList(info.InfoSpirit.InfoPokemon.FastFightSquad)
	end

	if info.InfoSpirit.InfoPokemon.EnabledBodyIds then
		gBattlePetsMgr:SyncUnlockedEquipIds(info.InfoSpirit.InfoPokemon)
	end

	t.FastSwitchSquad = info.InfoSpirit.FastSwitchSquad
	t.ArmoryWeapons = {}
	local armoryWeapons = info.InfoSpirit.InfoArmory.Weapons

	if armoryWeapons then
		for i = 1, armoryWeapons.Count do
			local weapon = armoryWeapons[i]

			if weapon then
				t.ArmoryWeapons[weapon.InstanceId] = weapon
			end
		end
	end

	t.SpiritWeaponSlotDict = {}
	local spirits = info.InfoSpirit.Spirits

	for i = 1, spirits.Count do
		t.SpiritWeaponSlotDict[spirits[i].TemplateId] = spirits[i].WeaponSlots
	end

	gTalentTreeMgr:OnSyncCommonTalentInfo(0, info.InfoSpirit.CommonSpiritTalentExp)
	self.bindData:RefreshData(t)
end

function M:OnLogOut()
	self.bindData:Clear()
end
