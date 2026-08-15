local HUDManager = LX6.GUI.HUDNew.HUDManager
local HUDCtrl = require("LX6/Manager/HUD/HudController")
C_DestructibleHUDCtrl = DefClass("C_DestructibleHUDCtrl", C_DestructibleHUDCtrl, HUDCtrl)
local DestructibleHUDCtrl = C_DestructibleHUDCtrl

function DestructibleHUDCtrl:ctor()
	self.tType = gHudMgr.HUDTargetType.Destruct
	self.destructId = nil
	self.hpShowRule = 0
	self.canShowHp = false
	self.autoHideHpTime = -1
	self.sceneItem = nil
	self.hp = 0
	self.showHpCoId = nil
end

function DestructibleHUDCtrl:RefreshData()
	self.destructId = gCS.LuaUtils.StringToUlong(string.match(self.uniId, "_(.*)"))
	self.sceneItem = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.destructId)
end

function DestructibleHUDCtrl:CustomProcedure()
	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.SlotTopInfo, self.uniId)
end

function DestructibleHUDCtrl:OnCreateSlotTopInfo()
	self.template.slotTopInfo.icon.gameObject:SetActive(false)
	self.template.slotTopInfo.name.gameObject:SetActive(false)

	self.sceneItem = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.destructId)
	local sceneItem = self.sceneItem
	local canShowHp, showRule = sceneItem:CanShowHp(0)
	self.hpShowRule = showRule
	self.canShowHp = canShowHp

	if canShowHp then
		local hpProgress = sceneItem.hpProgress

		self:HpProgressChange(hpProgress)

		if showRule == 0 then
			self.autoHideHpTime = 3
		end

		self:OnRefreshHpBarDisplay(true)
	else
		self:OnRefreshHpBarDisplay(false)
	end
end

function DestructibleHUDCtrl:HpProgressChange(progress)
	self.hp = progress

	if progress == nil or progress <= 0 then
		self:OnRefreshHpBarDisplay(false)

		return
	end

	if progress < 1 and progress > 0 then
		self:OnRefreshHpBarDisplay(true)
	end

	if self.template.slotTopInfo then
		self.template.slotTopInfo.hpFillAmount = progress
	end
end

function DestructibleHUDCtrl:OnRefreshHpBarDisplay(show, recursionEnd)
	self.template.slotTopInfo.hp.gameObject:SetActive(show)

	if show then
		if recursionEnd then
			return
		end

		if self.autoHideHpTime > 0 then
			gLuaTimeMgrUtils.CancelUnitDelay(self.showHpCoId)

			self.showHpCoId = gLuaTimeMgrUtils.Delay(function ()
				self.sceneItem = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.destructId)

				if self.sceneItem and self.template.slotTopInfo then
					self:OnRefreshHpBarDisplay(false, true)
				end
			end, self.autoHideHpTime, nil, nil, true)
		end
	end
end

function DestructibleHUDCtrl:SetDestructibleDebugVisible(visible)
	if self:CheckDebugTextExist("DestructHp") then
		self.templatesGroup.debug.DestructHp.template:SetTemplateVisibility(visible)
	else
		self:OnShowDestructHp("", "")
		self.templatesGroup.debug.DestructHp.template:SetTemplateVisibility(visible)
	end

	if self:CheckDebugTextExist("DestructDamage") then
		self.templatesGroup.debug.DestructDamage.template:SetTemplateVisibility(visible)
	else
		self:OnShowDestructDamage("")
		self.templatesGroup.debug.DestructDamage.template:SetTemplateVisibility(visible)
	end

	if self:CheckDebugTextExist("DestructTemplateInfo") then
		self.templatesGroup.debug.DestructTemplateInfo.template:SetTemplateVisibility(visible)
	else
		self:OnShowDestructTemplateInfo()
		self.templatesGroup.debug.DestructTemplateInfo.template:SetTemplateVisibility(visible)
	end
