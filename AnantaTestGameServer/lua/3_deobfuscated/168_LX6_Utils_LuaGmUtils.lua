local StoneConfig = LTConfig.StoneConfig
local M = {
	currentGachaOnceStoneIdx = 0,
	photoNoLimit = false,
	currentGachaOnceSpriteIdx = 0,
	useNewTestMainPanel = false,
	stealPhoneMode = 0,
	gachaOnceSpriteIds = {},
	gachaOnceStoneIds = {}
}
local this = M

function M:ShowGachaOnce(id)
	return
end

function M:ShowGachaOnceAllSprite()
	local spriteIds = {}
	this.currentGachaOnceSpriteIdx = 1
	this.gachaOnceSpriteIds = spriteIds

	this:ShowGachaOnceSprite()
end

function M:ShowGachaOnceSprite()
	return
end

function M:ShowGachaOnceAllStone()
	local ids = {}

	for i = 0, StoneConfig.count - 1 do
		local cfg = StoneConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.Texture) then
			table.insert(ids, {
				id = cfg.Id
			})
		end
	end

	this.currentGachaOnceStoneIdx = 1
	this.gachaOnceStoneIds = ids

	this:ShowGachaOnceStone()
end

function M:ShowGachaOnceStone()
	return
end

function M:PhotoNoLimit(enable)
	self.photoNoLimit = enable
end

function M:SwitchMainPhonePanelSGui(enable)
	self.isMainPhoneSGuiEnable = enable
end

function M:SwitchCallPhoneSGui(enable)
	self.isCallPhoneSGuiEnable = enable
end

function M:SwitchHalfScreen(enable)
	self.isHalfScreenEnable = enable
end

function M:SwitchTimePanelSgui(enable)
	self.isTimePanelSGuiEnable = enable
end

function M:EnableMainPhoneFansView()
	self.isEnableMainPhoneFansView = true
end

function M:SwitchTestMainPanelSgui(enable)
	local state = enable and 1 or 0

	UnityEngine.PlayerPrefs.SetInt("UseNewTestMainPanel", state)
end

function M:SetStealPhoneMode(mode)
	self.stealPhoneMode = mode
end

