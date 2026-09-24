# 切人传送时机 —— 「上升段播完、镜头到高空将降时」再传送

> 2026-09-23 · 针对 `Ananta CBT3` 私服后台面板「切人动画」卡片
> 问题：选「传送到锚点」（原版行为）时，**点一下立刻传送**，画面瞬移；运镜之后才开始播。

---

## 一、结论先说

原版切人运镜是**三段式**，真正的传送点在**顶点**（镜头爬到高空、刚准备下降），
而不是「点下去」那一刻：

```
时间 ──────────────────────────────────────────────────────────────────────►

 SyncPreSwitchSpirit          SyncSwitchSpiritConfigId        ★顶点          AskSwitchSpiritComplete
        │                              │                        │                    │
        ▼                              ▼                        ▼                    ▼
   ┌────────────────┐   ┌──────────────────────────────┐   ┌────────────────────────┐
   │  Prepare       │   │  loading_switch_moving_…     │   │ loading_switch_after_… │
   │  预加载模型     │   │  ① 上升 yMoveStartTime→Apex  │   │  ③ 下降 Apex→yMoveEnd  │
   │  建 LOD 相机    │   │  ② ★APEX yReachMaxHeightTime │   │  ④ Loop 落地待机循环    │
   └────────────────┘   └──────────────────────────────┘   └────────────────────────┘
                                                              ＋ SwitchChar_common_XX 定制演出
        ▲                                                                          
        └─ 旧实现在这里就传送了（比顶点早 ≈6s）→ 画面瞬移
```

**四个阶段**（客户端 `LX6.TimelineScript.LoadingSwitchSeamlessFeature` 里叫
「远景切人演出Feature」，字段直接给出了切分）：

| 阶段 | 字段 | 含义 |
|---|---|---|
| ① 上升 | `yMoveStartTime → yReachMaxHeightTime`，曲线 `yMoveUpCurve` | 镜头从锚点地面抬升到 `yMoveMaxHeight` 高空 |
| ② **顶点** | `yReachMaxHeightTime` | ★ **传送点**：镜头到顶，刚准备下降 |
| ③ 下降 | `yReachMaxHeightTime → yMoveEndTime`，曲线 `yMoveDownCurve` | 镜头俯冲到 `targetPos`（锚点）；XZ 同时由 `xzMoveStartTime→xzMoveEndTime` 把 `fromPosXZ` 推到 `targetPosXZ` |
| ④ 落地循环 | `Loop` clip（`LoopEndJumpTo` 跳出） | 落地后的待机段，等 `NotifyEndTimelineWaiting` |

---

## 二、两条独立证据

### 证据 1：客户端 `LoadingSwitchSeamlessFeature`（运镜本体）

`Ananta/WorldDump/06_RUNTIME_CODE/*/csharp/L50Game/LX6/TimelineScript/LoadingSwitchSeamlessFeature.cs`

```csharp
[AddComponentMenu("Timeline/玩法Feature/远景切人演出Feature")]
public class LoadingSwitchSeamlessFeature : TimelineGamePlayFeatureBase
{
    private readonly string MOVING_CLIP_NAME;      // MOVING 片段名
    public double moveClipStart, moveClipDuration, moveClipEnd;

    private float yMoveMaxHeight, startPosHeight, targetPosHeight;
    private float yMoveStartTime, yReachMaxHeightTime, yMoveEndTime, yMoveDuration;   // ★ 顶点在这
    private float xzMoveStartTime, xzMoveEndTime, xzMoveDuration;
    private AnimationCurve yMoveUpCurve, yMoveDownCurve, xzMoveFactorCurve, camRotateCurve;

    private const string LOOP_CLIP_NAME   = "Loop";
    private const string JUMP_TO_CLIP_NAME = "LoopEndJumpTo";

    private void InitMoveTimePoint() { }        // ← 算出上面三个时间点
    private bool OnMovingHeight_Update(float time, out float y) { }
    private bool OnMovingXZ_Update(float time, out Vector3 xz) { }
    private void NotifyPreShowFinished() { }    // ← 上升段结束回调
    private void NotifyEnterLoop() { }
    private void NotifyResLoaded() { }
    private void NotifyEndTimelineWaiting() { }
    public  void ProcessEvent(string param) { } // "ChangeLodCamEndPoint" / "CloseCloudShadowParams" …
}
```

