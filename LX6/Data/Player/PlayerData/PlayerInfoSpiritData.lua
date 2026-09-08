-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoSpiritData.lua
-- Decompiled from: 00098_PlayerInfoSpiritData.lua_0cccaeb60276.luajit

C_PlayerInfoSpiritData = DefClass("C_PlayerInfoSpiritData", C_PlayerInfoSpiritData, C_PlayerDataBase)
local M = C_PlayerInfoSpiritData

M.InitPlayerInfo = function(self, info)
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
	t.InstalledApps = info.InfoSpirit.InstalledApps
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

	gWeaponManager:DictClear()
	gWeaponManager:ClearAllArmory()

	local armoryDict = info.InfoSpirit.ExtraArmories

	if armoryDict then
		for armoryId, infoArmory in pairs(armoryDict) do
			if infoArmory.Weapons then
				gWeaponManager:SyncArmoryWeapons(armoryId, infoArmory.Weapons)
			end
		end
	end

	local armoryWeapons = info.InfoSpirit.InfoArmory.Weapons

	if armoryWeapons then
		gWeaponManager:SyncArmoryWeapons(LTConfig.SceneitemWeaponArmoryIndexConfig.WeaponArmoryIndex_World, armoryWeapons)
	end

	t.SpiritWeaponSlotDict = {}
	local spirits = info.InfoSpirit.Spirits

	for i = 1, spirits.Count do
		local slots = spirits[i].WeaponSlots
		t.SpiritWeaponSlotDict[spirits[i].TemplateId] = slots

		if slots then
			for j = 1, slots.Length do
				gWeaponManager:DictAdd(slots[j])
			end
		end
	end

	self.bindData:RefreshData(t)

	gPoliceJobManager.todayMissionCnt = 0
	gPoliceJobManager.completeCntInHideTask = 0

	if info.InfoSpirit.InfoPolice then
		gPoliceJobManager.todayMissionCnt = info.InfoSpirit.InfoPolice.TodayCompleteMissionCnt
	end

	t.SexTransitionLastTime = info.InfoSpirit.SexTransitionLastTime
	gHomeInteractionManager.sexTransitionLastTime = t.SexTransitionLastTime
end

M.OnLogOut = function(self)
	self.bindData:Clear()
end
