# 手机 App 内部内容（千年虫 / 蓝猫物流 / 伪人档案）根因分析与修复

> 日期：2026-09-23
> 用户报的三个问题（原文）：
> 1. 「西摩的专属 app 千年虫进入后要求输入名称，输入后游戏卡在界面未死机，界面退不出去。」
> 2. 「塔菲的蓝猫物流 app 手机界面上没有。」
> 3. 「app 内有部分内容需要解锁，比如伪人档案等等，修改一下让他们默认全部解锁」

---

## 0. 结论速览

| # | 现象 | 根因 | 修复 |
|---|---|---|---|
| 1 | 千年虫要求输入名称，输入后卡界面退不出去 | ① 从不下发 `SyncHackerJobInfo`(64189208) ⇒ 客户端 `HackManager.HackerSpiritInfo[cardId]` 是 nil ⇒ `CheckIsNew` 判定"新用户"、弹输入框并进 `isRename=1`；② `AskChangeHackerName`(63975191) **没有任何处理器**（服务端日志 `unimplemented AskChangeHackerName -> typed-default void 0b`），客户端拿到回复后 `CheckIsNew()` 又回到"新用户"⇒ **2 秒一次死循环重试，界面出不去** | 注册并实现 `AskChangeHackerName` / `AskReadHackerNewPost` / `AskAcceptHackerPostTask`；登录/进世界下发 `SyncHackerJobInfo`（含代号 + 20 条帖子）；改名后立即回推 |
| 2 | 塔菲的蓝猫物流（Cat Express）不在手机界面 | 手机图标**唯一**门控是客户端 `LX6.Utils.MainPhoneUtils.CheckAppCanShow(appId)`，其中 `CheckJobCanShow` 要求当前角色的 `SpiritJobInfo.AvailableJobs` 里存在职业大类 ∈ `MobileMenuSGuiConfig.JobClassIdList`。`Cat Express(15)` 要 `[11300005]`（Truck Driver），而塔菲 `DefaultUrbanJob = 100`（无业）⇒ 以前 `AvailableJobs` 空 ⇒ 图标不显示 | 新增**第二套**角色→职业映射：`UrbanJobAvatarConfig`（`Avatar<jobId>` 非 0）。塔菲 → 501/502/503 → 大类 11300005；`AvailableJobs` 同时补上无业 100 |
| 3 | 伪人档案等 App 内内容锁住 | `PolicePanelManager.fakeFileInfo[spiritId]` 只由 `SyncSpiritPoliceJobInfo`(64349458) / `SyncPoliceFakeFileInfo`(64618923) 填充，两个包都不发 ⇒ `CheckFakeInfoState(id, Unlock)` 永远 `None` ⇒ 27 条全锁 | 下发 `SyncPoliceFakeFileInfo`，把 `PoliceFakeFileConfig` 的 27 条（里希 15021021 专属）全部置为 `PoliceFakeFileState.Unlock`(8) |

顺带修掉一个隐藏 bug：**所有"无业"角色每帧刷 `该角色职业配置不存在！spirit:,xxx, jobId:,0`**
（`CurrentJob` 写 0 导致 `UrbanJobConfig.GetConfig(0)` 返回 nil）。现在无业角色 `CurrentJob = 100`。

---

## 1. 客户端 App 显示门控全链路（**问题 2 的关键**）

客户端 lua（CBT2 反混淆转储 `AnantaTestGameServer/tools/3_deobfuscated/1085_LX6_Utils_MainPhoneUtils.lua`，
与 CBT3 的 `MobileMenuSGuiConfig` 字段集完全一致，可作等价参考）：

