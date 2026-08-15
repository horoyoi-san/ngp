local json = require("cjson/json")
local EntityType = UX.Game.EntityType
local PlayerUnit = LX6.Units.PlayerUnit
local ClientUnitData = LX6.Units.ClientUnitData
local RaidConfig = LTConfig.RaidConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local MoneyType = UX.Game.MoneyType
local ColorUtils = LX6.Utils.ColorUtils
local BuffConfig = LTConfig.BuffConfig
local FightManager = LX6.Engine.FightManager
local ProfileManager = LX6.Engine.ProfileManager
local SpiritQuality = UX.Game.SpiritQuality
local GameConfig = LTConfig.GameConfig
local MessageConfig = LTConfig.MessageConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local SexType = UX.Game.SexType
local Screen = UnityEngine.Screen
local UniSDKManager = UniSDKManager
local DropConfig = LTConfig.DropConfig
local DailyDropConfig = LTConfig.ActivityDailyDropConfig
local PlayerPrefs = UnityEngine.PlayerPrefs
local FashionSlot = LX6.Share.FashionSlot
local M = {
	currentVoiceUUID = 0,
	LI_HUI_PATH_FORMATTER = "Assets/Res/Textures/UI/Content/Lihui/",
	ITEM_ICON_BG = {
		[SpiritQuality.White] = "tongyong_pinzhi_hui",
		[SpiritQuality.Blue] = "tongyong_pinzhi_lan",
		[SpiritQuality.Purple] = "tongyong_pinzhi_zi",
		[SpiritQuality.Gold] = "tongyong_pinzhi_huang"
	},
	ITEM_ACHIEVEMENT_BG = {
		[SpiritQuality.White] = "ChengJiu_White",
		[SpiritQuality.Blue] = "ChengJiu_Blue",
		[SpiritQuality.Purple] = "ChengJiu_Purple",
		[SpiritQuality.Gold] = "ChengJiu_Gold"
	},
	CLICKMENU_XPOSITION = {
		MIDDLE = -100
	},
	ITEM_QUALITY_COLOR = {
		[0] = ColorUtils.GetColorByString(GameConfig.WhiteColor),
		[SpiritQuality.White] = ColorUtils.GetColorByString(GameConfig.GreenColor),
		[SpiritQuality.Blue] = ColorUtils.GetColorByString(GameConfig.BlueColor),
		[SpiritQuality.Purple] = ColorUtils.GetColorByString(GameConfig.PurpleColor),
		[SpiritQuality.Gold] = ColorUtils.GetColorByString(GameConfig.GoldColor),
		[5] = Color.New(0.9294117647058824, 0.5803921568627451, 0)
	},
	ITEM_QUALITY_DECORATE_COLOR = {
		[0] = ColorUtils.GetColorByString(GameConfig.WhiteDecorateColor),
		[SpiritQuality.White] = ColorUtils.GetColorByString(GameConfig.GreenDecorateColor),
		[SpiritQuality.Blue] = ColorUtils.GetColorByString(GameConfig.BlueDecorateColor),
		[SpiritQuality.Purple] = ColorUtils.GetColorByString(GameConfig.PurpleDecorateColor),
		[SpiritQuality.Gold] = ColorUtils.GetColorByString(GameConfig.GoldDecorateColor)
	},
	PACKAGE_ITEM_QUALITY_COLOR = {
		[SpiritQuality.White] = Color.New(0.6039215686274509, 0.8392156862745098, 0.611764705882353),
		[SpiritQuality.Blue] = Color.New(0.45098039215686275, 0.5647058823529412, 0.7294117647058823),
		[SpiritQuality.Purple] = Color.New(0.6352941176470588, 0.3764705882352941, 0.6941176470588235),
		[SpiritQuality.Gold] = Color.New(0.9568627450980393, 0.8196078431372549, 0.38823529411764707)
	},
	LING_QUALITY_COLOR = {
		[SpiritQuality.White] = Color.New(0.6039215686274509, 0.8392156862745098, 0.611764705882353),
		[SpiritQuality.Blue] = Color.New(0.45098039215686275, 0.5647058823529412, 0.7294117647058823),
		[SpiritQuality.Purple] = Color.New(0.6666666666666666, 0.611764705882353, 0.9490196078431372),
		[SpiritQuality.Gold] = Color.New(1, 0.8392157, 0.4196078)
	},
	SexType = {
		[SexType.UnKnow] = LTConfig.TextScriptTextConfig.GetConfig(89900809).Text,
		[SexType.Male] = LTConfig.TextScriptTextConfig.GetConfig(89900810).Text,
		[SexType.Female] = LTConfig.TextScriptTextConfig.GetConfig(89900811).Text
	},
	FindComponent = function (self, root, path, class)
		return root.transform:Find(path):GetComponent(typeof(class))
	end,
	PlaySound = function (self, effectId)
		gSoundMgr:PlaySoundByTid(effectId)
	end,
	PlayMusic = function (self, effectId)
		gCS.GuiUtils.PlayMusic(effectId)
	end,
	PlayVoiceOld = function (self, soundId, startTime, postEndCb, callback)
		self:StopVoiceOld()

		local cb = startTime and startTime > 0 and function ()
			local soundData = gSoundMgr:GetSoundData(gLuaUIMgr.lastVoiceEffect)

			if soundData then
				soundData.soundEvt:SeekToTime(startTime * 1000)
			end

			if callback then
				callback(soundData.UUId)
			end
		end or nil

		gSoundMgr:PlaySoundByTid(soundId, nil, function (uuid)
			gLuaUIMgr.lastVoiceEffect = uuid

			if postEndCb then
				postEndCb(uuid)
			end
		end, cb or callback)
	end,
	StopVoiceOld = function (self)
		if gLuaUIMgr.lastVoiceEffect and gLuaUIMgr.lastVoiceEffect > 0 then
			gSoundMgr:StopSound(gLuaUIMgr.lastVoiceEffect)

			gLuaUIMgr.lastVoiceEffect = 0
		end
	end,
	PlayVoice = function (self, voiceId, successCb, failCb)
		self:CancelVoice()

		if voiceId <= 0 then
			if failCb then
				failCb()
			end

			return
		end

		if self.voiceCallback == nil then
			function self.voiceCallback(uuid, soundData)
				if uuid == 0 then
					if self.voiceFailCb then
						self.voiceFailCb()
					end
				else
					self.currentVoiceUUID = uuid

					if self.voiceSuccessCb then
						self.voiceSuccessCb(uuid, soundData)
					end
				end
			end
		end

		self.voiceFailCb = failCb
		self.voiceSuccessCb = successCb

		gSoundMgr:PlaySoundByTid(voiceId, nil, nil, self.voiceCallback)
	end,
	StopVoice = function (self, voiceUUID)
		if voiceUUID ~= 0 then
			gSoundMgr:StopSound(voiceUUID)

			self.currentVoiceUUID = 0
		end
	end,
	CancelVoice = function (self)
		self:StopVoice(self.currentVoiceUUID)
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if gSwitchSceneType.Image <= switchType and self.currentVoiceUUID ~= 0 then
			self:CancelVoice()
		end
	end,
	PlayTweenForward = function (self, tweener, resetToBegin)
		return
	end,
	PlayTweensForward = function (self, go, resetToBegin)
		return
	end,
	PlayTweenReverse = function (self, tweener, resetToBegin)
		if resetToBegin == nil then
			resetToBegin = true
		end
	end,
	PlayTweensReverse = function (self, go, resetToBegin)
		if resetToBegin == nil then
			resetToBegin = true
		end
	end,
	SetTweeensFactor = function (self, go, factor)
		return
	end,
	StopTweens = function (self, go)
		gCS.GuiUtils.StopTweens(go)
	end,
	PlayOpenAni = function (self, ani, openName, loopName, isEventCd)
		if not gCS.LuaUtils.IsNull(ani) then
			local clip = ani:GetClip(openName)

			if clip == nil then
				print_error(ani.gameObject.name, "节点上找不到", openName, "动效")

				return
			end

			clip:SampleAnimation(ani.gameObject, 0)
			ani:Stop()

			ani:get_Item(openName).speed = 1

			ani:Play(openName)

			if loopName then
				if self.AniDelay then
					gLuaTimeMgrUtils.CancelUnitDelay(self.AniDelay)
				end

				self.AniDelay = gLuaTimeMgrUtils.Delay(function ()
					self:PlayOpenAni(ani, loopName)

					self.AniDelay = nil
				end, clip.length)
			end

			return clip.length
		end

		return 0
	end,
	SkipAni = function (self, ani, name)
		if ani then
			local clip = ani:GetClip(name)

			if clip then
				clip:SampleAnimation(ani.gameObject, clip.length)
				ani:Stop(name)
			else
				print_error(ani.gameObject.name, "节点上找不到", name, "动效")
			end
		end
	end,
	PlayAniClosePanel = function (self, ani, aniName, panelId)
		if not gCS.LuaUtils.IsNull(ani) then
			local clip = ani:GetClip(aniName)

			if clip == nil then
				print_error(ani.gameObject.name, "节点上找不到", aniName, "动效")

				return false
			end

			clip:SampleAnimation(ani.gameObject, 0)
			ani:Stop()

			ani:get_Item(aniName).speed = 1

			ani:Play(aniName)

			if panelId then
				if self.AniDelay then
					gLuaTimeMgrUtils.CancelUnitDelay(self.AniDelay)
				end

				self.AniDelay = gLuaTimeMgrUtils.Delay(function ()
					self.AniDelay = nil

					gPanelManager:Close(panelId)
				end, clip.length)
			end

			return true
		end

		return false
	end,
	PlayAniCallback = function (self, ani, aniName, callback, notPrint)
		local function cb()
			if callback then
				callback()
			end
		end

		if not gCS.LuaUtils.IsNull(ani) then
			local clip = ani:GetClip(aniName)

			if clip == nil then
				if not notPrint then
					print_warn(ani.gameObject.name, "节点上找不到", aniName, "动效")
				end

				cb()

				return
			end

			ani:Play(aniName)

			local timer = nil
			timer = Timer.New(function ()
				timer = nil

				cb()
			end, clip.length):Start()

			return
		end

		cb()
	end,
	ScrollToMe = function (self, ScrollView, ArrayDatas)
		return
	end,
	Round = function (self, num)
		return math.floor(num + 0.5)
	end
}
local CONTROL_BUFF_IDS = {
	[BuffConfig.DebuffFaint] = true,
	[BuffConfig.DebuffFrozen] = true
}
local tempName = ""

