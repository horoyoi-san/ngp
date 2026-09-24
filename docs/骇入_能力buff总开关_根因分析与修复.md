# 西摩骇入「完全没反应」的真正根因：缺少「黑客骇入能力总开关」buff

> 2026-09-23 第 11 轮 · build 4229938
> 用户：「为啥非得警车啊，我召唤了一辆目前是不行。你分析下并修复。
> 还有千年虫app里的EonBug Forum / Spider Bot / Hacker Drone / 大停电这些项目也没有，修复一下」

---

## 0. 结论速览

| 现象 | 根因 | 状态 |
|---|---|---|
| **骇入完全没反应**（连 UI 都不出，一个请求都不发） | 玩家身上没有 **`BuffConfig.HackingAbility = 52606133`**（「黑客骇入能力总开关」）⇒ 客户端 `RefreshHackInteract` 里 `target` 恒为 `nil` | ✅ 已修 |
| **千年虫 APP 里「蜂形机器人 / 黑客无人机」不显示** | 同样缺 buff：`52606149`（黑客APP-蜘蛛机器人入口）/ `52606150`（黑客APP-无人机入口） | ✅ 已修 |
| 「为什么非得警车」 | 我上一轮只把**派车**接上了标记，**召唤车**那条路径其实也接了 —— 但真正的闸门在 buff，跟车是警车还是召唤车无关 | 见 §4 |

自检：`bash tools/run.sh --probe-jobability`（exit 0）→ 打印整组 buff id 与各自的作用。

---

## 1. 真正的闸门：客户端 lua 里的 `HasGlobalHackBuff()`

`29_LX6_Gadget_GadgetManager.lua`：

```lua
function M:RefreshHackInteract()
    ...
    local target = nil
    local minAngle = 90
    local camPos = gCS.CameraDataMgr.MainCamera.transform.position
    local camDir = gCS.CameraDataMgr.MainCamera.transform.forward

    if self:HasGlobalHackBuff() then          -- ★★★ 没有这个 buff ⇒ 整段被跳过
        for key, data in pairs(self.HackInteractList) do
            ... 选角度最小的骇入目标 ...
        end
    end

    self:RefreshPedestrianHackTarget()
    ...
    self:SetHackTarget(target)                -- target = nil ⇒ **完全没有骇入 UI**
    gMainMenuMgr:SetWallJumpStateByInturn(target == nil)
end

function M:HasGlobalHackBuff()
    if L50.L50App.Scene.GamePlayUtils:IsNotPeople(gCS.MyPlayerManager.PlayerUnit) then
        return true                            -- 非人类单位（怪物）天生能骇
    end

    return L50.L50App.Scene.HackManager.debugHackIgnoreBuff
        or gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid,
                              LTConfig.BuffConfig.HackingAbility)   -- = 52606133
end
```

**`BuffConfig.HackingAbility = 52606133`**（`ConfigData/LT/ConfigGen/BuffConfig.cs:223`）。

配置表里的名字是 **「黑客骇入能力总开关」**（`Duration = -1` 永久、`DeadKeep = true`、`IsHidden = true`、`Abandon = false`）。

⇒ 没有它 ⇒ `SetHackTarget(nil)` ⇒ **`gGadgetManager.HackInteractTarget` 永远是 nil**
⇒ 图①那个骇入准星图标不出现 ⇒ **一个骇入请求都不会发出去**。

实测证据（第 10 轮日志，`logs/console-20260923-180303.log`）：

```
307  ntf AskInteractCmd          ← 交互总线
  0  rpc/ntf AskHack
  0  rpc/ntf AskHackVehicle
  0  rpc/ntf AskHackingNpc
```

**这解释了为什么前两轮改的东西都"没效果"** —— 它们全是**下游**：
第 9 轮的 `EnableHack` / 骇入电量、第 10 轮的 `SyncUnitHackableState` 车辆标记，
都要求客户端**先有骇入 UI** 才有意义。

