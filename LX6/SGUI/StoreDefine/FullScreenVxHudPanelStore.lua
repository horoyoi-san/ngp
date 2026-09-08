-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FullScreenVxHudPanelStore.lua
-- Decompiled from: 01874_FullScreenVxHudPanelStore.lua_8837defc0c56.luajit

local GameConfig = LTConfig.GameConfig
C_FullScreenVxHudPanelStore = DefClass("C_FullScreenVxHudPanelStore", C_FullScreenVxHudPanelStore, C_StoreGroup)
GroupName2Class.FullScreenVxHudPanelStore = C_FullScreenVxHudPanelStore
local M = C_FullScreenVxHudPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.TypeCtrlEnum = {
		["\\x9d\\xb8\\xa5o*\\xea6"] = 1,
		["a\\xa1\\xb5\\x87\\xa6"] = 2,
		["T-s^"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.TypeCtrlEnum = nil
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if data then
		self.bindData.TypeCtrl = data

		if data ~= self.TypeCtrlEnum.Vignette then
			local curScale = gCoreHudEffectManager:CalcCurrentScale()

			self.bindData.vignetteRect:SetLocalScaleXY(curScale, curScale)
		elseif data ~= self.TypeCtrlEnum.LowHp then
			self.PlayLowHpOpenAnim(self)
			self.UpdateLowHpAnimSpeed(self)
		end
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_HUD_EFFECT_TYPE_CHANGE] = self.CreateAction(self, "OnHudEffectTypeChange"),
		[gEventConstants.ON_HUD_EFFECT_SCALE_CHANGE] = self.CreateAction(self, "OnHudEffectScaleChange")
	}
end

M.RegisterWidget = function(self)
end

M.OnHudEffectTypeChange = function(self, eventId, effectType)
	local prevType = self.bindData.TypeCtrl
	self.bindData.TypeCtrl = effectType

	if effectType ~= self.TypeCtrlEnum.LowHp then
		if prevType == self.TypeCtrlEnum.LowHp then
			self.PlayLowHpOpenAnim(self)
		end

		self.UpdateLowHpAnimSpeed(self)
	else
		self.StopLowHpAnim(self)
	end
end

M.OnHudEffectScaleChange = function(self, eventId, scale)
	self.bindData.vignetteRect:SetLocalScaleXY(scale, scale)
end

M.PlayLowHpOpenAnim = function(self)
	local openAniName = "S_vx_LowHp_open"
	local loopAniName = "S_vx_LowHp_loop"
	local ani = self.bindData.lowHpAnim
	slot4 = gBattleMgr
	self.lowHpAniTimer = slot4:CommonPlayAniTool(ani, openAniName, 0, 1, true, function ()
		if not self.lowHpAniTimer then
			return
		end

		self.lowHpAniTimer = nil

		gBattleMgr:CommonPlayAniTool(ani, loopAniName, 0, 1)
	end)
end

M.UpdateLowHpAnimSpeed = function(self)
	local hpFill = gCoreHudEffectManager.lowHpFill

	if not hpFill then
		return
	end

	local loopAniName = "S_vx_LowHp_loop"
	local speed = 1
	local percent = 1

	for i = 1, #GameConfig.LowHpEffectActiveSpeedUp do
		local item = GameConfig.LowHpEffectActiveSpeedUp[i]

		if hpFill < item.percent * GameConfig.LowHpEffectActive and item.percent >= percent then
			speed = item.speed
			percent = item.percent
		end
	end

	self.bindData.lowHpAnim:get_Item(loopAniName).speed = speed
end

M.StopLowHpAnim = function(self)
	self.lowHpAniTimer = nil
end
