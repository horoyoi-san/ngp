-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WeaponArmoryMATooltipStore.lua
-- Decompiled from: 01151_WeaponArmoryMATooltipStore.lua_819189925b8a.luajit

local SceneitemConfig = LTConfig.SceneitemConfig
C_WeaponArmoryMATooltipStore = DefClass("C_WeaponArmoryMATooltipStore", C_WeaponArmoryMATooltipStore, C_StoreGroup)
GroupName2Class.WeaponArmoryMATooltipStore = C_WeaponArmoryMATooltipStore
local M = C_WeaponArmoryMATooltipStore

M.DefineAllVariables = function(self)
	self.maData = {}
	self.TOOLTIP_TEMPLATE = {
		["\\xbaIA"] = 2,
		["y\\x87\\x96\\x83\\x93"] = 0,
		["\\xfa\\xf4:);\n\\xc5"] = 1
	}
	self.CONTROL = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.BTN_MODE_LOGIC = {
		["8g\\xa4\\xac\\xafd"] = 2,
		["/a\\xbf\\xa9\\xafd"] = 1,
		["T\rS~"] = 0
	}
	self.leftCallback = nil
	self.rightCallback = nil
	self.buttonModeLogic = 0
	self.buttonRightEnableLogic = false
	self.buttonLeftEnableLogic = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.qualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.buttonModeCtrlEnum = {
		["_\\xa7\\xa5\\xa7\\xa2"] = 2,
		["x-iS"] = 3,
		["v'{O"] = 1,
		["t-s^"] = 0
	}
	self.checkActiveCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.checkSelectedCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.leftBtnTextStateCtrlEnum = {
		["8M\\x85\\x8f\\x8aM"] = 1,
		["qB|eO?"] = 0
	}
	self.tipShowModeCtrlEnum = {
		["fVy`^\n<"] = 1,
		["\\x88\\xbe\\xadf7\\xfd'"] = 2,
		["T-s^"] = 0
	}
	self.typeCtrlEnum = {
		["\\x9d"] = 0,
		["\\x9c"] = 1,
		["\\x9f"] = 2,
		["\\x9e"] = 3,
		["\\x99"] = 4
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.qualityCtrlEnum = nil
	self.buttonModeCtrlEnum = nil
	self.checkActiveCtrlEnum = nil
	self.checkSelectedCtrlEnum = nil
	self.leftBtnTextStateCtrlEnum = nil
	self.tipShowModeCtrlEnum = nil
	self.typeCtrlEnum = nil
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
	self.maData = nil
	self.TOOLTIP_TEMPLATE = nil
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
	self.bindData.attrList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderAttrListItem")
	self.bindData.attrList.onGetTIndex = self:CreateAction("OnAttrListGetTIndex")
	self.bindData.checkBoxBtn.luaClick = self:CreateAction("OnCheckBoxBtnClick")

	self.bindData.videoPlayer:Init()

	self.bindData.leftBtn.luaClick = self:CreateAction("OnLeftBtnClick")
	self.bindData.rightBtn.luaClick = self:CreateAction("OnRightBtnClick")
end

M.OnAttrListGetTIndex = function(self, index)
	local idx = index + 1
	local data = self.maData and self.maData.attrInfos and self.maData.attrInfos[idx]

	if data then
		return data.template
	end

	return 0
end

M.OnSimpleRenderAttrListItem = function(self, btn, index)
	local data = self.maData and self.maData.attrInfos[index + 1]

	if data then
		if data.template ~= self.TOOLTIP_TEMPLATE.TITLE then
			local store = gStoreManager:GetStoreGroup("WeaponArmoryTooltipStore"):GetStoreByWidget(btn)

			if store then
				store.title = data.title
			end
		elseif data.template ~= self.TOOLTIP_TEMPLATE.CONTENT then
			local store = gStoreManager:GetStoreGroup("WeaponArmoryTooltipStore"):GetStoreByWidget(btn)

			if store then
				store.content = data.content
			end
		elseif data.template ~= self.TOOLTIP_TEMPLATE.TAG then
			local store = gStoreManager:GetStoreGroup("WeaponArmoryMATooltipStore"):GetStoreByWidget(btn)

			if store then
				store.tagList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderTagListItem", data.tagList)

				store.tagList:SetSimpleList(#data.tagList)
			end
		end
	end
end

M.OnSimpleRenderTagListItem = function(self, tags, btn, index)
	local data = tags[index + 1]
	local store = gStoreManager:GetStoreGroup("WeaponArmoryMATooltipStore"):GetStoreByWidget(btn)

	if data and store then
		store.name = data.TagName
		store.typeCtrl = data.TagType
	end
end

M.OnCheckBoxBtnClick = function(self)
	local select = self:GetCheckSelect()
	select = not select
	self.bindData.checkSelectedCtrl = select and self.CONTROL.TRUE or self.CONTROL.FALSE
end

M.OnLeftBtnClick = function(self)
	if self.leftCallback then
		self.leftCallback()
	end
end

M.OnRightBtnClick = function(self)
	if self.rightCallback then
		self.rightCallback()
	end
end

M.RegisterButtonHandler = function(self, leftCallback, rightCallback)
	self.leftCallback = leftCallback
	self.rightCallback = rightCallback
end

M.SetTipShowMode = function(self, mode)
	self.bindData.tipShowModeCtrl = mode
end

M.SetMAId = function(self, id)
	local cfg = LTConfig.FightSkillConfig.GetConfig(id)

	if not cfg then
		print_error("[WeaponArmoryMATooltipStore] FightSkillConfig 找不到配表数据，id=", id)

		return
	end

	if not self.maData then
		print_error("[WeaponArmoryMATooltipStore] prefab 实例已销毁，还在调用设置方法 name=", self.m_Name)

		return
	end

	table.clear(self.maData)

	self.maData.cfg = cfg
	self.maData.attrInfos = self.GetAttrInfos(self, cfg)
	self.bindData.name = cfg.Name
	self.bindData.qualityCtrl = cfg.Quality
	local adaptiveWeapon = ""

	for i = 1, LTConfig.SceneitemFightStyleConfig.count - 1 do
		local fsCfg = LTConfig.SceneitemFightStyleConfig.GetConfig(i)

		if fsCfg and fsCfg.FightSkillTypes and table.contains(fsCfg.FightSkillTypes, cfg.FightSkillType) then
			adaptiveWeapon = fsCfg.Name or ""

			break
		end
	end

	self.bindData.adaptWeaponType = adaptiveWeapon
	local typeCfg = LTConfig.FightSkillFightSkillTypeConfig.GetConfig(cfg.FightSkillType)
	self.bindData.typeIcon = typeCfg and typeCfg.ImageId or 0

	self.bindData.videoPlayer:PlayVideo(cfg.Video or 0, true)
	self.bindData.attrList:SetSimpleList(#self.maData.attrInfos)
end

M.GetAttrInfos = function(self, cfg)
	local infos = {}
	local tagList = {}

	if cfg.TagId then
		for i = 1, #cfg.TagId do
			local tagCfg = LTConfig.FightSkillFightSkillTagConfig.GetConfig(cfg.TagId[i])

			if tagCfg then
				table.insert(tagList, tagCfg)
			end
		end
	end

	table.insert(infos, {
		tagList = tagList,
		template = self.TOOLTIP_TEMPLATE.TAG
	})
	table.insert(infos, {
		title = SceneitemConfig.TooltipData4,
		template = self.TOOLTIP_TEMPLATE.TITLE
	})
	table.insert(infos, {
		content = cfg.SimpleDesc or "",
		template = self.TOOLTIP_TEMPLATE.CONTENT
	})

	return infos
end

M.SetCheckActive = function(self, active)
	self.bindData.checkActiveCtrl = active and self.checkActiveCtrlEnum._true or self.checkActiveCtrlEnum._false
end

M.ResetCheck = function(self)
	self.bindData.checkSelectedCtrl = 0
end

M.GetCheckSelect = function(self)
	return self:GetCheckActive() and self.bindData.checkSelectedCtrl and self.bindData.checkSelectedCtrl ~= 1 or false
end

M.GetCheckActive = function(self)
	return self.bindData.checkActiveCtrl and self.bindData.checkActiveCtrl ~= 1 or false
end

M.SetButtonModeLogic = function(self, mode)
	self.buttonModeLogic = mode
	self.bindData.buttonModeCtrl = self.getButtonMode(self)
end

M.SetButtonLeftEnableLogic = function(self, enable)
	self.buttonLeftEnableLogic = enable
	self.bindData.buttonModeCtrl = self.getButtonMode(self)
end

M.SetButtonRightEnableLogic = function(self, enable)
	self.buttonRightEnableLogic = enable
	self.bindData.buttonModeCtrl = self.getButtonMode(self)
end

M.getButtonMode = function(self)
	if self.buttonModeLogic ~= self.BTN_MODE_LOGIC.NONE then
		return self.buttonModeCtrlEnum.none
	elseif self.buttonModeLogic ~= self.BTN_MODE_LOGIC.SINGLE then
		if self.buttonLeftEnableLogic then
			return self.buttonModeCtrlEnum.left
		elseif self.buttonRightEnableLogic then
			return self.buttonModeCtrlEnum.right
		else
			return self.buttonModeCtrlEnum.none
		end
	elseif self.buttonModeLogic ~= self.BTN_MODE_LOGIC.DOUBLE then
		if self.buttonLeftEnableLogic and self.buttonRightEnableLogic then
			return self.buttonModeCtrlEnum.both
		elseif not self.buttonLeftEnableLogic and not self.buttonRightEnableLogic then
			return self.buttonModeCtrlEnum.none
		elseif self.buttonLeftEnableLogic then
			return self.buttonModeCtrlEnum.left
		else
			return self.buttonModeCtrlEnum.right
		end
	end

	return self.buttonModeCtrlEnum.none
end

M.SetLeftButtonControllerActionId = function(self, id)
	self.bindData.leftControllerKey:ChangeActionId(id)
end

M.SetRightButtonControllerActionId = function(self, id)
	self.bindData.rightControllerKey:ChangeActionId(id)
end

M.ClearButtonState = function(self)
	self.bindData.leftBtn:InstantClearState()
	self.bindData.rightBtn:InstantClearState()
end
