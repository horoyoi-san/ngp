C_AnimalFavorabilityPanelStore = DefClass("C_AnimalFavorabilityPanelStore", C_AnimalFavorabilityPanelStore, C_StoreGroup)
GroupName2Class.AnimalFavorabilityPanelStore = C_AnimalFavorabilityPanelStore
local M = C_AnimalFavorabilityPanelStore
local PetAnimalConfig = LTConfig.PetAnimalConfig

function M:ctor()
	return
end

function M:OnAwake()
	self.panelId = gPanelId.S_ANIMAL_FAVOR_CHANGE
	self.closeTimer = nil
	self.animTimer = nil
	self.animSeq = {}
	self.curAnimIndex = 1
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
	self.cfgId = data.Id
	self.animalCfg = PetAnimalConfig.GetConfig(self.cfgId)
	self.bindData.headIconId = self.animalCfg.SImage
	self.areaIndex = data.areaIndex

	self:CloseAutoCloseTimer()

	self.closeTimer = Timer.New(function ()
		self.closeTimer = nil

		gPanelManager:Close(gPanelId.S_ANIMAL_FAVOR_CHANGE)
	end, 10):Start()

	self:InitFavorAnim(data)
	self:CalAnimationSequence(data)

	local ani = self.bindData.rootAnim
	local duration = ani.clip.length

	gCS.LuaUtils.PlayAnimationByName(ani, "S_Vx_AnimalFavorabilityPanel_open")
	Timer.New(function ()
		self:PlayFavorUpAnimations()
	end, duration):Start()
end

function M:InitFavorAnim(data)
	local favorLevel = data.FavorLevel + 1

	if favorLevel > 3 then
		favorLevel = 3
	end

	self.bindData.favorLevel = favorLevel

	for i = 1, 3 do
		local process = self:GetFillProcess(data.PrevFavor, i)
		local anim = self.bindData["heart" .. i .. "Anim"]

		gCS.LuaUtils.SampleTargetAnimation(anim, "S_Vx_AnimalFavorabilityPanel_aixin", process * anim.clip.length)
	end
end

function M:CalAnimationSequence(data)
	self.animSeq = {}
	local from = self:GetFillProcess(data.PrevFavor, data.PrevFavorLevel + 1)
	local to = self:GetFillProcess(data.Favor, data.FavorLevel + 1)

	if data.PrevFavorLevel == data.FavorLevel then
		table.insert(self.animSeq, {
			animType = 1,
			favorLevel = data.FavorLevel + 1,
			from = from,
			to = to
		})
	else
		for favorLevel = data.PrevFavorLevel + 1, data.FavorLevel + 1 do
			if favorLevel == data.PrevFavorLevel + 1 then
				table.insert(self.animSeq, {
					animType = 1,
					to = 1,
					favorLevel = favorLevel,
					from = from
				})
				table.insert(self.animSeq, {
					animType = 2,
					favorLevel = favorLevel
				})
			elseif favorLevel == data.FavorLevel + 1 then
				if self:GetFillProcess(data.Favor, favorLevel) > 0 then
					table.insert(self.animSeq, {
						animType = 1,
						from = 0,
						favorLevel = favorLevel,
						to = to
					})
				end
			else
				table.insert(self.animSeq, {
					animType = 1,
					from = 0,
					to = 1,
					favorLevel = favorLevel
				})
				table.insert(self.animSeq, {
					animType = 2,
					favorLevel = favorLevel
				})
			end
		end
	end

	table.insert(self.animSeq, {
		duration = 0.5,
		animType = 3
	})
	table.insert(self.animSeq, {
		animType = 4
	})
end

function M:GetFillProcess(favor, level)
	local min = 0
	local max = self.animalCfg.Lv3

	if level == 1 then
		min = 0
		max = self.animalCfg.Lv1
	elseif level == 2 then
		min = self.animalCfg.Lv1
		max = self.animalCfg.Lv2
	elseif level == 3 then
		min = self.animalCfg.Lv2
		max = self.animalCfg.Lv3
	else
		return 0
	end

	if favor < min then
		return 0
	elseif favor < max then
		return (favor - min) / (max - min)
	else
		return 1
	end
end

function M:PlayFavorUpAnimations()
	self:CloseAnimTimer()

	if self.curAnimIndex <= #self.animSeq then
		local animCfg = self.animSeq[self.curAnimIndex]

		if animCfg.animType == 1 then
			local anim = self.bindData["heart" .. animCfg.favorLevel .. "Anim"]
			local duration = anim.clip.length * (animCfg.to - animCfg.from)

			gCS.LuaUtils.SampleTargetAnimation(anim, "S_Vx_AnimalFavorabilityPanel_aixin", animCfg.from * anim.clip.length)
			gCS.LuaUtils.PlayAnimationByName(anim, "S_Vx_AnimalFavorabilityPanel_aixin", animCfg.from * anim.clip.length)
			gCS.LuaUtils.PlayAnimationByName(self.bindData["max" .. animCfg.favorLevel .. "Anim"], "S_Vx_AnimalFavorabilityPanel_Add")

			self.animTimer = Timer.New(function ()
				self:OnCurrAnimFinished()
			end, duration):Start()
		elseif animCfg.animType == 2 then
			local anim = self.bindData["max" .. animCfg.favorLevel .. "Anim"]
			local duration = anim.clip.length

			gCS.LuaUtils.PlayAnimationByName(anim, "S_Vx_AnimalFavorabilityPanel_AddMax")

			self.animTimer = Timer.New(function ()
				self:OnCurrAnimFinished()
			end, duration):Start()
		elseif animCfg.animType == 3 then
			self.animTimer = Timer.New(function ()
				self:OnCurrAnimFinished()
			end, animCfg.duration):Start()
		elseif animCfg.animType == 4 then
			local duration = self.bindData.rootAnim:GetClip("S_Vx_AnimalFavorabilityPanel_close").length

			if duration > 0 then
				gCS.LuaUtils.PlayAnimationByName(self.bindData.rootAnim, "S_Vx_AnimalFavorabilityPanel_close")

				self.animTimer = Timer.New(function ()
					self:OnCurrAnimFinished()
				end, duration):Start()
			else
				gPanelManager:Close(gPanelId.S_ANIMAL_FAVOR_CHANGE)
			end
		end
	else
		gPanelManager:Close(gPanelId.S_ANIMAL_FAVOR_CHANGE)
	end
end

function M:OnCurrAnimFinished()
	self.animTimer = nil
	local animCfg = self.animSeq[self.curAnimIndex]

	if animCfg.animType == 1 then
		local anim = self.bindData["heart" .. animCfg.favorLevel .. "Anim"]

		gCS.LuaUtils.StopCurrentAnimation(anim)
		gCS.LuaUtils.SampleTargetAnimation(anim, "S_Vx_AnimalFavorabilityPanel_aixin", animCfg.to * anim.clip.length)
		gCS.LuaUtils.StopCurrentAnimation(self.bindData["max" .. animCfg.favorLevel .. "Anim"])
	end

	self.curAnimIndex = self.curAnimIndex + 1

	self:PlayFavorUpAnimations()
end

function M:CloseAutoCloseTimer()
	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end
end

function M:CloseAnimTimer()
	if self.animTimer then
		self.animTimer:Stop()

		self.animTimer = nil
	end
end

function M:OnClose()
	self:CloseAutoCloseTimer()
	self:CloseAnimTimer()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