`yReachMaxHeightTime` 就是**顶点**，而且它是 `[NonSerialized]` 的**运行时算出来的 double**，
不在任何配置表里 —— 所以抓包看不到、配置表里也查不到。

### 证据 2：协议 `PreTeleportOption` / `LoadingInfoBase`（原版把传送定义成三段事务）

`UX.Game.PreTeleportOption`（`dump.cs` TypeDefIndex 33015）：

```csharp
public uint      configId;          public ulong teleportId;
public bool      ForceClear;        public uint  TimeLineDration;
public UXVector3 position;          public float facing;
public string    beforeResName;     // ① 上升
public bool      customBeforeTrans; public UXVector3 beforePosition, beforeRot;
public string    loadingResName;    // ② 加载
public string    afterResName;      // ③ 下降
public bool      customAfterTrans;  public UXVector3 afterPosition, afterRot;
public string    extParams;
```

`LX6.GUI.LoadingInfoBase` 逐字段对应：`before_name/before_data` → `loading_name` → `after_name`，
并配 `LoadingManager.TriggerTime` 枚举：

```
OnFlowBegin, BeforeLoading, BeforeLoading_Playing, BeforeLoading_End,
Loading, Loading_Playing, Loading_End,
AfterLoading, AfterLoading_Playing, AfterLoading_End, OnEndAction
```

`LX6.GUI.LoadingManager` 的握手（原版语义）：

```
beforeResName（上升）
  → C2S  ReportPreTeleportFinish (63032762)      ← 客户端说"上升段播完了"
  → S2C  SyncTeleport          (64030755)      ← 服务端这时才把人放过去
afterResName（下降）
  → C2S  ReportPostTeleportFinish (63682240)
```

⇒ **协议本身就规定「传送点在 before/after 交界」**，与证据 1 的顶点完全吻合。

`TimelineConfig` 也印证了这个分工：

| Id | TimelineName | Group | SupportTeleport |
|---|---|---|---|
| 186 | `loading_switch_moving_seamless` | Loading | **true** ← 上升段（允许传送） |
| 185 | `loading_switch_after_seamless` | Loading | false ← 下降段 |
| 659 | `switchchar_common_14` | SwitchChar | false ← 角色定制演出 |

---

## 三、实测时序（这次是真的量出来的）

对照同一时刻的两份日志：

* 客户端 `Ananta/log/Player-prev13.log`（2026-09-22 20:04 那次 `SwitchChar_common_14`「撸猫」，
  锚点 `(2832.10, 0.05, 1880.63)`，玩家原位 `(3586.16, 1.97, 1899.23)`，距离 **754.29m**）
* 服务端 `Ananta/PrivateServer/logs/console-20260922-195716.log` 的 `SWITCH-TL` 行

| 墙钟 | gameTime | 事件 | 相对 `SyncSwitchSpiritConfigId` |
|---|---|---|---|
| 20:04:11.951 | 365.607 | `LiftOffOneShot_CreateChangeLodCam`<br>`SceneLodManager SetTarget name:SwitchTeleportLodCam,pos:(2832.10, 0.05, 1880.63)` | **−3.43s**（= `SyncPreSwitchSpirit` 时刻） |
| 20:04:15.381 | 369.036 | `SwitchChar_common_14` 开始加载动画 | 0.00s |
| 20:04:17.787 | 371.443 | `loading_switch_moving_seamless` 开始播 | **+2.41s** ← 上升段真正开始 |
| 20:04:27.833 | 381.456 | `LiftOffOneShot_TryDestroyChangeLodCam`（流程结束） | +12.46s |

**关键结论**：

1. 旧实现（`⓪ 传送旧单位`）在 `SyncPreSwitchSpirit` 时刻就把人挪走，
   比上升段开始早 **5.84s**，比顶点更早 ⇒ 用户看到的「点一下画面瞬移」。
2. 客户端从收到 `SyncSwitchSpiritConfigId` 到真正开始播上升段，中间隔着 **2.41s**
   （资源加载 + `SwitchChar_common_XX` 自己的前奏）⇒ `apexDelayMs` **必须 ≥ 2410**。
3. LOD 相机在 `SyncPreSwitchSpirit` 时刻就被摆到**锚点**上 —— 所以运镜的取景中心是锚点，
   而人物的真实位置是另一回事，两者不能混用。

