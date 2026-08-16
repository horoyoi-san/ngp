using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    // ── Request Args ──────────────────────────────────────────────

    public class AskSetSpiritWearFashionHiddenPartsArg : SerializedClass
    {
        public uint spiritid;
        public byte hiddenparts;
        public AskSetSpiritWearFashionHiddenPartsArg() { onlyFields = true; }
    }

    public class AskSetSpiritCustomSuitSchemeInfoArg : SerializedClass
    {
        public uint spiritid;
        public int schemeindex;
        // customsuitschemeinfo is a complex struct — skip parsing for private server
        public AskSetSpiritCustomSuitSchemeInfoArg() { onlyFields = true; }
    }

    public class AskSetSpiritFunctionSuitSchemeInfoArg : SerializedClass
    {
        public uint spiritid;
        public uint functionsuitid;
        public bool isbatch;
        // functionsuitschemeinfo is a complex struct — skip parsing for private server
        public AskSetSpiritFunctionSuitSchemeInfoArg() { onlyFields = true; }
    }

    public class AskModifySpiritWearFashionEditInfosArg : SerializedClass
    {
        public uint spiritid;
        public List<uint> uneditwearfashionidlist;
        // editwearfashioneditinfolist is a complex list — skip parsing for private server
        public AskModifySpiritWearFashionEditInfosArg() { onlyFields = true; }
    }

    // ── Handlers ──────────────────────────────────────────────────

    public static class SpiritFashionHandlers
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

        /// <summary>
        /// AskSetSpiritCustomSuitSchemeInfo:
        /// Set a custom suit scheme for a spirit (cosmetic outfit combination).
        /// The scheme info is a complex struct — for private server we just acknowledge.
        /// </summary>
        [Handler(MethodId.AskSetSpiritCustomSuitSchemeInfo)]
        public static void AskSetSpiritCustomSuitSchemeInfoHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskSetSpiritCustomSuitSchemeInfoArg>();
                Console.WriteLine($"[Fashion] AskSetSpiritCustomSuitSchemeInfo: spirit={args.spiritid} scheme={args.schemeindex}");
            }
            catch
            {
                Console.WriteLine("[Fashion] AskSetSpiritCustomSuitSchemeInfo (parse failed)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetSpiritCustomSuitSchemeInfo);
        }

        /// <summary>
        /// AskModifySpiritCustomSuitSchemeN:
        /// Rename a custom suit scheme. Already parses args in existing stub — enhanced with state storage.
        /// </summary>
        [Handler(MethodId.AskModifySpiritCustomSuitSchemeN)]
        public static void AskModifySpiritCustomSuitSchemeNameHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskModifySpiritCustomSuitSchemeNArgs>();
            Console.WriteLine($"[Fashion] AskModifySpiritCustomSuitSchemeName: spirit={args.spiritId} scheme={args.schemeIndex} name={args.schemeName}");

            // Store scheme name per spirit/scheme
            string key = $"{args.spiritId}_{args.schemeIndex}";
            conn.SpiritCustomSuitSchemeNames[key] = args.schemeName ?? "";

            SendEmptySuccessReturn(conn, msg, MethodId.AskModifySpiritCustomSuitSchemeN);
        }

        /// <summary>
        /// AskSetSpiritWearFashionHiddenParts:
        /// Toggle hidden body parts on a spirit's fashion (byte bitmask).
        /// </summary>
        [Handler(MethodId.AskSetSpiritWearFashionHiddenPar)]
        public static void AskSetSpiritWearFashionHiddenPartsHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskSetSpiritWearFashionHiddenPartsArg>();
                Console.WriteLine($"[Fashion] AskSetSpiritWearFashionHiddenParts: spirit={args.spiritid} hidden=0x{args.hiddenparts:X2}");

                conn.SpiritHiddenParts[args.spiritid] = args.hiddenparts;
            }
            catch
            {
                Console.WriteLine("[Fashion] AskSetSpiritWearFashionHiddenParts (parse failed)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetSpiritWearFashionHiddenPar);
        }

        /// <summary>
        /// AskSetSpiritFunctionSuitSchemeInfo:
        /// Set a function suit scheme (functional outfit set like combat/work).
        /// The scheme info is a complex struct — for private server we just acknowledge.
        /// </summary>
        [Handler(MethodId.AskSetSpiritFunctionSuitSchemeIn)]
        public static void AskSetSpiritFunctionSuitSchemeInfoHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskSetSpiritFunctionSuitSchemeInfoArg>();
                Console.WriteLine($"[Fashion] AskSetSpiritFunctionSuitSchemeInfo: spirit={args.spiritid} suit={args.functionsuitid} batch={args.isbatch}");

                conn.SpiritFunctionSuitIds[args.spiritid] = args.functionsuitid;
            }
            catch
            {
                Console.WriteLine("[Fashion] AskSetSpiritFunctionSuitSchemeInfo (parse failed)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetSpiritFunctionSuitSchemeIn);
        }

        /// <summary>
        /// AskModifySpiritWearFashionEditInfos:
        /// Edit fashion display info (which fashion items are shown/hidden in the UI).
        /// The edit info list is complex — for private server we just acknowledge.
        /// </summary>
        [Handler(MethodId.AskModifySpiritWearFashionEditIn)]
        public static void AskModifySpiritWearFashionEditInfosHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskModifySpiritWearFashionEditInfosArg>();
                Console.WriteLine($"[Fashion] AskModifySpiritWearFashionEditInfos: spirit={args.spiritid} unedit={args.uneditwearfashionidlist?.Count ?? 0}");
            }
            catch
            {
                Console.WriteLine("[Fashion] AskModifySpiritWearFashionEditInfos (parse failed)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskModifySpiritWearFashionEditIn);
        }
    }
}