function M:LoadModel(name, modelId, unitAction, loadCompletePlayEffectId, loadCompleteSwitchRenderQueue, simpleInfo, callback, beforeLoadCallBack, otherData)
	if name == nil then
		name = tempName
	end

	local unitId = gCS.UnitsManager.GetUnitNextLongId()
	local c = ClientUnitData.New(unitId, name)
	c.AgentId = otherData and otherData.AgentId or 0
	c.ModelId = modelId
	c.uiModelId = modelId
	c.isVirtualUnit = true
	c.isUI = true
	c.isFaceBuild = false
	c.position = Vector3.New(1000, 1000, 1000)
	local fastload = false

	if otherData then
		c.cardId = otherData.cardId or 0

		if otherData.fastLoad then
			fastload = true
		end

		if otherData.IsPet then
			c.isUI = false
			c.isVirtualUnit = false
		end

		if otherData.isDMUI then
			c.isDMUI = true
			c.isUI = false
		end

		if otherData.isPhotoUnit then
			c.isPhotoUnit = true
			c.useHighModel = true
			c.isUI = false
		end

		if otherData.usePlayer then
			c.useHighModel = true
			c.Type = EntityType.Player
			c.isUI = false
		end

		if otherData.isImage then
			c.isUI = false
			c.useHighModel = true
		end

		if otherData.faceBoneData ~= nil then
			c.faceBoneData = otherData.faceBoneData
		end

		if otherData.transformId ~= nil then
			c.transformId = otherData.transformId
		end

		if otherData.sexType then
			c.sexType = otherData.sexType
		end

		if otherData.isUseHM then
			c.useHighModel = true
		end

		if otherData.uiModelId then
			c.uiModelId = otherData.uiModelId
		end

		if otherData.lastCardId then
			c.lastCardId = otherData.lastCardId
		end

		if otherData.isFaceBuild then
			c.isFaceBuild = true
		end

		if otherData.weaponSkin then
			c.WeaponSkinId = otherData.weaponSkin
		end

		if otherData.SubType then
			c.SubType = otherData.SubType
		end

		if otherData.cardId then
			c.cardId = otherData.cardId
		end

		if otherData.fashionWearInfo then
			FashionSlot.RefreshUnitWearInfoByLua(c, otherData.fashionWearInfo)
		end

		if otherData.syncPlayerFashion then
			c.syncPlayerFashion = otherData.syncPlayerFashion
		end

		if otherData.agentBornWithWeaponId then
			c.AgentBornWithWeaponId = otherData.agentBornWithWeaponId
		end
	end

	if loadCompletePlayEffectId ~= nil then
		c.loadCompletePlayEffectId = loadCompletePlayEffectId
	end

	if loadCompleteSwitchRenderQueue ~= nil then
		c.loadCompleteSwitchRenderQueue = loadCompleteSwitchRenderQueue
	end

	local showUnit = nil

	if otherData and otherData.IsUIPet and otherData.PetAnimalId then
		c.SubType = otherData.PetAnimalId
	end

	showUnit = gCS.LuaUtils.CreateDisplayModelUnit(c)

	if showUnit and unitAction ~= nil then
		gCS.AnimationManager.AnimatorPlay(showUnit, unitAction, showUnit.State.ActionGroupId, 0, 0)
	end

	local uiShowModel = false

	if otherData ~= nil then
		if otherData.horseTextureId ~= nil then
			showUnit.horseTextureId = otherData.horseTextureId
		end

		if otherData.uiShowModel then
			uiShowModel = true
		end

		if otherData.firstLoadCompleteHandler then
			showUnit.OnFirstLoadCompleteHandler = showUnit.OnFirstLoadCompleteHandler + otherData.firstLoadCompleteHandler
		end

		if otherData.actionGroup then
			showUnit.dialogActionGroupType = otherData.actionGroup
		end
	end

	if callback ~= nil then
		showUnit.OnLoadCompleteHandler = showUnit.OnLoadCompleteHandler + callback
	end

	showUnit.loadPlugin.uiShowModel = uiShowModel

	if beforeLoadCallBack then
		beforeLoadCallBack(showUnit)
	end

	showUnit:LoadModel(modelId, true, fastload, false)

	return showUnit