```lua
function M.GetPhoneAppIdList()
    for i = 0, MobileMenuSGuiConfig.count - 1 do
        local cfg = MobileMenuSGuiConfig.LoadAt(i)
        if not cfg.IsBottom and M.CheckAppCanShow(cfg.Id) then ... end
    end
end

function M.CheckAppCanShow(appId)
    if not cfg.IsShow then return false end                       -- ①
    if table.contains(GameConfig.HideMainCubeApps, panelId) then return false end   -- ② CBT3 无 PanelId，空转
    if #cfg.NpcCultivationIdList > 0 and not table.find(cfg.NpcCultivationIdList, M.GetNpcCultivationId()) then
        return false end                                          -- ③ 当前角色的修炼 id
    if table.find(cfg.LockNpcCultivationIdList, M.GetNpcCultivationId()) then return false end  -- ④
    if cfg.TemporaryNpcConfig and (no spirit or cfg.Invisible) then return false end            -- ⑤
    if not M.CheckJobCanShow(appId) then return false end          -- ⑥ ★ 服务端状态
    return M.CheckAppSystemUnlocked(appId) and M.CheckAppCanUse(appId)  -- ⑦ 系统解锁 / 特例
end

function M.CheckJobCanShow(appId)
    local jobClassIdList = cfg.JobClassIdList
    if jobClassIdList and #jobClassIdList > 0 then
        for _, jobId in ipairs(gSpiritJobManager.GetCurSpiritAvailableJobIdList()) do
            local jobClassId = LTConfig.UrbanJobConfig.GetConfig(jobId).JobClass
            if table.contains(jobClassIdList, jobClassId) then return true end
        end
        return false
    end
    return true
end
```

- `M.GetNpcCultivationId()` = 拿 `gBattleSpiritMgr.currentSpiritTemplateId` 去 `NpcCultivationConfig`
  里按 `FightSpiritID` 反查 `Id`（纯客户端，服务端管不到）。
- `gSpiritJobManager.GetCurSpiritAvailableJobIdList()` 读的是
  **`SpiritInfo.SpiritJobInfo.AvailableJobs`（服务端 `SyncSpiritJobInfo` / 登录包下发）**，
  并且**过滤掉 `UrbanJobConfig.Jobless = 100`**。
- **`InstalledApps` 完全不参与 `CheckAppCanShow`**（客户端 lua 里根本没有 `installedApps` 的引用），
  所以"把 App 塞进 `InstalledApps`"对"图标是否出现"没有帮助 —— 这是上一轮修复的盲区。

### 相关 App 的门控一览（CBT3 实测）

| App Id | 名称 | `SystemIdList` | `NpcCultivationIdList` | `JobClassIdList` |
|---|---|---|---|---|
| 15 | Cat Express（蓝猫物流） | `[305]` 货车司机 | — | **`[11300005]`** |
| 22 | Cat Express（蓝猫物流） | — | `[91050014]` 塔菲 | — |
| 20 | EonBug（千年虫） | `[304]` 黑客 | — | `[11300004]` |
| 21 | Duty Terminal | `[30302]` 巡卫官 APP | — | `[11300003]` |
| 31 | Mimic Database（伪人档案） | `[320]` 伪人档案 app | — | `[11300003]` |
| 12 | Bubble | `[231]` | `[91050025, 91050026]` 主角 | — |
| 34 | Theme Party | `[160]` | `[91050025, 91050026]` | — |
| 58 | 惊喜礼物 | `[337]` | `[91050025, 91050026]` | — |
| 59 | 重霄食谱 | — | `[91050037]` 成娘 | `[11300020]` |

`gameplay.systems.unlockAll = true` 已经把 `SystemUnlockConfig` 全部 195 个 id 解锁，
所以 ⑦ 这一关一直是过的；**卡住的从来都是 ⑥**。

---

## 2. 角色 → 职业：**两套**映射，缺一不可

| 来源 | 覆盖 | 例子 |
|---|---|---|
| `FightSpiritConfig.DefaultUrbanJob`（→ `UrbanJobConfig.Id`） | 里希 301 / 赛默 401 / 嘉姆 1301 / 成娘 2000 / 梅卡妮卡 10；其余 101 个角色是 `100` 无业 | 里希 → NCCA Officer(11300003) |
| **`UrbanJobAvatarConfig`**（字段名 `Avatar<jobId>`，值非 0 即拥有） | 本 build 只有 3 行 | **塔菲 15020992 → 501/502/503 → Truck Driver(11300005)**；安诺尼姆 15021038 → 601；班西 15020991 → 1/2/3 |

