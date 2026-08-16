using System;
using System.Collections.Generic;

namespace AnantaTestGameServer.BehaviorTreeEngine
{
    // ================================================================
    // TASK STATUS — mirrors BehaviorAI.TaskStatus
    // ================================================================
    public enum TaskStatus
    {
        Success,
        Failure,
        Running
    }

    // ================================================================
    // BLACKBOARD — shared data store for BT nodes (mirrors SharedVariable)
    // ================================================================
    public class Blackboard
    {
        private readonly Dictionary<string, object> _data = new();

        public void Set<T>(string key, T value) => _data[key] = value;

        public T Get<T>(string key, T defaultValue = default)
        {
            if (_data.TryGetValue(key, out var val) && val is T typed)
                return typed;
            return defaultValue;
        }

        public bool Has(string key) => _data.ContainsKey(key);
        public void Remove(string key) => _data.Remove(key);
        public void Clear() => _data.Clear();
    }

    // ================================================================
    // BT CONTEXT — mirrors UnitBehaviorContext
    // Holds reference to Connection, SpawnedNpc, and Blackboard.
    // Pre-computed fields (PlayerDist) are set once per tick.
    // ================================================================
    public class BTContext
    {
        public Connection Conn;
        public Connection.SpawnedNpc Npc;
        public Blackboard Board;
        public float PlayerDist;       // distance from NPC to player (cached per tick)
        public double TimeInState;     // seconds since last state change
        public DateTime Now;

        public BTContext(Connection conn, Connection.SpawnedNpc npc, Blackboard board)
        {
            Conn = conn;
            Npc = npc;
            Board = board;
            Now = DateTime.UtcNow;

            // Cache player distance
            float dx = npc.PosX - conn.LastKnownPlayerPosition.X;
            float dz = npc.PosZ - conn.LastKnownPlayerPosition.Z;
            PlayerDist = MathF.Sqrt(dx * dx + dz * dz);

            // Cache time in state
            TimeInState = (Now - npc.StateEnteredAt).TotalSeconds;
        }
    }

    // ================================================================
    // BT NODE — base class for all behavior tree nodes
    // Mirrors BehaviorAI.Node.Action / Conditional / Composite / Decorator
    // ================================================================
    public abstract class BTNode
    {
        public string Name { get; set; } = "";
        protected bool _isRunning = false;

        /// <summary>
        /// Main entry point. Handles lifecycle (start/update/end).
        /// </summary>
        public TaskStatus Evaluate(BTContext ctx)
        {
            if (!_isRunning)
            {
                OnStart(ctx);
                _isRunning = true;
            }

            var status = OnUpdate(ctx);

            if (status != TaskStatus.Running)
            {
                OnEnd(ctx);
                _isRunning = false;
            }

            return status;
        }

        /// <summary>Reset running state (used when tree is interrupted).</summary>
        public virtual void Reset()
        {
            _isRunning = false;
        }

        protected virtual void OnStart(BTContext ctx) { }
        protected abstract TaskStatus OnUpdate(BTContext ctx);
        protected virtual void OnEnd(BTContext ctx) { }
    }

    // ================================================================
    // BT TREE — container that holds a root node and evaluates it
    // ================================================================
    public class BTTree
    {
        public BTNode Root;
        public string TreeName;
        public readonly Blackboard Board = new();

        public BTTree(string name, BTNode root)
        {
            TreeName = name;
            Root = root;
        }

        /// <summary>
        /// Evaluate the tree for a given NPC in a connection context.
        /// Called every tick by NpcBehaviorManager.
        /// </summary>
        public TaskStatus Evaluate(Connection conn, Connection.SpawnedNpc npc)
        {
            var ctx = new BTContext(conn, npc, Board);
            return Root.Evaluate(ctx);
        }
    }
}