function M:TryAddFriend(pid)
	local function Callback(err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessageContentDebug("操作成功")
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	gClientToAvatarDelegate:ResponseFriendApplication(pid, true).Callback = Callback

	gFriendManager:ApplyFriend(pid, Callback)
end

function M:ShowFakeNpcChat(cfgId)
	local panelId = gClientUtils.GetMainPhonePanelId()

	if not gPanelManager:IsPanelShowing(panelId) then
		gNpcChatNpcsPhoneManager:ShowNpcFakeChat(cfgId)
	end
end

function M:GmSkipNpcChatDialog(chatId)
	gNpcChatUtils.GmUtils.SkipNpcChatDialog(chatId)
end

function M:SwitchMainPhonePopularity(enable)
	self.isEnableMainPhonePopularity = enable
end

function M:SwitchNewAnnouncement(enable)
	self.useNewAnnouncement = enable
end

function M:SwitchBaiKeSGui(enable)
	self.isEnableBaikeSgui = enable
end

function M:SwitchToMobileStyle(isMobile)
	gCS.PanelManager.Instance.IsMobileMode = isMobile

	if gLuaDataManager.gameStage == LX6.Scene.SwitchSceneManager.GameStage.GameScene then
		gLuaDataManager.guiMgr.panelCache:SwitchSceneClosePanels(true)
		gClientToGameGMDelegate:FastReenter()
	end
end

function M:ForceOpenMainPhonePanel(isForce)
	self.isForceOpenMainPhonePanel = isForce
end

function M:SwitchYanJieFullScreen(isForce)
	self.isYanJieFullScreen = isForce
end

function M:ShowChaosMasterGacha(id)
	gPanelManager:CheckShow(gPanelId.CHAOS_GACHA_PANEL, {
		poolId = id
	})
end

function M:VisitOtherHouse(pid, houseId)
	gClientToGameGMDelegate:GmHouseVisit(pid, houseId).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			local houseInfo = data

			gFurnitureManager:RemoveAllFurniture()

			gHouseManager.serverToClientUidMap = {}
			gHouseManager.clientToServerUidMap = {}
			gHouseManager.serverSyncState = {}

			for floorKey, indoorBuildInfo in pairs(houseInfo.FloorBuildInfoDict) do
				local furnitureDict = indoorBuildInfo.Root.ChildrenDict
				local processedFurnitures = {}

				for key, furnitureInfo in pairs(furnitureDict) do
					gFurnitureUtils:ProcessServerFurnitureData(furnitureInfo)

					processedFurnitures[key] = furnitureInfo
				end

				local loadedFurnitureIds = {}

				local function LoadFurnitureRecursively(furnitureInfo, parentId)
					local furnitureId = furnitureInfo.PlacedInstanceId

					if loadedFurnitureIds[furnitureId] then
						return
					end

					loadedFurnitureIds[furnitureId] = true

					gHouseManager:CreateFurnitureFromServerData(furnitureInfo, parentId)

					for _, childFurnitureInfo in pairs(processedFurnitures) do
						if childFurnitureInfo.ParentPlacedInstanceId == furnitureId then
							LoadFurnitureRecursively(childFurnitureInfo, furnitureId)
						end
					end
				end

				for _, furnitureInfo in pairs(processedFurnitures) do
					if not furnitureInfo.ParentPlacedInstanceId or furnitureInfo.ParentPlacedInstanceId == 0 then
						LoadFurnitureRecursively(furnitureInfo, nil)
					end
				end
			end

			gFriendManager:GetPlayerRealName(pid, function (playerName)
				gDisplayMessageMgr:ShowMessageContentDebug("成功加载玩家 " .. playerName .. " 的家园")
			end)
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:EnableFormalShortCutKey(_)
	return
end

function M:GetFormalShortCutKeyState()
	return true
end

function M:SetLanguage(index)
	local SettingsScriptFunc = require("LX6/GUI/Setting/SettingsScriptFunc")

	SettingsScriptFunc._RealSetLanguage(index)
end

function M:AddChallengeRecord(id, score, paramList, callback)
	paramList = paramList and paramList:ToTable() or {}
	local taskId = LTConfig.ChallengeConfig.GetConfig(id).RelatedTask[1]
	local params = {}

	for i = 1, #LTConfig.ChallengeConfig.GetConfig(id).CountersDescription do
		params[i] = paramList[i] or false
	end

	local gm = require("LuaGen/AutoGen/GmToGamePlayerDelegate")

	gm:ForceAcceptTask(taskId).Callback = function (err)
		gDisplayMessageMgr:DisplayServerMessageId(err)

		gClientToGameDelegate:SetNewChallengeData(id, params, score).Callback = function (err)
			gDisplayMessageMgr:DisplayServerMessageId(err)

			gClientToGameDelegate:FinishNewChallenge(id, taskId).Callback = function (err1, challengeRecord)
				gDisplayMessageMgr:DisplayServerMessageId(err1)

				if callback then
					callback(challengeRecord)
				end
			end
		end
	end
end

function M:FinishSeasonGamePlay(id, cnt)
	coroutine.start(function ()
		for i = 0, LTConfig.SeasonTrialConfig.count - 1 do
			local seasonTrialCfg = LTConfig.SeasonTrialConfig.LoadAt(i)

			if seasonTrialCfg.Season == self.instance.seasonId and seasonTrialCfg.SeasonGamePlay == id and seasonTrialCfg.PrevStage == 0 then
				local cfgIt = seasonTrialCfg

				while cfgIt do
					local lock = true
					local params = {}

					for i = 1, #LTConfig.ChallengeConfig.GetConfig(seasonTrialCfg.ChallengeID).CountersDescription do
						params[i] = true
					end

					self:AddChallengeRecord(seasonTrialCfg.ChallengeID, 0, params, function ()
						lock = false
					end)

					while lock do
						coroutine.step()
					end

					cfgIt = LTConfig.SeasonTrialConfig.GetConfig(cfgIt.NextStage)
				end

				break
			end
		end
	end)
end

function M:SetGuitarChordPCKey(...)
	local store = gStoreManager:GetStoreGroup("InstrumentsGuitarPanelStore")

	if store.STATE_EnableOnce then
		store:SetChordPCKey({
			...
		})
	end
end

function M:SetCoreHudRefresh(isNewRefresh)
	gCoreHudUIManager.isNewRefresh = isNewRefresh
end

function M:ShowCoreHudLog(isShow)
	gMainMenuMgr.ShowTestMsg = isShow
end

function M:BowlingGameEnableDirDebug(isEnable)
	self.isBowlingGameEnableDireDebug = isEnable
end

function M:BasketBallGameShootType(shootType)
	self.basketballGameShootType = shootType
end

gGmUtils = M