end

function M:CheckCanSwitchScene(callback)
	callback()
end

function M:AskLeaveRaid()
	gCS.NetworkManager.PlayerLeaveRaid:DynamicInvoke()
end

function M:TryLeaveRaid()
	gCS.NetworkManager.PlayerLeaveRaid:DynamicInvoke()
end

function M:ShowExitRaidWindow()
	self:CheckCanSwitchScene(function ()
		local currentRaidId = gRaidDataManager.RaidId
		local config = RaidConfig.GetConfig(currentRaidId)
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(config.RaidType)
		local raidType = raidTypeConfig.Type

		local function leftCallBack()
			self:TryLeaveRaid()

			return true
		end

		local function rightCallBack()
			return true
		end

		local messageId = nil

		if gRaidDataManager.HasReward then
			messageId = MessageConfig.RaidExit
		else
			messageId = MessageConfig.ExitRaid
		end

		if raidType == RaidRaidTypeConfig.TypeType.SoloPve or raidType == RaidRaidTypeConfig.TypeType.TeamPve then
			gSettlementMgr:AskExist()

			return
		end

		gDisplayMessageMgr:ShowMessage(messageId, leftCallBack, rightCallBack)
	end)
end

function M:IsAllowChangeCardType()
	return gLuaDataManager:IsAllowChangeCardType()
end

function M:ShouldOpenExpResListPanel()
	return false
end

function M:ShouldOpenExpResEntryPanel()
	return false
end

function M:SetUnitLayer(unit, layer)
	if unit.CanUseRes then
		local renderers = unit.ModelSlot.rendererList:ToTable()

		for i = 1, #renderers do
			renderers[i].gameObject.layer = layer
		end
	end
end