### 客户端不给顶点信号（抓包实证）

统计 `logs/packets-*.log` 全部切人流程，客户端只发两个 C2S：

| RPC | 出现 | 说明 |
|---|---|---|
| `ReportPreSwitchSpiritFinish` (67654364) | ✅ | 开始 |
| `AskSwitchSpiritComplete` (67272187) | ✅ | 结束（约 +11s） |
| `ReportPreTeleportFinish` (63032762) | ❌ | **不发** |
| `QuerySwitchSpiritTimelineState` (68328467) | ❌ | 不发 |

⇒ **顶点只能由服务端定时触发**；同时保留 `ReportPreTeleportFinish` 处理器作为
「万一客户端/插件上报了就提前触发」的快路径。

---

## 四、实现

### 4.1 新增配置

`config/private-server.json` → `gameplay.switchAnimations`：

```json
{
  "switchType": 2,
  "commonTimelinePrefix": "SwitchChar_common",
  "avoidImmediateRepeat": true,
  "teleportTiming": "apex",     // apex | immediate
  "apexDelayMs": 3600           // 从下发 SyncSwitchSpiritConfigId 起算，必须 ≥ 2410
}
```

* `apex`（默认）—— 等上升段播完、镜头到高空将降时才传送。
* `immediate` —— 老行为，点一下立刻传送（只留给面板做 A/B 对比）。

### 4.2 服务端流程改动（`Ananta.Handlers/Game/GameRouter.SwitchTimeline.cs`）

```
PlaySwitchTimelineAsync(session, switchConfigId, templateId,
                        teleportToAnchor, skipPreSwitch,
                        teleportTiming?, apexDelayMs?, token)     ← 新增两个可选参数

  ⓪ 传送旧单位          apex 模式：**跳过**（旧单位留在原位）
  ⓪.5 spawn 同伴        apex 模式：摆在**玩家原位**前方
  ① SyncPreSwitchSpirit  带锚点（客户端据此把 LOD 相机摆到锚点）
  ② 等 ReportPreSwitchSpiritFinish
  ③ 身份交接             apex 模式：位置断言用**玩家原位**（新角色先出现在原地）
  ④ SyncSwitchSpiritConfigId   position 仍传**锚点**（取景中心）
  ④.5 ★ apex 传送        定时 apexDelayMs 后：
                          SyncUnitPositionAndFacing(unit → 锚点)   ×2（隔 180ms 补一帧）
                          + 同伴一起挪
  ⑥ 回收同伴
```

新增两个 C2S 处理器：

| 处理器 | 方法 id | 作用 |
|---|---|---|
| `OnReportPreTeleportFinish` | 63032762 | 快路径：客户端上报「上升段播完」→ 立刻传送（`Interlocked` 抢占，与定时器互斥） |
| `OnAskSwitchSpiritComplete` | 67272187 | 标定：记录整条演出播完，日志里给出 `apexDelay` 与是否已传送，用来校准 `apexDelayMs` |

新增状态：`WorldEntryState.ActiveSwitchTimeline`
（`PendingSwitchTimeline` 在播片开始时就被置空，播片阶段要用另一份记录）
以及 `PendingSwitchTimeline4229938.TeleportTiming / ApexDelayMs / OriginPosition / TryBeginApexTeleport()`。

### 4.3 面板参数

`POST /api/story/timeline/play` 新增两个入参：

```json
{
  "switchConfigId": 54,
  "targetSpiritId": 15020992,
  "teleport": true,
  "teleportTiming": "apex",     // 或 "immediate"，也接受 true/false
  "apexDelayMs": 3600           // 不填走配置
}
```

响应新增 `teleportTiming` / `apexDelayMs` / `teleportPlan`，`note` 会写明
「先在玩家原位出现，N ms 后送到锚点」。

### 4.4 顶点探针（用来精确标定 `apexDelayMs`）

`tools/bep_plugin/SwitchApexProbe/`。**只读探针，不改任何游戏行为**，
但 ⚠️ **默认不启用**（v1 曾导致 Fatal，见第六节）：
产物放 `Ananta/BepInEx/_disabled/SwitchApexProbe.dll.fixed-v2`，
用 `bash tools/switch_apex_probe.sh enable|disable|status` 控制。

