# 骇入（西摩）：能力 buff 全集 + 千年虫 App 条目触发链路 —— 根因分析与修复

> 日期：2026-09-23（第 12 轮）
> 用户原话：
> 1. 「目前还是无法骇入，车辆附近和npc附近没有鼠标中键骇入的选项。你分析下并修复。」
> 2. 「还有千年虫app里的EonBug Forum / Spider Bot / 项目也还是没有，修复一下。」
> 3. 「还有个问题。Hacker Drone / 大停电这两个既然没有按钮，那应该怎么触发，
>    能加到后台页面里触发吗，还是怎么触发」

---

## 0. 结论速览

| # | 现象 | 根因 | 修复 |
|---|---|---|---|
| 1 | **仍然无法骇入**（车辆/NPC 边没有中键选项） | 第 11 轮只补了**一个总开关** `52606133`。但客户端是**逐技能查 buff** 的：`NpcHackSkillBase.CanUse` 会查 `HackerConfig.HackNPCAbilityBuff[NpcHackType]`（**8 条**），载具另查 `52606167` / `52606168`。缺任意一条 ⇒ `HackManager.GetUnitHackBtns` 返回**空列表** ⇒ 面板一个按钮都没有 | 把这 **14 条** buff 作为**单位的能力 buff 全集**，随新单位的初始 buff 列表（`SyncUnitBuffList`）一起下发 —— 见 §2 |
| 2 | 补的 buff「没生效」 | 第 11 轮走的是 `SyncUnitAddBuff`，而且**只在时间线换人（`AskSwitchSpiritComplete`）里补**。实测用户走的是**直切**（日志 `[SWITCH-MIN] direct ... target=15021023`）⇒ 那条路径**根本没被调用** ⇒ 赛默身上一条 buff 都没有 | 改走 `WebTraversal.CapabilityBuffIds(template)` —— 登录 / 直切 / 时间线**三条路都会走到** |
| 3 | 街上的**氛围车**不能骇 | `GameRouter.Aether.cs` 只生成车、**从没调 `MarkHackableAsync`**；第 11 轮只标了「召唤车 + 派出的警车」 | 生成 12 台氛围车后逐台 `SyncUnitHackableState` |
| 4 | 千年虫 App 里 **Spider Bot / Hacker Drone 不显示** | 这两条 `MenuType=1`，`HackerAppMainPanelStore:RefreshSkillList` 要求**身上有 `cfg.BuffID`**（52606149 / 52606150） | 已包含在 §2 的 14 条里 |
| 5 | **Hacker Drone / 大停电 怎么触发** | 见 §4 —— **Spider Bot / Drone 有按钮**（客户端 `UseSkillByPid`），**大停电是死条目** | 后台加了 `POST /api/jobability/hack` |

---

## 1. 权威依据：客户端配置 + 反汇编

### 1.1 `HackerConfig.static.json`（客户端静态配置，权威）

```
HackNPCAbilityName     = [74003210, 74003211, 74003212, 74003213,
                          74003323, 74003324, 74003207, 74000960]   (8 条 = NpcHackSkillType 0..7)
HackNPCAbilityBuff     = [52606135, 52606136, 52606137, 52606138,
                          52606161, 52606162, 52606178, 52606179]   ★ 逐技能必需 buff
HackNPCDistance        = 30
HackNPCAngel           = 90
HackVehicleDistance    = 30
HackVehicleAbilityName = [74003116, 74003208]
HackVehicleAbilityBuff = 52606167        ★ 骇入载具的总能力
HackVehicleSkillBuff   = [0, 52606168]   ★ ChaseTarget=0 不需要；RushForward=1 要 52606168
HackBatteryCount       = 6
```

### 1.2 反汇编（`tools/disasm.py`）

