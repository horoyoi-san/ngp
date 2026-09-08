-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WeaponMADetailPanelStore.lua
-- Decompiled from: 01156_WeaponMADetailPanelStore.lua_55ac7c667b9f.luajit

C_WeaponMADetailPanelStore = DefClass("C_WeaponMADetailPanelStore", C_WeaponMADetailPanelStore, C_StoreGroup)
GroupName2Class.WeaponMADetailPanelStore = C_WeaponMADetailPanelStore
local M = C_WeaponMADetailPanelStore

M.DefineAllVariables = function(self)
	self.toolTipRenderData = {}
	self.CONTROL = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
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
	self.LockCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.tipQualityCtrlEnum = nil
	self.LockCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	local fsId = data
	local fsCfg = LTConfig.FightSkillConfig.GetConfig(fsId)

	if not fsCfg then
		print_error("FightSkillConfig 表获取不到数据，id=", fsId)

		return
	end

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.mobileMode = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.bindData.tipMAName = fsCfg.Name
	self.bindData.tipMAIcon = fsCfg.IconId
	self.bindData.tipQualityCtrl = fsCfg.Quality
	self.bindData.tipFsTag = fsCfg.Tag
	local cfg = gWeaponManager:GetFightSkillStyleCfg(fsId)
	self.bindData.tipFsType = cfg and cfg.Name or ""

	table.clear(self.toolTipRenderData)

	for i = 1, 8 do
		local desc = fsCfg["Text" .. i]

		if table.isNilOrEmpty(desc) then
			break
		end

		local locked = false

		if fsCfg["UnlockCondition" .. i] and fsCfg["UnlockCondition" .. i]() ~= false then
			locked = true
		end

		table.insert(self.toolTipRenderData, {
			desc = desc,
			locked = locked
		})
	end

	self.bindData.tipMAList:SetSimpleList(#self.toolTipRenderData)
end

M.OnClose = function(self)
	self.toolTipRenderData = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device

	self.bindData.tipMAList:SetSimpleList(#self.toolTipRenderData)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.tipMAList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTipMAListItem")
	self.bindData.tipMAList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderTipMAListItem")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
end

M.OnSimpleRenderTipMAListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local data = self.toolTipRenderData[index + 1]

	if store and data then
		local text = nil

		if self.mobileMode then
			text = data.desc[1]
		elseif self.gamepadMode then
			text = data.desc[3] or data.desc[1]
		else
			text = data.desc[2] or data.desc[1]
		end

		text = text or ""
		store.maText = gGuideGlyph:GetRichTextByGuideStr(text)
		store.LockCtrl = data.locked and self.CONTROL.TRUE or self.CONTROL.FALSE
	end
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(gPanelId.WEAPON_MA_DETAIL_PANEL)
end