挂的钩子：

| 类 | 方法 | 挂法 |
|---|---|---|
| `LX6.GUI.SwitchTeleportManager` | `Flow_Prepare/Showing/End`、`OnSyncPreSwitchSpirit`、`OnSyncSwitchSpiritConfigId`、`ReportPreSwitchSpiritFinish` | 前置+后置（安全，实测通过） |
| `LX6.GUI.LiftOffOneShotFlow` | `InitInfo`、`TriggerPrepare/Showing/End`、`PreShow_ShowFinished`、`OnSwitchLodCamPosToEnd`、`OnEnterLoop/OnEndLoop` | **仅后置** |
| `LX6.TimelineScript.LoadingSwitchSeamlessFeature` | `BeforePlay_After`、`NotifyPreShowFinished`、`NotifyResLoaded`、`NotifyEnterLoop`、`InitYMoveHeight`、`CollectTransformClipInfo` | **仅后置**（dump 全部时间点，含 `★APEX`） |
| 同上 | `Prepare`、`BeforePlay_Before`、`ProcessEvent` | **仅前置** |
| 同上 | ~~`InitMoveTimePoint`~~ | **故意不挂** —— 挂它必 Fatal（见 6.2） |

日志：`Ananta/BepInEx/SwitchApexProbe.log`，每行带「相对插件加载的秒数」。
关键行形如：

```
[SEAMLESS-DUMP] BeforePlay_After | MOVING clip: start=… dur=… end=…
   | Y: start=… ★APEX=… end=… dur=… | XZ: … | Loop: …
[SEAMLESS-DUMP] BeforePlay_After | ★相对 MOVING 片段起点: 上升 x.xxx s → 顶点 y.yyy s → 落地 z.zzz s
```

**标定方法**（最省事）：在同一份日志里取
`OnSyncSwitchSpiritConfigId` 那行的秒数 `T0`，和含 `★APEX` 的那行秒数 `T1`，
`apexDelayMs ≈ (T1 − T0) × 1000`。填进配置后记得 `disable`。

⚠️ 若启用后游戏崩溃：先看 `Ananta/BepInEx/ErrorLog.log`，
出现 `SEHException` / `Fatal error` 且栈里有 `DynamicClass.DMD<` ⇒ 就是探针，立刻 disable。

---

## 五、验证清单

1. **服务端**：`bash tools/build.sh` 或 PowerShell + 系统 `dotnet 8`（见下方坑）→ 0 error。
2. **面板**：点一条切人动画，看返回里的 `teleportTiming` = `apex`、`apexDelayMs` = 3600。
3. **服务端日志**应出现：
   ```
   [SWITCH-TL] ⓪ apex 模式：**不在 SyncPreSwitchSpirit 时刻传送**（旧单位留在原位 …）
   [SWITCH-TL] ③ 身份交接完成 … handoff=(玩家原位) anchor=(锚点) timing=apex
   [SWITCH-TL] ④.5 apex 传送已排程：3600ms 后把 unit=… 从 (原位) 送到锚点 (锚点) …
   [SWITCH-TL] ④.5 ★ apex 传送执行（定时器（apex 顶点））：…
   [SWITCH-TL] ⑦ 客户端上报 AskSwitchSpiritComplete —— 整条换人演出播完 … apexTeleport=已传送
   ```
4. **画面上**：点一下 → 镜头开始抬升 → **在最高点/刚开始下降时**人物落到锚点 → 镜头俯冲下来。
5. **对比诊断**：把 `teleportTiming` 传 `"immediate"`，应复现「点一下立刻瞬移」。

---

## 六、★ 2026-09-23 首次实测：点了就崩 —— 定位与修复

### 6.1 现象

点切人动画 → 游戏**直接闪退**（无异常弹窗）。`log/Player.log` 在
`LiftOffOneShot_CreateChangeLodCam` 那一行**戛然而止**：

```
[info]2026-09-23 02:58:55.568-88.06464-33901 [CameraTextureLayerLimitManager] LiftOffOneShot_CreateChangeLodCam]
[info]2026-09-23 02:58:55.57-88.06464-33901 SceneLodManager SetTarget name:SwitchTeleportLodCam,pos:(3142.59, -0.10, 2532.11)
[warning]... target:(3142.59, -0.10, 2532.11), secondTarget:(2809.91, 10.07, 1940.67)
<日志到此结束>
```