function M:GetMoneyTypeId(moneyType)
	if moneyType == MoneyType.Money then
		return ConsumableConfig.RewardMoney
	elseif moneyType == MoneyType.Gold then
		return ConsumableConfig.RewardGold
	elseif moneyType == MoneyType.BindingGold then
		return ConsumableConfig.RewardBindingGold
	else
		return 0
	end
end

function M:GetMoneyType(consumableId)
	if consumableId == ConsumableConfig.RewardMoney then
		return MoneyType.Money
	elseif consumableId == ConsumableConfig.RewardGold then
		return MoneyType.Gold
	elseif consumableId == ConsumableConfig.RewardBindingGold then
		return MoneyType.BindingGold
	else
		return MoneyType.Default
	end
end

function M:GetMoneyConsumableId(money)
	if money == MoneyType.Money then
		return ConsumableConfig.RewardMoney
	elseif money == MoneyType.Gold then
		return ConsumableConfig.RewardGold
	elseif money == MoneyType.BindingGold then
		return ConsumableConfig.RewardBindingGold
	else
		return money
	end
end

function M:GetMoneyNameByType(moneyType)
	local cfg = ConsumableConfig.GetConfig(moneyType)

	if cfg then
		return cfg.Name
	end

	local itemId = self:GetMoneyTypeId(moneyType)
	cfg = ConsumableConfig.GetConfig(itemId)

	return cfg.Name
end

function M:GetMoneyByType(moneyType)
	local type = self:GetMoneyType(moneyType)

	if type > 0 then
		moneyType = type or moneyType
	end

	if moneyType == MoneyType.Money then
		return gPlayerManager.infoItem.bindData.money
	elseif moneyType == MoneyType.Gold then
		return gPlayerManager.infoItem.bindData.gold
	elseif moneyType == MoneyType.BindingGold then
		return gPlayerManager.infoItem.bindData.bindGold
	else
		return 0
	end
end

function M:GetMoneyImageConfigIdByType(moneyType)
	if moneyType == MoneyType.Money then
		return ConsumableConfig.GetConfig(ConsumableConfig.RewardMoney).MoneyIconId
	elseif moneyType == MoneyType.Gold then
		return ConsumableConfig.GetConfig(ConsumableConfig.RewardGold).MoneyIconId
	elseif moneyType == MoneyType.BindingGold then
		return ConsumableConfig.GetConfig(ConsumableConfig.RewardBindingGold).MoneyIconId
	else
		return 0
	end
end

function M:CheckMoneyEnough(checkMoney, moneyType)
	local money = self:GetMoneyByType(moneyType)

	if money < checkMoney then
		if moneyType == MoneyType.Gold then
			gDisplayMessageMgr:ShowMessage(MessageConfig.GoldNotEnough)
		elseif moneyType == MoneyType.Money then
			gDisplayMessageMgr:ShowMessage(MessageConfig.MoneyNotEnough)
		elseif moneyType ~= MoneyType.FashionPoint then
			gDisplayMessageMgr:ShowMessage(MessageConfig.ItemNotEnough, nil, nil, self:GetMoneyNameByType(moneyType))
		end

		return false
	end

	return true
end

function M:SetUITouchEnable(canTouch)
	gGFManager:SetTouchMask(not canTouch, gTouchMaskId.COMMON)
end

function M:GetItemName(packItem)
	return self:GetItemNameRaw(packItem.ItemTemplateId, packItem.Count)
end

function M:GetItemNameRaw(itemId, count)
	local itemConfig = ConsumableConfig.GetConfig(itemId)

	return itemConfig.Name .. tostring(count) .. LTConfig.TextScriptTextConfig.GetConfig(89900062).Text
end

function M:NumberToChinese(number)
	local NumberToChineseTab = {
		LTConfig.TextScriptTextConfig.GetConfig(89900073).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900074).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900075).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900076).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900077).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900078).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900079).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900080).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900081).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900082).Text
	}

	return NumberToChineseTab[number]
end

function M:IsFullScreenPanelShow(controlPanelId)
	local checkPanelIds = {}

	for i = 1, #checkPanelIds do
		local panelId = checkPanelIds[i]

		if panelId ~= controlPanelId and gPanelManager:IsPanelShowing(panelId) then
			return true
		end
	end

	return false
end

function M:parseTitlesAndContents(input)
	local result = {}
	local currentTitle = nil

	for line in string.gmatch(input, "[^\r\n]+") do
		local title = line:match("【(.-)】")

		if title then
			currentTitle = title
			result[currentTitle] = ""
		elseif currentTitle then
			if result[currentTitle] ~= "" then
				result[currentTitle] = result[currentTitle] .. "\n"
			end

			result[currentTitle] = result[currentTitle] .. line .. "\n"
		end
	end

	local ret = {}

	for k, v in pairs(result) do
		table.insert(ret, {
			title = k,
			content = v
		})
	end

	return ret
end

function M:ParseMessageExplain(input)
	local result = {}
	local currentItem = nil

	for line in string.gmatch(input, "[^\r\n]+") do
		local title = line:match("【(.-)】")

		if title then
			currentItem = {
				content = "",
				title = title
			}

			table.insert(result, currentItem)
		else
			currentItem = currentItem or {
				content = "",
				title = ""
			}

			if string.is_null_or_empty(currentItem.content) then
				currentItem.content = line
			else
				currentItem.content = currentItem.content .. "\n" .. line
			end
		end
	end

	return result
end

function M:CheckPhysicsLandPos(pos)
	if not pos then
		return
	end

	local x = pos.x
	local y = pos.y
	local z = pos.z

	if pos.y == 0 then
		local posLand = FightManager.GetPhysicsLandPosCheckGravityArea(pos)

		return posLand, true
	end

	return pos, false