| 函数 | RVA | 关键指令 / 语义 |
|---|---|---|
| `HackManager.OnUpdate` | `0x1332E2D0` | `cmp dword ptr [rcx+0xE0],0` / `je <ret>` ⇒ **`HasGlobalHackAble==0` 时整个目标选择器不跑**（`hackUnitTarget`/`hackVehicleTarget` 恒 null） |
| `HackTargetSelector.SelectUnitTarget` | `0x133425AB` | `HasBuff(pid, 52606133 HackingAbility) \|\| HasBuff(pid, 52899024 TempHackingAbility)`；随后 `HasBuff(pid, 52606134 HackingAtmosphereNPC)` |
| `NpcHackSkillBase.CanUse` | `0x13339E90` | `HasBuff(pid, this.RequiredBuff)`；`RequiredBuff` = `BuffIdsByHackType[this.NpcHackType]` |
| `NpcHackSkillBase.get_RequiredBuff` | `0x133511D0` | `static uint[] (staticFields+0x38)[NpcHackType]` ⇒ 就是 `HackerConfig.HackNPCAbilityBuff` |
| `HackManager.GetUnitHackBtns` | `0x1332EC00` | 遍历 `_npcSkills` 逐个 `CanUse`，只把通过的 `TextId` 加进列表，**最多 3 个** |
| `BuffUtils.HasBuff` | `0x9782200` | `UnitsManager.GetUnit(pid)` → 找不到再 `LocalUnitMgr.GetNpcByPid` / `CutsceneUnitManager` → `unit.BuffModule.hasBuff(buffId)`（**按 buffId 的集合查表**） |
| `HackManager.IsHackBanned` | `0x13339A80` | `HackerConfig.HackBanGameplaytag = [903, 919]` + 过场中禁用 |

### 1.3 正式版是怎么给这些 buff 的 —— 职业徽章

`UrbanBadgeConfig`（`Type=2` = Job，`JobBadgeType` 0=ExtraSkill/1=Permission/2=Upgrade），
`JobId = 401`（Professional Hacker = 赛默 `15021023`）共 5 张：

| 徽章 | 名字 | 授予的 buff |
|---|---|---|
| 19001102 | Hacking 101 | `[52606133]` |
| 19001103 | Nowhere to Hide | `[52606134, 52606135, 52606137, 52606161]` |
| 19001108 | Watch Your Step | `[52606149]` |
| 19001109 | Eyes on the Sky | `[52606150]` |
| 19001110 | 骇入载具能力 | `[52606167, 52606168]` |

徽章走 **`SyncUrbanBadgeInfo`(64600925，`midToExportOption = LuaOnly`)** 解锁 ——
私服**从不发这条**，所以徽章 buff 一条都没有。
（`SyncSpiritBadgeInfo`(64337038) 发的是 `FightspiritId != 0` 的角色徽章，与职业能力无关。）

> 注意：徽章表里 `52606136 / 52606138 / 52606162 / 52606178 / 52606179`
> 没有出现在这 5 张里 —— 可能由别的徽章（其它 JobId）或关卡授予。
> 反正 `HackNPCAbilityBuff` 要这 8 条，**全给**最省事。

---

## 2. 修复 ①：能力 buff 全集随单位的初始 buff 列表下发

### 2.1 为什么走 `SyncUnitBuffList` 而不是 `SyncUnitAddBuff`

- 客户端是在**单位建立时**按 buff 算出骇入指示状态的（`HasGlobalHackAble` 由 Lua
  `SetHackIndicateState` 推给 C#），**随快照发最可靠**；
- 三条换人路径（登录 / 直切 / 时间线）**都会调** `PublishSafeRuntimeBuffSnapshot*`
  ⇒ 一处改动全覆盖，不会再出现"某条路径没补"；
- 第 11 轮走 `AskSwitchSpiritComplete` 那条路，而用户实际用的是**直切** —— 这就是"改了没效果"的直接原因。

### 2.2 载荷格式核对（`SyncUnitBuffList` 68118081）

客户端 `RPCDeserializeAuto.lua`：

```lua
self.midToReader[68118081] = function (reader)
    local entityId = reader:ReadUInt64()
    local buffList = Base.ReadList7Bit(reader, function (r)
        return Base.ReadStruct(r, Auto.Reader[397])
    end)
    return entityId, buffList
end

Auto.Reader[397] = function (reader, obj)   -- BuffViewData
    obj.InstanceId     = reader:ReadUInt32()
    obj.Id             = reader:ReadUInt32()
    obj.ReleaserId     = reader:ReadUInt64()
    obj.ExpireTime     = reader:ReadDouble()
    obj.Tier           = reader:ReadUInt32()
    obj.Permanent      = reader:ReadBoolean()
    obj.DestructibleId = reader:ReadUInt64()
end
```

服务端 `UxSerializer` 对 `List<T>` 的默认计数编码是 **`UxCountEncoding.Int7`**
（`UxContract.cs:289` `WriteCount(..., defaultEncoding: UxCountEncoding.Int7)`）
⇒ 与 `ReadList7Bit` 一致 ✅。
`SyncUnitAddBuff`(68596304) 的载荷是 `entityId(u64) + BuffViewData` = **45 字节**
（实测 `packets-latest.log` `body=45b` ✅）。

### 2.3 改动