服务端侧是正常的（apex 逻辑按设计跑）：

```
[SWITCH-TL] ⓞ 演出 ... timing=apex apexDelay=3600ms
[SWITCH-TL] ⓪ apex 模式：**不在 SyncPreSwitchSpirit 时刻传送**（旧单位留在原位 (3142.59,-0.1,2532.11)…）
[SWITCH-TL] ① SyncPreSwitchSpirit configId=55 ...
[SWITCH-TL] 客户端 10000ms 未上报 ReportPreSwitchSpiritFinish，走超时兜底继续   ← 客户端已经死了
[SWITCH-TL] 超时兜底失败: Cannot access a disposed object.
```

### 6.2 根因：**顶点探针插件（SwitchApexProbe）自己把游戏搞崩了**

`Ananta/BepInEx/ErrorLog.log`：

```
Fatal error. System.Runtime.InteropServices.SEHException (0x80004005): External component has thrown an exception.
Repeat 2 times:
   at Il2CppInterop.Runtime.IL2CPP.il2cpp_runtime_invoke(IntPtr, IntPtr, Void**, IntPtr ByRef)
   at DynamicClass.DMD<LX6.TimelineScript.LoadingSwitchSeamlessFeature::InitMoveTimePoint>(...)
   at DynamicClass.(il2cpp -> managed) InitMoveTimePoint(IntPtr, Il2CppMethodInfo*)
   at Il2CppInterop.Runtime.IL2CPP.il2cpp_runtime_invoke(...)
   at DynamicClass.DMD<LX6.TimelineScript.LoadingSwitchSeamlessFeature::BeforePlay_Before>(...)
```

`SwitchApexProbe.log` 最后一行正是 `94.350s [SEAMLESS] → InitMoveTimePoint`，
然后就没有下一行了 —— 崩在这。

**机制**：探针 v1 给 `LoadingSwitchSeamlessFeature.InitMoveTimePoint` 同时挂了
`prefix` **和** `postfix`。这个方法是**零参数 private、被 native 代码直接调用**，
HarmonyX 的 detour 会经 `il2cpp_runtime_invoke` 回到托管侧；而它方法体里本来就会抛
托管异常（`InitMoveTimePoint` 跑之前 `yMoveStartTime/★APEX/yMoveEndTime` 全是 0，
说明曲线/字段没准备好 ⇒ NRE），异常**跨不过 native 边界** ⇒ 整个进程 fatal。

**关键点：不挂它的时候，同一个 NRE 只是被 IL2CPP 吞掉并打日志，游戏继续跑。**
⇒ 探针把一个"被容忍的客户端 bug"升级成了致命崩溃。
（`BepInEx/LogOutput.log` / `ErrorLog.log` 的时间戳 = 02:58:55，正好是插件加载之后，
也印证了这一点。）

### 6.3 修复

1. **`Ananta/BepInEx/plugins/` 清空** —— 探针移出，游戏恢复可运行。
2. **探针改 v2**（`tools/bep_plugin/SwitchApexProbe/`）：
   * **彻底删掉 `InitMoveTimePoint` 的钩子**（以及 `CheckExecuteOutLoopClip`）。
   * 想读它算出来的字段 → 改成 hook **下游**的
     `BeforePlay_After` / `NotifyPreShowFinished` / `NotifyResLoaded` / `NotifyEnterLoop`
     的 postfix，那时字段已经写好了，且不碰危险方法。
   * `Hook()` 加**硬护栏**：同一个方法 prefix 与 postfix 同时传时，
     自动丢弃 prefix 只留 postfix。
   * `LiftOffOneShotFlow` 的钩子统一收敛成 **postfix-only**。
3. 新增 `tools/switch_apex_probe.sh`：`status` / `enable` / `disable`。
   **探针默认不启用**（产物放 `BepInEx/_disabled/`），只有要标定 `apexDelayMs` 时才
   `enable`，标完 `disable`。

### 6.4 顺带发现：运镜的 Cinemachine 轨道本身是坏的（**既有问题，与本改动无关**）

`Ananta/log/Player-prev15.log` 里，`loading_switch_moving_seamless` 播放期间
**每帧**刷同一个错误：

