-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\DestructibleHUDCtrl.lua
-- Decompiled from: 02289_DestructibleHUDCtrl.lua_04d113c069b0.luajit

local HUDManager = LX6.GUI.HUDNew.HUDManager
local HUDCtrl = require("LX6/Manager/HUD/HudController")
C_DestructibleHUDCtrl = DefClass("C_DestructibleHUDCtrl", C_DestructibleHUDCtrl, HUDCtrl)
local DestructibleHUDCtrl = C_DestructibleHUDCtrl

DestructibleHUDCtrl.ctor = function(self)
	self.tType = gHudMgr.HUDTargetType.Destruct
	self.destructId = nil
	self.hpShowRule = 0
	self.canShowHp = false
	self.autoHideHpTime = -1
	self.sceneItem = nil
	self.hp = 0
	self.showHpCoId = nil
	self.paperPlaneText = nil
	self.paperPlaneTextAdded = false
end

DestructibleHUDCtrl.RefreshData = function(self)
	self.destructId = gCS.LuaUtils.StringToUlong(string.match(self.uniId, "_(.*)"))
	self.sceneItem = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.destructId)
end

DestructibleHUDCtrl.CustomProcedure = function(self)
	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.SlotTopInfo, self.uniId)
end

DestructibleHUDCtrl.OnCreateSlotTopInfo = function(self)
	self.template.slotTopInfo.icon.gameObject:SetActive(false)
	self.template.slotTopInfo.name.gameObject:SetActive(false)

	self.sceneItem = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.destructId)
	local sceneItem = self.sceneItem
	local canShowHp, showRule = sceneItem:CanShowHp(0)
	self.hpShowRule = showRule
	self.canShowHp = canShowHp

	if canShowHp then
		local hpProgress = sceneItem.hpProgress

		self.HpProgressChange(self, hpProgress)

		if showRule ~= 0 then
			self.autoHideHpTime = 3
		end

		self.OnRefreshHpBarDisplay(self, true)
	else
		self.OnRefreshHpBarDisplay(self, false)
	end
end

DestructibleHUDCtrl.HpProgressChange = function(self, progress)
	self.hp = progress

	if progress ~= nil or progress < 0 then
		self.OnRefreshHpBarDisplay(self, false)

		return
	end

	if progress >= 1 and progress <= 0 then
		self.OnRefreshHpBarDisplay(self, true)
	end

	if self.template.slotTopInfo then
		self.template.slotTopInfo.hpFillAmount = progress
	end
end

DestructibleHUDCtrl.OnRefreshHpBarDisplay = function(self, show, recursionEnd)
	self.template.slotTopInfo.hp.gameObject:SetActive(show)

	if show then
		if recursionEnd then
			return
		end

		if self.autoHideHpTime <= 0 then
			gLuaTimeMgrUtils.CancelUnitDelay(self.showHpCoId)

			self.showHpCoId = gLuaTimeMgrUtils.Delay(function ()
				self.sceneItem = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.destructId)

				if self.sceneItem and self.template.slotTopInfo then
					self:OnRefreshHpBarDisplay(false, true)
				end
			end, self.autoHideHpTime, nil, , true)
		end
	end
end

DestructibleHUDCtrl.SetDestructibleDebugVisible = function(self, visible)
	if self.CheckDebugTextExist(self, "DestructHp") then
		self.templatesGroup.debug.DestructHp.template:SetTemplateVisibility(visible)
	else
		self:OnShowDestructHp("", "")
		self.templatesGroup.debug.DestructHp.template:SetTemplateVisibility(visible)
	end

	if self.CheckDebugTextExist(self, "DestructDamage") then
		self.templatesGroup.debug.DestructDamage.template:SetTemplateVisibility(visible)
	else
		self:OnShowDestructDamage("")
		self.templatesGroup.debug.DestructDamage.template:SetTemplateVisibility(visible)
	end

	if self.CheckDebugTextExist(self, "DestructTemplateInfo") then
		self.templatesGroup.debug.DestructTemplateInfo.template:SetTemplateVisibility(visible)
	else
		self:OnShowDestructTemplateInfo()
		self.templatesGroup.debug.DestructTemplateInfo.template:SetTemplateVisibility(visible)
	end
end

DestructibleHUDCtrl.HpProgressChangeDebug = function(self, hp, maxHp, damageText)
	self.OnShowDestructHp(self, hp, maxHp)
	self.OnShowDestructDamage(self, damageText)
	self.OnShowDestructTemplateInfo(self)
end

