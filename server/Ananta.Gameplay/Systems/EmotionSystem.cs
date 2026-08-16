using AnantaTestGameServer.BehaviorTreeEngine;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using System;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Emotion System — NPCs express emotions based on context.
    /// Mirrors DLL's AgentEmotionManager + EmotionExpressionModule.
    ///
    /// Emotions affect NPC behavior tree scoring and animation.
    /// Sent to client via SyncAgentEmotion packet.
    /// </summary>
    public static class EmotionSystem
    {
        public enum NpcEmotion : byte
        {
            Neutral = 0,
            Fear = 1,
            Anger = 2,
            Happy = 3,
            Sad = 4,
            Surprised = 5,
            Disgusted = 6,
            Curious = 7
        }

        public enum EmotionLevel : byte
        {
            Low = 1,
            Medium = 2,
            High = 3
        }

        /// <summary>
        /// Evaluate and update NPC emotion based on current context.
        /// Called from NpcBehaviorManager.Tick() before BT evaluation.
        /// </summary>
        public static void EvaluateEmotion(Connection conn, Connection.SpawnedNpc npc)
        {
            var newEmotion = DetermineEmotion(conn, npc);

            // Only send sync if emotion changed
            NpcEmotion currentEmotion = npc.Board.Get("emotion", NpcEmotion.Neutral);
            if (newEmotion != currentEmotion)
            {
                npc.Board.Set("emotion", newEmotion);
                var level = GetEmotionLevel(newEmotion, conn, npc);
                SendEmotionSync(conn, npc.EntityId, newEmotion, level);
            }
        }

        /// <summary>
        /// Determine the appropriate emotion for an NPC based on state/context.
        /// </summary>
        static NpcEmotion DetermineEmotion(Connection conn, Connection.SpawnedNpc npc)
        {
            // State-driven emotions (highest priority)
            switch (npc.CurrentState)
            {
                case Connection.NpcState.Fleeing:
                    return NpcEmotion.Fear;

                case Connection.NpcState.Stunned:
                case Connection.NpcState.Unconscious:
                    return NpcEmotion.Sad;

                case Connection.NpcState.Dancing:
                case Connection.NpcState.Celebrating:
                    return NpcEmotion.Happy;

                case Connection.NpcState.Examined:
                    return NpcEmotion.Fear;

                case Connection.NpcState.Talking:
                case Connection.NpcState.Interacting:
                    return NpcEmotion.Happy;

                case Connection.NpcState.Sleeping:
                    return NpcEmotion.Neutral;
            }

            // Context-driven emotions
            if (conn.InCombat)
            {
                float dx = npc.PosX - conn.LastKnownPlayerPosition.X;
                float dz = npc.PosZ - conn.LastKnownPlayerPosition.Z;
                float dist = MathF.Sqrt(dx * dx + dz * dz);

                if (dist < 10f) return NpcEmotion.Fear;
                if (dist < 20f) return NpcEmotion.Surprised;
            }

            // Player nearby → curious
            float playerDist = MathF.Sqrt(
                MathF.Pow(npc.PosX - conn.LastKnownPlayerPosition.X, 2) +
                MathF.Pow(npc.PosZ - conn.LastKnownPlayerPosition.Z, 2));
            if (playerDist < 8f) return NpcEmotion.Curious;

            return NpcEmotion.Neutral;
        }

        static EmotionLevel GetEmotionLevel(NpcEmotion emotion, Connection conn, Connection.SpawnedNpc npc)
        {
            if (emotion == NpcEmotion.Fear && conn.InCombat)
                return EmotionLevel.High;
            return EmotionLevel.Medium;
        }

        /// <summary>
        /// Get a BT score modifier based on current emotion.
        /// Fearful NPCs are more likely to flee, happy NPCs more likely to interact.
        /// </summary>
        public static float GetEmotionScoreModifier(Connection.SpawnedNpc npc)
        {
            var emotion = npc.Board?.Get("emotion", NpcEmotion.Neutral) ?? NpcEmotion.Neutral;
            return emotion switch
            {
                NpcEmotion.Fear => 20f,       // boost flee score
                NpcEmotion.Anger => 10f,       // boost confront score
                NpcEmotion.Happy => -5f,       // slightly reduce flee
                NpcEmotion.Curious => -10f,    // reduce flee, boost approach
                _ => 0f,
            };
        }

        /// <summary>
        /// Force an emotion on an NPC (external trigger, e.g. from combat).
        /// </summary>
        public static void ForceEmotion(Connection conn, Connection.SpawnedNpc npc, NpcEmotion emotion, EmotionLevel level = EmotionLevel.Medium)
        {
            npc.Board?.Set("emotion", emotion);
            SendEmotionSync(conn, npc.EntityId, emotion, level);
        }

        static void SendEmotionSync(Connection conn, ulong agentId, NpcEmotion emotion, EmotionLevel level)
        {
            var data = new EmotionSyncArgs()
            {
                agentId = agentId,
                emotionType = (uint)emotion,
                emotionLevel = (uint)level
            };

            var msg = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentEmotion,
            };
            msg.SetArgs(MethodId.SyncAgentEmotion, data);
            conn.SendPacket(msg);
        }

        class EmotionSyncArgs : Methods.SerializedClass
        {
            public ulong agentId;
            public uint emotionType;
            public uint emotionLevel;
            public EmotionSyncArgs() { onlyFields = true; }
        }
    }
}