end

function M:GetPhysicsLandPosByXZ(pos)
	if not pos then
		return
	end

	if pos.y == 0 and gCS.MyPlayerManager.PlayerUnit then
		local tempPos = Vector3.New(pos.x, 10000, pos.z)
		local tpos = gCS.MyPlayerManager.PlayerUnit:GetPhysicsLandPosByXZ(tempPos)

		if tpos and tpos ~= tempPos then
			return tpos, false
		end
	end

	return pos, false
end

local LARGE_NUM_LIMIT = {
	10000,
	1000
}
local NUM_SCALE = {
	10000,
	1000
}

function M:BuildLargeNumStr(value, limit)
	if value == nil then
		return 0
	end

	local curLang = ProfileManager.languageProfile.textLanguage

	if curLang > #NUM_SCALE then
		curLang = 1
	end

	limit = limit or LARGE_NUM_LIMIT[curLang]
	limit = math.max(limit, LARGE_NUM_LIMIT[curLang])
	local scale = NUM_SCALE[curLang]
	local scaleStr = curLang == 2 and GameConfig.ENGNumAbbr or GameConfig.CHNNumAbbr

	if value < limit then
		return math.floor(value)
	else
		if value < scale then
			return math.floor(value)
		end

		local scaleMaxNum = 1
		local scaleIndex = 0

		for i = 1, #scaleStr do
			if value < scaleMaxNum * scale then
				break
			end

			scaleMaxNum = scaleMaxNum * scale
			scaleIndex = i
		end

		return math.floor(value / scaleMaxNum) .. scaleStr[scaleIndex]
	end
end

function M:FormatMoney(value)
	if value == nil then
		return 0
	end

	local curLang = ProfileManager.languageProfile.textLanguage
	local languageCfg = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(curLang)
	local formatMoneyThreshold = languageCfg.FormatMoneyThreshold
	local numberFormat = languageCfg.NumberFormat

	if formatMoneyThreshold == -1 or value < formatMoneyThreshold then
		return math.floor(value)
	end

	local scaleIndex = 0

	for i, v in ipairs(numberFormat) do
		if value < v.scale then
			break
		end

		scaleIndex = i
	end

	if scaleIndex == 0 then
		print_error("本地化的数字简写配置有误! 语言=", curLang, " 数字=", value)

		return math.floor(value)
	end

	return math.floor(value / numberFormat[scaleIndex].scale) .. numberFormat[scaleIndex].abbr
end

function M:SaveLuaTableToJson(fileName, data)
	if string.is_null_or_empty(fileName) then
		return
	end

	if table.isNilOrEmpty(data) then
		gCS.LuaUtils.DeleteFile(fileName)

		return
	end

	local jsonStr = json.encode(data)

	gCS.LuaUtils.WriteFile(fileName, jsonStr)
end

function M:SaveLuaTableToJsonWithPid(fileName, data)
	self:SaveLuaTableToJson("Config/" .. ulong.tostring(gPlayerManager.infoLogin.bindData.pid) .. "/" .. fileName, data)
end

function M:SaveEncryptedJsonWithPid(path, fileName, key, vector, content, encryptedName, encryptedContent)
	if string.is_null_or_empty(fileName) then
		return
	end

	if table.isNilOrEmpty(content) then
		gCS.LuaUtils.DeleteEncryptedFile(path, fileName, key, vector)

		return
	end

	local jsonStr = json.encode(content)

	gCS.LuaUtils.WriteEncryptedFile(path, fileName, jsonStr, key, vector, encryptedName, encryptedContent)
end

function M:LoadJsonToLuaTable(fileName)
	if string.is_null_or_empty(fileName) then
		return
	end

	local jsonStr = gCS.LuaUtils.ReadFile(fileName)

	if not string.is_null_or_empty(jsonStr) then
		return json.decode(jsonStr)
	end

	return nil
end

function M:LoadJsonToLuaTableWithPid(fileName)
	return self:LoadJsonToLuaTable("Config/" .. ulong.tostring(gPlayerManager.infoLogin.bindData.pid) .. "/" .. fileName)
end

function M:LoadEncryptedJsonWithPid(path, fileName, key, vector, encryptedName, encryptedContent)
	if string.is_null_or_empty(fileName) then
		return
	end

	local jsonStr = gCS.LuaUtils.ReadEncryptedFile(path, fileName, key, vector, encryptedName, encryptedContent)

	if not string.is_null_or_empty(jsonStr) then
		return json.decode(jsonStr)
	end

	return nil
end

function M:ShowBannedReason(reasonStr)
	if reasonStr == nil or reasonStr == "" then
		gDisplayMessageMgr:ShowMessage(MessageConfig.BanAccount)
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.BanAccountWithReason, nil, nil, reasonStr)
	end
end

function M:NumberTo2String(number)
	if number <= 9 and number >= 0 then
		return gString.Format("0%d", number)
	end

	return tostring(number)
end

function M:GetPreciseDecimal(nNum, n)
	if type(nNum) ~= "number" then
		return nNum
	end

	n = n or 0
	n = math.floor(n)
	local fmt = "%." .. n .. "f"

	return tonumber(gString.Format(fmt, nNum))
end

function M:GetPreciseDecimalStr(nNum, n)
	if type(nNum) ~= "number" then
		return nNum
	end

	n = n or 0
	n = math.floor(n)
	local fmt = "%." .. n .. "f"

	return gString.Format(fmt, nNum)
end

function M:GetTexturePath(path, textureName, extension)
	if extension == nil then
		extension = ".png"
	end

	if not string.ends_with(path, "/") then
		path = path .. "/"
	end

	path = gString.Format("%s%s%s", path, textureName, extension)

	return path
