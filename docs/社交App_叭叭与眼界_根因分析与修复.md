# 社交 App「叭叭 / 叭卜 / 眼界」内容为空 —— 根因分析与修复

> 日期：2026-09-23 ~ 09-24（第 13 轮）
> 用户原话：
> 1. 「眼界、叭叭、叭卜 APP里面的内容是空的，能帮我修复吗」
> 2. 「叭卜app里还是空的，正常应该是有类似**角色邀约**的内容的。你再分析下并修复」

---

## 0. 结论速览

### 0.1 ★ 三个 App 的**正确**对应关系（第 2 次报障后才定案）

**资源名是唯一可靠的判据**（`SguiImageConfig.ImgPath`）：

| 用户叫法 | 客户端 App | `MobileMenuSGuiConfig.Id` | 判据 | 内容来源 | 传输 |
|---|---|---|---|---|---|
| **叭叭** | `Friends` | 3 | 图标 `S_MainPhone_icon_**baba**.png`（`SIconId=28001024`）；`SystemUnlockConfig.Id=147` = 「好友（原**叭叭**好友聊天功能）」 | `Friends*` 系列表 | UX-RPC |
| **叭卜** | `Bubble` | 12 | App Store 截图 `S_img_APPStore_**babu**1/2.png`（`DisplayImage=[28003853,28003854]`） | `SocialMediaConfig`(55) + `AgentDataSets*` | UX-RPC |
| **眼界** | `Scope` | 17 | `GuideId = "TwitterGuide"`，`SystemIdList=[115]`（`SystemUnlockConfig.Id=115` 描述「Scope」） | `TuiteConfig` 等 7 表 | ☠️ **HTTP REST** |

> ⚠️ 第一轮我把「叭叭」猜成了 `Bubble`（因为 `Bubble.GuideId = "BaBoGuide"`），**是错的**。
> `BaBo` 这个 guide 名对 叭叭/叭卜 都模棱两可；**资源路径里的 `baba` / `babu` 才是硬证据**。
> 教训：**给中文 App 名找归属，优先查 `SguiImageConfig` 的资源路径**（拼音直接写在文件名里）。

### 0.2 「叭卜」的两个内容面

`Bubble`（叭卜）点进去后有两块内容，**数据通道完全不同**：

| 界面 | 客户端 | 数据 | 状态 |
|---|---|---|---|
| **首页动态流** | `NewBubbleMgr:AskPostList` | `AskMomentsPostSimpleInfos`(63452251) → `SocialMediaConfig` 55 条 | ✅ 已实现 |
| **角色主页 → 今日行程（邀约）** | `BubbleFriendHomePanelStore` 的 `SCHEDULE` tab | `SyncFavorNpcTimeTableInfos`(64219939) → `AgentDataSets*Config` | ✅ 已实现 |

用户说的「类似**角色邀约**的内容」= 后者（`NpcDaliyManager:GetTodayScheduleList`，
渲染出来是「邀约：共餐 / 电影 / 摩天轮 / 保龄球 / 兜风约会」那种日程条目）。

### 0.3 ☠️☠️☠️ 第 2 次报障的**真正根因**：处理器白名单

第一轮把 8 个 `AskMoments*` 处理器**全写好了**、编译通过、DLL 里也有字符串，
但客户端日志显示：

```
[04:06:48] -> rpc AskMomentsPostSimpleInfos [0x03C8345B] #212836645 5b
[04:06:48] ! [RPC4229938] unimplemented AskMomentsPostSimpleInfos -> typed-default list7-empty 2b
```

**「unimplemented」** —— 处理器没被注册。

原因：`GameRouter.Build()` 用的是

```csharp
var registered = AttributedHandlerRegistry.RegisterSelected(router, this, Enabled4229938MethodIds);
```

**只注册白名单 `Enabled4229938MethodIds` 里的方法 id**。
写了 `[Handler]` 但没加进白名单 ⇒ **静默跳过**，服务端零报错，客户端界面空。

启动日志的判据：`[ROUTER] game 注册 180 个处理器` —— 加完 9 个 id 后变成 **189**。

**已加启动自检**（和骇入自检同一个位置），任何一个 False 都说明白名单漏了 id：

