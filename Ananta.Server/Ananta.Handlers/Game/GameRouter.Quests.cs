using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    internal static GameMethods.SyncPlayerAllTask4229938 BuildTaskContainer(
        WorldEntryState state, string? aliasOverride = null, uint? raidOverride = null)
    {
        var container = new GameMethods.SyncPlayerAllTask4229938
        {
            currentTask = state.CurrentQuestTaskId,
            loginGameServer = true,
            eventPanelInfo = new GameMethods.EventPanelInfo4229938(),
        };

        lock (state.SyncRoot)
        {
            foreach (var (taskId, taskState) in state.QuestStates.OrderBy(x => x.Key))
            {
                var info = new GameMethods.TaskInfo4229938
                {
                    TaskId = taskId,
                    State = taskState,
                    RecoverResource = false,
                };

                
                info.SpoonViewInfo = BuildSpoonViewInfo(taskId, aliasOverride, raidOverride);

                
                
                
                
                var configured = TaskCatalogRepository.Counters(taskId);
                for (var i = 0; i < configured.Length; i++)
                {
                    info.CounterValues.Add(0);
                    info.Counters.Add(new GameMethods.TaskCounter4229938
                    {
                        Index = i,
                        Value = 0,
                        ConfigValue = configured[i],
                        Parent = 0,
                    });
                }

                container.taskInfos.Add(info);
            }

            container.currentTask = state.CurrentQuestTaskId;

            
            container.eventPanelInfo = BuildEventPanelInfo(state);
        }

        return container;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static GameMethods.EventPanelInfo4229938 BuildEventPanelInfo(WorldEntryState state)
    {
        var quests = PrivateServerConfigStore.Current.Gameplay.Quests;
        var panel = new GameMethods.EventPanelInfo4229938();

        
        
        
        
        foreach (var eventId in quests.SubmitEventIds)
            if (eventId != 0 && !panel.SubmitEventList.Contains(eventId))
                panel.SubmitEventList.Add(eventId);

        
        var candidates = new HashSet<uint>();
        if (quests.AutoDeriveEvents)
        {
            foreach (var taskId in state.QuestStates.Keys)
                foreach (var eventId in TaskEventCatalogRepository.EventsForTask(taskId))
                    candidates.Add(eventId);
        }
        foreach (var eventId in quests.EventIds)
            candidates.Add(eventId);

        if (candidates.Count == 0)
            return panel;

        
        var unlockTime = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds();

        foreach (var eventId in candidates.OrderBy(x => x))
        {
            var hasRow = TaskEventCatalogRepository.TryGet(eventId, out var row);

            var taskId = 0u;
            if (quests.EventTaskIdFollowsContainer)
                taskId = CurrentTaskOfEvent(state, eventId);
            if (taskId == 0 && hasRow)
                taskId = row.StartTask;

            panel.EventsInfo.Add(new GameMethods.EventPanelTaskEvent4229938
            {
                EventId = eventId,
                TaskId = taskId,
                UnlockTime = unlockTime,
                FinishedChoiceLs = [],
                
                StatusData = quests.EventStatusFlags,
            });
        }

        return panel;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static uint CurrentTaskOfEvent(WorldEntryState state, uint eventId)
    {
        var chain = TaskEventCatalogRepository.TasksOf(eventId);
        if (chain.Count == 0)
            return 0;

        var current = state.CurrentQuestTaskId;
        if (current != 0 && chain.Contains(current))
            return current;

        for (var i = chain.Count - 1; i >= 0; i--)
        {
            if (state.QuestStates.ContainsKey(chain[i]))
                return chain[i];
        }

        return 0;
    }

    
    internal sealed record QuestContainerSnapshot(
        uint CurrentTask,
        IReadOnlyList<QuestTaskSnapshot> Tasks);

    internal sealed record QuestTaskSnapshot(uint TaskId, byte State, IReadOnlyList<int> Values);

    
    
    
    
    internal static QuestContainerSnapshot? SnapshotQuestContainer(TcpSession? session)
    {
        if (session is null)
            return null;
        var state = GetStateIfExists(session);
        if (state is null)
            return null;

        lock (state.SyncRoot)
        {
            var tasks = state.QuestStates
                .OrderBy(x => x.Key)
                .Select(kv => new QuestTaskSnapshot(
                    kv.Key,
                    kv.Value,
                    state.QuestCounterValues.TryGetValue(kv.Key, out var v) ? v : []))
                .ToList();
            return new QuestContainerSnapshot(state.CurrentQuestTaskId, tasks);
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static GameMethods.SpoonViewInfo4229938? BuildSpoonViewInfo(
        uint taskId, string? aliasOverride = null, uint? raidOverride = null)
    {
        var quests = PrivateServerConfigStore.Current.Gameplay.Quests;
        if (!quests.SendSpoonViewInfo)
            return null;

        return new GameMethods.SpoonViewInfo4229938
        {
            SpoonMd5 = string.Empty,
            SpRaidId = raidOverride ?? TaskCatalogRepository.RelatedRaid(taskId),
            StartTaskId = taskId,
            EndTaskId = taskId,
            Alias = aliasOverride ?? quests.SpoonAlias ?? string.Empty,
            EventId = 0,
            EventStartTaskId = 0,
        };
    }

    
    
    
    
    internal static async Task PushTaskContainerAsync(TcpSession session, CancellationToken token = default)
    {
        if (!PrivateServerConfigStore.Current.Gameplay.Quests.Enabled)
            return;

        var state = GetStateIfExists(session);
        if (state is null)
            return;

        var container = BuildTaskContainer(state);
        lock (state.SyncRoot)
            state.QuestContainerSent = true;

        await session.NotifyAsync(MethodId.SyncPlayerAllTask, UxSerializer.Serialize(container), token);
        session.Log.Info(
            $"[QUEST] SyncPlayerAllTask tasks={container.taskInfos.Count} current={container.currentTask} "
            + $"events={container.eventPanelInfo.EventsInfo.Count} loginGameServer=true");

        
        foreach (var ev in container.eventPanelInfo.EventsInfo)
        {
            var name = TaskEventCatalogRepository.TryGet(ev.EventId, out var row)
                ? (row.NameCn.Length > 0 ? row.NameCn : row.Name)
                : "(TaskEventConfig 里没有这个事件)";
            session.Log.Info(
                $"[QUEST][EVENT] event={ev.EventId} '{name}' task={ev.TaskId} status={ev.StatusData}");
        }

        
        
        var quests = PrivateServerConfigStore.Current.Gameplay.Quests;
        if (quests.SendSpoonViewInfo && container.currentTask != 0)
        {
            var raid = TaskCatalogRepository.RelatedRaid(container.currentTask);
            session.Log.Info(
                $"[QUEST] SpoonViewInfo → 期望客户端加载 GameRes/Spoon/Task/SpoonTask{raid}_{quests.SpoonAlias}.tcp"
                + $"（task={container.currentTask} raid={raid} alias='{quests.SpoonAlias}'）"
                + " —— 若客户端日志里的文件名与此不同，说明 SpRaidId/Alias 需要调整");
        }

        
        
        
        if (quests.SpoonAliasProbe.Length > 0)
        {
            for (var i = 0; i < quests.SpoonAliasProbe.Length; i++)
            {
                
                var spec = quests.SpoonAliasProbe[i];
                var alias = spec;
                uint? raidOv = null;
                var colon = spec.IndexOf(':');
                if (colon > 0 && uint.TryParse(spec[..colon], out var parsedRaid))
                {
                    raidOv = parsedRaid;
                    alias = spec[(colon + 1)..];
                }
                var raid = raidOv ?? TaskCatalogRepository.RelatedRaid(container.currentTask);
                session.Log.Info(
                    $"[QUEST][PROBE] {i + 1}/{quests.SpoonAliasProbe.Length} raid={raid} alias='{alias}'"
                    + $" → 期望客户端去要 GameRes/Spoon/Task/SpoonTask{raid}_{alias}.tcp");

                var probed = BuildTaskContainer(state, alias, raidOv);
                await session.NotifyAsync(MethodId.SyncPlayerAllTask, UxSerializer.Serialize(probed), token);
                await Task.Delay(400, token);
            }
        }

        
        
        
        
        
        
        
        
        
        
        
        
        
        var titles = new HashSet<ushort>();
        lock (state.SyncRoot)
        {
            foreach (var taskId in state.QuestStates.Keys)
            {
                var titleId = TaskCatalogRepository.TitleId(taskId);
                if (titleId is > 0 and <= ushort.MaxValue)
                    titles.Add((ushort)titleId);
            }
        }
        foreach (var titleId in DisplayTaskTitles)
        {
            if (titleId is > 0 and <= ushort.MaxValue)
                titles.Add((ushort)titleId);
        }

        foreach (var titleId in titles)
        {
            await session.NotifyAsync(MethodId.SyncTaskTitleGuideUnlock,
                UxSerializer.Serialize(new GameMethods.SyncTaskTitleGuideUnlock4229938
                {
                    taskTitleId = titleId,
                    unlock = true,
                }),
                token);
            session.Log.Info($"[QUEST] SyncTaskTitleGuideUnlock title={titleId} unlock=true");
        }

        
        
        if (container.currentTask != 0)
        {
            await session.NotifyAsync(MethodId.SyncTaskSpoonResourceLoaded,
                UxSerializer.Serialize(new GameMethods.SyncTaskSpoonResourceLoaded4229938
                {
                    taskId = container.currentTask,
                }),
                token);
            session.Log.Info($"[QUEST] SyncTaskSpoonResourceLoaded task={container.currentTask}");
        }

        
        
        
        
        if (container.currentTask != 0)
        {
            var spoon = new GameMethods.SyncSpoonTaskClientData4229938();
            spoon.data.Add(new GameMethods.SpoonTaskClientData4229938
            {
                TaskId = container.currentTask,
                EventId = 0,
            });
            await session.NotifyAsync(MethodId.SyncSpoonTaskClientData, UxSerializer.Serialize(spoon), token);
            session.Log.Info($"[QUEST] SyncSpoonTaskClientData task={container.currentTask} entries={spoon.data.Count}");
        }
    }

    
    internal static void SeedConfiguredQuests(WorldEntryState state)
    {
        var quests = PrivateServerConfigStore.Current.Gameplay.Quests;
        if (!quests.Enabled || quests.StartingTaskIds.Length == 0)
            return;

        lock (state.SyncRoot)
        {
            foreach (var taskId in quests.StartingTaskIds)
                state.QuestStates[taskId] = DefaultTaskState();
            if (state.CurrentQuestTaskId == 0)
                state.CurrentQuestTaskId = quests.StartingTaskIds[0];
        }
    }

    

    
    
    
    
    
    
    
    
    
    
    
    internal static class TaskState4229938
    {
        internal const byte NotAccept = 0;
        internal const byte Accepted = 1;
        internal const byte Submited = 3;
        internal const byte Aborted = 4;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static readonly int[] DisplayTaskTitles = [1, 4, 5, 6, 8, 9, 17, 19];

    
    private static byte DefaultTaskState()
    {
        var configured = PrivateServerConfigStore.Current.Gameplay.Quests.StartingTaskState;
        return configured is TaskState4229938.NotAccept
            or TaskState4229938.Accepted
            or TaskState4229938.Submited
            or TaskState4229938.Aborted
            ? configured
            : TaskState4229938.Accepted;
    }

    internal static async Task<string> AcceptQuestAsync(
        TcpSession session,
        uint taskId,
        byte? stateByte = null,
        CancellationToken token = default)
    {
        if (taskId == 0)
            return "taskId must not be zero";

        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        
        
        if (TaskCatalogRepository.Name(taskId) is null)
            return $"task {taskId} is not in TaskConfig — it would be accepted but never rendered";

        var quests = PrivateServerConfigStore.Current.Gameplay.Quests;
        
        var requested = stateByte ?? quests.StartingTaskState;
        var applied = requested is TaskState4229938.NotAccept
            or TaskState4229938.Accepted
            or TaskState4229938.Submited
            or TaskState4229938.Aborted
            ? requested
            : TaskState4229938.Accepted;
        var adjusted = applied != requested;

        lock (state.SyncRoot)
        {
            state.QuestStates[taskId] = applied;
            state.CurrentQuestTaskId = taskId;
            
            state.UnlockedQuestIds.Add(taskId);
        }

        await PushTaskContainerAsync(session, token);
        await UnlockQuestAsync(session, taskId, token);
        await PushCurrentTaskAsync(session, type: 0, taskId, firstTime: true, token);

        var name = TaskCatalogRepository.Name(taskId);
        var note = adjusted
            ? $" (state {requested} is not a valid UX.Game.TaskState; used {applied})"
            : string.Empty;
        return $"accepted quest {taskId} '{name}' state={applied}{note}";
    }

    internal static async Task<string> SubmitQuestAsync(
        TcpSession session,
        uint taskId,
        CancellationToken token = default)
    {
        if (taskId == 0)
            return "taskId must not be zero";

        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        lock (state.SyncRoot)
        {
            if (!state.QuestStates.ContainsKey(taskId))
                return $"quest {taskId} is not in the container";
            
            
            
            state.QuestStates[taskId] = TaskState4229938.Submited;
        }

        await PushTaskContainerAsync(session, token);
        await PushCurrentTaskAsync(session, type: 1, taskId, firstTime: false, token);
        return $"submitted quest {taskId}";
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static async Task<string> ResetQuestsAsync(
        TcpSession session,
        bool reseed = false,
        CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        int before;
        lock (state.SyncRoot)
        {
            before = state.QuestStates.Count;
            state.QuestStates.Clear();
            state.QuestCounterValues.Clear();
            state.UnlockedQuestIds.Clear();
            state.CompletedSubQuestIds.Clear();
            state.StoryChain.Clear();
            state.CurrentQuestTaskId = 0;
            if (reseed)
                SeedConfiguredQuests(state);
        }

        await PushTaskContainerAsync(session, token);
        var after = SnapshotQuestContainer(session)?.Tasks.Count ?? 0;
        return $"quest container reset (was {before} task(s), now {after}"
            + (reseed ? ", reseeded from config)" : ", no reseed)");
    }

    internal static async Task PushCurrentTaskAsync(
        TcpSession session,
        byte type,
        uint taskId,
        bool firstTime,
        CancellationToken token)
    {
        var state = GetStateIfExists(session);
        var body = new GameMethods.SyncCurrentTask4229938
        {
            type = type,
            taskId = taskId,
            eventId = 0,
            firstTime = firstTime,
            reason = state is null
                ? (byte)0
                : PrivateServerConfigStore.Current.Gameplay.Quests.CurrentTaskReason,
        };
        await session.NotifyAsync(MethodId.SyncCurrentTask, UxSerializer.Serialize(body), token);
        session.Log.Info($"[QUEST] SyncCurrentTask type={type} task={taskId} firstTime={firstTime}");
    }

    

    
    internal static async Task<string> UnlockQuestAsync(
        TcpSession session,
        uint questId,
        CancellationToken token = default)
    {
        if (questId == 0)
            return "questId must not be zero";

        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        lock (state.SyncRoot)
            state.UnlockedQuestIds.Add(questId);

        await session.NotifyAsync(
            MethodId.SyncCollectionQuestUnlock,
            UxSerializer.Serialize(new GameMethods.SyncCollectionQuestUnlock4229938 { questId = questId }),
            token);
        session.Log.Info($"[QUEST] SyncCollectionQuestUnlock quest={questId}");
        return $"unlocked quest {questId}";
    }

    
    internal static async Task<string> CompleteSubQuestAsync(
        TcpSession session,
        uint subQuestId,
        CancellationToken token = default)
    {
        if (subQuestId == 0)
            return "subQuestId must not be zero";

        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        lock (state.SyncRoot)
            state.CompletedSubQuestIds.Add(subQuestId);

        await session.NotifyAsync(
            MethodId.SyncCompletedSubQuest,
            UxSerializer.Serialize(new GameMethods.SyncCompletedSubQuest4229938 { subQuestId = subQuestId }),
            token);
        session.Log.Info($"[QUEST] SyncCompletedSubQuest subQuest={subQuestId}");
        return $"completed sub-quest {subQuestId}";
    }

    
    
    
    
    internal static async Task PushConfiguredQuestProgressAsync(
        TcpSession session,
        CancellationToken token = default)
    {
        var quests = PrivateServerConfigStore.Current.Gameplay.Quests;
        if (!quests.Enabled)
            return;

        var state = GetStateIfExists(session);
        if (state is null)
            return;

        foreach (var questId in quests.UnlockedQuestIds.Distinct())
        {
            lock (state.SyncRoot)
            {
                if (!state.UnlockedQuestIds.Add(questId))
                    continue;
            }
            await session.NotifyAsync(
                MethodId.SyncCollectionQuestUnlock,
                UxSerializer.Serialize(new GameMethods.SyncCollectionQuestUnlock4229938 { questId = questId }),
                token);
        }

        foreach (var subQuestId in quests.CompletedSubQuestIds.Distinct())
        {
            lock (state.SyncRoot)
            {
                if (!state.CompletedSubQuestIds.Add(subQuestId))
                    continue;
            }
            await session.NotifyAsync(
                MethodId.SyncCompletedSubQuest,
                UxSerializer.Serialize(new GameMethods.SyncCompletedSubQuest4229938 { subQuestId = subQuestId }),
                token);
        }

        session.Log.Info(
            $"[QUEST] configured progress replayed unlocked={quests.UnlockedQuestIds.Length} completedSub={quests.CompletedSubQuestIds.Length}");
    }

    

    
    
    
    
    
    
    
    
    [Handler(MethodId.AskSubmitTask, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskSetTaskCounterValue, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskUpdatePlayerScenarioInfo, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskStartGuideByCondition, HandlerPacketKind.Invoke)]
    [Handler(MethodId.FinishTaskTitleGuideUnlock, HandlerPacketKind.Invoke)]
    [Handler(MethodId.ForceAcceptTask, HandlerPacketKind.Invoke)]
    [Handler(MethodId.ForceSubmitTask, HandlerPacketKind.Invoke)]
    [Handler(MethodId.RemoveCurrentTask, HandlerPacketKind.Invoke)]
    [Handler(MethodId.GmAcceptTask, HandlerPacketKind.Invoke)]
    private Task ClientTaskCommand(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info($"[QUEST] client {Ananta.SDK.Logging.RpcMethodNames.Display(msg.MethodId)} body={msg.Body.Length}b -> ok");
        return conn.ReturnEmptyOkAsync(msg);
    }

    
    [Handler(MethodId.SyncTaskTitleGuideUnlock, HandlerPacketKind.Notify)]
    private Task ClientTaskNotify(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info($"[QUEST] client notify {Ananta.SDK.Logging.RpcMethodNames.Display(msg.MethodId)} body={msg.Body.Length}b");
        return Task.CompletedTask;
    }
}