```
[error] loading_switch_moving_seamless 2 System.NullReferenceException
  at LX6.TimelineScript.CinemachineMixer.ProcessFrame(Playable, FrameData, Object)
     [CinemachineMixer.cs 176]
```

⇒ 那条 timeline 的 **Cinemachine 轨道绑不上虚拟相机**，每帧 NRE。
也就是说：

| 相机 | 状态 |
|---|---|
| `SwitchTeleportLodCam`（LOD 过渡相机，`LiftOffOneShotFlow` 建的） | ✅ 正常创建并摆到锚点 |
| 运镜用的 Cinemachine 虚拟相机（timeline 里的 authored 轨道） | ❌ 每帧 NRE，**动不了** |

**含义**：目前私服环境下，你在画面上看到的「镜头移动」大概率来自 **LOD 相机**，
而 timeline authored 的上升/下降运镜是坏的。所以：
* `apexDelayMs` 仍然有意义（它对齐的是**客户端脚本时间线**，不是相机视觉），
* 但"镜头爬到高空"这个**视觉参照**在修好 Cinemachine 轨道之前可能看不到。
* 这条与 T-pose 那条线（169 个动画剪辑缺失 / timeline 资源不全）很可能是同一个根因，
  属于**下一步要单独查的**客户端资源问题。

---

## 七、坑（下次别再踩）

### 7.1 Agent 里 `dotnet build` 会**静默空转**（退出码 0、零输出、产物不变）

`bash tools/build.sh`、内联 `dotnet build`、PowerShell `& dotnet build`、
`Start-Process`、`*>` 重定向 —— **都中过招**（沙箱吞掉了编译进程的输出与文件写入）。

**唯一可靠的判据**：
```bash
ls -la --time-style=full-iso Ananta.Server/Ananta.App/bin/Debug/net8.0/Ananta.Handlers.dll
```
时间戳没动 = 没编译。

**✅ 唯一稳定可用的办法：把构建写进 `.sh` 脚本文件，再 `bash <脚本>` 跑，输出重定向到文件。**

```bash
cat > /tmp/b.sh <<'SH'
set -u
cd "F:/Game/AnantaCBT3/Ananta/PrivateServer"
export ProgramFiles="C:\\Program Files"
export CommonProgramFiles="C:\\Program Files\\Common Files"
export APPDATA="C:\\Users\\Administrator\\AppData\\Roaming"
export NUGET_PACKAGES="C:\\Users\\Administrator\\.nuget\\packages"
"/c/Program Files/dotnet/dotnet.exe" build Ananta.Server/Ananta.App/Ananta.App.csproj --nologo -v m
echo "BUILD_EXIT=$?"
SH
bash /tmp/b.sh > /tmp/b.log 2>&1; echo "bytes=$(wc -c < /tmp/b.log)"; cat /tmp/b.log
```

* **必须用 `/c/Program Files/dotnet/dotnet.exe`（系统 8.0.403）**；
  `.dotnet10`（SDK 10.0.401）**缺目标包** → `NETSDK1127`。
* 别用 `set -euo pipefail` —— `export "ProgramFiles(x86)=…"` 在 bash 里是
  非法标识符会直接退出。
* `bytes=0` 就是空转了。

### 7.2 `PendingSwitchTimeline` 在播片阶段已经是 null

`OnReportPreSwitchSpiritFinish` 里 `state.PendingSwitchTimeline = null;` 之后才进播片，
所以 `AskSwitchSpiritComplete` / `ReportPreTeleportFinish` 到达时读不到它 ——
必须用新增的 `ActiveSwitchTimeline`。

### 7.3 `apexDelayMs` 的下界是 2410ms

这是「客户端收到 `SyncSwitchSpiritConfigId` → 真正开始播上升段」的固定夹层。
设得比它小 = 镜头还没抬起来人就走了，等于没修。

### 7.4 探针装进 `plugins/` 前，先想清楚它会不会崩游戏

见 6.2 / 6.3。规则：**同一方法绝不同时挂 prefix+postfix**；危险方法只读它**下游**的字段。
排查口诀：`BepInEx/ErrorLog.log` 里出现 `SEHException` 且栈里有 `DynamicClass.DMD<`
⇒ 是你自己的 Harmony 探针，删 dll 即可恢复。