```
UrbanJobAvatarConfig 第 1 行：
{"Id":1,"SpiritId":15020992,"Avatar1":0,"Avatar2":0,"Avatar3":0,
 "Avatar501":28000037,"Avatar502":28000037,"Avatar503":28000037,
 "Avatar601":0,"Avatar504":28000037}
```

⇒ 塔菲的职业是 **501 Trainee Driver（大类 11300005）**，`DefaultUrbanJob` 那份给不出来。
注意 `Avatar504` 非 0 但 `UrbanJobConfig` 里没有 504，所以要按 `JobLevel(jobId) is not null` 过滤。

### `CurrentJob` 必须是合法 id

客户端 `SwapCharacterListPanelStore:RefreshJobIcon`：

```lua
local jobId = jobInfo.CurrentJob
if jobId == Jobless then
    for i, v in pairs(jobInfo.AvailableJobs) do
        if i ~= Jobless then jobId = i; break end     -- 有真职业就显示它的图标
    end
end
if jobId == Jobless then jobsIcon:SetActive(false)
else
    local jobCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
    if not jobCfg then
        print_error("该角色职业配置不存在！spirit:", ..., " jobId:", jobId)   -- ★ 每帧刷屏
        return
    end
end
```

以前无业角色 `CurrentJob = 0` ⇒ `GetConfig(0)` = nil ⇒ 每帧一条 `jobId:,0` 错误日志。
现在统一写 `100`（`LTConfig.UrbanJobConfig.Jobless`）。

同时 `CurrentJob = 100` 让 `DeliveryAppPanelStore` 的「接取职业」按钮显示
（`takeJobControl = selectedJobId == currentJobId and Hide or Show`），塔菲因此能在蓝猫物流里接单。

---

## 3. 黑客论坛（千年虫 EonBug）

### 3.1 客户端流程

`HackerBBSMainPanelStore`：

```lua
function M:CheckIsNew()
    local cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
    local info = gHackManager.HackerSpiritInfo[cardId]        -- ← 只由 SyncHackerJobInfo 填
    if info and info.HackerName and info.HackerName ~= "" then
        self.name = info.HackerName; self.rank = info.Rank
        self:ActivateInputField(); self.bindData.isNew = 0
    else
        self.rank = 0; self.name = ""; self.bindData.isNew = 1   -- ← "新用户"，弹输入框
    end
end

function M:OnFinishRenameBtnClick()
    self.inputName = self.bindData.inputNameFirst.text
    self:CheckName(self.inputName, function ()
        gClientToGameDelegate:AskChangeHackerName(self.inputName).Callback = function (err, data)
            if err == MessageConfig.Ok then
                self.bindData.isRename = 0                        -- ← 只有这里能退出改名态
                self.name = self.inputName
                gNewGuideMgr:NotifySignal(EGuideSignal.SetHackerName)
                self:CheckIsNew()                                  -- ← 这里又读 HackerSpiritInfo
            else
                self.bindData.isRename = 0
            end
        end
    end)
end
```

### 3.2 真实证据（服务端日志）

`logs/console-20260923-094545.log`：

```
[09:48:30] -> rpc AskChangeHackerName [0x03D02F17] #-2104891357 10b
[09:48:30] ! [RPC4229938] unimplemented AskChangeHackerName -> typed-default void 0b
[09:48:30] <- ret AskChangeHackerName #-2104891357 e=0 0b
[09:48:32] -> rpc AskChangeHackerName #-2104891356 10b
...
[09:51:44] -> rpc AskChangeHackerName #-2104891347 10b
```