| 文件 | 改动 |
|---|---|
| `Ananta.Core/Configuration/PrivateServerConfig.cs` | `SpiritContentSettings` 新增 `HackerSpiritTemplateId`(默认 15021023) 与 `HackerAbilityBuffIds`(14 条，带逐条注释) + `DefaultHackerAbilityBuffIds` |
| `Ananta.Gameplay/WebTraversal.cs` | 新增 `HackerSpiritTemplateId` / `IsHacker(templateId)` / `HackerCapabilityBuffIds`；`CapabilityBuffIds(templateId)` 对黑客角色 `Combine(shared, hackerBuffs)` |
| `Ananta.Handlers/Game/GameRouter.Profiles.cs` | `PublishInitialCapabilityBuffs` 从写死 `InitialCapabilityBuffIds` 改为 `CapabilityBuffIds(Profile.InitialSpiritTemplateId)` |
| `Ananta.Handlers/Game/GameRouter.JobAbilities.cs` | `HackingBuffIds` 改为 `WebTraversal.HackerCapabilityBuffIds`（单一来源）；`GrantHackingAbilityBuffAsync` 降级为**兜底**：只给黑客角色、跳过快照已覆盖的 |
| `config/private-server.json` / `private-server.example.json` | 新增同名键 |

### 2.4 14 条 buff 一览

| id | 配置名 | 缺了会怎样 |
|---|---|---|
| 52606133 | 黑客骇入能力总开关 | `HasGlobalHackAble=0` ⇒ 完全没有骇入 UI |
| 52606134 | 黑客骇入氛围NPC能力 | `SelectUnitTarget` 第二道判定不过 |
| 52606135 | 骇入氛围NPC-偷看短信 | `HackNPCAbilityBuff[0]` |
| 52606136 | 骇入氛围NPC-偷听电话 | `[1]` |
| 52606137 | 骇入氛围NPC-分心 | `[2]` |
| 52606138 | 骇入氛围NPC-外放音乐 | `[3]` |
| 52606161 | 骇入氛围NPC-偷钱 | `[4]` |
| 52606162 | 骇入氛围NPC-偷粉丝 | `[5]` |
| 52606178 | 骇入分心/干扰能力 | `[6]` |
| 52606179 | 骇入叛变能力 | `[7]` |
| 52606167 | 骇入车流载具能力 | `HackVehicleAbilityBuff` |
| 52606168 | 骇入车流载具-加速技能 | `HackVehicleSkillBuff[1]` |
| 52606149 | 黑客APP-蜘蛛机器人入口 | 千年虫 App 里「Spider Bot」不显示 |
| 52606150 | 黑客APP-无人机入口 | 千年虫 App 里「Hacker Drone」不显示 |

---

## 3. 修复 ②：街上的氛围车也要标可骇入

`GameRouter.Aether.cs` 的 `PushAetherVehiclesAsync` 生成完 12 台氛围车后，
新增逐台 `MarkHackableAsync(session, id, token, rememberAsLastVehicle: false)`。

- `rememberAsLastVehicle: false` —— 否则「最近可骇入车辆」会被最后一台路过车覆盖，
  玩家骇完一辆再点自动驾驶会开到别人身上（`AskVehicleStartHackerAutonomousDriving` 回的就是这个 id）。
- 车辆通道只能用 `SyncUnitHackableState`(68941159)；
  `SyncVehicleHackableState`(68037721) 在本 build **没有 C# 实现**。

> ⚠️ 上一轮文档里写的「街上的 Aether 车流是客户端本地生成，服务端不知道实体 id ⇒ 无法标记」
> 是**错的**。日志证据：`[AETHER] 已生成 12 台氛围车（玩家 (3143,2528) 半径 160m…）`
> —— 车是**服务端**按真实车道投放的，id 基数 `AetherVehicleIdBase = 700000000000`。

NPC 侧无需额外动作：Aether 人群 / 固定 NPC 的 `ClientStaticNpcInitData.EnableHack`
已经跟着 `spiritContent.hackTargetsEnabled = true` 下发
（日志：`已生成 30 个人群 NPC` + `26 个固定 NPC`）。

---

## 4. 修复 ③ / 回答：千年虫 App 四条菜单怎么触发

### 4.1 机制：`FuncAction` 是 **Lua 源码**

`HackerMenuConfig.FuncAction` 是一个**字符串形式的 Lua 代码**，点击条目后
`HackAction.RunFunc(cfg.FuncAction, cfg)` 把它 `load(code, nil, "t", HackScriptFunc)` 执行。
（依据：CBT2 反混淆转储 `tools/3_deobfuscated/445_LX6_GUI_Hacker_HackAction.lua`）

### 4.2 四条菜单的真相（`446_LX6_GUI_Hacker_HackScriptFunc.lua`）