end

function M:GetDropItemList(dropId, count, sortByItemType, isReturnCount)
	local itemList = {}

	if dropId and dropId ~= 0 then
		local cfg = DropConfig.GetConfig(dropId)

		if not cfg then
			return nil
		end

		if count == nil then
			count = 1
		end

		local index = 1

		if not sortByItemType and cfg.Money ~= 0 then
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(ConsumableConfig.RewardMoney), isReturnCount and cfg.Money * count or self:BuildLargeNumStr(cfg.Money * count or 0))

			if itemList[index] then
				itemList[index].SortItemType = gLuaEnum.SortItemType.Money
				index = index + 1
			end
		end

		if cfg.BindingGold ~= 0 then
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(ConsumableConfig.RewardBindingGold), isReturnCount and cfg.BindingGold * count or self:BuildLargeNumStr(cfg.BindingGold * count or 0))

			if itemList[index] then
				itemList[index].SortItemType = gLuaEnum.SortItemType.BindingGold
				index = index + 1
			end
		end

		local item = cfg.Item1

		for i = 1, #item do
			local itemId = item[i].id1
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(itemId), isReturnCount and item[i].count * count or self:BuildLargeNumStr(item[i].count * count))

			if not itemList[index] then
				itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(itemId), isReturnCount and item[i].count * count or self:BuildLargeNumStr(item[i].count * count))
			end

			if itemList[index] then
				itemList[index].SortItemType = gLuaEnum.SortItemType.Item
				index = index + 1
			end
		end

		item = cfg.Item2

		for i = 1, #item do
			local itemId = item[i].id2
			local counts = ""
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(itemId), counts)

			if itemList[index] then
				itemList[index].SortItemType = gLuaEnum.SortItemType.Item
				index = index + 1
			end
		end

		item = cfg.Item3

		for i = 1, #item do
			local itemId = item[i].id3
			local counts = ""
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(itemId), counts)

			if itemList[index] then
				itemList[index].SortItemType = gLuaEnum.SortItemType.Item
				index = index + 1
			end
		end

		item = cfg.Item4Range

		for i = 1, #item do
			local itemId = item[i].id4
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(itemId), "")

			if itemList[index] then
				itemList[index].SortItemType = gLuaEnum.SortItemType.Item
				index = index + 1
			end
		end

		if cfg.FreeGold ~= 0 then
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(ConsumableConfig.RewardGold), isReturnCount and cfg.FreeGold * count or self:BuildLargeNumStr(cfg.FreeGold * count))

			if itemList[index] then
				itemList[index].SortItemType = gLuaEnum.SortItemType.FreeGold
				index = index + 1
			end
		end

		if sortByItemType then
			table.sort(itemList, gItemUtils.SortByItemType)
		end

		if sortByItemType and cfg.Money ~= 0 then
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(ConsumableConfig.RewardMoney), isReturnCount and cfg.Money * count or self:BuildLargeNumStr(cfg.Money * count or 0))

			if itemList[index] then
				itemList[index].SortItemType = gLuaEnum.SortItemType.Money
				index = index + 1
			end
		end

		if not table.isNilOrEmpty(cfg.Fan) then
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(ConsumableConfig.RewardFan), "")
			itemList[index].SortItemType = gLuaEnum.SortItemType.FreeGold
			index = index + 1
		end

		if cfg.Popularity > 0 then
			itemList[index] = gItemUtils:GetDropListItem(ConsumableConfig.GetConfig(ConsumableConfig.RewardPopularity), "")
			itemList[index].SortItemType = gLuaEnum.SortItemType.FreeGold
			index = index + 1
		end
	end

	return itemList
end

function M:GetDailyDrop(dailyDropId, date, count, sortByItemType)
	if not date or date < 1 or date > 7 then
		return self:GetDailyDropOnToday(dailyDropId)
	end

	local itemList = {}
	local canChoose = false

	if dailyDropId and dailyDropId > 0 then
		local cfg = DailyDropConfig.GetConfig(dailyDropId)

		if not cfg then
			return nil
		end

		local dropIdList = cfg["Drop" .. date]
		local uniqueList = {}
		canChoose = #dropIdList > 1

		for _, dropId in ipairs(dropIdList) do
			local dropList = self:GetDropItemList(dropId, count)

			for _, item in ipairs(dropList) do
				if item.ItemId == ConsumableConfig.RewardExp or item.ItemId == ConsumableConfig.RewardMoney then
					uniqueList[item.ItemId] = item
				end

				if not uniqueList[item.ItemId] then
					table.insert(itemList, item)

					uniqueList[item.ItemId] = true
				end
			end
		end

		if sortByItemType then
			table.sort(itemList, gItemUtils.SortByItemType)
			table.insert(itemList, uniqueList[ConsumableConfig.RewardExp])
			table.insert(itemList, uniqueList[ConsumableConfig.RewardMoney])
		else
			if uniqueList[ConsumableConfig.RewardMoney] then
				table.insert(itemList, 1, uniqueList[ConsumableConfig.RewardMoney])
			end

			if uniqueList[ConsumableConfig.RewardExp] then
				table.insert(itemList, 1, uniqueList[ConsumableConfig.RewardExp])
			end
		end
	end

	return itemList, canChoose
end

function M:GetDailyDropOnToday(dailyDropId, count, sortByItemType)
	local today = gCS.TimeManager.ServerDateTime.DayOfWeek

	if today == 0 then
		today = 7
	end

	if today < 1 or today > 7 then
		print_error("function GetDailyDropOnToday, impl GetServerDateTime error, today = ", today)

		return nil
	end

	return self:GetDailyDrop(dailyDropId, today, count, sortByItemType)