```
[ROUTER] 社交自检: AskMomentsPostSimpleInfos=True AskMomentsPostInfos=True AskMomentsMarkRead=True
        AskMomentsLikePost=True AskMomentsSendCommentWithId=True AskMomentsUnreadMessage=True
        AskServerGraffitoUrl=True | enabled=True graffito='http://127.0.0.1:5809'
```

---

## 1. 叭卜·首页动态流（Bubble / Moments）

### 1.1 根因

`MethodId.cs` 里有 39 个 `AskMoments*` / `AskTuite*` 方法 id，但 `Ananta.Handlers` 里
**零个 `[Handler]`**（第一轮），加上白名单问题（第二轮），客户端请求一直回空列表。

### 1.2 客户端流程（CBT2 反混淆 lua，逻辑与 CBT3 一致）

`tools/3_deobfuscated/629_LX6_Manager_GameSystem_NewBubbleMgr.lua`：

```lua
function M:OnAfterSwitchScene(_, switchType)     -- 进世界后自动拉
    self:AskPostList(UX.Game.GetPostType.All)
end

function M:AskPostList(getPostType)
    gClientToGameDelegate:AskMomentsPostSimpleInfos(self.lastPostId, getPostType).Callback =
        function (err, data)
            if err ~= MessageConfig.Ok then return end
            for i = 1, #data do self.postDict[data[i].Id] = data[i] end
            if not table.isNilOrEmpty(data) then self:BuildPostList() end
        end
end

function M:BuildPostList()
    local cfg = SocialMediaConfig.GetConfig(v.PostConfigId)   -- ★ 正文来自客户端配置
    if cfg and cfg.IfPinStory or info.IsPinStory then ... SHARE(3)
    elseif cfg and cfg.IsStory or info.IsStory   then ... STORY(2)
    else ... POST(1) end
end

function M:HasRedDot(id)
    local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)
    return cfg.WithMe and not info.IsRead          -- ★ 红点 = WithMe 且未读
end
```

⇒ **帖子正文/配图/点赞数全在客户端配置里**，服务端只需要产出
「有哪些帖子（`PostConfigId` = `SocialMediaConfig.Id`）」+「个人状态」。

### 1.3 ★★★ 线格式取证：权威 dump 这次取不到

`PostSimpleClientInfo` / `PostPlayerCommentClientInfo` / `SimpleUnreadMessage`
在 CBT3 元数据里**字段被剥离**（全项目共 72 个这样的空类）：

| 来源 | 结果 |
|---|---|
| `ux_rpc/ux_game_all.dump.cs` | `public class PostSimpleClientInfo {}` |
| `ux_rpc/ux_all.il2cpp.h` | `struct ..._Fields { };` |
| `base/il2cpp.h`（434 MB 全量） | 同样空 |
| `DummyDll/Auto.Client.dll`（用 `MetadataReader` 数过） | `fields=0` |
| CBT2 参考服务端 `GeneratedStructs.cs` | `// No fields found in dump for PostSimpleClientInfo` |

**改用「两张独立生成的 Lua 表互证」**：

| 文件 | 位置 | 结果 |
|---|---|---|
| `RPCDeserializeAuto.lua`（读侧） | `Auto.Reader[513]` | 18 字段 + `ReadList7Bit` |
| `RPCSerializeAuto.lua`（写侧） | `Auto.WritePostSimpleClientInfo` | **同样 18 字段 + `WriteList7Bit`** |

再加 CBT2 `Auto.Reader[183]` 字段列表/顺序逐字段一致
（只有列表 framing 从 `ReadList`(Int32) 演进成 `ReadList7Bit`）。

**入参/返回类型**以 `ux_game_all.dump.cs` 的**接口签名**为准：

