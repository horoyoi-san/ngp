-- Ananta private-server fastpatch for client 4229938
-- GameSwitch defaults only. Original ClientGameSwitch.lua logic is unchanged.

local M = {}

M.Sync = function(key, value)
    M[key] = value

    gMessageManager:SendMessage(gEventConstants.ON_GM_GAME_SWITCH_CHANGE)
end

M.EnableBuzzCenter = true
M.EnableMall = true
M.EnableMallBundle = true
M.EnableMallRecommend = true
M.EnableMallDirectSale = true
M.EnableCheckIn = true
M.EnableTime = true
M.EnableDossier = true
M.EnableRadiantChest = true
M.EnableCloset = true
M.EnableGachaSystem = true
M.EnableSeasonalBattlePass = true
M.EnableBBChat = true
M.EnableScope = true
M.EnableParty = true
M.EnableSpiritTalent = true
M.EnablePhoto = true
M.EnableMail = true
M.EnablePhone = true
M.EnableFriends = true
M.EnableAchievement = true
M.EnableTutorial = true
M.EnableCityPedia = true
M.EnableNotices = true
M.EnableCustom = true
M.EnableInteractionAction = true
M.EnableDutyTerminal = true
M.EnableCatExpress = true
M.EnableEonBug = true
M.EnableJanitor = true
M.EnableRadioStation = true
M.EnableBubble = true
M.EnableFashionStore = true
M.Enable4SStore = true
M.EnableProfile = true
M.EnableClub = true
M.EnableRanking = true
M.EnableAkashicSystem = true
M.EnablePhotoTemplate = true
M.EnableFirstPhotoTemplate = true
M.EnableThirdPersonPhotoTemplate = true
M.EnableThirdPersonPhoto = true
M.EnablePhotoMoveMode = true
M.EnableNewPhotoTask = true
M.EnableOldPhotoMoreOperationConfig = true
M.EnablePhotoStateTreeSignal = true
M.EnableTimeFreezePhoto = true
M.EnableFocusNpcCamera = true
M.EnableFocusCamera = true
M.EnableActionCamera = true
M.EnableCamera = true
M.EnableMainCamera = true
M.EnableFirstPersonCamera = true
M.EnableGlobalFirstPersonCamera = true
M.IsCameraAllowed = true
M.IsHavePermissionCamera = true
M.ProfilerAetherVehicle = true
M.ProfilerAetherVehicleGO = true
M.ProfilerStaticVehicle = true
M.ProfilerEnableNpcGo = true
M.ProfilerIntersection = true
M.ProfilerIntersectionRender = true
M.ProfilerGadget = true
M.ProfilerDestructible = true
M.ProfilerDynamicGo = true
M.ProfilerRandomEvent = true
M.ProfilerSpoonAgent = true
M.ProfilerEnableMetro = true
M.EnableZoneGraphUndirectLane = true
M.EnableDGTemporaryResource = true
M.EnableGPUScene = true
M.EnableNPCNormalMoveBeta = true
M.EnableIndoor = true
M.EnableECSResponse = true
M.EnableNpcGateway = true
M.EnableNpcDensityMigration1 = true
M.EnableLifeScheduleNpcAlwaysGo = true
M.EnableAetherNpcFixedSpawnPointRule = true
M.EnableNpcUseBelonging = true
M.EnablePedConvertWorthyCheck = true

M.EnableClientZoneClosure = false
M.EnableVoxelSectorControl3 = false

-- 兜底：任何**没有显式定义**的开关一律返回 true（开）。
-- 这份文件是整文件替换客户端 ClientGameSwitch.lua，漏写一个键客户端读到就是 nil（假）
-- 对应功能会被静默关掉，排查极其隐蔽。用 __index 兜底后漏写不再是问题；
-- 要显式关掉某个开关，写在上面（__index 只在键不存在时触发）。
setmetatable(M, {
    __index = function(_, key)
        if type(key) ~= "string" then return nil end
        -- 覆盖前缀说明：
        --   Enable* / Is* / Use*  —— 原就有
        --   Profiler*            —— 2026-09-18 补。GO（GameObject）提升开关全是这个前缀
        --     （ProfilerAetherVehicleGO / ProfilerEnableNpcGo / ProfilerStaticVehicle），
        --     漏掉就是 nil(假) → MassAI·Boid·Aether 实体一个都不提升 →
        --     交通灯、路牌、路灯、NPC、车流**一起**消失。
        -- ⚠️ 不要图省事改成"所有未定义键一律 true"：原作者踩过坑 ——
        --    EnableClientZoneClosure 被兜底成 true 后坐地铁会卡死子区流送。
        if key:sub(1, 7) == "Disable" then return false end
        if key:sub(1, 6) == "Enable" or key:sub(1, 2) == "Is"
            or key:sub(1, 3) == "Use" or key:sub(1, 8) == "Profiler" then
            return true
        end
        return nil
    end,
})

