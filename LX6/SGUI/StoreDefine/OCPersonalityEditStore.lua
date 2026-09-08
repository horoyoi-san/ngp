-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCPersonalityEditStore.lua
-- Decompiled from: 00953_OCPersonalityEditStore.lua_e049e7c8d5c7.luajit

C_OCPersonalityEditStore = DefClass("C_OCPersonalityEditStore", C_OCPersonalityEditStore, C_StoreGroup)
GroupName2Class.OCPersonalityEditStore = C_OCPersonalityEditStore
local M = C_OCPersonalityEditStore

M.ctor = function(self)
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.tempData = {
		name = self.mgr.baseData.name,
		desc = self.mgr.personalityAndStory.desc,
		age = self.mgr.baseData.age,
		sex = self.mgr.baseData.sex
	}
	self.initialData = {
		name = self.mgr.baseData.name,
		desc = self.mgr.personalityAndStory.desc,
		age = self.mgr.baseData.age,
		sex = self.mgr.baseData.sex
	}
	self.sexList = self.mgr:GetSexList()

	self.bindData.genderPopUp:SetSimpleOptions(#self.sexList)

	for i = 1, #self.sexList do
		self.bindData.genderPopUp:SetItemLabel(i - 1, self.sexList[i].label)
	end

	local sexIndex = (self.tempData.sex or 1) - 1

	if sexIndex >= 0 then
		sexIndex = 0
	end

	self.bindData.genderPopUp:SelectOption(sexIndex, true)

	self.ageList = self.mgr:GetAgeList()
	local ageIndex = 0

	for i, v in ipairs(self.ageList) do
		if v.id ~= self.tempData.age then
			ageIndex = i - 1

			break
		end
	end

	self.bindData.agePopUp:SetSimpleOptions(#self.ageList)

	for i = 1, #self.ageList do
		self.bindData.agePopUp:SetItemLabel(i - 1, self.ageList[i].label)
	end

	self.bindData.agePopUp:SelectOption(ageIndex, true)

	self.bindData.nameInput.text = self.tempData.name
	self.bindData.descInput.text = self.tempData.desc
end

M.OnClose = function(self)
	self.sexList = nil
	self.ageList = nil
	self.tempData = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.genNameBtn.luaClick = self.CreateAction(self, self.OnClickGenNameBtn)
	self.bindData.genDescBtn.luaClick = self.CreateAction(self, self.OnClickGenDescBtn)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.OnClickCancelBtn)
	self.bindData.nameInput.luaValueChanged = self.CreateAction(self, self.OnNameInputInputValueChanged)
	self.bindData.descInput.luaValueChanged = self.CreateAction(self, self.OnDescInputInputValueChanged)
	self.bindData.agePopUp.luaSimpleOptionClick = self.CreateAction(self, self.OnSelectedAge)
	self.bindData.genderPopUp.luaSimpleOptionClick = self.CreateAction(self, self.OnSelectedSex)
end

M.OnClickGenNameBtn = function(self)
	self.bindData.genNameBtn.interactable = false
	slot1 = self.mgr

	slot1:GetNameByGen(function (name)
		if name then
			self.bindData.nameInput.text = name
			self.tempData.name = name
		end

		self.bindData.genNameBtn.interactable = true
	end)
end

M.OnClickGenDescBtn = function(self)
	self.bindData.genDescBtn.interactable = false
	self.mgr.baseData.name = self.tempData.name
	self.mgr.personalityAndStory.desc = self.tempData.desc
	self.mgr.baseData.age = self.tempData.age
	self.mgr.baseData.sex = self.tempData.sex
	slot1 = self.mgr

	slot1:GetDescByGen(function (desc)
		if desc then
			self.bindData.descInput.text = desc
			self.tempData.desc = desc
		end

		self.bindData.genDescBtn.interactable = true
	end)
end

M.OnClickConfirmBtn = function(self)
	self.hasConfirmed = true
	self.mgr.baseData.name = self.tempData.name
	self.mgr.personalityAndStory.desc = self.tempData.desc
	self.mgr.baseData.age = self.tempData.age
	self.mgr.baseData.sex = self.tempData.sex

	self.mgr:UpLoadBaseData()
	gMessageManager:SendMessage(gEventConstants.OC_DATA_REFRESH)
	gPanelManager:Close(self.panelId)
end

M.OnClickCancelBtn = function(self)
	self.mgr.baseData.name = self.initialData.name
	self.mgr.personalityAndStory.desc = self.initialData.desc
	self.mgr.baseData.age = self.initialData.age
	self.mgr.baseData.sex = self.initialData.sex

	self.mgr:UpLoadBaseData()
	gPanelManager:Close(self.panelId)
end

M.OnNameInputInputValueChanged = function(self, text)
	self.tempData.name = text
end

M.OnDescInputInputValueChanged = function(self, text)
	self.tempData.desc = text
end

M.OnSelectedAge = function(self, btn, index)
	if self.ageList and self.ageList[index + 1] then
		self.tempData.age = self.ageList[index + 1].id
	end
end

M.OnSelectedSex = function(self, btn, index)
	self.tempData.sex = index + 1
end