```csharp
UXRPCTask<List<PostSimpleClientInfo>> AskMomentsPostSimpleInfos(uint lastId, GetPostType postType);
UXRPCTask<List<PostSimpleClientInfo>> AskMomentsPostInfos(List<uint> postIds);
UXRPCTask<List<SimpleUnreadMessage>>  AskMomentsUnreadMessage();
UXRPCTask<bool>                       AskMomentsHaveUnreadMessage();
UXRPCTask                             AskMomentsMarkRead(List<uint> postIds);
UXRPCTask                             AskMomentsLikePost(uint postId, bool like);
UXRPCTask<PostPlayerCommentClientInfo> AskMomentsSendCommentWithId(uint postId, uint commentId);
UXRPCTask                             AskMomentsTapPostWithCount(uint postId, List<EmojiData> emojiList);
```

> ⚠️ 已发现 proxy lua 与 dump 冲突的一例：`AskMomentsSendCommentWithId` 在 lua 里是 void，
> dump 签名是 `UXRPCTask<PostPlayerCommentClientInfo>` ⇒ **以 dump 为准**。
> ⚠️ 也别无条件相信 proxy lua：`Auto.Reader[282]`（`SpiritHackerJobInfo`）**多一个 `DailyCounts`**（旧 build）。

### 1.4 实测线格式（`GET /api/socialapp` 的 `wire.head`，整包 2270 字节）

```
FF 38 | FF 91D4C305 02 91D4C305 6A42AE6A 01 01 01 00000000 00 FF01 FF01 FF01 00 00 00000000 00000000 01 00 ...
│  │    │  └─Id────┘ │ └PostConfigId┘ └─Date──┘ │  │  │  └Likes─┘ │  │    │    │    │   │  │  └Acquire┘ └Activity┘ │  └IsPinStory
│  │    │            └PostType=2(STORY)         │  │  └Title(空)   └Liked        │    │    │   └HasNewLike      └IsStory
│  │    └Complex 标记                            │  └Approved                     │    │    └PlayerComments=FF01
│  └Int7(55+1)=0x38                              └ImageUrl(空)                    │    └Comments=FF01
└列表非空标记                                                                    └LikeNpcs=FF01
```

**18 个字段逐一对齐** ✓

### 1.5 处理器（8 个）

| 方法 id | 名字 | 返回 |
|---|---|---|
| 63452251 | `AskMomentsPostSimpleInfos` | `List<PostSimpleClientInfo>` |
| 63879443 | `AskMomentsPostInfos` | 同上 |
| 63525787 | `AskMomentsUnreadMessage` | `List<SimpleUnreadMessage>` |
| 63304982 | `AskMomentsHaveUnreadMessage` | `bool` |
| 63132673 | `AskMomentsMarkRead` | void（写存档） |
| 63895686 | `AskMomentsLikePost` | void（写存档） |
| 63943988 | `AskMomentsSendCommentWithId` | `PostPlayerCommentClientInfo` |
| 63024597 | `AskMomentsTapPostWithCount` | void |

---

## 2. 叭卜·角色主页「今日行程」（**邀约**）

### 2.1 客户端链路

`815_LX6_SGUI_StoreDefine_BubbleFriendHomePanelStore.lua`：

```lua
function M:RefreshContent()
    if index == FriendHomeShowType.SCHEDULE then
        self.contentList = self.daliyMgr:GetTodayScheduleList(self.agentType)   -- ★ 邀约列表
    elseif index == FriendHomeShowType.PROCESS then ...
    elseif index == FriendHomeShowType.SHARE then ...
    end
end
```

`628_LX6_Manager_Npc_NpcDaliyManager.lua`：

