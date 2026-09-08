-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AcrossSwitchRoleEffPanelStore.lua
-- Decompiled from: 01592_AcrossSwitchRoleEffPanelStore.lua_d223a2428cd1.luajit

C_AcrossSwitchRoleEffPanelStore = DefClass("C_AcrossSwitchRoleEffPanelStore", C_AcrossSwitchRoleEffPanelStore, C_StoreGroup)
GroupName2Class.AcrossSwitchRoleEffPanelStore = C_AcrossSwitchRoleEffPanelStore
local M = C_AcrossSwitchRoleEffPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.openCloudEffName = "S_vx_xinqiTochongxiao_cloud_Fadein"
	self.closeCloudEffName = "S_vx_xinqiTochongxiao_cloud_Fadeout"
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

M.OnShow = function(self, panelId, guiUXMirror)
	self.switchCloudEffAction = self:CreateAction(self.SwitchCloudAnim)

	gMessageManager:AddMessageListener(gEventConstants.ACROSS_SCENE_SHOW_SWITCH_CLOUD_EFFECT, self.switchCloudEffAction)

	local rectTrans = self.bindData.rectTrans

	if rectTrans then
		if guiUXMirror then
			rectTrans.localRotation = Quaternion.Euler(0, 0, 180)
		else
			rectTrans.localRotation = Quaternion.Euler(0, 0, 0)
		end
	end
end

M.OnClose = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.ACROSS_SCENE_SHOW_SWITCH_CLOUD_EFFECT, self.switchCloudEffAction)
end

M.SwitchCloudAnim = function(self, eventId, switchState)
	if switchState then
		self.PlayCloudAnim(self)
	else
		self.StopCloudAnim(self)
	end
end

M.PlayCloudAnim = function(self)
	local clip = self.bindData.effectAnimation:GetClip(self.openCloudEffName)

	if clip then
		self.bindData.effectAnimation:Stop()
		self.bindData.effectAnimation:Play(self.openCloudEffName)
	end
end

M.StopCloudAnim = function(self)
	local clip = self.bindData.effectAnimation:GetClip(self.closeCloudEffName)

	if clip then
		self.bindData.effectAnimation:Stop()
		self.bindData.effectAnimation:Play(self.closeCloudEffName)
	end
end
