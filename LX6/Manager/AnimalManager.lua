-- Original chunk: @Lua\LuaFiles\LX6\Manager\AnimalManager.lua
-- Decompiled from: 00575_AnimalManager.lua_863a949f41d1.luajit

local PetAnimalConfig = LTConfig.PetAnimalConfig
local PetAnimalInteractionConfig = LTConfig.PetAnimalInteractionConfig
C_AnimalManager = DefClass("C_AnimalManager", C_AnimalManager)
local M = C_AnimalManager

M.ctor = function(self)
	self.showFavorTimer = nil
	self.msgEvents = {
		[gEventConstants.ON_DISCONNECT] = function (eventId, data)
			self:OnDisconnected()
		end
	}

	for event, func in pairs(self.msgEvents) do
		gMessageManager:AddMessageListener(event, func)
	end
end

M.OnDisconnected = function(self)
	self:CloseFavorTimer()
end

M.OnBeforeSwitchScene = function(self, switchType)
	self:CloseFavorTimer()
end

M.CloseFavorTimer = function(self)
	if self.showFavorTimer then
		self.showFavorTimer:Stop()

		self.showFavorTimer = nil
	end
end

M.EnterAnimalInteraction_Story = function(self, npc, type)
	if not npc then
		return
	end

	gCS.AnimalInteractionManager.Instance:EnterAnimalInteraction_Story(npc, type or 0)
end

M.SetDoingInteract = function(self, doingInteracting)
	local storeGroup = gStoreManager:GetStoreGroup("AnimalInteractionPanelStore")

	if storeGroup then
		storeGroup:SetDoingInteract(doingInteracting)
	end
end

M.ShowInteractEmoji = function(self, bubble, duration)
	local storeGroup = gStoreManager:GetStoreGroup("AnimalInteractionPanelStore")

	if storeGroup then
		storeGroup:ShowEmoji(bubble, duration)
	end
end

M.GetFavorLevel = function(self, animalId)
	local animalInfo = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos[animalId]

	if animalInfo then
		return animalInfo.Favor, animalInfo.FavorLevel
	else
		return 0, 0
	end
end

M.TryShowFavorLevelUp = function(self, animalId, prevFavor, prevFavorLevel)
	self:CloseFavorTimer()

	self.showFavorTimer = Timer.New(function ()
		self.showFavorTimer = nil

		self:TryShowAnimalFavorPopup(animalId, prevFavor, prevFavorLevel)
	end, 0.5):Start()
end

M.TryShowAnimalFavorPopup = function(self, animalId, prevFavor, prevFavorLevel)
	local animalInfo = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos[animalId]

	if not animalInfo then
		return
	end

	local favor = animalInfo.Favor
	local favorLevel = animalInfo.FavorLevel

	if prevFavor ~= favor or prevFavorLevel > 3 then
		return
	end

	if prevFavorLevel < favorLevel then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.AnimalFavorability, {
			Id = animalId,
			FavorLevel = favorLevel,
			Favor = favor,
			PrevFavorLevel = prevFavorLevel,
			PrevFavor = prevFavor
		})
	end
end

gAnimalManager = gAnimalManager or C_AnimalManager.new()