```lua
function M:OnSyncNpcTimeTableInfos(timeTableInfos)        -- ★ 本轮的 S2C
    self.NpcTimeTableInfos = timeTableInfos or {}
    for k, v in pairs(self.NpcTimeTableInfos) do
        self.NpcTimeTableLists[k] = { v.Schedule0, v.Schedule1, v.Schedule2, v.Schedule3, v.Schedule4 }
        if self.NpcTimeTableLists[k][1].EndDaySecond < self.NpcTimeTableLists[k][1].StartDaySecond then
            self.NpcTimeTableLists[k][1].StartDaySecond = self.NpcTimeTableLists[k][1].StartDaySecond - SECONDS_PER_DAY
        end
        if self.NpcTimeTableLists[k][5].EndDaySecond < self.NpcTimeTableLists[k][5].StartDaySecond then
            self.NpcTimeTableLists[k][5].EndDaySecond = self.NpcTimeTableLists[k][5].EndDaySecond + SECONDS_PER_DAY
        end
    end
end

function M:GetTodayScheduleList(agentType)
    for i = 1, #scheduleList do
        if scheduleInfo.ActivityId ~= 0 then ret[#ret + 1] = i end   -- ★ 0 = 空档，过滤掉
        if self:CheckScheduleOnGoing(scheduleInfo) then break end
    end
end

function M:OnRenderActivity(tag, btn, index)
    local cfg = ActivityConfig.GetConfig(scheduleInfo.ActivityId)   -- ★ 内容来自活动表
    store.startTimeLabel = self:FormatTime(startTime)               -- 秒 → HH:MM
end

function M:CheckScheduleOnGoing(scheduleInfo)
    local cTime = AtmosphereManager.Instance:GetGameTime()
    return scheduleInfo.StartDaySecond < cTime and cTime <= scheduleInfo.EndDaySecond
end
```

### 2.2 数据来源（两张客户端表）

| 表 | 行数 | 作用 |
|---|---|---|
| `AgentDataSetsTimeTableConfig` | 75 | 每个角色 4 个时段的**起点**：`Schedule1..4` = **HHMM 整数**（`800` = 08:00、`1200` = 12:00、`1700` = 17:00、`2200` = 22:00） |
| `AgentDataSetsActivityConfig` | 284 | 活动条目：`AgentTag` / `Raid` / `Schedule=[{Index,Priority}]` / `ActivityPerformance`（"坐着刷手机"/"麦当劳吃汉堡"）/ `Icon` / `MapName` |

`Schedule[].Index` ∈ {1,2,3,4} ⇒ 槽位；同槽位多条按 `Priority` 取最高。

### 2.3 5 个槽位怎么铺（照客户端自己的 wrap 修正反推）

```
Schedule0 = [S4 - 86400, S1)     昨天的第 4 段（兜住"现在早于第一个时段起点"）
Schedule1 = [S1, S2)
Schedule2 = [S2, S3)
Schedule3 = [S3, S4)
Schedule4 = [S4, S1 + 86400)     今天的第 4 段，尾巴拖到明天
```

5 段无缝覆盖 24h ⇒ 客户端 `GetCurrentSchedule` 永远有值
（拿不到时 `CheckNpcInBusy` 直接返回 true，角色会一直显示"忙"）。
因为服务端**已经**把跨天偏移算进去了，客户端那两段 wrap 修正不会触发（幂等）。

`CurrentSpoonAgentId = 0` —— 表示该角色的世界实体没被投放；
`CheckNpcInBusy` 只在 `CurrentSpoonAgentId ~= 0 且与当前时段不匹配` 时判"忙"，给 0 最安全。

### 2.4 ☠️ 字典计数是 **Int7**，不是 Int32

客户端 `midToReader[64219939]`：

```lua
local timeTableInfos = Base.ReadDict7Bit(reader,
    function (r) return r:ReadUInt32() end,
    function (r) return Base.ReadComplex(r, Auto.Reader[286]) end)
```

而 `UxSerializer.WriteDictionary` 的默认计数是 **`UxCountEncoding.Int32`**
（`UxContract.cs:265`）⇒ 契约里**必须显式**：

```csharp
[UxCollection(Count = UxCountEncoding.Int7)]
public Dictionary<uint, NpcTimeTableInfo4229938> timeTableInfos = new();
```

### 2.5 结构（`Auto.Reader[286]` / `[1101]`）

```csharp
NpcTimeTableScheduleInfo   // [1101]，Complex
    ActivityId:u32, StartDaySecond:i32, Position:UXVector3(**Struct,无标记**),
    SpoonAgentId:i32, EndDaySecond:i32, RaidId:u32

NpcTimeTableInfo           // [286]，Complex
    Schedule0..4:NpcTimeTableScheduleInfo(Complex，可为 null),
    CurrentSpoonAgentId:i32, SpoonPosition:UXVector3(**Struct,无标记**),
    TempSchedule:?Complex, IsTempScheduleOnly:bool, RefreshDay:i64
```

