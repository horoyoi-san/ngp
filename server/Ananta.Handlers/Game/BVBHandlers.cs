using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskStartBVBGameArg : SerializedClass
    {
        public uint gameMode;
        public AskStartBVBGameArg() { onlyFields = true; }
    }

    public class AskBVBLockChaosBuffCandidatesArg : SerializedClass
    {
        public uint buffId;
        public AskBVBLockChaosBuffCandidatesArg() { onlyFields = true; }
    }

    public class AskBVBLinkGameSelectTeamArg : SerializedClass
    {
        public uint teamId;
        public AskBVBLinkGameSelectTeamArg() { onlyFields = true; }
    }

    public class AskBVBDebugSelectNpcFightPokemonArg : SerializedClass
    {
        public ulong npcId;
        public uint pokemonId;
        public AskBVBDebugSelectNpcFightPokemonArg() { onlyFields = true; }
    }

    public class AskPlayerOnBVBFinishArg : SerializedClass
    {
        public uint result;
        public AskPlayerOnBVBFinishArg() { onlyFields = true; }
    }

    public class AskBVBGetReadyArg : SerializedClass
    {
        public bool ready;
        public AskBVBGetReadyArg() { onlyFields = true; }
    }

    public class AskBVBUnlockChaosBuffCandidatesArg : SerializedClass
    {
        public uint buffId;
        public AskBVBUnlockChaosBuffCandidatesArg() { onlyFields = true; }
    }

    public class AskBVBSelectFightPokemonListArg : SerializedClass
    {
        public List<uint> pokemonIds;
        public AskBVBSelectFightPokemonListArg() { onlyFields = true; }
    }

    public class AskExitBVBGameArg : SerializedClass
    {
        public AskExitBVBGameArg() { onlyFields = true; }
    }

    public class AskBVBRefreshChaosBuffCandidatesArg : SerializedClass
    {
        public AskBVBRefreshChaosBuffCandidatesArg() { onlyFields = true; }
    }

    public class AskBVBSelectChaosBuffArg : SerializedClass
    {
        public uint buffId;
        public AskBVBSelectChaosBuffArg() { onlyFields = true; }
    }

    public static class BVBHandlers
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

        [Handler(MethodId.AskStartBVBGame)]
        public static void AskStartBVBGameHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskStartBVBGameArg>();
            Console.WriteLine($"[BVB] AskStartBVBGame gameMode={args.gameMode}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartBVBGame);
        }

        [Handler(MethodId.AskBVBLockChaosBuffCandidates)]
        public static void AskBVBLockChaosBuffCandidatesHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBVBLockChaosBuffCandidatesArg>();
            Console.WriteLine($"[BVB] AskBVBLockChaosBuffCandidates buffId={args.buffId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBVBLockChaosBuffCandidates);
        }

        [Handler(MethodId.AskBVBLinkGameSelectTeam)]
        public static void AskBVBLinkGameSelectTeamHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBVBLinkGameSelectTeamArg>();
            Console.WriteLine($"[BVB] AskBVBLinkGameSelectTeam teamId={args.teamId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBVBLinkGameSelectTeam);
        }

        [Handler(MethodId.AskBVBDebugSelectNpcFightPokemon)]
        public static void AskBVBDebugSelectNpcFightPokemonHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBVBDebugSelectNpcFightPokemonArg>();
            Console.WriteLine($"[BVB] AskBVBDebugSelectNpcFightPokemon npcId={args.npcId} pokemonId={args.pokemonId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBVBDebugSelectNpcFightPokemon);
        }

        [Handler(MethodId.AskPlayerOnBVBFinish)]
        public static void AskPlayerOnBVBFinishHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPlayerOnBVBFinishArg>();
            Console.WriteLine($"[BVB] AskPlayerOnBVBFinish result={args.result}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayerOnBVBFinish);
        }

        [Handler(MethodId.AskBVBGetReady)]
        public static void AskBVBGetReadyHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBVBGetReadyArg>();
            Console.WriteLine($"[BVB] AskBVBGetReady ready={args.ready}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBVBGetReady);
        }

        [Handler(MethodId.AskBVBUnlockChaosBuffCandidates)]
        public static void AskBVBUnlockChaosBuffCandidatesHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBVBUnlockChaosBuffCandidatesArg>();
            Console.WriteLine($"[BVB] AskBVBUnlockChaosBuffCandidates buffId={args.buffId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBVBUnlockChaosBuffCandidates);
        }

        [Handler(MethodId.AskBVBSelectFightPokemonList)]
        public static void AskBVBSelectFightPokemonListHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBVBSelectFightPokemonListArg>();
            Console.WriteLine($"[BVB] AskBVBSelectFightPokemonList count={args.pokemonIds?.Count ?? 0}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBVBSelectFightPokemonList);
        }

        [Handler(MethodId.AskExitBVBGame)]
        public static void AskExitBVBGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[BVB] AskExitBVBGame");
            SendEmptySuccessReturn(conn, msg, MethodId.AskExitBVBGame);
        }

        [Handler(MethodId.AskBVBRefreshChaosBuffCandidates)]
        public static void AskBVBRefreshChaosBuffCandidatesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[BVB] AskBVBRefreshChaosBuffCandidates");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBVBRefreshChaosBuffCandidates);
        }

        [Handler(MethodId.AskBVBSelectChaosBuff)]
        public static void AskBVBSelectChaosBuffHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBVBSelectChaosBuffArg>();
            Console.WriteLine($"[BVB] AskBVBSelectChaosBuff buffId={args.buffId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBVBSelectChaosBuff);
        }
    }
}
