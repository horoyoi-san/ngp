using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskPoliceDispatchArg : SerializedClass
    {
        public uint taskId;
        public AskPoliceDispatchArg() { onlyFields = true; }
    }

    public class AskSkipPoliceTaskArg : SerializedClass
    {
        public uint taskId;
        public AskSkipPoliceTaskArg() { onlyFields = true; }
    }

    public class AskPoliceExamInteractArg : SerializedClass
    {
        public ulong agentId;
        public AskPoliceExamInteractArg() { onlyFields = true; }
    }

    public class AskReadPoliceFakeClueAgentInfoLiArg : SerializedClass
    {
        public AskReadPoliceFakeClueAgentInfoLiArg() { onlyFields = true; }
    }

    public class AskPoliceFakeFileAcceptTaskEventArg : SerializedClass
    {
        public uint taskId;
        public AskPoliceFakeFileAcceptTaskEventArg() { onlyFields = true; }
    }

    public class AskAbandonPoliceTaskArg : SerializedClass
    {
        public uint taskId;
        public AskAbandonPoliceTaskArg() { onlyFields = true; }
    }

    public class AskPoliceStopHelicopterDispatchArg : SerializedClass
    {
        public AskPoliceStopHelicopterDispatchArg() { onlyFields = true; }
    }

    public class AskPoliceEffectiveExamArg : SerializedClass
    {
        public ulong agentId;
        public AskPoliceEffectiveExamArg() { onlyFields = true; }
    }

    public class AskPolicePrepareExamArg : SerializedClass
    {
        public ulong agentId;
        public AskPolicePrepareExamArg() { onlyFields = true; }
    }

    public class AskPoliceExitEscortOrExamArg : SerializedClass
    {
        public AskPoliceExitEscortOrExamArg() { onlyFields = true; }
    }

    public class ReportPoliceExamCommandEndArg : SerializedClass
    {
        public ulong agentId;
        public bool success;
        public ReportPoliceExamCommandEndArg() { onlyFields = true; }
    }

    public class UsePoliceChargingProgressArg : SerializedClass
    {
        public uint skillId;
        public UsePoliceChargingProgressArg() { onlyFields = true; }
    }

    public class AddPoliceChargingProgressArg : SerializedClass
    {
        public uint skillId;
        public float progress;
        public AddPoliceChargingProgressArg() { onlyFields = true; }
    }

    public class AskPoliceFineNpcArg : SerializedClass
    {
        public ulong agentId;
        public AskPoliceFineNpcArg() { onlyFields = true; }
    }

    public class AskPolicePrepareEscortArg : SerializedClass
    {
        public ulong agentId;
        public AskPolicePrepareEscortArg() { onlyFields = true; }
    }

    public class AskPoliceEscortNpcArg : SerializedClass
    {
        public ulong agentId;
        public AskPoliceEscortNpcArg() { onlyFields = true; }
    }

    public class AskAcceptPoliceTaskArg : SerializedClass
    {
        public uint taskId;
        public AskAcceptPoliceTaskArg() { onlyFields = true; }
    }

    public class AskPoliceTakeCaseRewardArg : SerializedClass
    {
        public uint taskId;
        public AskPoliceTakeCaseRewardArg() { onlyFields = true; }
    }

    public static class PoliceHandlers
    {
        private static void SendEmptySuccessReturn(Connection conn, UxRpcMessage msg, MethodId methodId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceDispatch)]
        public static void AskPoliceDispatchHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPoliceDispatchArg>();
            Console.WriteLine($"[Police] AskPoliceDispatch taskId={args.taskId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceDispatch);
        }

        [Handler(MethodId.AskSkipPoliceTask)]
        public static void AskSkipPoliceTaskHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskSkipPoliceTaskArg>();
            Console.WriteLine($"[Police] AskSkipPoliceTask taskId={args.taskId}");
            
            uint taskId = args.taskId;
            
            // Mark as submitted/finished
            conn.SubmittedPoliceTasks.Add(taskId);
            conn.AcceptedPoliceTasks.Remove(taskId);
            
            if (conn.CurrentPoliceTaskId == taskId)
                conn.CurrentPoliceTaskId = null;
            
            Console.WriteLine($"[Police] Task {taskId} skipped and marked as submitted");
            
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkipPoliceTask);
        }

        [Handler(MethodId.AskPoliceExamInteract)]
        public static void AskPoliceExamInteractHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPoliceExamInteractArg>();
            Console.WriteLine($"[Police] AskPoliceExamInteract agentId={args.agentId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceExamInteract);
        }

        [Handler(MethodId.AskReadPoliceFakeClueAgentInfoLi)]
        public static void AskReadPoliceFakeClueAgentInfoLiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Police] AskReadPoliceFakeClueAgentInfoLi");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReadPoliceFakeClueAgentInfoLi);
        }

        [Handler(MethodId.AskPoliceFakeFileAcceptTaskEvent)]
        public static void AskPoliceFakeFileAcceptTaskEventHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPoliceFakeFileAcceptTaskEventArg>();
            Console.WriteLine($"[Police] AskPoliceFakeFileAcceptTaskEvent taskId={args.taskId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceFakeFileAcceptTaskEvent);
        }

        [Handler(MethodId.AskAbandonPoliceTask)]
        public static void AskAbandonPoliceTaskHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskAbandonPoliceTaskArg>();
            Console.WriteLine($"[Police] AskAbandonPoliceTask taskId={args.taskId}");
            
            uint taskId = args.taskId;
            
            // Remove from accepted tasks
            conn.AcceptedPoliceTasks.Remove(taskId);
            
            if (conn.CurrentPoliceTaskId == taskId)
                conn.CurrentPoliceTaskId = null;
            
            Console.WriteLine($"[Police] Task {taskId} abandoned");
            
            SendEmptySuccessReturn(conn, msg, MethodId.AskAbandonPoliceTask);
        }

        [Handler(MethodId.AskPoliceStopHelicopterDispatch)]
        public static void AskPoliceStopHelicopterDispatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Police] AskPoliceStopHelicopterDispatch");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceStopHelicopterDispatch);
        }

        [Handler(MethodId.AskPoliceEffectiveExam)]
        public static void AskPoliceEffectiveExamHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPoliceEffectiveExamArg>();
            Console.WriteLine($"[Police] AskPoliceEffectiveExam agentId={args.agentId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceEffectiveExam);
        }

        [Handler(MethodId.AskPolicePrepareExam)]
        public static void AskPolicePrepareExamHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPolicePrepareExamArg>();
            Console.WriteLine($"[Police] AskPolicePrepareExam agentId={args.agentId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPolicePrepareExam);
        }

        [Handler(MethodId.AskPoliceExitEscortOrExam)]
        public static void AskPoliceExitEscortOrExamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Police] AskPoliceExitEscortOrExam");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceExitEscortOrExam);
        }

        [Handler(MethodId.ReportPoliceExamCommandEnd)]
        public static void ReportPoliceExamCommandEndHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<ReportPoliceExamCommandEndArg>();
            Console.WriteLine($"[Police] ReportPoliceExamCommandEnd agentId={args.agentId} success={args.success}");
            SendEmptySuccessReturn(conn, msg, MethodId.ReportPoliceExamCommandEnd);
        }

        [Handler(MethodId.UsePoliceChargingProgress)]
        public static void UsePoliceChargingProgressHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<UsePoliceChargingProgressArg>();
            Console.WriteLine($"[Police] UsePoliceChargingProgress skillId={args.skillId}");
            SendEmptySuccessReturn(conn, msg, MethodId.UsePoliceChargingProgress);
        }

        [Handler(MethodId.AddPoliceChargingProgress)]
        public static void AddPoliceChargingProgressHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AddPoliceChargingProgressArg>();
            Console.WriteLine($"[Police] AddPoliceChargingProgress skillId={args.skillId} progress={args.progress}");
            SendEmptySuccessReturn(conn, msg, MethodId.AddPoliceChargingProgress);
        }

        [Handler(MethodId.AskPoliceFineNpc)]
        public static void AskPoliceFineNpcHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPoliceFineNpcArg>();
            Console.WriteLine($"[Police] AskPoliceFineNpc agentId={args.agentId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceFineNpc);
        }

        [Handler(MethodId.AskPolicePrepareEscort)]
        public static void AskPolicePrepareEscortHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPolicePrepareEscortArg>();
            Console.WriteLine($"[Police] AskPolicePrepareEscort agentId={args.agentId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPolicePrepareEscort);
        }

        [Handler(MethodId.AskPoliceEscortNpc)]
        public static void AskPoliceEscortNpcHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPoliceEscortNpcArg>();
            Console.WriteLine($"[Police] AskPoliceEscortNpc agentId={args.agentId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceEscortNpc);
        }

        [Handler(MethodId.AskAcceptPoliceTask)]
        public static void AskAcceptPoliceTaskHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskAcceptPoliceTaskArg>();
            Console.WriteLine($"[Police] AskAcceptPoliceTask taskId={args.taskId}");
            
            uint taskId = args.taskId;
            
            // Add to accepted tasks if not already there
            if (!conn.AcceptedPoliceTasks.Contains(taskId))
                conn.AcceptedPoliceTasks.Add(taskId);
            
            conn.CurrentPoliceTaskId = taskId;
            
            // Initialize counter for this task
            if (!conn.PoliceTaskCounterValues.ContainsKey(taskId))
                conn.PoliceTaskCounterValues[taskId] = new List<int> { 0 };
            
            // Increment counter to indicate task started
            conn.PoliceTaskCounterValues[taskId][0] = 1;
            
            Console.WriteLine($"[Police] Task {taskId} accepted and set as current, counter set to 1");
            
            SendEmptySuccessReturn(conn, msg, MethodId.AskAcceptPoliceTask);
        }

        [Handler(MethodId.AskPoliceTakeCaseReward)]
        public static void AskPoliceTakeCaseRewardHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPoliceTakeCaseRewardArg>();
            Console.WriteLine($"[Police] AskPoliceTakeCaseReward taskId={args.taskId}");
            
            uint taskId = args.taskId;
            
            // Mark as submitted/finished
            conn.SubmittedPoliceTasks.Add(taskId);
            conn.AcceptedPoliceTasks.Remove(taskId);
            
            if (conn.CurrentPoliceTaskId == taskId)
                conn.CurrentPoliceTaskId = null;
            
            Console.WriteLine($"[Police] Task {taskId} completed and reward taken");
            
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceTakeCaseReward);
        }
    }
}