⚠️ `UXVector3` 在 `Client4229938Contracts.Auto.cs` 里是 `[UxContract]`（非 Inline ⇒ 带标记），
但客户端用 `Base.ReadStruct` 读 ⇒ 字段上要 `[UxObject(Encoding = UxObjectEncoding.Struct)]` 覆盖。

### 2.6 实测（`GET /api/socialapp` 的 `npcSchedule`）

```
catalog         = AgentDataSetsTimeTableConfig=75 个角色 / AgentDataSetsActivityConfig=284 条活动
builtAgentCount = 75
wireBytes       = 14703
sample agentTag 4:
    -02:00 -> 08:00  activity 11400044  raid 0
     08:00 -> 12:00  activity 11400041  raid 23300888
     12:00 -> 17:00  activity 11400043  raid 23300888
     17:00 -> 22:00  activity 11400042  raid 23300888
     22:00 -> 08:00  activity 11400044  raid 0
```

---

## 3. 改动文件清单

| 文件 | 改动 |
|---|---|
| `Ananta.Core/Protocol/Client4229938/MethodId.cs` | 补 `AskServerGraffitoUrl`(63489995) 的说明（常量本来就有） |
| `Ananta.Core/ClientData/Client4229938/SocialCatalogRepository4229938.cs` | **新增**。读 `SocialMediaConfig` / `SocialMediaNPCConfig` / `SocialMediaCommentConfig` |
| `Ananta.Core/ClientData/Client4229938/NpcScheduleCatalogRepository4229938.cs` | **新增**。读 `AgentDataSetsTimeTableConfig` / `AgentDataSetsActivityConfig`（邀约） |
| `Ananta.RpcTypes/Client4229938/Methods/Game/SocialAppMethods4229938.cs` | **新增**。11 个契约类（8 个动态 + 3 个邀约，含完整取证注释） |
| `Ananta.Handlers/Game/GameRouter.SocialApp.cs` | **新增**。8 个动态处理器 + `AskServerGraffitoUrl` + `BuildSocialPostList()` + `BuildNpcTimeTableInfos()` |
| `Ananta.Handlers/Game/GameRouter.cs` | ☠️ **把 9 个方法 id 加进 `Enabled4229938MethodIds` 白名单** + 新增社交启动自检 |
| `Ananta.Handlers/Game/GameRouter.Baseline.cs` | 新增基线步骤 `socialapp`（推 `SyncFavorNpcTimeTableInfos`） |
| `Ananta.Core/State/PlayerState.cs` | 新增 `SocialReadPosts` / `SocialLikedPosts` / `SocialPlayerComments`（存档） |
| `Ananta.Core/Configuration/PrivateServerConfig.cs` | 新增 `gameplay.socialApp`（`enabled` / `postDateBaseUnix` / `includeAllPosts` / `postDateStepSeconds` / `graffitoUrl` / `sendNpcSchedule`） |
| `Ananta.App/DebugApiServer.cs` / `.Content.cs` | `GET /api/socialapp`（含动态线格式探针 + 邀约探针）、`POST /api/socialapp/reset`、`/social_media/*` 探针 |
| `Ananta.Server/ClientData/4229938/Configs/` | **补 3 张表**：`SocialMediaConfig.json` / `SocialMediaCommentConfig.json` / `SocialMediaTabConfig.json` |
| `config/private-server.json`、`.example.json` | 新增 `gameplay.socialApp` |

> ☠️ **配置目录的坑**：`Ananta.Server/ClientData/4229938/Configs/` 是**手工维护的子集**
> （356 张），不是 `ConfigDump_v3`（全量）的拷贝。`SocialMediaNPCConfig.json` 在，
> 但 `SocialMediaConfig.json` / `SocialMediaCommentConfig.json` **不在** ⇒
> 第一次跑出来是 `SocialMediaConfig=0 条动态`。加功能时**必须确认要读的表已发布**。

---

## 4. 眼界（Scope）—— 机制查明，数据待下一轮

### 4.1 它**不走 UX-RPC**，走 HTTP REST

客户端 `143_LX6_Utils_CommonRequestUtils.lua:141`：

