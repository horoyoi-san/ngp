-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WeaponChipTooltipStore.lua
-- Decompiled from: 01155_WeaponChipTooltipStore.lua_69ee6bc7e4f5.luajit

C_WeaponChipTooltipStore = DefClass("C_WeaponChipTooltipStore", C_WeaponChipTooltipStore, C_StoreGroup)
GroupName2Class.WeaponChipTooltipStore = C_WeaponChipTooltipStore
local M = C_WeaponChipTooltipStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.leftCallback = nil
	self.rightCallback = nil
	self.moveCallback = nil
	self.equippedWeaponData = nil
	self.tagList = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.tipQualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.tipBtnModeCtrlEnum = {
		["w-k^"] = 2,
		["L\\xbe\\xb2\\xa3\\xaf"] = 0,
		["M\\x9d\\x8b\\x97D"] = 1
	}
	self.tipRBtnTextStateCtrlEnum = {
		[";G\\x93\\x8f\\x80J"] = 2,
		["\\xeb\\xde'\\xf4"] = 1,
		["0\\xe6O \\xd3\\x81D\\xa0F\\xbf\\xb8"] = 0
	}
	self.stockCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.tipQualityCtrlEnum = nil
	self.tipBtnModeCtrlEnum = nil
	self.tipRBtnTextStateCtrlEnum = nil
	self.stockCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.tipLBtn.luaClick = self.CreateAction(self, self.OnClickTipLBtn)
	self.bindData.tipRBtn.luaClick = self.CreateAction(self, self.OnClickTipRBtn)
	self.bindData.moveBtn.luaClick = self.CreateAction(self, self.OnClickMoveBtn)

	self.bindData.weapon.luaRenderTooltip = function(btn, popIns, idx)
		local tooltipStore = gStoreManager:GetStoreGroup("WeaponArmoryTooltipStore")

		if tooltipStore and self.equippedWeaponData then
			tooltipStore.SetBaseWeapon(tooltipStore, self.equippedWeaponData)
		end
	end

	self.bindData.tipTagList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTipTagListItem)
	self.bindData.tipTagList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTipTagList)
end

M.OnClickTipLBtn = function(self)
	if self.leftCallback then
		self.leftCallback()
	end
end

M.OnClickTipRBtn = function(self)
	if self.rightCallback then
		self.rightCallback()
	end
end

M.OnClickMoveBtn = function(self)
	if self.moveCallback then
		self.moveCallback()
	end
end

M.RegisterButtonHandler = function(self, leftCallback, rightCallback, moveCallback)
	self.leftCallback = leftCallback
	self.rightCallback = rightCallback
	self.moveCallback = moveCallback
end

M.SetChipData = function(self, data)
	self.equippedWeaponData = data.equippedWeaponData
	self.bindData.tipName = data.name or ""
	self.bindData.tipQualityCtrl = data.quality or 0
	self.bindData.tipDesc = data.desc or ""
	self.bindData.stockCtrl = data.stockCtrl or 1
	self.bindData.tipBtnModeCtrl = data.btnMode or 0
	self.tagList = data.tags or {}

	self.bindData.tipTagList:SetSimpleList(#self.tagList)

	local weaponStore = gStoreManager:GetStoreGroup(self.bindData.weapon.Store):GetStoreByWidget(self.bindData.weapon)

	if weaponStore then
		if data.equippedCfg then
			weaponStore.weaponIcon = data.equippedCfg.SWeaponWheelsIconId or 0
			weaponStore.qualityCtrl = data.equippedCfg.Quality
			weaponStore.durability = data.durability or ""
			weaponStore.BrokenCtrl = data.brokenCtrl or 0
		else
			weaponStore.weaponIcon = 0
			weaponStore.qualityCtrl = 0
			weaponStore.durability = ""
			weaponStore.BrokenCtrl = 0
		end
	end
end

M.OnSimpleRenderTipTagListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.tagList[index + 1]

	if data then
		store.TypeCtrl = data.TagType
	end
end

M.OnSimpleClickTipTagList = function(self, btn, index)
end