end

function M:SetSkinGoActive(trans, isShow)
	if gCS.LuaUtils.IsNull(trans.gameObject) then
		return
	end

	trans:SetLocalPositionZ(isShow and 0 or gCS.GuiUtils.UI_TRANS_OUT_RANGE)
end

function M:SetGoActive(trans, isShow)
	if not trans or gCS.LuaUtils.IsNull(trans) then
		return
	end

	trans.gameObject:SetActive(isShow)
end

function M.ConfirmRepairClient()
	gClientUtils.CloseMainPhonePanel()
	gCS.LuaUtils.GoRepairClient()
end

function M:ClickRepairClient(cancelFunc)
	gDisplayMessageMgr:ShowMessage(MessageConfig.ClientRepairConfirm, self.ConfirmRepairClient, cancelFunc)
end

function M:IsInOtherWorld()
	return gRaidDataManager.RaidId > 0 and not ulong.equals(gRaidDataManager.hostPid, 0) and not ulong.equals(gRaidDataManager.hostPid, gPlayerManager.infoLogin.bindData.pid)
end

local houseRaid2HouseId = nil

function M:IsInSeasonRaid()
	if gRaidDataManager.RaidId == 0 then
		return false
	end

	local raidId = gRaidDataManager.RaidId
	local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

	if not raidCfg then
		return false
	end

	return raidCfg.RaidType == LTConfig.RaidConfig.SeasonRaidTypeId
end

function M:IsInBattleRaid()
	if gRaidDataManager.RaidId == 0 then
		return false
	end

	local raidId = gRaidDataManager.RaidId
	local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

	if not raidCfg then
		return false
	end

	return raidCfg.RaidType == 15
end

function M:IsInXinShouRaid()
	if gRaidDataManager.RaidId == 0 then
		return false
	end

	local raidId = gRaidDataManager.RaidId

	for i = 1, #RaidConfig.XinShouRaidHideUI do
		if raidId == RaidConfig.XinShouRaidHideUI[i] then
			return true
		end
	end

	return false
end

function M:IsInShowEnemyLevelRaid()
	if gRaidDataManager.RaidId == 0 or not RaidConfig.ShowEnemyLevel then
		return false
	end

	local raidId = gRaidDataManager.RaidId

	for i = 1, #RaidConfig.ShowEnemyLevel do
		if raidId == RaidConfig.ShowEnemyLevel[i] then
			return true
		end
	end

	return false
end

function M:OnConfigHotfix(eventId, data)
	local list = data:ToTable()

	if array.contains(list, "HouseConfig") then
		houseRaid2HouseId = nil
	end

	if array.contains(list, "TaskClueConfig") then
		gClueManager:InitTaskInfo()
	end
end

function M:GetNearestUnit(id, mPos)
	local enemys = gCS.UnitsManager:GetEnemyUnitsByTemplateId(id):ToTable()
	local dis, unit = nil

	if enemys then
		for i = 1, #enemys do
			local value = enemys[i]

			if not value.IsDead and not value.IsDestroyed then
				if not mPos then
					unit = value

					break
				end

				local distance = gUtils:GetDistance(value.PlayerObj.position, mPos)

				if not dis or distance < dis then
					unit = value
					dis = distance
				end
			end
		end
	end

	return unit
end

function M:ShowErrorMessage(err, ...)
	local msgConfig = MessageConfig.GetConfig(err)

	if msgConfig and msgConfig.Content then
		gDisplayMessageMgr:ShowMessage(err, nil, nil, ...)
	else
		print_debug("ShowErrorMessage:", err)
	end
end

function M:AdjustAgeTip(screenPos, spriteWidth, spriteHeight)
	local Screen = UnityEngine.Screen
	local uiHeight = SGUI.UWidget.canvasScaler.matchWidthOrHeight
	local uiWidth = Screen.width / Screen.height * uiHeight
	local x = screenPos.x * Screen.width / uiWidth
	local y = screenPos.y * Screen.height / uiHeight
	local widthR = Screen.width / uiWidth
	local heightR = Screen.height / uiHeight
	local minR = math.min(widthR, heightR)
	local width = spriteWidth * minR
	local height = spriteHeight * minR

	UniSDKManager.SetAgeTipPos(x, y, 0, width, height)
end

M.CollectionPageType = {
	PersonalRecord = 2,
	MediaFiles = 4,
	Album = 5,
	MainStory = 1,
	ResearchReport = 3,
	GuideHelp = 6
}

function M:CheckCanOpenCardPanel()
	if gVehicleInteractManager.cs_manager.isInteracting then
		gDisplayMessageMgr:ShowMessage(MessageConfig.DriveRaceOpenCard)

		return false
	end

	if gChallengeManager.challengeData.IsChallenging then
		gDisplayMessageMgr:ShowMessage(MessageConfig.DriveRaceOpenCard)

		return false
	end

	local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)

	if raidCfg then
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

		if not gCS.SceneDataMgr.IsRaidEnd and raidTypeConfig.ChangeCardRule == RaidRaidTypeConfig.ChangeCardRuleType.Forbidden then
			return false
		end
	end

	return true
end

function M:GetNowRaidCfg()
	return RaidConfig.GetConfig(gRaidDataManager.RaidId)
end