- 一共 **9 次**，间隔 ~2 秒，invoke id 递减 ⇒ 客户端在**死循环重试**。
- 服务端回的是 `e=0` + 0 字节（`AskChangeHackerName` 声明就是 `UXRPCTask` 无返回值，
  `ux_game_all.dump.cs:3228 public abstract UXRPCTask AskChangeHackerName(string name);`）。
- 客户端拿到 `Ok` 后走 `self:CheckIsNew()`，因为 `HackerSpiritInfo[cardId]` 仍然是 nil，
  **又变回 `isNew = 1`** ⇒ 改名态立刻重建 ⇒ 界面出不去。
- **客户端 `Player.log` 里没有一条 Lua 错误** —— 只看客户端日志会得出"没事"的错误结论，
  这一轮是**服务端日志（重试计数）**才定位到根因。

### 3.3 线格式（权威：`ux_rpc/ux_all.il2cpp.h`）

```c
struct UX_Game_SpiritHackerJobInfo_Fields {   // TypeDefIndex 33375
    System_String_o* HackerName;
    Dictionary<uint, HackerPostInfo>* PostInfos;
    uint32_t Rank;
};                                            // ★ 只有 3 个字段，没有 DailyCounts

struct UX_Game_HackerPostInfo_Fields {        // TypeDefIndex 33376
    uint32_t Id;
    int32_t  State;                           // ★ int32（4 字节），不是 byte
    bool     HaveRead;
};
```

`SyncHackerJobInfo` 的客户端签名（dump 里就有，**没有 spiritId**）：

```
ux_game_all.dump.cs:9620    public abstract void SyncHackerJobInfo(SpiritHackerJobInfo hackerJobInfo);
ux_game_all.dump.cs:161845  public const int IGameToClient_SyncHackerJobInfo = 64189208;
```

⚠️ **`Ananta.Proxy/proxy/lua/RPCSerializeAuto.lua` 是旧 build**：它的 `Auto.Reader[282]` 比本 build
**多一个 `DailyCounts`**（`Auto.WriteSpiritHackerJobInfo` 也写了 4 个字段）。
本 build 里 `grep -c HackerDailyCounts ux_game_all.dump.cs` = **0**，该类根本不存在。
照旧 lua 写会多 5 个字节 ⇒ 客户端 `deserialize failed`。**以 dump 为准。**

---

## 4. 伪人档案（Mimic Database）

### 4.1 客户端

`PolicePanelManager`：

```lua
function M:CheckFakeInfoState(id, targetState)
    local info = self:GetCurrentFakeFileInfo()
    local state = info and info.UnlockFileInfoDict[id] or FakeFileState.None
    return state == targetState            -- CBT3 里 UnlockFileInfoDict 的值是 SinglePoliceFakeFileInfo
end

function M:GetMainFakeList()               -- 列表本身来自配置
    for i = 0, FakeFileConfig.count - 1 do
        if cfg.FightSpiritId == self.tid then table.insert(ret, { id = cfg.Id }) end
    end
end

function M:GetMainFakeInfo(fileId)
    return { isUnlock = self:CheckFakeInfoState(fileId, FakeFileState.Unlock), ... }
end
```

`fakeFileInfo[spiritId]` 只由 `OnSpiritPoliceJobInfoSync`（`SyncSpiritPoliceJobInfo`）
或 `OnSyncPoliceFakeFileInfo`（`SyncPoliceFakeFileInfo`）填充。
两个包都不发 ⇒ `UnlockFileInfoDict` 空 ⇒ 27 条全 `None`（锁）。

### 4.2 线格式

```c
struct UX_Game_PoliceFakeFileInfo_Fields {            // TypeDefIndex 33381
    Dictionary<uint, SinglePoliceFakeFileInfo>* UnlockFileInfoDict;
    List<PoliceFakeClueAgentInfo>*              HistoryClueAgentInfoList;
};
struct UX_Game_SinglePoliceFakeFileInfo_Fields {      // TypeDefIndex 33382
    uint8_t  State;                                   // ★ byte
    uint32_t InterrogationTime;
};
struct UX_Game_PoliceFakeClueAgentInfo_Fields {       // TypeDefIndex 33383
    uint32_t AgentId; bool IsRead; uint32_t ProvideClueTime;
};
```

