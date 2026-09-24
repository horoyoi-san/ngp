# 手机 App 内容补全（NCCA 拘捕记录 / 执勤面板 / 被门控的图标）—— 根因分析与修复

> 2026-09-23 第 9 轮（下半） · build 4229938
> 用户：「手机app界面的内容你也看下 我们现在app界面的内容没有截图里那么多，帮我补全」
> 附三张图：① EonBug 骇客 App ② NCCA 拘捕记录 ③ NCCA 执勤面板

---

## 0. 结论速览

| 图 | 界面 | 数据来源 | 状态 |
|---|---|---|---|
| ① | **EonBug（千年虫）骇客 App**：`#1`、黑客论坛、召唤车辆、`// TITLE:黑客工具` → 蜂形机器人 / 黑客无人机 | 菜单**全部来自客户端配置** `HackerMenuConfig`（本 build 只有 4 条：EonBug Forum / Spider Bot / Hacker Drone / **大停电**）；`#1` 来自 `SyncHackerJobInfo.Rank`（已发） | ⚠️ 截图第 4 条是「召唤车辆」而配置里是「大停电」⇒ **版本内容差异**，服务端加不了条目 |
| ② | **NCCA 拘捕记录**：哈利 / 藤原一马、日期、状态「待讯问」、违规事项、+500、前往讯问 | **纯服务端** `SyncSpiritPoliceCaseInfos`(64848107) | ✅ 已修 |
| ③ | **NCCA 执勤面板**：巡逻犬 / 直升机搜索 / 战术支援、巡逻载具、`0/0` `Lv16`、巡逻督察 / 案件记录 / 结束执勤 | **纯服务端** `SyncPoliceDispatchInfos`(64393704) + `SyncPoliceServiceData`(64502222) | ✅ 已修 |
| — | 主屏 **4 个 App 图标**永远不显示 | `MobileMenuSGuiConfig.JobClassIdList` 门控，名册里没人持有那个职业大类 | ✅ 已修 |

自检：`bash tools/run.sh --probe-jobability`（exit 0）+ `/api/spirit/phoneapp` 的 `policeAppProbe`。

---

## 1. ☠️ 先纠正上一轮的一个错误结论

上一轮（`职业能力互动选项_根因分析与修复.md` §5）我写过：

> 「CBT3 的警察**数据模型**大幅缩水 …… `SpiritPoliceJobInfo` / `PoliceCaseInfo` /
> `PoliceViolationInfo` / `PoliceDispatchInfo` / `PoliceDutyBasicInfo` **全部不存在**
> （`dump.cs` / `base/il2cpp.h` 里搜不到）」

**这是错的。** 我只查了 C# 的 `IDMAP1 LX6-Service-*` 那一层，漏掉了 **Lua 层**。

用「两层判据」重查（见 SKILL.md「客户端真正实现了哪些 S2C」）：

| 方法 | id | `midToExportOption` | `midToReader` | CBT2 lua 函数体 |
|---|---|---|---|---|
| `SyncSpiritPoliceJobInfo` | 64349458 | LuaOnly | ✓ | `1206:1428` |
| `SyncPoliceServiceData` | 64502222 | LuaOnly | ✓ | `1206:1423` |
| `SyncSpiritPoliceCaseInfos` | 64848107 | LuaOnly | ✓ | `1206:1432` |
| `SyncSpiritPoliceViolationInfos` | 64812240 | LuaOnly | ✓ | `1206:1436` |
| `SyncPoliceDispatchInfos` | 64393704 | LuaOnly | ✓ | `1206:1440` |
| `SyncPoliceDailyIncidentInfo` | 64829293 | LuaAndCSharp | ✓ | — |
| `SyncPoliceRPSCardInfo` | 64816304 | **CSharpOnly** | **无** | — （☠️ 别发） |

⇒ **客户端全都实现了**，服务端发就有效。

> **教训**：`IDMAP1` 只覆盖 C# 层。判「客户端有没有处理器」必须**两条腿都查**：
> `IDMAP1`（C#）+ `midToExportOption`（Lua）。只查一条会得到"不存在"的错误结论。

---

## 2. 载荷结构（权威 = `RPCDeserializeAuto.lua`）

### 2.1 `SyncSpiritPoliceCaseInfos`(64848107) —— 图②