function M:FilterList(dataList, filterTitles, filterSettings)
	local result = {}

	for i = 1, #dataList do
		local canInsert = true

		for groupIdx = 1, #filterSettings do
			local filterSetting = filterSettings[groupIdx]
			local filterInfos = filterTitles[groupIdx]

			if not self:AllSame(filterSetting) then
				canInsert = canInsert and M:Filter(dataList[i], filterInfos, filterSetting)
			end
		end

		if canInsert or dataList[i].passFilter then
			table.insert(result, dataList[i])
		end
	end

	return result
end

function M:AllSame(booleanArray)
	for i = 1, #booleanArray do
		if booleanArray[i] ~= booleanArray[1] then
			return false
		end
	end

	return true
end

function M:Filter(data, filterInfo, filtersSettings)
	local attrName = filterInfo.type
	local pass = false

	for subFilterIdx = 1, #filtersSettings do
		local needCheck = filtersSettings[subFilterIdx]

		if needCheck then
			local attrVal = filterInfo.values[subFilterIdx]
			pass = pass or data[attrName] == attrVal
		end
	end

	return pass
end

function M:SortList(dataList, sortKey, sToL, frontDatas)
	local tmp1 = {}
	local tmp2 = {}
	local dic = {}

	for i, v in pairs(frontDatas) do
		dic[v] = i
	end

	table.sort(dataList, function (a, b)
		local a_f = dic[a.Tid] or false
		local b_f = dic[b.Tid] or false

		if a_f or b_f then
			tmp1[1] = (a_f or math.huge) < (b_f or math.huge)
			tmp2[1] = a_f

			return (a_f and b_f and tmp1 or tmp2)[1]
		end

		if a[sortKey] ~= b[sortKey] then
			if sToL then
				return a[sortKey] < b[sortKey]
			else
				return b[sortKey] < a[sortKey]
			end
		else
			return M:SortLingDefault(a, b, sToL)
		end
	end)

	return dataList
end

function M:SortLingDefault(a, b, sToL)
	if a.Lv ~= b.Lv then
		if sToL then
			return a.Lv < b.Lv
		else
			return b.Lv < a.Lv
		end
	end

	if a.Quality ~= b.Quality then
		if sToL then
			return a.Quality < b.Quality
		else
			return b.Quality < a.Quality
		end
	end

	if a.ElementType ~= b.ElementType then
		if sToL then
			return a.ElementType < b.ElementType
		else
			return b.ElementType < a.ElementType
		end
	end

	if a.Tid ~= b.Tid then
		if sToL then
			return a.Tid < b.Tid
		else
			return b.Tid < a.Tid
		end
	end
end

function M:GetNumberStr(num)
	if num > 0 then
		return "+" .. num
	elseif num == 0 then
		return ""
	end

	return num
end

function M:NumToRoman(num)
	local romanNumerals = {
		{
			1000,
			"M"
		},
		{
			900,
			"CM"
		},
		{
			500,
			"D"
		},
		{
			400,
			"CD"
		},
		{
			100,
			"C"
		},
		{
			90,
			"XC"
		},
		{
			50,
			"L"
		},
		{
			40,
			"XL"
		},
		{
			10,
			"X"
		},
		{
			9,
			"IX"
		},
		{
			5,
			"V"
		},
		{
			4,
			"IV"
		},
		{
			1,
			"I"
		}
	}
	local result = ""

	for _, pair in ipairs(romanNumerals) do
		local value = pair[1]
		local roman = pair[2]

		while value <= num do
			result = result .. roman
			num = num - value
		end
	end

	return result
end

function M:GetLanguageIndex()
	local lang = LTConfig.TableGetLanguage()

	for i = 1, #LTConfig.ShezhiPanelConfig.LanguagesDisplay do
		if lang == LTConfig.ShezhiPanelConfig.LanguagesDisplay[i] then
			return i
		end
	end

	return 1
end

function M:_format_number(fmt, num)
	if fmt:sub(1, 1) == "p" then
		local n = tonumber(fmt:sub(2)) or 0
		local real_fmt = "%." .. n .. "f%%"

		return string.format(real_fmt, num * 100)
	elseif fmt:sub(1, 1) == "f" then
		local n = tonumber(fmt:sub(2)) or 0
		local real_fmt = "%." .. n .. "f"

		return string.format(real_fmt, num)
	else
		return tostring(num)
	end
end

function M:GetFormattedString(str)
	return string.lower(string.gsub(str, " ", ""))
end

function M:IsMatchCondition(name, text)
	name = self:GetFormattedString(name)
	text = self:GetFormattedString(text)
	local completePinyin = gCS.LuaUtils.GetPinyin(name)
	local firstLetterPinyin = ""

	for word in string.gmatch(completePinyin, "%a+") do
		firstLetterPinyin = firstLetterPinyin .. word:sub(1, 1)
	end

	completePinyin = self:GetFormattedString(completePinyin)

	if string.is_null_or_empty(text) then
		return false
	else
		return string.find(name, text) or string.find(firstLetterPinyin, text) or string.find(completePinyin, text)
	end
end

function M:CommonShowPhoto(data)
	if table.isNilOrEmpty(data) or LTConfig.SguiImageConfig.GetConfig(data.imageId) == nil and data.texture == nil then
		print_error("[ShowPhotoPanelStore] CommonShowPhoto no image data", data)

		return
	end

	if data.textId then
		local textCfg = LTConfig.TextScriptTextConfig.GetConfig(data.textId)

		if textCfg == nil then
			print_error("[ShowPhotoPanelStore] can not find text, Id=", data.textId)
		end
	end

	gPanelManager:CheckShow(gPanelId.S_SHOW_PHOTO_PANEL, data)
end

gUIUtils = M
