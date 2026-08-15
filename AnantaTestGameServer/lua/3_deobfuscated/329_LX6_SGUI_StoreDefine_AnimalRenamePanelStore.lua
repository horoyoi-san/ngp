C_AnimalRenamePanelStore = DefClass("C_AnimalRenamePanelStore", C_AnimalRenamePanelStore, C_StoreGroup)
GroupName2Class.AnimalRenamePanelStore = C_AnimalRenamePanelStore
local M = C_AnimalRenamePanelStore
local PetAnimalConfig = LTConfig.PetAnimalConfig
local MessageConfig = LTConfig.MessageConfig

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.btnCancel.luaClick = self:CreateAction(self.OnClickCancel)
	self.bindData.btnConfirm.luaClick = self:CreateAction(self.OnClickConfirm)
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.cfgId = data
	self.panelId = panelId
	self.bindData.inputField.characterLimit = PetAnimalConfig.NameLimit
	local nickName = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos[self.cfgId].NickName
	nickName = nickName or PetAnimalConfig.GetConfig(self.cfgId).Name
	self.bindData.inputField.placeHolder.text = nickName
	self.closeTimer = nil

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_AnimalRenamePanel_open")
end

function M:OnClose()
	return
end

function M:OnClickCancel()
	self:PlayAnimationAndClose()
end

function M:OnClickConfirm()
	local text = self.bindData.inputField.text

	if string.is_null_or_empty(text) then
		if not string.is_null_or_empty(self.bindData.inputField.placeHolder.text) then
			self:PlayAnimationAndClose()
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.PetNameEmpty)
		end

		return
	end

	if not gCS.LuaUtils.IsInputNameValidByLength(text, 1, PetAnimalConfig.NameLimit) then
		return
	end

	EnvSDK.reviewNickNameAsync(text, function (result)
		if result.code == 200 then
			gClientToGameDelegate:AskNameAnimal(self.cfgId, text).Callback = function (errID, data)
				if errID > 0 then
					print_warn("AskNameAnimal failed, error =", gCS.Error.GetNameById(errID))

					return
				end

				self:PlayAnimationAndClose()
			end
		elseif result.code == 202 then
			gDisplayMessageMgr:ShowMessage(MessageConfig.NameSensitive)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.AnimalNameFail)
		end
	end)
end

function M:PlayAnimationAndClose()
	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end

	local duration = self.bindData.panelAnimation:GetClip("S_Vx_AnimalRenamePanel_close").length

	if duration > 0 then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_AnimalRenamePanel_close")

		self.closeTimer = Timer.New(function ()
			gPanelManager:Close(self.panelId)
		end, duration):Start()
	else
		gPanelManager:Close(self.panelId)
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