```lua
-- RPCDeserializeAuto.lua:4005
self.midToReader[64848107] = function (reader)
    local spiritId = reader:ReadUInt32()
    local cases = Base.ReadList7Bit(reader, function (r)
        return Base.ReadComplex(r, Auto.Reader[377])   -- ← 每条一个非空标记
    end)
    return spiritId, cases
end
```

`PoliceCaseInfo`（`Auto.Reader[377]`，**17 字段**）：

| # | 字段 | 类型 | 界面用途 |
|---|---|---|---|
| 1 | `Time` | u32 | `DateFormat("%d-%02d-%02d")` → 日期 |
| 2 | `NpcId` | u32 | `AgentConfig.GetConfig()` → **名字 + 头像** |
| 3 | `Fines` | `List<int32>` | `FineConfig.GetConfig().Title` → **违规事项** |
| 4 | `Sentence` | **i32** | `GetStateStr`：`0` ⇒ 89901145+89901147「待讯问」 |
| 5 | `Drops` | `List<int32>` | — |
| 6 | `RewardTaken` | bool | — |
| 7 | `BonusDrops` | `List<int32>` | `GetAwardByDropId` → **`+500` 那个奖励** |
| 8 | `Id` | **u64** | `caseDict` 的键 |
| 9 | `IsFakePerson` | bool | — |
| 10 | `InterrogationInfo` | Complex | 界面不读 ⇒ **写 null 跳过整棵子树** |
| 11 | `NpcImprisonStatus` | byte | — |
| 12–14 | `FinedCrimes` / `NoCheckCrimeList` / `NoIssuedBonusDrops` | `List<int32>` | — |
| 15 | `HasUnlockClue` | bool | — |
| 16 | `SourceType` | byte | — |
| 17 | `CrimeDefaultItems` | `List<int32>` | — |

### 2.2 `SyncPoliceServiceData`(64502222) —— 图③ 的 `0/0`

`spiritId + serviceData(Complex) + weeklyServiceData(Complex) + stopPatrol(bool)`

`PoliceServiceData`（`Auto.Reader[327]`，7 字段）：
`DispatchTimes / PatrolTimes / ArrestTimes / FineCount / TotalDrops / LastUpdateTime / CarFineCount`

### 2.3 `SyncPoliceDispatchInfos`(64393704) —— 图③ 的三个按钮

`spiritId + dict7<u32, PoliceDispatchInfo>`

`PoliceDispatchInfo`（`Auto.Reader[310]`，5 字段）：
`Id / NextAvailableTime / IsTemp / TempEventId / TodayArrestSupportTimes`

### 2.4 ☠️ `ReadList` ≠ `ReadList7Bit`

| Lua | 计数编码 | 空集合字节 |
|---|---|---|
| `Base.ReadList` / `Base.ReadDict` | **int32** | `FF 00 00 00 00`（5 字节） |
| `Base.ReadList7Bit` / `ReadDict7Bit` | **varint(n+1)** | `FF 01`（2 字节） |

⇒ 契约里必须写对：
`[UxCollection(Count = UxCountEncoding.Int32)]` vs `Int7`。
`PoliceCaseInfo` 里 7 个 List 字段**全是 int32**，写错整包长度就不对。

---

## 3. 数据：**逐条对上截图**

### 3.1 案件里的两个人就在配置里

| 截图 | `AgentConfig.Id` | 名字 | `HeadIcon` |
|---|---|---|---|
| 哈利 | **40650550** | 哈利？ | 28002113 |
| 藤原一马 | **4065053** | Fujiwara Kazuma | 28030385 |

### 3.2 「违规事项」= `PoliceFineConfig`（31 条）

| 截图文字 | `PoliceFineConfig.Id` | `Title` | 自带 `Drop` |
|---|---|---|---|
| 身份造假 | 1 | Fake ID | 14575004（Money **200** / JobExp[11300003] **20**） |
| 携带违禁物品 | 4 | Carrying Forbidden Items | 14575004 |
| 酒驾 | 5 | Drunk Driving | 14575003（Money **150** / JobExp **15**） |

⇒ 案件的 `BonusDrops` 直接取**这些罚款自带的 `Drop`**（去重），
客户端 `GetAwardByDropId` 就能算出与原版一致的奖励。

### 3.3 状态文案

`TextScriptTextConfig`：
`89901144 Arrested` / `89901145 Released` / `89901146 Serving %d Days` /
**`89901147 Temporarily Detained`（= 截图「待讯问」）** / `89901148 Not Guilty` /
`89901149 Released After Sentenced Served` / `89901152 In Detention` / `89901153 Fine`