```lua
function M.Start(request, args)
    local baseUrl = gCS.LuaUtils.GetGraffitoUrl()      -- ★ 基址
    local url = ("%s%s"):format(baseUrl, request.url)
    ...
    gCS.LuaUtils.HttpGet(url, onResponse)              -- 或 HttpPost
end

function M.HandleResponse(args)
    local responseInfo = json.decode(args.responseContent)
    if responseInfo.code == 0 then                     -- ★ 要求 code == 0
        successCallback(responseInfo.data)             -- ★ 数据在 data
    end
end
```

`RequestMap` 里 **20 个端点**（同文件 22-127 行）：

```
/social_media/api/user/profile?{viewRoleId}
/social_media/api/moment/recc_list?{page}&{pageSize}&{menuTuiteType}     ← 眼界首页推荐流
/social_media/api/moment/follow_list?{page}&{pageSize}
/social_media/api/moment/detail?{momentId}
/social_media/api/moment/like | cancel_like | collect | cancel_collect   (POST)
/social_media/api/moment/collect_list?{categoryId}&{page}&{pageSize}
/social_media/api/moment/list_by_topic?{topicId}&{page}&{pageSize}
/social_media/api/comment/list?{momentId}&{page}&{pageSize}
/social_media/api/comment/add | like | cancel_like | delete             (POST)
/social_media/api/follow/add | delete                                    (POST)
/social_media/api/trend/list?{areaId}&{page}&{pageSize}
```

POST 会带 `roleId` + `skey`（`gSKeyManager:GetCachedSKey()`）。

### 4.2 基址从哪来 —— 服务端能给

`AskServerGraffitoUrl`(63489995) → `UXRPCTask<string>`
（`ux_game_all.dump.cs:1894074`）—— 客户端**向服务端索要**这个基址。
私服以前不实现 ⇒ 空串 ⇒ URL 是相对路径 ⇒ 请求发不出去 ⇒ 界面恒空。

**已做的**：
1. 实现 `AskServerGraffitoUrl` → 返回 `gameplay.socialApp.graffitoUrl`（默认 `http://127.0.0.1:5809`）；
2. 调试 HTTP 服务加 `/social_media/*` 兜底：**把客户端真正调用的端点/查询串/请求体打进日志**，
   并回一个合法的 `{"code":0,"data":[]}`。

### 4.3 下一轮要做的

响应体形状**没有权威 dump**（REST 是 JSON，没有字段序表），只能从客户端
`SocialNetWorkUtils.RefreshCommonMomentItem` 读的字段反推：

```lua
store.likeButton.isSelected = data.isLike
store.collectButtonCtrl     = data.isCollect and 1 or 0
store.content               = M.GetMomentFormatContent(data)
store.time                  = M.GetFormatTime(data.publicTime)
store.hotCount              = M.GetCountFormat(data.viewCount)
store.commentCount          = M.GetCountFormat(data.commentCount)
store.likeCount             = M.GetCountFormat(data.likeCount)
store.isOfficial            = data.roleInfo.isCertified == true
store.officialName          = "@" .. data.roleInfo.account
avatarStore.headIcon        = M.GetSGuiAvatarId(data.roleInfo)
local imageList, isVideo    = M.GetSocialNetworkImageList(data)
local tuiteCfg              = M.GetTuiteConfig(data)      -- → TuiteConfig.Id
```

⇒ 字段名是小写驼峰（`isLike` / `publicTime` / `roleInfo` …），
和 UX-RPC 那套 PascalCase 完全不是一回事。

**步骤**：① 让用户打开一次眼界 App；② 从服务端日志拿到真实端点清单；
③ 按上面的字段把 `TuiteConfig` 转成响应体；④ 逐端点补齐。

---

## 5. 验证

```bash
bash tools/build.sh          # 0 警告 0 错误，多态审计通过
curl http://127.0.0.1:5809/api/socialapp
```

启动日志（**最关键的两行**）：

```
[ROUTER] game 注册 189 个处理器 | 骇入自检: ... EnableHack=True 电池=6/6
[ROUTER] 社交自检: AskMomentsPostSimpleInfos=True AskMomentsPostInfos=True AskMomentsMarkRead=True
        AskMomentsLikePost=True AskMomentsSendCommentWithId=True AskMomentsUnreadMessage=True
        AskServerGraffitoUrl=True | enabled=True graffito='http://127.0.0.1:5809'
```

