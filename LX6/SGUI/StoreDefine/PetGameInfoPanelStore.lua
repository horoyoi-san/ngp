-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameInfoPanelStore.lua
-- Decompiled from: 00809_PetGameInfoPanelStore.lua_7325741e57f0.luajit

local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local GameObject = UnityEngine.GameObject
C_PetGameInfoPanelStore = DefClass("C_PetGameInfoPanelStore", C_PetGameInfoPanelStore, C_StoreGroup)
GroupName2Class.PetGameInfoPanelStore = C_PetGameInfoPanelStore
local M = C_PetGameInfoPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
	self.UnBindSystemBtn(self)
	self.ClearPetGo(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.UnBindSystemBtn(self)
	self.ClearPetGo(self)
end

M.OnShow = function(self, panelId, data)
	self.parentPanel = data.parent
	self.panelId = panelId
	self.petEntity = gPetGameManager.currentGame and gPetGameManager.currentGame.pet

	self:BindSystemBtn()
	self:ShowPetInfo()
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
	self.ClearPetGo(self)
end

M.ShowPetInfo = function(self)
	if not self.petEntity then
		print_error("找不到宠物")

		return
	end

	local petData = self.petEntity:GetPetData()
	self.bindData.nameText.text = self.petEntity:GetPetName()
	local daySec = PetGameConst.DAY_SECONDS
	local yearAge = petData.age / daySec
	local tips = gPetGameMultilingual:GetText(400508)
	self.bindData.ageText.text = string.format(tips, yearAge)

	self:LoadPetGo()
end

M.LoadPetGo = function(self)
	if self.clonePet then
		return
	end

	local pet = gPetGameManager.currentGame.pet

	if not pet or not pet.petGo then
		return
	end

	local parent = self.bindData.petTans
	local clone = UnityEngine.GameObject.Instantiate(pet.petGo, parent)
	self.clonePet = clone

	clone.transform:SetLocalPosition(0, 0, 0)

	local animator = clone.transform:GetComponent("Animation")

	if animator then
		animator.enabled = false
		local idleAni = PetGameEnum.PetAnimation[PetGameEnum.PetAniEnum.idle]

		if idleAni and animator.GetClip(animator, idleAni) then
			animator.Play(animator, idleAni)
			animator.Sample(animator)
		end
	end

	self.ClearPetEffect(self, clone.transform)
end

M.ClearPetGo = function(self)
	if self.clonePet then
		GameObject.Destroy(self.clonePet)

		self.clonePet = nil
	end
end

M.ClearPetEffect = function(self, petTrans)
	local effects_treat = petTrans.Find(petTrans, "body/effects_treat")

	if effects_treat then
		effects_treat.gameObject:SetActive(false)
	end

	local effects_sleep = petTrans.Find(petTrans, "body/effects_sleep")

	if effects_sleep then
		effects_sleep.gameObject:SetActive(false)

		local sleepAni = effects_sleep:GetChild(0)

		if sleepAni then
			sleepAni.gameObject:SetActive(false)
		end
	end

	local effects_up = petTrans.Find(petTrans, "body/effects_up")

	if effects_up then
		effects_up.gameObject:SetActive(false)
	end

	local effects_dirty = petTrans.Find(petTrans, "body/effects_dirty")

	if effects_dirty then
		effects_dirty.gameObject:SetActive(false)
	end
end

M.BindSystemBtn = function(self)
	self.isMenuBtnPressed = false
	local eventHandler = {
		panelId = self.panelId,
		OnMenuBtnClick = self.OnMenuBtnClick,
		OnConfirmBtnClick = self.OnConfirmBtnClick,
		OnCancleBtnClick = self.OnCancleBtnClick,
		target = self
	}

	self.parentPanel:RegisterSystemBtnEvent(eventHandler)
end

M.UnBindSystemBtn = function(self)
	self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
end

M.OnMenuBtnClick = function(self)
end

M.OnConfirmBtnClick = function(self)
end

M.OnCancleBtnClick = function(self)
	self:ClearPetGo()
	self.parentPanel:CloseChildPanel(self.panelId)
end