`PoliceFakeFileState`（底层 **byte**，位标志）：
`None=0 / CanTraceTask=1 / AcceptTask=2 / SubmitTask=4 / Unlock=8 / RewardTaken=16`。

`SyncPoliceFakeFileInfo`(64618923) 客户端 reader：`spiritId:uint32` + `PoliceFakeFileInfo(Complex)`。

`PoliceFakeFileConfig` 27 行**全部是 `FightSpiritId = 15021021`（里希）**，
所以这个 App 的内容只对里希有意义。

---

## 5. 实现清单

| 文件 | 变更 |
|---|---|
| `Ananta.RpcTypes/.../Auto/PhoneAppContentContracts.cs` | **新增**：`SpiritHackerJobInfo`(3 字段) / `HackerPostInfo`(State 为 int32) / `PoliceFakeFileInfo` / `SinglePoliceFakeFileInfo` / `PoliceFakeClueAgentInfo`。`UnlockFileInfoDict` 与 `HistoryClueAgentInfoList` 用 **`UxCountEncoding.Int32`**（客户端是 `Base.ReadDict` / `Base.ReadList`，不是 7Bit） |
| `Ananta.RpcTypes/.../Methods/Game/PhoneAppContentMethods4229938.cs` | **新增**：`AskChangeHackerName4229938{name}` / `AskReadHackerNewPost4229938{postId}` / `AskAcceptHackerPostTask4229938{postId}` / `SyncHackerJobInfo4229938{hackerJobInfo}` / `SyncPoliceFakeFileInfo4229938{spiritId, policeFakeFileInfo}` |
| `Ananta.Handlers/Game/GameRouter.PhoneAppContent.cs` | **新增**：3 个处理器 + `PushHackerJobInfoAsync` / `PushPoliceFakeFilesAsync` / `PushAllPhoneAppContentAsync` |
| `Ananta.Handlers/Game/GameRouter.cs` | 注册 `AskChangeHackerName` / `AskReadHackerNewPost` / `AskAcceptHackerPostTask` |
| `Ananta.Handlers/Game/GameRouter.Baseline.cs` | 新基线项 `phoneapp`（`PushAllPhoneAppContentAsync`） |
| `Ananta.Handlers/Game/GameRouter.SpiritContent.cs` | `PushJobInfoAsync` 用 `EffectiveJobIds` + 无业 100；`ResolveJobLevelId` 认 avatar 职业；日志/报告加 `avatarJobIds` / `effectiveJobIds` / `fakeFiles` |
| `Ananta.Core/ClientData/.../SpiritContentCatalogRepository.cs` | 新增 `UrbanJobAvatarConfig` / `PoliceFakeFileConfig` / `HackerPostConfig` 载入；`AvatarJobIds` / `EffectiveJobIds` / `EffectiveJobClasses` / `FakeFilesForSpirit` / `FakeFileSpiritIds` / `AllHackerPosts`；`AppsForSpirit` 改用 `EffectiveJobClasses` |
| `Ananta.Core/Protocol/.../RuntimePayloadFactory.cs` | `ApplySpiritContent4229938` 职业段重写（两套映射 + 无业 100 + `UrbanJobConfigJobless` 常量） |
| `Ananta.Core/State/PlayerState.cs` | 新增 `HackerName` / `HackerReadPosts` / `HackerPostStates` / `PoliceFakeFilesUnlocked` |
| `Ananta.Core/Configuration/PrivateServerConfig.cs` | `SpiritContentSettings` 新增 `GrantAvatarJobs` / `HackerName` / `HackerRank` / `UnlockHackerPosts` / `HackerPostState` / `HackerPostsRead` / `UnlockPoliceFakeFiles` |
| `Ananta.App/DebugApiServer.cs` + `.Content.cs` | 新增 `GET /api/spirit/phoneapp`（清单 + 两个字节探针）、`POST /api/spirit/phoneapp/push`（补推）；`jobSummary` 加 `availableJobs` / `availableClasses`；`payload/login` 加 `phoneAppProbe` |
| `Ananta.App/DebugPanel/index.html` | 新增「手机 App 内部内容」卡片 + `phoneAppLoad` / `phoneAppPush`；「角色专属内容」输出加职业来源 2 / 伪人档案 |
| `ClientData/4229938/Configs/` | 补入 `PoliceFakeFileConfig.json`(27) / `HackerPostConfig.json`(20) / `HackerRankConfig.json`(10)（`UrbanJobAvatarConfig.json` 已有） |
| `config/private-server.json` | `gameplay.spiritContent` 新增 7 个键 |