> 加白名单之前是 **180** 个处理器（`AskMomentsPostSimpleInfos` 一直回 `unimplemented`）；
> 加完 9 个 id 后是 **189**。**这两个数字是判断"处理器到底有没有挂上"的第一判据。**

`/api/socialapp` 实测：

```
catalog         = SocialMediaConfig=55 条动态 / SocialMediaNPCConfig=46 个发布者 / SocialMediaCommentConfig=231 条评论（WithMe=1）
builtPostCount  = 55
wire bytes      = 2270
firstPosts[0]   = {id:96720017, postType:2, postConfigId:96720017, isStory:true, comments:0}

npcSchedule.catalog         = AgentDataSetsTimeTableConfig=75 个角色 / AgentDataSetsActivityConfig=284 条活动
npcSchedule.builtAgentCount = 75
npcSchedule.wireBytes       = 14703
```

```
[SOCIAL][GRAFFITO] GET /social_media/api/moment/recc_list?page=1&pageSize=10&roleId=1&skey=x
```

服务端：login 5200/5201 + game 5202 + 调试面板 `http://127.0.0.1:5809/` 全部 listening。

### 5.1 客户端行为取证（判定"到底有没有发请求"）

```bash
grep -a "AskMomentsPostSimpleInfos" logs/console-*.log
# 修好前：
#   -> rpc AskMomentsPostSimpleInfos [0x03C8345B] #212836645 5b
#   ! [RPC4229938] unimplemented AskMomentsPostSimpleInfos -> typed-default list7-empty 2b
# 修好后应只剩 -> rpc ...，不再有 unimplemented
```

---

## 6. 还没做 / 边界

1. **眼界 / Scope 的数据**：只做了"基址 + 端点探针"，响应体形状待下一轮（见 §4.3）。
2. **`AskMomentsShareCustomPost`(63069828) / `AskMomentsDeleteCustomPost`(63518682) /
   `AskPublishNpcMoment`(63969781)** 未实现 —— 都是"发自己的动态"，需要服务端存自定义帖。
3. **邀约的"当前进行中"标记**：`CurrentSpoonAgentId` 一律给 0（角色实体不投放），
   所以客户端不会显示"该角色现在在这里"的定位按钮；日程**列表本身**是完整的。
4. **`AgentDataSetsActivityConfig` 的 `Icon` / `MapName`** 没随包下发 ——
   客户端自己查表拿得到，服务端只需要给 `ActivityId`。
5. **`SocialMediaConfig.Txt` 在 dump 里是空的**（`__RAW__Txt` 才有文本）：
   正文由**客户端** `SocialMediaConfig.GetConfig(...).Txt` 取，客户端有自己的文本表。
   若实测正文空白，需要另找通道（服务端不带 `Title`）。
6. **图片**：`SocialMediaConfig.Image` 是 OSS URL（`https://l18-md-cn.fp.ps.netease.com/...`），
   私服不代理图片 ⇒ 头像/配图可能加载不出来（正文和文字内容不受影响）。
7. **列表 framing 的残余风险**：`PostSimpleClientInfo` 内部三个列表用的是
   `List7Bit`（两张 proxy 表一致）。万一实测客户端报 `deserialize failed`，
   把 `Ananta.RpcTypes/.../SocialAppMethods4229938.cs` 里这三个字段
   加 `[UxCollection(Count = UxCountEncoding.Int32)]` 再试（CBT2 就是这个 framing）。
8. **`baba` / `babu` 之外还有没有别的「叭」系 App** 没查 ——
   `MessageExplainConfig.Id=65920008` 把「叭叭、叭卜」并列，
   目前只定位到 `Friends`(3) 与 `Bubble`(12)。

---

## 7. ★★★ 实测修正（2026-09-24 08:29）：方法入参的列表是 **Int7**，不是 Int32