gGameSwitch = M

-- ★ 同时把 C# 侧 UX.GameSwitch 的静态开关置位。
--   gGameSwitch 只是给 Lua 用的镜像；C# 代码（AetherCity / MassAI / MassBoid 的 GO 提升）
--   读的是 UX.GameSwitch 的静态字段，而那些字段**只由 SyncGameSwitchToClient 赋值**，
--   私服从来没发过这个包，所以它们全是 false → 一个实体都不提升成 GameObject。
--   这里显式置位；用 pcall 包住，绑定不存在也只是静默跳过，不影响其它逻辑。
do
    local csSwitchOn = {
        "EnableBuzzCenter",
        "EnableMall",
        "EnableMallBundle",
        "EnableMallRecommend",
        "EnableMallDirectSale",
        "EnableCheckIn",
        "EnableTime",
        "EnableDossier",
        "EnableRadiantChest",
        "EnableCloset",
        "EnableGachaSystem",
        "EnableSeasonalBattlePass",
        "EnableBBChat",
        "EnableScope",
        "EnableParty",
        "EnableSpiritTalent",
        "EnablePhoto",
        "EnableMail",
        "EnablePhone",
        "EnableFriends",
        "EnableAchievement",
        "EnableTutorial",
        "EnableCityPedia",
        "EnableNotices",
        "EnableCustom",
        "EnableInteractionAction",
        "EnableDutyTerminal",
        "EnableCatExpress",
        "EnableEonBug",
        "EnableJanitor",
        "EnableRadioStation",
        "EnableBubble",
        "EnableFashionStore",
        "Enable4SStore",
        "EnableProfile",
        "EnableClub",
        "EnableRanking",
        "EnableAkashicSystem",
        "EnablePhotoTemplate",
        "EnableFirstPhotoTemplate",
        "EnableThirdPersonPhotoTemplate",
        "EnableThirdPersonPhoto",
        "EnablePhotoMoveMode",
        "EnableNewPhotoTask",
        "EnableOldPhotoMoreOperationConfig",
        "EnablePhotoStateTreeSignal",
        "EnableTimeFreezePhoto",
        "EnableFocusNpcCamera",
        "EnableFocusCamera",
        "EnableActionCamera",
        "EnableCamera",
        "EnableMainCamera",
        "EnableFirstPersonCamera",
        "EnableGlobalFirstPersonCamera",
        "IsCameraAllowed",
        "IsHavePermissionCamera",
        "ProfilerAetherVehicle",
        "ProfilerAetherVehicleGO",
        "ProfilerStaticVehicle",
        "ProfilerEnableNpcGo",
        "ProfilerIntersection",
        "ProfilerIntersectionRender",
        "ProfilerGadget",
        "ProfilerDestructible",
        "ProfilerDynamicGo",
        "ProfilerRandomEvent",
        "ProfilerSpoonAgent",
        "ProfilerEnableMetro",
        "EnableZoneGraphUndirectLane",
        "EnableDGTemporaryResource",
        "EnableGPUScene",
        "EnableNPCNormalMoveBeta",
        "EnableIndoor",
        "EnableECSResponse",
        "EnableNpcGateway",
        "EnableNpcDensityMigration1",
        "EnableLifeScheduleNpcAlwaysGo",
        "EnableAetherNpcFixedSpawnPointRule",
        "EnableNpcUseBelonging",
        "EnablePedConvertWorthyCheck",
    }
    local csSwitchOff = {
        "EnableClientZoneClosure",
        "EnableVoxelSectorControl3",
    }
    for i = 1, #csSwitchOn do
        pcall(function() CS.UX.GameSwitch[csSwitchOn[i]] = true end)
    end
    for i = 1, #csSwitchOff do
        pcall(function() CS.UX.GameSwitch[csSwitchOff[i]] = false end)
    end
end
