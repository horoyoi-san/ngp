-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\HudConst.lua
-- Decompiled from: 02284_HudConst.lua_dbfe1c7d4337.luajit

local M = gHudMgr
local EnemyHUDCtrl = require("LX6/Manager/HUD/EnemyHUDCtrl")
local PlayerHUDCtrl = require("LX6/Manager/HUD/PlayerHUDCtrl")
local NpcHUDCtrl = require("LX6/Manager/HUD/NpcHUDCtrl")
local DestructibleHUDCtrl = require("LX6/Manager/HUD/DestructibleHUDCtrl")
local SlotEntityHUDCtrl = require("LX6/Manager/HUD/SlotEntityHUDCtrl")
local VehicleHUDCtrl = require("LX6/Manager/HUD/VehicleHUDCtrl")
local AetherHUDCtrl = require("LX6/Manager/HUD/AetherHUDCtrl")
M.MinNpcVisibleDist = 10
M.NameBarShowDist = 20
M.ExtraDist = 2
M.HUDTargetType = LX6.GUI.HUDNew.HUDTargetType
M.HUDTemplateType = LX6.GUI.HUDNew.HUDTemplateType
M.TemplateType2Store = {
	[M.HUDTemplateType.EnemyHpBar] = "EnemyHpTemplate",
	[M.HUDTemplateType.EnemyPartShieldBar] = "EnemyWeaponShieldBarTemplate",
	[M.HUDTemplateType.DistanceAttackMarker] = "DistanceAttackMarkerTemplate",
	[M.HUDTemplateType.BVB] = "BVBTemplate",
	[M.HUDTemplateType.BuffHeadIcon] = "BuffHeadIconTemplate",
	[M.HUDTemplateType.EnemyPosition] = "EnemyPositionTemplate",
	[M.HUDTemplateType.StealthDetectValue] = "StealthDetectValueTemplate",
	[M.HUDTemplateType.DangerHint] = "DangerHintTemplate",
	[M.HUDTemplateType.NpcName] = "NpcNameTemplate",
	[M.HUDTemplateType.NpcTitle] = "NpcTitleTemplate",
	[M.HUDTemplateType.NpcIcon] = "NpcFeatureIconTemplate",
	[M.HUDTemplateType.NPCAIChatting] = "NPCAIChattingTemplate",
	[M.HUDTemplateType.DebugText] = "DebugTextTemplate",
	[M.HUDTemplateType.SlotTopInfo] = "SlotTopInfoTemplate",
	[M.HUDTemplateType.PlayerName] = "PlayerNameTemplate",
	[M.HUDTemplateType.LevitationBar] = "LevitationBarTemplate",
	[M.HUDTemplateType.PlayerIdentifiedNumber] = "PlayerNumberIconTemplate",
	[M.HUDTemplateType.TopIcon] = "TopIconTemplate",
	[M.HUDTemplateType.TopText] = "TopTextTemplate",
	[M.HUDTemplateType.TopAnimIcon] = "TopAnimIconsTemplate",
	[M.HUDTemplateType.PlayerBubble] = "PlayerBubbleTemplate",
	[M.HUDTemplateType.PlayerSurvivalStatus] = "PlayerSurvivalStatusTemplate",
	[M.HUDTemplateType.PlayerImageBubble] = "PlayerBubbleImageTemplate",
	[M.HUDTemplateType.AllyHpBar] = "AllyHpTemplate",
	[M.HUDTemplateType.VehicleHpBar] = "EnemyVehicleHpBarTemplate"
}
M.TemplateType2Name = {
	hpBar = M.HUDTemplateType.EnemyHpBar,
	partBar = M.HUDTemplateType.EnemyPartShieldBar,
	missileLock = M.HUDTemplateType.DistanceAttackMarker,
	BVB = M.HUDTemplateType.BVB,
	buffIcon = M.HUDTemplateType.BuffHeadIcon,
	enemyPos = M.HUDTemplateType.EnemyPosition,
	detect = M.HUDTemplateType.StealthDetectValue,
	dangerHint = M.HUDTemplateType.DangerHint,
	npcName = M.HUDTemplateType.NpcName,
	npcTitle = M.HUDTemplateType.NpcTitle,
	npcIcon = M.HUDTemplateType.NpcIcon,
	npcAIChat = M.HUDTemplateType.NPCAIChatting,
	debug = M.HUDTemplateType.DebugText,
	slotTopInfo = M.HUDTemplateType.SlotTopInfo,
	playerName = M.HUDTemplateType.PlayerName,
	Levitation = M.HUDTemplateType.LevitationBar,
	PlayerNum = M.HUDTemplateType.PlayerIdentifiedNumber,
	TopIcon = M.HUDTemplateType.TopIcon,
	TopText = M.HUDTemplateType.TopText,
	topAnimIcon = M.HUDTemplateType.TopAnimIcon,
	bubble = M.HUDTemplateType.PlayerBubble,
	survival = M.HUDTemplateType.PlayerSurvivalStatus,
	imageBubble = M.HUDTemplateType.PlayerImageBubble,
	allyHpBar = M.HUDTemplateType.AllyHpBar,
	vehicleHpBar = M.HUDTemplateType.VehicleHpBar
}
M.HUDTargetType2Ctrl = {
	[M.HUDTargetType.Enemy] = EnemyHUDCtrl,
	[M.HUDTargetType.Player] = PlayerHUDCtrl,
	[M.HUDTargetType.Npc] = NpcHUDCtrl,
	[M.HUDTargetType.Destruct] = DestructibleHUDCtrl,
	[M.HUDTargetType.SlotEntity] = SlotEntityHUDCtrl,
	[M.HUDTargetType.Vehicle] = VehicleHUDCtrl,
	[M.HUDTargetType.Aether] = AetherHUDCtrl
}
M.OnCreateFunc = {
	[M.HUDTemplateType.EnemyHpBar] = "OnCreateEnemyHpBar",
	[M.HUDTemplateType.EnemyPartShieldBar] = "OnCreateEnemyPartShieldBar",
	[M.HUDTemplateType.DistanceAttackMarker] = "OnCreateDistanceAttackMarker",
	[M.HUDTemplateType.BVB] = "OnCreateBVBTemplate",
	[M.HUDTemplateType.BuffHeadIcon] = "OnCreateBuffHeadIcon",
	[M.HUDTemplateType.EnemyPosition] = "OnCreateEnemyPosition",
	[M.HUDTemplateType.StealthDetectValue] = "OnCreateStealthDetectValue",
	[M.HUDTemplateType.DangerHint] = "OnCreateDangerHint",
	[M.HUDTemplateType.NpcName] = "OnCreateNpcName",
	[M.HUDTemplateType.NpcTitle] = "OnCreateNpcTitle",
	[M.HUDTemplateType.NpcIcon] = "OnCreateNpcIcon",
	[M.HUDTemplateType.NPCAIChatting] = "OnCreateNPCAIChatting",
	[M.HUDTemplateType.DebugText] = "OnCreateDebugText",
	[M.HUDTemplateType.SlotTopInfo] = "OnCreateSlotTopInfo",
	[M.HUDTemplateType.PlayerName] = "OnCreatePlayerName",
	[M.HUDTemplateType.LevitationBar] = "OnCreateLevitationBar",
	[M.HUDTemplateType.PlayerIdentifiedNumber] = "OnCreatePlayerIdentifiedNumber",
	[M.HUDTemplateType.TopIcon] = "OnCreatCommonTopIcon",
	[M.HUDTemplateType.TopText] = "OnCreatCommonTopText",
	[M.HUDTemplateType.TopAnimIcon] = "OnCreatTopAnimIcon",
	[M.HUDTemplateType.PlayerBubble] = "OnCreatPlayerBubble",
	[M.HUDTemplateType.PlayerSurvivalStatus] = "OnCreatPlayerSurvivalStatus",
	[M.HUDTemplateType.PlayerImageBubble] = "OnCreatPlayerImageBubble",
	[M.HUDTemplateType.AllyHpBar] = "OnCreatAllyHpBar",
	[M.HUDTemplateType.VehicleHpBar] = "OnCreatVehicleHpBar"
}
M.DebugTag = {
	["\\xa91(6{\\x91D\\xf09\\xac\\xb6"] = "\\xa91(6{\\x91D\\xf09\\xac\\xb6",
	["pOelB?5"] = "pOelB?5",
	["\\x9b\\xbe\\xb8o\\xeb>"] = "\\x9b\\xbe\\xb8o\\xeb>",
	["\\x8a\\x98$\\xa8~7\\xf1="] = "\\x8a\\x98$\\xa8~7\\xf1=",
	["q[ݶ\\x81\\x9a\\xc5\\xe4"] = "q[ݶ\\x81\\x9a\\xc5\\xe4",
	["[y\\xb9pD\\xbc\\xf7TyTkA"] = "[y\\xb9pD\\xbc\\xf7TyTkA",
	["Kw\\xa1VB\\xb6\\xd6BlTkA"] = "Kw\\xa1VB\\xb6\\xd6BlTkA",
	[")\r"] = ")\r",
	["\\x87\\xb4\\xaef\\xeb>"] = "\\x87\\xb4\\xaef\\xeb>",
	["e\\xbe\\x8c\\xba\\xbb"] = "e\\xbe\\x8c\\xba\\xbb"
}
M.TopAnimType = {
	["\\#sH"] = 1,
	["]+{O"] = 0
}
M.TopAnimTypePriority = {
	[M.TopAnimType.Fans] = 0,
	[M.TopAnimType.Gift] = 1
}
M.HpDebuffType = {
	["a\\xa7\\xa7\\x9b\\xbf"] = 1,
	["T-s^"] = 0
}
M.DisarmDebuffType = {
	[",G\\xa9\\x87\\x8dF"] = 2,
	["8]\\x90\\x80\\xbaH"] = 1,
	["T-s^"] = 0
}