---

## 6. 验证

```
bash tools/build_check.sh      →  0 警告 0 错误；audit exit=0（569 契约类 / 3 个多态字段核对通过）

启动日志：
[SPIRITCONTENT] 角色专属内容已载入: spirits=109 styles=88 characteristics=48 apps=57(auto=10)
  jobLevels=49 jobClasses=20 spiritTalents=18 talentEffects=144 talentTrees=18 talentNodes=623
  avatarJobs=3 fakeFiles=27(1角色) hackerPosts=20
```

`GET /api/payload/login`（382130 字节，比修复前 +1506）：

| 角色 | CurrentJob | availableJobs | availableClasses | 结论 |
|---|---|---|---|---|
| 15020992 塔菲 | 100 无业 | `[100,501,502,503]` | `[11300005]` | Cat Express 15 的门控通过 ✔ |
| 15021021 里希 | 301 NCCA Officer | `[100,301]` | `[11300003]` | Duty Terminal 21 + 伪人档案 31 ✔ |
| 15021023 赛默 | 401 Professional Hacker | `[100,401]` | `[11300004]` | EonBug 20 ✔ |
| 15021043 尤志 | 100 无业 | `[100]` | `[]` | 不再刷 `jobId:0` ✔ |

`GET /api/spirit/content?spiritId=15020992`：

```
defaultJobId=100 无业   jobClassId=11300005 Truck Driver   jobSystemUnlock=305
avatarJobIds=[501,502,503,504]   effectiveJobIds=[501,502,503]   effectiveJobClasses=[11300005]
apps=[15 Cat Express, 22 Cat Express]
talentTrees=[99900009 Truck Driver(23 节点), 99900022(45 节点)]
```

`GET /api/spirit/phoneapp`：

```
hackerSyncProbe   mid=64189208  299 字节
  hexHead = FF09 "ZeroCool" FF14000000 01000000 FF 01000000 00000000 00 03000000 FF ...
             ↑代号        ↑Dict int32 计数=20   ↑key=1     ↑Id=1  ↑State=0  ↑HaveRead
policeSyncProbe   mid=64618923  285 字节
  hexHead = DD33E500 FF FF1B000000 01000000 FF 08 00000000 00 02000000 FF 08 ...
             ↑spiritId=15021021  ↑27 条  ↑key=1  ↑State=8  ↑InterrogationTime=0
```

字节数与手工计算完全吻合：
- 黑客：`1+8`（代号）+ `1+4`（Dict 头）+ `20×(4+1+4+4+1)` + `4`（Rank）= 299
- 警察：`4`（spiritId）+ `1`（Complex 标记）+ `1+4`（Dict 头）+ `27×(4+1+1+4)` + `1+4`（空 List）= 285

---

## 7. 证据来源与坑

