using AnantaTestGameServer.BehaviorTreeEngine;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Dialogue System — handles NPC dialogues with the player.
    /// Mirrors DLL's DialogueModule + DialogueModuleTask.
    ///
    /// Processes AskAgentStartNpcDialog / AskAgentFinishNpcDialog requests.
    /// Sends SyncAgentPrepareStartNpcDialog / SyncAgentFinishNpcDialog.
    /// </summary>
    public static class DialogueSystem
    {
        // ================================================================
        // DIALOGUE DATA
        // ================================================================

        /// <summary>
        /// Simple dialogue entry — text + optional choices.
        /// </summary>
        public class DialogueEntry
        {
            public uint DialogueId;
            public string NpcText;
            public List<DialogueChoice> Choices;
        }

        public class DialogueChoice
        {
            public uint ChoiceId;
            public string Text;
            public uint NextDialogueId; // 0 = end dialogue
        }

        /// <summary>
        /// Pre-built dialogues for common NPC interactions.
        /// In the real game, these come from Spoon graph configs.
        /// </summary>
        static readonly Dictionary<uint, DialogueEntry> DefaultDialogues = new()
        {
            { 1001, new DialogueEntry { DialogueId = 1001, NpcText = "Hello there! Nice weather today.", Choices = new() {
                new DialogueChoice { ChoiceId = 1, Text = "Yes, it is!", NextDialogueId = 1002 },
                new DialogueChoice { ChoiceId = 2, Text = "I'm in a hurry.", NextDialogueId = 0 },
            }}},
            { 1002, new DialogueEntry { DialogueId = 1002, NpcText = "Take care out there!", Choices = new() {
                new DialogueChoice { ChoiceId = 1, Text = "You too.", NextDialogueId = 0 },
            }}},
            { 2001, new DialogueEntry { DialogueId = 2001, NpcText = "Need any help?", Choices = new() {
                new DialogueChoice { ChoiceId = 1, Text = "Maybe later.", NextDialogueId = 0 },
                new DialogueChoice { ChoiceId = 2, Text = "What do you sell?", NextDialogueId = 2002 },
            }}},
            { 2002, new DialogueEntry { DialogueId = 2002, NpcText = "I have various goods. Take a look!", Choices = new() {
                new DialogueChoice { ChoiceId = 1, Text = "Thanks.", NextDialogueId = 0 },
            }}},
        };

        // ================================================================
        // DIALOGUE STATE
        // ================================================================

        /// <summary>
        /// Start a dialogue between a player and an NPC.
        /// Called when client sends AskAgentStartNpcDialog.
        /// </summary>
        public static void StartDialogue(Connection conn, ulong npcEntityId, uint dialogueId = 0)
        {
            var npc = conn.GetNpcById(npcEntityId);
            if (npc == null) return;

            // Set NPC to Talking state
            npc.PreviousState = npc.CurrentState;
            npc.CurrentState = Connection.NpcState.Talking;
            npc.StateEnteredAt = DateTime.UtcNow;
            npc.InteractionTargetId = conn.Pid;

            // Pick default dialogue if not specified
            if (dialogueId == 0)
            {
                dialogueId = PickDefaultDialogue(npc);
            }

            npc.Board?.Set("dialogueId", dialogueId);
            npc.Board?.Set("inDialogue", true);

            // Send prepare start dialog sync
            SendPrepareStartDialog(conn, npcEntityId, dialogueId);

            // Send the dialogue data
            if (DefaultDialogues.TryGetValue(dialogueId, out var entry))
            {
                SendDialogueCaption(conn, npcEntityId, entry.NpcText);
            }

            Console.WriteLine($"[Dialogue] Started dialogue {dialogueId} with NPC {npcEntityId}");
        }

        /// <summary>
        /// Finish a dialogue. Called when client sends AskAgentFinishNpcDialog
        /// or when player selects "end" choice.
        /// </summary>
        public static void FinishDialogue(Connection conn, ulong npcEntityId)
        {
            var npc = conn.GetNpcById(npcEntityId);
            if (npc == null) return;

            // Restore previous state
            var prevState = npc.PreviousState;
            npc.CurrentState = prevState;
            npc.StateEnteredAt = DateTime.UtcNow;
            npc.InteractionTargetId = 0;
            npc.Board?.Set("inDialogue", false);
            npc.Board?.Remove("dialogueId");

            // Send finish dialog sync
            SendFinishDialog(conn, npcEntityId);

            Console.WriteLine($"[Dialogue] Finished dialogue with NPC {npcEntityId}, restored state to {prevState}");
        }

        /// <summary>
        /// Handle a dialogue choice from the player.
        /// </summary>
        public static void HandleChoice(Connection conn, ulong npcEntityId, uint choiceId)
        {
            var npc = conn.GetNpcById(npcEntityId);
            if (npc == null) return;

            var currentDialogId = npc.Board?.Get<uint>("dialogueId", 0) ?? 0;
            if (currentDialogId == 0) return;

            if (DefaultDialogues.TryGetValue(currentDialogId, out var entry))
            {
                var choice = entry.Choices?.Find(c => c.ChoiceId == choiceId);
                if (choice != null)
                {
                    if (choice.NextDialogueId == 0)
                    {
                        FinishDialogue(conn, npcEntityId);
                    }
                    else if (DefaultDialogues.TryGetValue(choice.NextDialogueId, out var nextEntry))
                    {
                        npc.Board?.Set("dialogueId", choice.NextDialogueId);
                        SendDialogueCaption(conn, npcEntityId, nextEntry.NpcText);
                    }
                }
            }
        }

        // ================================================================
        // HELPERS
        // ================================================================

        static uint PickDefaultDialogue(Connection.SpawnedNpc npc)
        {
            // Simple heuristic: shopping NPCs get shop dialogue, others get greeting
            if (npc.CurrentState == Connection.NpcState.Shopping)
                return 2001;
            return 1001;
        }

        /// <summary>
        /// Check if an NPC is currently in dialogue.
        /// </summary>
        public static bool IsInDialogue(Connection.SpawnedNpc npc)
        {
            return npc.CurrentState == Connection.NpcState.Talking;
        }

        // ================================================================
        // PACKET SENDERS
        // ================================================================

        static void SendPrepareStartDialog(Connection conn, ulong npcId, uint dialogueId)
        {
            var data = new PrepareDialogArgs()
            {
                agentId = npcId,
                dialogId = dialogueId,
            };
            SendNotify(conn, MethodId.SyncAgentPrepareStartNpcDialog, data);
        }

        static void SendFinishDialog(Connection conn, ulong npcId)
        {
            var data = new FinishDialogArgs()
            {
                agentId = npcId,
            };
            SendNotify(conn, MethodId.SyncAgentFinishNpcDialog, data);
        }

        static void SendDialogueCaption(Connection conn, ulong npcId, string text)
        {
            var data = new DialogCaptionArgs()
            {
                agentId = npcId,
                text = text,
            };
            SendNotify(conn, MethodId.SyncAgentShowDialogCaption, data);
        }

        static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            var msg = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            msg.SetArgs(methodId, args);
            conn.SendPacket(msg);
        }

        class PrepareDialogArgs : SerializedClass
        {
            public ulong agentId;
            public uint dialogId;
            public PrepareDialogArgs() { onlyFields = true; }
        }

        class FinishDialogArgs : SerializedClass
        {
            public ulong agentId;
            public FinishDialogArgs() { onlyFields = true; }
        }

        class DialogCaptionArgs : SerializedClass
        {
            public ulong agentId;
            public string text;
            public DialogCaptionArgs() { onlyFields = true; }
        }
    }
}