```lua
function M.CheckShowPanel()                 -- Id=1 EonBug Forum
    local data = this.SettingData
    if data and data.panelId and data.panelId > 0 then
        gPanelManager:CheckShow(data.panelId)      -- PanelId = 703
    else
        print_error("黑客打开其他界面panelid不存在，请策划检查配置")
    end
end

function M:SpiderSkill()                    -- Id=2 Spider Bot
    gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, 51938181)
    gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
    gMainPhoneUtils.CloseMainPhonePanel()
end

function M:DroneSkill()                     -- Id=3 Hacker Drone
    gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, 51938183)
    ...
end
```

| Id | Title | MenuType | FuncAction | BuffID | 触发 / 显示 |
|---|---|---|---|---|---|
| 1 | EonBug Forum | 0 | `CheckShowPanel()` | 0 | 打开面板 703（内容 = `SyncHackerJobInfo.PostInfos`，已发 20 条） |
| 2 | **Spider Bot** | 1 | `SpiderSkill()` | **52606149** | `UseSkillByPid(pid, **51938181**)` |
| 3 | **Hacker Drone** | 1 | `DroneSkill()` | **52606150** | `UseSkillByPid(pid, **51938183**)` |
| 4 | **大停电** | 0 | **`""`（空串）** | 0 | **什么都不做 —— 死条目** |

### 4.3 回答用户的问题

**Q：Hacker Drone / 大停电这两个既然没有按钮，那应该怎么触发？**

**A（Hacker Drone）—— 它其实**有**按钮。**
条件是「身上有 `52606150`」，那时它会出现在
`HackerAppMainPanelStore.appList`（`RefreshSkillList` 的 buff 门控）里。
点一下就走 `UseSkillByPid(pid, 51938183)`。
技能本身来自客户端配置 `FightSpiritConfig[15021023].TempSkill = [51938181, 51938182, 51938183]`，
服务端**不需要**额外下发技能（`CombatCatalogRepository.IsKnownSkill(51938183)` 为 true，
`AllowsSkill` 会放行）。
Spider Bot 同理（`52606149` → `51938181`）。

**A（大停电）—— 本 build 在 App 里**没有**可点的入口。**
`HackerMenuConfig.Id=4.FuncAction = ""`，`RunFunc("")` 里 `load("")` 得到空函数体，
**点击什么都不发生**。它的真实实现在别处：

- 黑客**天赋** `TalentTreeTalentConfig.Id = 99906106`
  （`JobRequest = 401`、`NeedActive = true`、`LayerNum = 1`、
  `TalentTreeid = [99900010]`、`PreTalentIds = [99906204]`）
  描述：「可以骇入电网造成1分钟的大停电，使周围行人陷入恐慌，敌人感知与行动能力大幅下降一段时间」
- **Creation** `CreationConfig.Id = 56860922`「【黑客】大停电-范围干扰」
  （也等于 `HackerConfig.HackerTetris_CreationId` / `HackerTetris_CreationId_Dark|Light`
  ⇒ 是**俄罗斯方块小游戏**的产物）

⇒ App 侧**服务端加不了条目**（菜单是客户端配置 `HackerMenuConfig`，
第 9 轮就定案了：截图里的「召唤车辆」在本 build 配置里是「大停电」，属版本内容差异）。

**Q：能加到后台页面里触发吗？**

能，已加：**`POST /api/jobability/hack`**

| action | 作用 |
|---|---|
| `tools` | 只回上面这张触发链路表（不发包），后台页面可直接渲染 |
| `grant-buffs` | **强推**整组 14 条骇入能力 buff 到当前单位（无视幂等记录），用于"换了角色但 buff 没跟上"的手动补救 |
| `spider` | 推 `SpiderStart`(52800100) 触发 buff（**第二条路**；客户端自己的路是 `UseSkillByPid(51938181)`） |
| `drone` | 推 `DroneStart`(52800102) 触发 buff（同上，技能 51938183） |
| `blackout` | 返回大停电的**真实实现位置**并说明 App 里点不出来 |
| `forum` | 重推 `SyncHackerJobInfo`（含 20 条帖子） |
| `hackable-all` | 重标全部车辆 + 街边 NPC |

⚠️ **边界**：`UseSkillByPid` 是**客户端** API，服务端**无法代替客户端点击**。
所以「Spider Bot / Hacker Drone」最可靠的触发方式仍然是：
**把入口 buff 推齐 → 玩家在 App 里点**。后台的 `spider`/`drone` 只是备选。

---

## 5. 改动文件清单

