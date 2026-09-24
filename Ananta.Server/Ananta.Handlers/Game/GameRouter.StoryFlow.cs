using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    internal const uint StoryRootTaskId = 60004938;

    
    internal static async Task<string> ReportCounterAsync(
        TcpSession session,
        uint taskId,
        int index,
        int value,
        bool finish,
        CancellationToken token = default)
    {
        if (taskId == 0)
            return "taskId must not be zero";

        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        var configured = TaskCatalogRepository.Counters(taskId);
        if (configured.Length == 0)
            return $"task {taskId} has no authored counters (nothing to progress)";

        bool completed;
        lock (state.SyncRoot)
        {
            if (!state.QuestStates.ContainsKey(taskId))
                return $"task {taskId} is not in the container";

            if (!state.QuestCounterValues.TryGetValue(taskId, out var values) || values.Length != configured.Length)
            {
                values = new int[configured.Length];
                state.QuestCounterValues[taskId] = values;
            }

            if (index >= 0 && index < values.Length)
                values[index] = finish ? configured[index] : Math.Clamp(value, 0, configured[index]);

            
            completed = true;
            for (var i = 0; i < configured.Length; i++)
                if (values[i] < configured[i])
                {
                    completed = false;
                    break;
                }
        }

        await PushTaskContainerAsync(session, token);

        var name = TaskCatalogRepository.Name(taskId) ?? taskId.ToString();
        if (!completed)
        {
            session.Log.Info($"[QUEST] counter task={taskId} '{name}' index={index} value={value} finish={finish}");
            return $"counter {index} updated on task {taskId}";
        }

        return await CompleteAndAdvanceAsync(session, taskId, token);
    }

    
    internal static async Task<string> CompleteAndAdvanceAsync(
        TcpSession session,
        uint taskId,
        CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        var next = TaskCatalogRepository.NextTasks(taskId);
        string result;

        lock (state.SyncRoot)
        {
            
            state.QuestStates[taskId] = 1;
        }

        await PushTaskContainerAsync(session, token);
        await PushCurrentTaskAsync(session, type: 1, taskId, firstTime: false, token);

        if (next.Length == 0)
        {
            result = $"task {taskId} completed (chain end)";
            session.Log.Info($"[QUEST] {result}");
            return result;
        }

        var nextId = next[0];
        var nextName = TaskCatalogRepository.Name(nextId) ?? nextId.ToString();
        await AcceptStoryTaskAsync(session, nextId, token);
        result = $"task {taskId} completed -> next {nextId} '{nextName}'";
        session.Log.Info($"[QUEST] {result}");
        return result;
    }

    
    internal static async Task<string> AcceptStoryTaskAsync(
        TcpSession session,
        uint taskId,
        CancellationToken token = default)
    {
        if (taskId == 0)
            return "taskId must not be zero";
        if (TaskCatalogRepository.Name(taskId) is null)
            return $"task {taskId} is not in TaskConfig";

        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        var quests = PrivateServerConfigStore.Current.Gameplay.Quests;
        
        
        var requested = quests.StartingTaskState;
        var applied = requested is TaskState4229938.NotAccept
            or TaskState4229938.Accepted
            or TaskState4229938.Submited
            or TaskState4229938.Aborted
            ? requested
            : TaskState4229938.Accepted;

        lock (state.SyncRoot)
        {
            state.QuestStates[taskId] = applied;
            state.CurrentQuestTaskId = taskId;
            state.UnlockedQuestIds.Add(taskId);
            
            state.QuestCounterValues[taskId] = new int[TaskCatalogRepository.Counters(taskId).Length];
            if (!state.StoryChain.Contains(taskId))
                state.StoryChain.Add(taskId);
        }

        await PushTaskContainerAsync(session, token);
        await UnlockQuestAsync(session, taskId, token);
        await PushCurrentTaskAsync(session, type: 0, taskId, firstTime: true, token);
        return $"accepted task {taskId} '{TaskCatalogRepository.Name(taskId)}'";
    }

    
    
    
    
    
    
    internal static async Task<string> StartStoryChainAsync(
        TcpSession session,
        uint rootId = 0,
        CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        if (rootId == 0)
            rootId = StoryRootTaskId;

        var chain = TaskCatalogRepository.ChainFrom(rootId);
        if (chain.Count == 0)
            return $"story root {rootId} has no chain in TaskConfig";

        uint resume;
        lock (state.SyncRoot)
        {
            
            var reached = chain.Where(id => state.QuestStates.ContainsKey(id)).ToList();
            resume = reached.Count > 0 ? reached[^1] : rootId;
            if (state.CurrentQuestTaskId != 0 && chain.Contains(state.CurrentQuestTaskId))
                resume = state.CurrentQuestTaskId;
        }

        var result = await AcceptStoryTaskAsync(session, resume, token);
        session.Log.Info($"[STORY] chain from {rootId}: {chain.Count} step(s), resumed at {resume} — {result}");
        return result;
    }

    

    
    
    
    
    
    
    
    [Handler(MethodId.AskAcceptTask, HandlerPacketKind.Invoke)]
    private async Task AskAcceptTask(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        var taskId = FirstUInt32(msg.Body);
        conn.Log.Info($"[QUEST] client AskAcceptTask body={msg.Body.Length}b task={taskId}");
        if (taskId == 0)
            return;
        var result = await AcceptStoryTaskAsync(conn.Session, taskId, CancellationToken.None);
        conn.Log.Info($"[QUEST] {result}");
    }

    [Handler(MethodId.AskAcceptAndSetCurrentTask, HandlerPacketKind.Invoke)]
    private async Task AskAcceptAndSetCurrentTask(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        var taskId = FirstUInt32(msg.Body);
        conn.Log.Info($"[QUEST] client AskAcceptAndSetCurrentTask task={taskId}");
        if (taskId == 0)
            return;
        await AcceptStoryTaskAsync(conn.Session, taskId, CancellationToken.None);
    }

    
    
    
    
    [Handler(MethodId.AskChangeTaskCounterValue, HandlerPacketKind.Invoke)]
    private async Task AskChangeTaskCounterValue(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        var (taskId, index, value) = ParseCounterBody(msg.Body);
        conn.Log.Info($"[QUEST] client counter change task={taskId} index={index} value={value} body={Convert.ToHexString(msg.Body.AsSpan(0, Math.Min(msg.Body.Length, 32)))}");
        if (taskId == 0)
            return;
        await ReportCounterAsync(conn.Session, taskId, index, value, finish: false, CancellationToken.None);
    }

    
    [Handler(MethodId.AskFinishTaskCounter, HandlerPacketKind.Invoke)]
    private async Task AskFinishTaskCounter(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        var (taskId, index, _) = ParseCounterBody(msg.Body);
        conn.Log.Info($"[QUEST] client counter finish task={taskId} index={index}");
        if (taskId == 0)
            return;
        await ReportCounterAsync(conn.Session, taskId, index, 0, finish: true, CancellationToken.None);
    }

    
    [Handler(MethodId.AskDoGuide, HandlerPacketKind.Invoke)]
    private async Task AskDoGuide(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[STORY] client AskDoGuide guide={FirstUInt32(msg.Body)}");
    }

    [Handler(MethodId.AskFinishGuide, HandlerPacketKind.Invoke)]
    private async Task AskFinishGuide(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[STORY] client AskFinishGuide guide={FirstUInt32(msg.Body)}");
    }

    

    private static uint FirstUInt32(byte[] body)
        => body.Length >= 4 ? BitConverter.ToUInt32(body, 0) : 0u;

    private static (uint TaskId, int Index, int Value) ParseCounterBody(byte[] body)
    {
        if (body.Length < 4)
            return (0, 0, 0);
        var taskId = BitConverter.ToUInt32(body, 0);
        var index = body.Length >= 8 ? BitConverter.ToInt32(body, 4) : 0;
        var value = body.Length >= 12 ? BitConverter.ToInt32(body, 8) : 0;
        return (taskId, index, value);
    }
}