end

function DestructibleHUDCtrl:HpProgressChangeDebug(hp, maxHp, damageText)
	self:OnShowDestructHp(hp, maxHp)
	self:OnShowDestructDamage(damageText)
	self:OnShowDestructTemplateInfo()
end

function DestructibleHUDCtrl:OnShowDestructHp(hp, maxHp)
	if not self:CheckDebugTextExist("DestructHp") then
		self:GenDebugTextWithParams("DestructHp", hp, maxHp)

		return
	end

	self.templatesGroup.debug.DestructHp.template:SetTemplateVisibility(true)

	self.templatesGroup.debug.DestructHp.debugText = tostring(Mathf.Round(hp) * 0.01) .. "/" .. tostring(maxHp * 0.01)
end

function DestructibleHUDCtrl:OnCreateDebugDestructHp()
	if not self:CheckDebugParamsEfficient("DestructHp") then
		return
	end

	self:OnShowDestructHp(self.debugCreateParams.DestructHp[1], self.debugCreateParams.DestructHp[2])
end

function DestructibleHUDCtrl:OnShowDestructDamage(damageText)
	if not self:CheckDebugTextExist("DestructDamage") then
		self:GenDebugTextWithParams("DestructDamage", damageText)

		return
	end

	self.templatesGroup.debug.DestructDamage.template:SetTemplateVisibility(true)

	self.templatesGroup.debug.DestructDamage.debugText = damageText

	self.uiRoot:ReorderTemplates()
end

function DestructibleHUDCtrl:OnCreateDebugDestructDamage()
	if not self:CheckDebugParamsEfficient("DestructDamage") then
		return
	end

	self:OnShowDestructDamage(self.debugCreateParams.DestructDamage[1])
end

function DestructibleHUDCtrl:OnShowDestructTemplateInfo()
	if not self:CheckDebugTextExist("DestructTemplateInfo") then
		self:GenDebugTextWithParams("DestructTemplateInfo")

		return
	end

	self.templatesGroup.debug.DestructTemplateInfo.template:SetTemplateVisibility(true)

	local text = ""
	self.sceneItem = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.destructId, true)

	if self.sceneItem.TemplateId > 1 then
		text = tostring(self.sceneItem.TemplateId) .. "\n"
	end

	text = text .. LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(self.sceneItem)
	self.templatesGroup.debug.DestructTemplateInfo.debugText = text
end

function DestructibleHUDCtrl:OnCreateDebugDestructTemplateInfo()
	if not self:CheckDebugParamsEfficient("DestructTemplateInfo") then
		return
	end

	self:OnShowDestructTemplateInfo()
end

function DestructibleHUDCtrl:OnShowDestructCommonDebug(info)
	if not self:CheckDebugTextExist("DestructCommonDebug") then
		self:GenDebugTextWithParams("DestructCommonDebug", info)

		return
	end

	self.templatesGroup.debug.DestructCommonDebug.template:SetTemplateVisibility(true)

	self.templatesGroup.debug.DestructCommonDebug.debugText = info
end

function DestructibleHUDCtrl:OnCreateDebugDestructCommonDebug()
	if not self:CheckDebugParamsEfficient("DestructCommonDebug") then
		return
	end

	self:OnShowDestructCommonDebug(self.debugCreateParams.DestructCommonDebug[1])
end

function DestructibleHUDCtrl:SetDestructibleCommonDebugVisible(visible)
	if self:CheckDebugTextExist("DestructCommonDebug") then
		self.templatesGroup.debug.DestructCommonDebug.template:SetTemplateVisibility(visible)
	end
end

function DestructibleHUDCtrl:CustomClearProcedure()
	self.destructId = nil
	self.hpShowRule = 0
	self.canShowHp = false
	self.autoHideHpTime = -1
	self.sceneItem = nil
	self.hp = 0
	self.showHpCoId = nil
end

return DestructibleHUDCtrl