---

## 2. 千年虫 APP 的条目也是 buff 门控

`444_LX6_SGUI_StoreDefine_HackerAppMainPanelStore.lua`（就是截图里那个面板：
`bbsBtn`=黑客论坛 / `carBtn`=召唤车辆 / `appList`=技能列表）：

```lua
function M:RefreshSkillList()
    table.clear(self.skillList)

    for index = 0, HackerMenuConfig.count - 1 do
        local cfg = HackerMenuConfig.LoadAt(index)
        if cfg then
            local allowBuff = cfg.BuffID

            -- ★★★ 必须身上有 cfg.BuffID 这个 buff，技能才会进列表
            if gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, allowBuff)
                and cfg.MenuType ~= 0 then
                table.insert(self.skillList, { name = cfg.Title, img = cfg.Image, ... })
            end
        end
    end

    self.bindData.appList:SetSimpleList(#self.skillList)
    if #self.skillList > 0 then self.bindData.skillCtrl = 0 else self.bindData.skillCtrl = 1 end
end
```

`HackerMenuConfig`（4 条）与 buff 的对应：

| Id | Title | MenuType | `BuffID` | buff 名字 | 面板 |
|---|---|---|---|---|---|
| 1 | EonBug Forum | 0 | 0 | — | `HackerAppPanelStore` 的 itemList（**无 buff 门控**） |
| 2 | **Spider Bot / 蜂形机器人** | 1 | **52606149** | 黑客APP-蜘蛛机器人入口 | skillList（**有门控**） |
| 3 | **Hacker Drone / 黑客无人机** | 1 | **52606150** | 黑客APP-无人机入口 | skillList（**有门控**） |
| 4 | 大停电 | 0 | 0 | — | itemList（**无 buff 门控**） |

⇒ 补上 52606149 / 52606150，「蜂形机器人 / 黑客无人机」就会出现。
`黑客论坛` / `召唤车辆` 是面板 prefab 上的固定按钮（`bbsBtn` / `carBtn`），不受 buff 影响。

---

## 3. 修复

### 3.1 一次授予整组 buff

`GameRouter.GrantHackingAbilityBuffAsync(session)` —— 通过 `SyncUnitAddBuff`(68596304)
给**玩家当前单位**补上整组（都是永久 buff）：

| id | 配置名 | 缺了会怎样 |
|---|---|---|
| **52606133** | 黑客骇入能力总开关 | **完全没有骇入 UI，一个请求都不发** |
| **52606149** | 黑客APP-蜘蛛机器人入口 | 千年虫 APP 里「蜂形机器人」不显示 |
| **52606150** | 黑客APP-无人机入口 | 千年虫 APP 里「黑客无人机」不显示 |
| 52606134 | 黑客骇入氛围NPC能力 | 骇入氛围 NPC |

### 3.2 调用时机

| 位置 | 为什么 |
|---|---|
| 基线 `jobability` 步骤（**最先**执行） | 进世界就要有，否则整个骇入链路不成立 |
| `AskSwitchSpiritComplete` | buff 是**按单位**的（`SyncUnitAddBuff(unitId, …)`），换人后 unitId 变了必须重发 |

幂等：`WorldEntryState.ActiveHackingBuffInstances`（buffId→instanceId）+ `HackingBuffsUnitId`；
同一单位同一 buff 只发一次，换人后整组重发。

### 3.3 新增配置

```jsonc
// config/private-server.json → gameplay.spiritContent
"grantHackingAbilityBuff": true
```

---

## 4. 复盘：为什么排查了三轮才找到

