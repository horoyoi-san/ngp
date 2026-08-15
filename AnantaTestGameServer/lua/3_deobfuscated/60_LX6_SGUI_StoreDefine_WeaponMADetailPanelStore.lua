C_WeaponMADetailPanelStore = DefClass("C_WeaponMADetailPanelStore", C_WeaponMADetailPanelStore, C_StoreGroup)
GroupName2Class.WeaponMADetailPanelStore = C_WeaponMADetailPanelStore
local M = C_WeaponMADetailPanelStore

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	self.tipQualityCtrlEnum = {
		blue = 3,
		greengrey = 1,
		gold = 5,
		grey = 0,
		green = 2,
		orange = 6,
		purple = 4,
		noquality = 7
	}
	self.LockCtrlEnum = {
		_false = 0,
		_true = 1
	}
	self.toolTipRenderData = {}
end

function M:ClearAllEnumsAutoGen()
	self.tipQualityCtrlEnum = nil
	self.LockCtrlEnum = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnShow(panelId, data)
	local fsId = data
	local fsCfg = LTConfig.FightSkillConfig.GetConfig(fsId)

	if not fsCfg then
		print_error("FightSkillConfig 表获取不到数据，id=", fsId)

		return
	end

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
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

		table.insert(self.toolTipRenderData, desc)
	end

	self.bindData.tipMAList:SetSimpleList(#self.toolTipRenderData)
end

function M:OnClose()
	self.toolTipRenderData = nil
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device

	self.bindData.tipMAList:SetSimpleList(#self.toolTipRenderData)
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.tipMAList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTipMAListItem")
	self.bindData.tipMAList.luaSimpleDynamicRenderItem = self:CreateAction("OnSimpleRenderTipMAListItem")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
end

function M:OnSimpleRenderTipMAListItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local data = self.toolTipRenderData[index + 1]

	if store and data then
		local text = nil

		if self.mobileMode then
			text = data[1]
		elseif self.gamepadMode then
			text = data[3] or data[1]
		else
			text = data[2] or data[1]
		end

		text = text or ""
		store.maText = gGuideGlyph:GetRichTextByGuideStr(text)
	end
end

function M:OnCloseBtnClick()
	gPanelManager:Close(gPanelId.WEAPON_MA_DETAIL_PANEL)
end