`Sentence = 0` ⇒ `GetStateStr` 拼出 `89901145` + `89901147` = 截图那个「待讯问」。

### 3.4 图③ 的三个按钮 = `PoliceDispatchConfig`（4 条）

| Id | Name | `Number` | `ShowInApp` | 截图 |
|---|---|---|---|---|
| 1 | Support (Escort) | 2 | **false** | 不显示（只走圆形菜单） |
| 2 | NCCA Dog | 2 | true | 「巡逻犬 / 搜查」 |
| 3 | Helicopter Search | 2 | true | 「直升机搜索 / 2支援」 |
| 4 | Armed Support | 2 | true | 「战术支援 / 2支援」 |

`Number = 2` 就是按钮上的「2支援」。

---

## 4. 主屏图标：为什么少，怎么补

主屏图标 = `MobileMenuSGuiConfig` 里所有 `not IsBottom and CheckAppCanShow(Id)`
（**不按「已安装」过滤**）。非底栏共 **52 个**。

### 4.1 7 个 `IsShow = false`（**服务端改不了**）

`Shop(1)` / `Weapon(30)` / `Buzz Center(32)` / `Bug Report(35)` /
`联机玩法(38)` / `Wishing Wheel(41)` / `网易云音乐(54)`

### 4.2 4 个被「职业大类 / 修炼 id」门控（**服务端能补**）

客户端 `MainPhoneUtils.CheckJobCanShow`：

```lua
-- 1085_LX6_Utils_MainPhoneUtils.lua:191
if jobClassIdList and #jobClassIdList > 0 then
    for _, jobId in ipairs(gSpiritJobManager.GetCurSpiritAvailableJobIdList()) do
        if table.contains(jobClassIdList, LTConfig.UrbanJobConfig.GetConfig(jobId).JobClass)
            then return true end
    end
    return false
end
```

`GetCurSpiritAvailableJobIdList()` = 登录包 `SpiritJobInfo.AvailableJobs` 的 key 集合
⇒ **服务端完全可控**。

| App | 需要的大类 | 修炼门控 | 谁符合 |
|---|---|---|---|
| `Top Cleaning`(24) | 11300014 清洁助理 | 无 | 所有角色 |
| `Chaos Tide`(26) | 11300009 混厄召唤师 | 无 | 所有角色 |
| `VWT`(51) | 11300002 赛车手 | **91050033** | 只有 `Bai Jing`(15021039) |
| `茶农`(47) | 11300019 Tea Farmer | **91050035** | 只有 `You Zhi`(15021043) |

### 4.3 ★ 关键：**只补「名册里没人能拿到」的职业大类**

第一版实现是「遍历所有带 `JobClassIdList` 的 App，按需补职业」——
结果把 `11300003`(NCCA) / `11300004`(Hacker) / `11300005`(Truck) 也补给了**所有**角色，
于是 **EonBug / Duty Terminal / 蓝猫物流** 这些**角色专属 App** 对所有人显示了。

修正：`SpiritContentCatalogRepository.OrphanPhoneAppJobClasses` ——
只补「被某个 App 引用、但**没有任何角色**通过 `DefaultUrbanJob` /
`UrbanJobAvatarConfig` 持有」的大类。

实测结果（`/api/payload/login` 的 `jobSummary[].availableClasses`）：

```
11300014: 32 个角色   ★ Top Cleaning
11300009: 32 个角色   ★ Chaos Tide
11300002:  1 个角色   ★ VWT   （Bai Jing）
11300019:  1 个角色   ★ 茶农  （You Zhi）
11300003:  1 个角色   （NCCA，专属保持）
11300004:  1 个角色   （Hacker，专属保持）
11300005:  1 个角色   （Truck，专属保持）
```

---

## 5. 改动文件

