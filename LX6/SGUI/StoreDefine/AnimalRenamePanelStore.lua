-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnimalRenamePanelStore.lua
-- Decompiled from: 01553_AnimalRenamePanelStore.lua_36e06a29ae17.luajit

C_AnimalRenamePanelStore = DefClass("C_AnimalRenamePanelStore", C_AnimalRenamePanelStore, C_StoreGroup)
GroupName2Class.AnimalRenamePanelStore = C_AnimalRenamePanelStore
local M = C_AnimalRenamePanelStore
local PetAnimalConfig = LTConfig.PetAnimalConfig
local MessageConfig = LTConfig.MessageConfig

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.btnCancel.luaClick = self.CreateAction(self, self.OnClickCancel)
	self.bindData.btnConfirm.luaClick = self.CreateAction(self, self.OnClickConfirm)
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
	self.cfgId = data
	self.panelId = panelId
	self.bindData.inputField.characterLimit = PetAnimalConfig.NameLimit
	local nickName = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos[self.cfgId].NickName
	nickName = nickName or PetAnimalConfig.GetConfig(self.cfgId).Name
	self.bindData.inputField.placeHolder.text = nickName
	self.closeTimer = nil

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_AnimalRenamePanel_open")
end

M.OnClose = function(self)
end

M.OnClickCancel = function(self)
	self.PlayAnimationAndClose(self)
end

M.OnClickConfirm = function(self)
	local text = self.bindData.inputField.text

	if string.is_null_or_empty(text) then
		if not string.is_null_or_empty(self.bindData.inputField.placeHolder.text) then
			self.PlayAnimationAndClose(self)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.PetNameEmpty)
		end

		return
	end

	if not gCS.LuaUtils.IsInputNameValidByLength(text, 1, PetAnimalConfig.NameLimit) then
		return
	end

	EnvSDK.reviewNickNameAsync(text, function (result)
		if result.code ~= 200 then
			slot1 = gClientToGameDelegate

			slot1:AskNameAnimal(self.cfgId, text).Callback = function (errID, data)
				if errID <= 0 then
					print_warn("AskNameAnimal failed, error =", gCS.Error.GetNameById(errID))

					return
				end

				self:PlayAnimationAndClose()
			end
		elseif result.code ~= 202 then
			gDisplayMessageMgr:ShowMessage(MessageConfig.NameSensitive)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.AnimalNameFail)
		end
	end)
end

M.PlayAnimationAndClose = function(self)
	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end

	local duration = self.bindData.panelAnimation:GetClip("S_Vx_AnimalRenamePanel_close").length

	if duration <= 0 then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_AnimalRenamePanel_close")

		self.closeTimer = Timer.New(function ()
			gPanelManager:Close(self.panelId)
		end, duration):Start()
	else
		gPanelManager:Close(self.panelId)
	end
end

M.OnActiveDeviceChange = function(self, device)
end
