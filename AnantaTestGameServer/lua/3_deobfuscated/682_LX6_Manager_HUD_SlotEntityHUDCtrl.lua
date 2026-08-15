local HUDManager = LX6.GUI.HUDNew.HUDManager
local HUDCtrl = require("LX6/Manager/HUD/HudController")
C_SlotEntityHUDCtrl = DefClass("C_SlotEntityHUDCtrl", C_SlotEntityHUDCtrl, HUDCtrl)
local SlotEntityHUDCtrl = C_SlotEntityHUDCtrl

function SlotEntityHUDCtrl:ctor()
	self.tType = gHudMgr.HUDTargetType.SlotEntity
	self.entityId = nil
	self.showDis = nil
end

function SlotEntityHUDCtrl:CustomProcedure()
	self.entityId = gCS.LuaUtils.StringToUlong(string.match(self.uniId, "_(.*)"))
	self.showDis = self.data and self.data.dis or 10
	self.isCreateBySpoon = self.data and self.data.isCreateBySpoon or false

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.SlotTopInfo, self.uniId)
end

function SlotEntityHUDCtrl:OnCreateSlotTopInfo()
	self.template.slotTopInfo.template:SetDisplayDistance(self.showDis)
	self.template.slotTopInfo.hp.gameObject:SetActive(false)

	if not self.data.icon then
		self.template.slotTopInfo.icon.gameObject:SetActive(false)
	end

	if self.data.name then
		self.template.slotTopInfo.slotNameText.text = self.data.name
	else
		self.template.slotTopInfo.name.gameObject:SetActive(false)
	end
end

function SlotEntityHUDCtrl:CustomClearProcedure()
	self.entityId = nil
	self.showDis = nil
end

return SlotEntityHUDCtrl
