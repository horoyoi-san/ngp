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
        public uint EventId;
        public uint RaidId;
        public string SpoonMd5;

    }
    public class EventPanelInfo : SerializedClass
    {
       
        public List<TaskEventInfo> EventsInfo;

    }
    public class TaskEventInfo : SerializedClass
    {
        // Fields
       
        public uint EventId;
    
        public uint TaskId;
     
        public bool Visible;
       
        public bool IsRiskControl;
      
        public bool Acceptable;
        
        public bool HasAccepted;
        
        public bool RedPoint;
       
        public uint UnlockTime;
       
        public bool IsUnderway;
       
        public List<uint> FinishedChoiceLs;
       
        public bool Conflict;
     
        public bool IsRepeat;

    }
    public class TaskViewData : SerializedClass
    {
        // Fields
        public uint TaskId;
        public List<int> CounterValues;
        public List<TaskViewCounter> Counters;
        public TaskState State;
        public bool RecoverResource;
     
        public TaskSpoonViewInfo SpoonViewInfo;
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
        public int Index;
        public int Value;
        public int ConfigValue;
       
        public uint[] Duty;
        public bool WaitOtherCounter;
        public bool WaitOtherTask;
        public int Parent;
        public TaskViewCounter[] Child;

    }
}
