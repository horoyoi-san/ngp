-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameDeathPanelStore.lua
-- Decompiled from: 00927_PetGameDeathPanelStore.lua_ca9c45b74767.luajit

local GameObject = UnityEngine.GameObject
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
C_PetGameDeathPanelStore = DefClass("C_PetGameDeathPanelStore", C_PetGameDeathPanelStore, C_StoreGroup)
GroupName2Class.PetGameDeathPanelStore = C_PetGameDeathPanelStore
local M = C_PetGameDeathPanelStore

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

	self:BindSystemBtn()
	self:LoadPetGo()
	self.parentPanel:ResetPoo()
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
	self.ClearPetGo(self)
end

M.BindSystemBtn = function(self)
	local eventHandler = {
		panelId = gPanelId.MINI_GAMES_PET_GAME_DEATH,
		OnMenuBtnPressed = self.OnMenuBtnPressed,
		OnCancleBtnPressed = self.OnCancleBtnPressed,
		target = self
	}
	self.isMenuBtnPressed = false
	self.isCancleBtnPressed = false

	self.parentPanel:RegisterSystemBtnEvent(eventHandler)
end

M.UnBindSystemBtn = function(self)
	self.parentPanel:UnregisterSystemBtnEvent(gPanelId.MINI_GAMES_PET_GAME_DEATH)
end

M.OnMenuBtnPressed = function(self, isPressed)
	self.isMenuBtnPressed = isPressed

	self.CheckBtnState(self)
end

M.OnCancleBtnPressed = function(self, isPressed)
	self.isCancleBtnPressed = isPressed

	self.CheckBtnState(self)
end

M.CheckBtnState = function(self)
	if not self.isMenuBtnPressed then
		return
	end

	if not self.isCancleBtnPressed then
		return
	end

	self:ClearPetGo()
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_RESTART)
	self.parentPanel:CloseChildPanel(gPanelId.MINI_GAMES_PET_GAME_DEATH)
end

M.LoadPetGo = function(self)
	local pet = gPetGameManager.currentGame.pet

	if not pet then
		return
	end

	local parent = self.bindData.petTans
	local petInfo = pet.GetPetInfo(pet)

	if not pet.petGo then
		self.LoadPetGameObject(self, petInfo.prefab, parent)

		return
	end

	local clone = UnityEngine.GameObject.Instantiate(pet.petGo, parent)
	self.clonePet = clone

	clone.transform:SetLocalPosition(0, 0, 0)

	local animator = clone.transform:GetComponent("Animation")

	self:PlayDeathAni(animator)
	self:ClearPetEffect(clone.transform)
end

M.PlayDeathAni = function(self, animator)
	if not animator then
		return
	end

	local deathAni = PetGameEnum.PetAnimation[PetGameEnum.PetAniEnum.death]

	if not deathAni or not animator.GetClip(animator, deathAni) then
		return
	end

	animator.PlayQueued(animator, deathAni, 2)

	local deathLoopAni = PetGameEnum.PetAnimation[PetGameEnum.PetAniEnum.death_loop]

	if deathLoopAni and animator.GetClip(animator, deathLoopAni) then
		animator.PlayQueued(animator, deathLoopAni)
	end
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

M.LoadPetGameObject = function(self, prefabPath, parent)
	slot3 = gResourceManager

	slot3:LoadAssetWithCallBack(prefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if loadOp.asset then
			local clone = UnityEngine.GameObject.Instantiate(loadOp.asset, parent)

			if not clone then
				error("Failed to instantiate pet prefab: " .. prefabPath)

				return
			end

			self.clonePet = clone

			clone.transform:SetLocalPosition(0, 0, 0)

			local animator = clone.transform:GetComponent("Animation")

			self:PlayDeathAni(animator)
			self:ClearPetEffect(clone.transform)
		else
			error("Failed to load pet prefab: " .. prefabPath)
		end
	end)
end