| 结论 | 证据等级 |
|---|---|
| `CheckAppCanShow` 是手机图标唯一门控、`InstalledApps` 不参与 | **A** 客户端 lua（CBT2 反混淆转储，字段集与 CBT3 一致） |
| `CheckJobCanShow` 读服务端 `AvailableJobs` | **A** 同上 + `SpiritJobManager.lua` |
| 塔菲职业 = 501/11300005 | **A** `UrbanJobAvatarConfig` 配置 + `UrbanJobJobClassConfig` |
| 千年虫卡住 = `AskChangeHackerName` 无处理器 + 无 `SyncHackerJobInfo` | **A** 服务端日志 9 次重试 + 客户端 lua 流程 |
| `SpiritHackerJobInfo` 只有 3 个字段 | **A** `ux_all.il2cpp.h` + `ux_game_all.dump.cs`（`HackerDailyCounts` 类不存在） |
| `PoliceFakeFileInfo` 字段/计数编码 | **A** `ux_all.il2cpp.h` + 旧 lua `Auto.Reader[343]`（此处两者一致） |

### 本轮踩到的坑

1. **`InstalledApps` 不是显示门控**。上一轮把 App 塞进 `InstalledApps` 只解决了"应用商店显示已下载"，
   对"图标是否出现"没用。真正决定的是 `CheckAppCanShow` 里的**职业大类**。
2. **`DefaultUrbanJob` 不是唯一的角色→职业映射**。`UrbanJobAvatarConfig` 才是塔菲那一套。
3. **`ReadUInt32` 遇到 JSON 布尔会抛异常**：`PoliceFakeFileConfig.NeedActive` 是 `true`，
   用 `ReadUInt32(row, "NeedActive")` 会 `InvalidOperationException: ... type 'Number' ... type 'True'`，
   整个表**静默载入 0 行**（`ForEachRecord` 的 catch 只打一行 `读取 xxx 失败`）。
4. **客户端日志可能"干净"**：这一轮 `Player.log` 里没有任何 Lua 错误，
   只有**服务端日志的重复 `-> rpc AskChangeHackerName`** 暴露了死循环。
   ⇒ 排障必须**两边都看**，并且注意"同一请求 2 秒一次"这种模式。
5. **旧 build 的 lua 不能当权威**：`Auto.Reader[282]` 多一个 `DailyCounts` 就是活例。

---

## 8. 逃生阀与未验证项

- **逃生阀**：`gameplay.spiritContent.hackerName = ""` + `unlockHackerPosts = false`
  ⇒ `PushHackerJobInfoAsync` 直接跳过（不打这个包）。
  万一 `SpiritHackerJobInfo` 的字段数在本机与 dump 不一致（客户端会报
  `deserialize failed methodId=64189208`），关掉这两项就回到"只靠 `AskChangeHackerName` 处理器"的安全状态 ——
  那一条本身就足以让改名界面退出去。
- **未验证**：`SyncHackerJobInfo` 的客户端 reader 只能从 dump 反推（CBT3 的 lua 转储不存在，
  旧 build lua 在这一项上过时）。需要在真机进一次千年虫确认：
  1. 面板不再弹输入框（`HackerName` 已下发）；
  2. 若仍弹，输入并确认后**界面能退出**；
  3. 客户端日志无 `deserialize failed methodId=64189208`。
- **未做**：伪人档案的**跟踪/审讯流程**（`AskPoliceFakeFileAcceptTaskEvent` 63056330、
  `AddPoliceChargingProgress` 63155900、`SyncSpiritPoliceCaseInfos` 64848107、
  `SyncSpiritPoliceViolationInfos` 64812240）—— 只做了"条目默认解锁"，
  点「跟踪」之后的案子流程仍然没有服务端支持。
- **未做**：黑客论坛的接单流程（`AskAcceptHackerPostTask` 只记状态，
  没有对应的任务链 / `NotifyNewHackerPosts` 推送）。
- **未做**：电脑 App（`ComputerUnlockInfo.UnlockEmails` / `UnlockFiles`）
  与重霄食谱（`ChefUnlockInfo.RecipeDict`）的默认解锁 —— 结构已定位（TypeDefIndex 32504/32505），
  但这一轮没有证据说明用户指的"等等"包含它们。
