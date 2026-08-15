local PetAnimalConfig = LTConfig.PetAnimalConfig
local PetAnimalInteractionConfig = LTConfig.PetAnimalInteractionConfig
C_AnimalManager = DefClass("C_AnimalManager", C_AnimalManager)
local M = C_AnimalManager

function M:ctor()
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

function M:OnDisconnected()
	self:CloseFavorTimer()
end

function M:OnBeforeSwitchScene(switchType)
	self:CloseFavorTimer()
end

function M:CloseFavorTimer()
	if self.showFavorTimer then
		self.showFavorTimer:Stop()

		self.showFavorTimer = nil
	end
end

function M:OnAnimalFavorChanged(animalId)
	local menus = self:RefreshInteractMenus(animalId)
	local storeGroup = gStoreManager:GetStoreGroup("AnimalInteractionPanelStore")

	if storeGroup then
		storeGroup:OnAnimalFavorChanged(menus)
	end
end

function M:ShowAnimalInteractDialog(unit, animalCfgId)
	local menus = self:RefreshInteractMenus(animalCfgId)

	if #menus > 0 then
		gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
			gameplayType = "AnimalInteraction",
			params = {
				target = self,
				unit = unit,
				menus = menus
			}
		})
	end
end

function M:RefreshInteractMenus(animalCfgId)
	local menus = {}
	local animalCfg = PetAnimalConfig.GetConfig(animalCfgId)

	if not animalCfg then
		return menus
	end

	local animalInfos = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos

	if table.is_empty(animalInfos) or not animalInfos[animalCfgId] then
		return menus
	end

	local animalInfo = animalInfos[animalCfgId]
	local favorLevel = animalInfo.FavorLevel

	for _, interactionId in ipairs(PetAnimalConfig[animalCfg.Button]) do
		local cfg = PetAnimalInteractionConfig.GetConfig(interactionId)

		if cfg and cfg.FavorLevel <= favorLevel then
			local nickName = animalInfo.NickName

			table.insert(menus, {
				interactionId = cfg.Id,
				iconId = cfg.Icon,
				nickName = nickName or animalCfg.Name,
				interactNameId = cfg.InteractTextId,
				changeCatName = cfg.ChangeName
			})
		end
	end

	return menus
end

function M:OnSubClick(interactId)
	gCS.AnimalInteractionManager.Instance:StartSubInteraction(interactId)
end

function M:StopAnimalInteraction()
	gCS.AnimalInteractionManager.Instance:StopCurrentSubInteraction(false, false)
end

function M:SetDoingInteract(doingInteracting)
	local storeGroup = gStoreManager:GetStoreGroup("AnimalInteractionPanelStore")

	if storeGroup then
		storeGroup:SetDoingInteract(doingInteracting)
	end
end

function M:ShowInteractEmoji(bubble, duration)
	local storeGroup = gStoreManager:GetStoreGroup("AnimalInteractionPanelStore")

	if storeGroup then
		storeGroup:ShowEmoji(bubble, duration)
	end
end

function M:PlayerEnterInteract(petType, interactType)
	gCS.TransitionMgr.pettingAnimalType = petType
	gCS.TransitionMgr.pettingInteractType = interactType

	gCS.LuaUtils.CheckSwitchAction(true, true, false, 0)
end

function M:PlayerStopInteract()
	gCS.TransitionMgr.pettingAnimalType = 0
	gCS.TransitionMgr.pettingInteractType = 0

	gCS.LuaUtils.CheckSwitchAction(true, true, false, 0)
end

function M:GetFavorLevel(animalId)
	local animalInfo = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos[animalId]

	if animalInfo then
		return animalInfo.Favor, animalInfo.FavorLevel
	else
		return 0, 0
	end
end

function M:TryShowFavorLevelUp(animalId, prevFavor, prevFavorLevel)
	self:CloseFavorTimer()

	self.showFavorTimer = Timer.New(function ()
		self.showFavorTimer = nil

		self:TryShowAnimalFavorPopup(animalId, prevFavor, prevFavorLevel)
	end, 0.5):Start()
end

function M:TryShowAnimalFavorPopup(animalId, prevFavor, prevFavorLevel)
	local animalInfo = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos[animalId]

	if not animalInfo then
		return
	end

	local favor = animalInfo.Favor
	local favorLevel = animalInfo.FavorLevel

	if prevFavor == favor or prevFavorLevel >= 3 then
		return
	end

	if prevFavorLevel <= favorLevel then
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