| 文件 | 改动 |
|---|---|
| `Ananta.RpcTypes/.../Methods/Game/PoliceAppMethods4229938.cs` | **新增**：`PoliceCaseInfo`(17 字段) / `PoliceServiceData`(7) / `PoliceDispatchInfo`(5) / `PoliceViolationInfo`(3) + 3 个 S2C 契约 |
| `Ananta.Core/ClientData/Client4229938/PoliceAppCatalog4229938.cs` | **新增**：读 `PoliceDispatchConfig` / `PoliceFineConfig` |
| `Ananta.Core/ClientData/Client4229938/SpiritContentCatalogRepository.cs` | 新增 `OrphanPhoneAppJobClasses` |
| `Ananta.Core/Protocol/Client4229938/RuntimePayloadFactory.cs` | 新增 `GrantPhoneAppJobClasses4229938`（在 `PromoteToTopTier4229938` 之后） |
| `Ananta.Handlers/Game/GameRouter.PhoneAppContent.cs` | 新增 `PushPoliceAppContentAsync` / `BuildPoliceCases` / `NccaJobClassId` / `PoliceCaseIdBase`；接进 `PushAllPhoneAppContentAsync` |
| `Ananta.Handlers/Game/GameRouter.JobAbilities.cs` | `ProbeJobAbility` 加 NCCA App 段（字节 + 偏移校验） |
| `Ananta.Core/Configuration/PrivateServerConfig.cs` | `policeAppContentEnabled` / `policeCaseSpecs` / `policeCaseDaysAgo` / `unlockPhoneAppJobs` |
| `Ananta.App/DebugApiServer.Content.cs` | `/api/spirit/phoneapp` 加 `police.appContentEnabled` / `catalog` / `appDispatches` / `fines` + `policeAppProbe` |
| `ClientData/4229938/Configs/` | 新增 `PoliceDispatchConfig.json` / `PoliceFineConfig.json` / `PoliceViolationConfig.json` |
| `config/private-server.json` | 上面 4 个新键 |

编译 **0 警告 0 错误**；多态审计 `✅ 没有发现问题`；`--probe-jobability` exit 0。

### 探针输出（节选）

```
[probe] ── NCCA App（里希）：拘捕记录 / 执勤数据 / 派遣支援 ──
[probe]   PoliceDispatchConfig=4（App 显示 3） / PoliceFineConfig=31
[probe]   NCCA 角色 = [15021021]
[probe]   案件 2 条:
[probe]     id=930000000000 npc=40650550 t=1789896694 fines=[1] drops=[14575004] sentence=0
[probe]     id=930000000001 npc=4065053  t=1789810294 fines=[4,5] drops=[14575004,14575003] sentence=0
[probe]   App 显示的支援 = 2:NCCA Dog×2/3:Helicopter Search×2/4:Armed Support×2
[probe]   OK   SyncSpiritPoliceCaseInfos   154B | spiritId@0 / list7标记@4 / case[0]标记@6
[probe]   OK   字段 case[0].NpcId @11 expect 40650550 got 40650550
[probe]   OK   字段 case[0].BonusDrops[0] @39 expect 14575004 got 14575004
[probe]   OK   case[0].InterrogationInfo=null @51
[probe]   OK   SyncPoliceServiceData       65B  | serviceData标记@4 / TotalDrops空list标记@21 / weekly标记@34
[probe]   OK   SyncPoliceDispatchInfos     72B  | dict7标记@4 / 计数偏置@5=4 / 第1个key@6
[probe] -> OK
```

---

## 6. 还没做 / 边界

1. **图① 的 EonBug 菜单条目** —— 菜单完全来自客户端 `HackerMenuConfig`（4 条），
   截图里的「召唤车辆」在本 build 配置里是「大停电」⇒ 版本内容差异，服务端加不了。
2. **7 个 `IsShow=false` 的 App** —— 客户端配置里就写着不显示，服务端改不了。
3. **`SyncSpiritPoliceJobInfo`(64349458)** —— 客户端有处理器（`OnSpiritPoliceJobInfoSync`
   一次性设 serviceData / dispatchInfo / caseInfo / violationInfo / fakeFileInfo），
   但它要嵌 `DutyBasicInfo`(Reader[1213]) + `PoliceFakeFileInfo`(Reader[343]) 两棵子树
   ⇒ 本轮改用**三个更简单的独立 S2C**达到同样效果，没发它。
   将来若要一次同步全部，按 `Reader[1213]` / `Reader[343]` 补契约即可。
4. **`SyncPoliceDailyIncidentInfo`(64829293)** —— 客户端有处理器，但「每日事件」需要
   `PoliceIncidentConfig` 之类的数据源，本轮没查。
5. **`SyncPoliceRPSCardInfo`(64816304)** —— `CSharpOnly` 且**无 reader**，别发。
