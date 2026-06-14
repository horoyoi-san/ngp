using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncPlayerAllTask : SerializedClass
    {
        public List<TaskViewData> taskInfos; 
        public List<uint> submitTaskList; 
        public List<uint> submitEventList; 
        public uint currentTask; 
        public EventPanelInfo eventPanelInfo; 
        public List<EventSpoonViewInfo> eventViewInfoList;
        public bool loginGameServer;

        public SyncPlayerAllTask() : base()
        {
            onlyFields = true;
        }
    }
    public class EventSpoonViewInfo : SerializedClass
    {
        // Fields
        public uint EventId; // 0x10
        public uint RaidId; // 0x14
        public string SpoonMd5; // 0x18

    }
    public class EventPanelInfo : SerializedClass
    {
       
        public List<TaskEventInfo> EventsInfo; // 0x10

        // Constructors
        public EventPanelInfo() { } // 0x000000018C3B1BA0-0x000000018C3B1C80
    }
    public class TaskEventInfo : SerializedClass
    {
        // Fields
       
        public uint EventId; // 0x10
    
        public uint TaskId; // 0x14
     
        public bool Visible; // 0x18
       
        public bool IsRiskControl; // 0x19
      
        public bool Acceptable; // 0x1A
        
        public bool HasAccepted; // 0x1B
        
        public bool RedPoint; // 0x1C
       
        public uint UnlockTime; // 0x20
       
        public bool IsUnderway; // 0x24
       
        public List<uint> FinishedChoiceLs; // 0x28
       
        public bool Conflict; // 0x30
     
        public bool IsRepeat; // 0x31

    }
    public class TaskViewData : SerializedClass
    {
        // Fields
        public uint TaskId; // 0x10
        public List<int> CounterValues; // 0x18
        public List<TaskViewCounter> Counters; // 0x20
        public TaskState State; // 0x28
        public bool RecoverResource; // 0x2C
     
        public TaskSpoonViewInfo SpoonViewInfo; // 0x30
    }
    public enum TaskState // TypeDefIndex: 33951
    {
        NotAccept = 0,
        Accepted = 1,
        Submited = 3,
        Aborted = 4
    }
    public class TaskViewCounter : SerializedClass
    {
        // Fields
        public int Index; // 0x10
        public int Value; // 0x14
        public int ConfigValue; // 0x18
       
        public uint[] Duty; // 0x20
        public bool WaitOtherCounter; // 0x28
        public bool WaitOtherTask; // 0x29
        public int Parent; // 0x2C
        public TaskViewCounter[] Child; // 0x30

        // Constructors
        public TaskViewCounter() { } // 0x00000001871763E0-0x00000001871763F0
    }
}