DestructibleHUDCtrl.OnShowDestructHp = function(self, hp, maxHp)
	if not self.CheckDebugTextExist(self, "DestructHp") then
		self.GenDebugTextWithParams(self, "DestructHp", hp, maxHp)

		return
	end

	self.templatesGroup.debug.DestructHp.template:SetTemplateVisibility(true)

	self.templatesGroup.debug.DestructHp.debugText = tostring(Mathf.Round(hp) * 0.01) .. "/" .. tostring(maxHp * 0.01)
end

DestructibleHUDCtrl.OnCreateDebugDestructHp = function(self)
	if not self.CheckDebugParamsEfficient(self, "DestructHp") then
		return
	end

	self.OnShowDestructHp(self, self.debugCreateParams.DestructHp[1], self.debugCreateParams.DestructHp[2])
end

DestructibleHUDCtrl.OnShowDestructDamage = function(self, damageText)
	if not self.CheckDebugTextExist(self, "DestructDamage") then
		self.GenDebugTextWithParams(self, "DestructDamage", damageText)

		return
	end

	self.templatesGroup.debug.DestructDamage.template:SetTemplateVisibility(true)

	self.templatesGroup.debug.DestructDamage.debugText = damageText

	self.uiRoot:ReorderTemplates()
end

DestructibleHUDCtrl.OnCreateDebugDestructDamage = function(self)
	if not self.CheckDebugParamsEfficient(self, "DestructDamage") then
		return
	end

	self.OnShowDestructDamage(self, self.debugCreateParams.DestructDamage[1])
end

DestructibleHUDCtrl.OnShowDestructTemplateInfo = function(self)
	if not self.CheckDebugTextExist(self, "DestructTemplateInfo") then
		self.GenDebugTextWithParams(self, "DestructTemplateInfo")

		return
	end

	self.templatesGroup.debug.DestructTemplateInfo.template:SetTemplateVisibility(true)

	local text = ""
	self.sceneItem = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.destructId, true)

	if self.sceneItem.TemplateId <= 1 then
		text = tostring(self.sceneItem.TemplateId) .. "\n"
	end

	text = text .. LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.sceneItem)
	self.templatesGroup.debug.DestructTemplateInfo.debugText = text
end

DestructibleHUDCtrl.OnCreateDebugDestructTemplateInfo = function(self)
	if not self.CheckDebugParamsEfficient(self, "DestructTemplateInfo") then
		return
	end

	self.OnShowDestructTemplateInfo(self)
end

DestructibleHUDCtrl.OnShowDestructCommonDebug = function(self, info)
	if not self.CheckDebugTextExist(self, "DestructCommonDebug") then
		self.GenDebugTextWithParams(self, "DestructCommonDebug", info)

		return
	end

	self.templatesGroup.debug.DestructCommonDebug.template:SetTemplateVisibility(true)

	self.templatesGroup.debug.DestructCommonDebug.debugText = info
end

DestructibleHUDCtrl.OnCreateDebugDestructCommonDebug = function(self)
	if not self.CheckDebugParamsEfficient(self, "DestructCommonDebug") then
		return
	end

	self.OnShowDestructCommonDebug(self, self.debugCreateParams.DestructCommonDebug[1])
end

DestructibleHUDCtrl.SetDestructibleCommonDebugVisible = function(self, visible)
	if self.CheckDebugTextExist(self, "DestructCommonDebug") then
		self.templatesGroup.debug.DestructCommonDebug.template:SetTemplateVisibility(visible)
	end
end

DestructibleHUDCtrl.SetPaperPlaneText = function(self, text)
	self.paperPlaneText = text

	if self.template.TopText then
		self.template.TopText.topText = text

		return
	end

	if not self.paperPlaneTextAdded then
		self.paperPlaneTextAdded = true

		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.TopText, self.uniId)
	end
end

DestructibleHUDCtrl.OnCreatCommonTopText = function(self)
	if self.template.TopText and self.paperPlaneText then
		self.template.TopText.topText = self.paperPlaneText
	end
end

DestructibleHUDCtrl.RemovePaperPlaneText = function(self)
	if self.template.TopText then
		local instanceId = self.template.TopText.wgtId

		self.RemoveHudTemplate(self, instanceId)
	end

	self.paperPlaneText = nil
	self.paperPlaneTextAdded = false
end

DestructibleHUDCtrl.CustomClearProcedure = function(self)
	self.destructId = nil
	self.hpShowRule = 0
	self.canShowHp = false
	self.autoHideHpTime = -1
	self.sceneItem = nil
	self.hp = 0
	self.showHpCoId = nil
	self.paperPlaneText = nil
	self.paperPlaneTextAdded = false
end

return DestructibleHUDCtrl