| 轮次 | 找到的东西 | 层次 | 为什么"没效果" |
|---|---|---|---|
| 第 9 轮 | `ClientStaticNpcInitData.EnableHack` | 哪些**世界 NPC** 可骇 | 下游：UI 都没有，标了也没用 |
| 第 9 轮 | `SyncHackerBatteryCurrentAndTotalCount` 6/6 | 电量够不够 | 下游：`AskHack` 才查电量 |
| 第 10 轮 | `SyncUnitHackableState` 车辆标记 | 哪些**车辆**可骇 | 下游：同上 |
| **第 11 轮** | **`BuffConfig.HackingAbility = 52606133`** | **有没有骇入 UI** | ★ **真正的总开关** |

**教训（已写进 SKILL）**：
「某个功能没反应」时，**先找"UI / 入口"的那道闸门，再找"内容"的闸门**。
判据：在客户端 lua 里搜这个功能的**入口函数**（这里是 `RefreshHackInteract`），
看它的**第一个 if** —— 那才是总开关。

本轮方法：
```bash
# 1. 搜功能入口
grep -rn "SetHackTarget\|HackInteractTarget" *.lua          # → GadgetManager:RefreshHackInteract
# 2. 看它的第一个 if
sed -n '1583,1600p' 29_LX6_Gadget_GadgetManager.lua         # → if self:HasGlobalHackBuff() then
# 3. 追那个函数查什么
grep -n "function M:HasGlobalHackBuff" -A 8 29_LX6_Gadget_GadgetManager.lua
#    → gBuffUtils.HasBuff(pid, LTConfig.BuffConfig.HackingAbility)
# 4. 拿常量值（**生成的配置类**，不是 records dump）
grep -n "HackingAbility" WorldDump/06_RUNTIME_CODE/*/csharp/ConfigData/LT/ConfigGen/BuffConfig.cs
#    → public const uint HackingAbility = 52606133;
# 5. 查配置名确认语义
#    → BuffConfig.json Id=52606133 Name=「黑客骇入能力总开关」
```

> ☠️ **`LTConfig.BuffConfig.HackingAbility` 这种「命名常量」在 `ConfigDump_v3/BuffConfig.json`
> （records 形式）里搜不到** —— 它在生成的 C# 配置类里：
> `WorldDump/06_RUNTIME_CODE/*/csharp/ConfigData/LT/ConfigGen/BuffConfig.cs`。
> 以后要找 `LTConfig.XXX.YyyZzz` 这种常量，直接去那里 grep。

---

## 5. 改动文件

| 文件 | 改动 |
|---|---|
| `Ananta.Handlers/Game/GameRouter.JobAbilities.cs` | 新增 `HackingAbilityBuffId` / `HackerSpiderBotBuffId` / `HackerDroneBuffId` / `HackingAtmosphereNpcBuffId` / `HackingBuffIds` + `GrantHackingAbilityBuffAsync`；探针打印整组 buff |
| `Ananta.Core/Protocol/Client4229938/WorldEntryState.cs` | 新增 `ActiveHackingBuffInstances` / `HackingBuffsUnitId` |
| `Ananta.Handlers/Game/GameRouter.Baseline.cs` | `jobability` 步骤**最先**执行 buff 授予 |
| `Ananta.Handlers/Game/GameRouter.SwitchTimeline.cs` | 换人完成后重发（buff 是按单位的） |
| `Ananta.Core/Configuration/PrivateServerConfig.cs` | `spiritContent.grantHackingAbilityBuff`（默认 true） |
| `config/private-server.json` | 同上 |

编译 **0 警告 0 错误**；多态审计通过；`--probe-jobability` exit 0。

---

## 6. 还没做 / 边界

1. **「大停电」/「EonBug Forum」**（`HackerMenuConfig` 里 `MenuType=0` 的两条）
   走 `HackerAppPanelStore` 的 itemList，**没有 buff 门控** ⇒ 本来就该显示；
   如果实测仍不显示，需要再查那个面板的 `PanelId` 映射。
2. **`AskHackVehicle` 的 `actionType`** —— 私服只回成功，不做真实效果（「加速」等）。
3. **街上的 Aether 车流**仍是客户端本地生成，服务端不知道实体 id ⇒ 无法标记可骇入。