| 文件 | 改动 |
|---|---|
| `Ananta.Core/Configuration/PrivateServerConfig.cs` | `HackerSpiritTemplateId` / `HackerAbilityBuffIds` / `DefaultHackerAbilityBuffIds`；`GrantHackingAbilityBuff` 注释改写 |
| `Ananta.Gameplay/WebTraversal.cs` | 黑客能力 buff 全集 + `IsHacker` + `CapabilityBuffIds` 分支（附完整反汇编依据注释） |
| `Ananta.Handlers/Game/GameRouter.Profiles.cs` | `PublishInitialCapabilityBuffs` 按初始角色模板取集合 |
| `Ananta.Handlers/Game/GameRouter.JobAbilities.cs` | `HackingBuffIds` → 单一来源；`GrantHackingAbilityBuffAsync` 改为兜底（只给黑客 + 跳过已覆盖）；新增 `SpiderStartBuffId`/`DroneStartBuffId`/`SpiderBotSkillId`/`HackerDroneSkillId`/`HackerAppTools`/`ForceGrantHackerBuffsAsync`/`TriggerBuffAsync`；探针输出重写 |
| `Ananta.Handlers/Game/GameRouter.Aether.cs` | 氛围车生成后逐台标可骇入 |
| `Ananta.App/DebugApiServer.cs` | 路由 `POST /api/jobability/hack` |
| `Ananta.App/DebugApiServer.Content.cs` | `JobAbilityHackAsync`；`/api/jobability` 的 `hacker` 段新增 buff 全集 / 来源 / 工具表 |
| `config/private-server.json`、`private-server.example.json` | 新增两个键 |

验证：`bash tools/build.sh` → **0 警告 0 错误**，多态审计通过；
`bash tools/run.sh --probe-jobability` → **exit 0**；
服务端重启后 login 5200/5201 + game 5202 + 调试面板 `http://127.0.0.1:5809/` 全部 listening。

### 5.1 两条换人路径的 `templateId` 核对（**这是本次修复的正确性关键**）

快照函数收的是 `templateId` 形参，所以必须确认传的是**新角色**的模板：

| 路径 | 代码 | 传参 |
|---|---|---|
| 直切 | `GameRouter.Switching.cs:111` | `state.ActiveSpiritTemplateId = templateId;`（:92）→ `PublishSafeRuntimeBuffSnapshot4229938(ctx, unitId, templateId, "minimal-direct-switch")`（:111）✅ 新模板 |
| 时间线 | `GameRouter.SwitchTimeline.cs:532` | `PublishSafeRuntimeBuffSnapshotSessionAsync(session, state, unitId, templateId, "switch-timeline")` ✅ 新模板（`ActiveSpiritTemplateId` 在 :542 才赋值，但快照用的是形参，不受影响） |

实测日志里直切是 `target=15021023/100000000012` ⇒ `templateId = 15021023` ✅。
所以切到赛默后应能看到 `[BUFFS-MIN] minimal-direct-switch unit=100000000012 template=15021023 count=28`
（14 条基础能力 + 14 条骇入能力）。

### 5.2 蜘蛛/无人机技能**不会被服务端拒**（探针已验）

`OnClientUseSkill` 的最后一道闸门是 `weapon.AllowsSkill(style, skillId)`，
兜底分支是 `CombatCatalogRepository.IsKnownSkill(skillId)`
（= `SkillConfig.json` 的 `SkillCastTags` 里有这个 id）。探针输出：

```
[probe]   OK   召唤蜘蛛机器人 skill=51938181 IsKnownSkill=True ? AllowsSkill 的兜底分支放行
[probe]   OK   召唤送货无人机 skill=51938183 IsKnownSkill=True ? AllowsSkill 的兜底分支放行
```

⇒ 客户端点 Spider Bot / Hacker Drone 时 `AskUseSkill` **会被服务端接受**（只记日志，不拒）。

---

## 6. 还没做 / 边界

1. **`AskHackVehicle` 的 `actionType` 不做真实效果**（只回成功）——
   「加速 / 往前冲 / 打滑」需要服务端接管车流仿真，Aether 车的位置是 50ms 仿真循环算的。
2. **大停电**没有可点的 App 入口（客户端配置如此），要真正实现得做天赋主动技 + 俄罗斯方块小游戏。
3. **蜘蛛机器人 / 无人机的实体**：客户端会播召唤演出，但服务端**不生成**对应的可控实体
   （需要 entity 生成 + 接管 + AI）。目前只保证"按钮出现且请求不被拒"。
4. 徽章 5 张里缺的 5 条 NPC 技能 buff（52606136/138/162/178/179）在正式版由谁给**没有查清**，
   本私服直接全给。