第一次实现时照 CBT2 反混淆 lua 的生成代码
（`SerializerHelper.AskMomentsMarkRead_Serializer` → `SerializeBase.WriteList` → `WriteInt32`）
把方法入参的列表定成了 **Int32**。实机日志直接打脸：

```
08:29:37 -> rpc AskMomentsPostSimpleInfos #2134104183 5b
08:29:37 <- ret AskMomentsPostSimpleInfos #2134104183 e=0 2270b      ← ★ 动态流 55 条，2270 字节 ✅
08:29:37   [SOCIAL][BUBBLE] AskMomentsPostSimpleInfos lastId=0 postType=0 → 55 条动态

08:29:43 -> rpc AskMomentsMarkRead #2134104184 **6b**                 ← ★ 只有 6 字节
08:29:43 <- ret AskMomentsMarkRead #2134104184 e=0 0b
08:29:43 ! [SOCIAL][BUBBLE] AskMomentsMarkRead 参数解析失败或为空（parsed=False）
```

**6 字节怎么来的**：`FF`(非空标记) + `02`(Int7 计数 = varint(1+1)) + 4 字节(1 个 uint32) = 6。
若按 Int32 读，计数占 4 字节，整包至少 **9** 字节 —— 长度对不上，解析必然失败。

⇒ **客户端用的是 `WriteList7Bit`（Int7）**。

**教训**：
1. **CBT2 的生成代码不能代表 CBT3 的入参 framing**（这和 truth-source 笔记里
   「CBT2 只能用来理解逻辑，线格式以 CBT3 dump 为准」是同一条）。
2. **最可靠的判据是服务端实测日志里的请求字节数** ——
   `-> rpc X #id Nb` 里的 `N`。拿 `N` 和两种 framing 的理论长度对一下就知道答案，
   比翻任何 dump 都快。

**修法**：`AskMomentsMarkRead` / `AskMomentsPostInfos` / `AskMomentsTapPostWithCount`
各提供 **Int7（主）+ Int32（兜底）两套契约**，处理器里 `TryGetArgs` 先试 Int7、失败再试 Int32。

---

## 8. ★★ 一次 NRE 与它的修法（2026-09-24 08:18:57）

```
08:18:57 X handler failed method=AskMomentsPostSimpleInfos [0x03C8345B]: NullReferenceException
08:18:57 ! [RPC4229938] unimplemented AskMomentsPostSimpleInfos -> typed-default list7-empty 2b
08:18:57 <- ret AskMomentsPostSimpleInfos #2134103907 e=0 2b          ← 客户端只拿到空列表
```

**注意**：处理器抛异常后，路由器会**兜底回空包**（`e=0`），
所以客户端**不会崩**，只是**内容为空** —— 和"处理器没注册"的表现一模一样，
非常容易误判。

修法：
1. `BuildSocialPostList()` 里所有集合访问都加 `?? []` ——
   存档是 SQLite 里的 JSON payload，老存档可能没有这些键、也可能显式是 `null`。
2. **SDK 的 `ServerLogger.Error` 现在会打堆栈**（以前只打 `类型: Message`）——
   正是这条缺失让这次只能靠猜。第一行格式保持不变，堆栈缩进单独打。

---

## 9. 后台面板按钮（2026-09-24）

面板：<http://127.0.0.1:5809/> → 「职业对应能力」卡片下面，新增两个卡片：

| 卡片 | 按钮 |
|---|---|
| **社交 App（叭叭 / 叭卜）** | 查看内容 / 线格式探针 · 清空个人状态（已读 / 点赞） |
| **黑客「大停电」（西摩）** | 查看机制分析 · ① 补前置条件 · ② 生成停电创造物 · ①+② 一起 |

☠️ **面板 HTML 读的是磁盘副本**（`DebugApiServer.PanelHtmlDiskCandidates`）：
先找 `AppContext.BaseDirectory/DebugPanel/index.html`，找不到就从输出目录**向上找 6 层**
命中源码目录 `Ananta.Server/Ananta.App/DebugPanel/index.html`。
⇒ **改 HTML 不需要重新编译**（每次请求都重新读盘），但**改完必须确认服务端在跑** ——
服务端一停，5809 会返回 **502 Bad Gateway**（不是 404），很容易误判成"面板没生效"。
