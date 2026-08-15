
using AnantaTestGameServer.Methods;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Messages
{
    public enum UxRpcPacketMode : byte // TypeDefIndex: 51686
    {
        Invoke = 1,
        Return = 2,
        Notify = 3
    }
    public class UxRpcMessage : UxMessage
    {
        public int RpcPayloadOffset;
        public int RpcPayloadLength;
        public UxRpcPacketMode Mode;
        public int RpcInvokeId;
        public int RpcMethodId;
        public uint RpcRetcode;
        public byte[] Args;
        public UxRpcMessage() : base(UxMessageType.Raw)
        {

        }
        public override void Parse()
		{
			// Body format depends on Mode; guard against malformed/desynced packets.
			if (Body == null || Body.Length < 1)
			{
				Mode = 0;
				RpcMethodId = 0;
				RpcInvokeId = 0;
				RpcRetcode = 0;
				RpcPayloadOffset = 0;
				RpcPayloadLength = 0;
				Args = Array.Empty<byte>();
				return;
			}

			Mode = (UxRpcPacketMode)Body[0];

			// Defaults for safety.
			RpcPayloadOffset = 0;
			RpcPayloadLength = 0;
			Args = Array.Empty<byte>();

			// Unknown mode => mark as invalid.
			if (Mode != UxRpcPacketMode.Invoke && Mode != UxRpcPacketMode.Return && Mode != UxRpcPacketMode.Notify)
			{
				RpcMethodId = 0;
				RpcInvokeId = 0;
				RpcRetcode = 0;
				return;
			}

			try
			{
				if (Mode == UxRpcPacketMode.Invoke)
				{
					// [mode:1][methodId:4][invokeId:4][payload...]
					if (Body.Length < 1 + 4 + 4)
						return;

					RpcMethodId = BitConverter.ToInt32(Body, 1);
					RpcInvokeId = BitConverter.ToInt32(Body, 1 + 4);
					RpcPayloadOffset = 1 + 4 + 4;
					RpcPayloadLength = Body.Length - RpcPayloadOffset;
					if (RpcPayloadLength < 0)
					{
						RpcPayloadOffset = 0;
						RpcPayloadLength = 0;
						Args = Array.Empty<byte>();
						return;
					}
				}
				else if (Mode == UxRpcPacketMode.Return)
				{
					// [mode:1][methodId:4][invokeId:4][retcode:4][payload...]
					if (Body.Length < 1 + 4 + 4 + 4)
						return;

					RpcMethodId = BitConverter.ToInt32(Body, 1);
					RpcInvokeId = BitConverter.ToInt32(Body, 1 + 4);
					RpcRetcode = BitConverter.ToUInt32(Body, 1 + 4 + 4);
					RpcPayloadOffset = 1 + 4 + 4 + 4;
					RpcPayloadLength = Body.Length - RpcPayloadOffset;
					if (RpcPayloadLength < 0)
					{
						RpcPayloadOffset = 0;
						RpcPayloadLength = 0;
						Args = Array.Empty<byte>();
						return;
					}
				}
				else if (Mode == UxRpcPacketMode.Notify)
				{
					// [mode:1][methodId:4][payload...]
					if (Body.Length < 1 + 4)
						return;

					RpcMethodId = BitConverter.ToInt32(Body, 1);
					RpcPayloadOffset = 1 + 4;
					RpcPayloadLength = Body.Length - RpcPayloadOffset;
					if (RpcPayloadLength < 0)
					{
						RpcPayloadOffset = 0;
						RpcPayloadLength = 0;
						Args = Array.Empty<byte>();
						return;
					}
				}

				if (RpcPayloadLength > 0)
					Args = GetRpcBytes();
			}
			catch
			{
				// Keep safe defaults on any parsing issue.
				Mode = 0;
				RpcMethodId = 0;
				RpcInvokeId = 0;
				RpcRetcode = 0;
				RpcPayloadOffset = 0;
				RpcPayloadLength = 0;
				Args = Array.Empty<byte>();
			}
		}

        private byte[] GetRpcBytes()
        {
            return Body.AsSpan().Slice(RpcPayloadOffset, RpcPayloadLength).ToArray();
        }
        public T GetArgs<T>() where T : SerializedClass, new()
        {
            // new() permette di creare l'istanza con il costruttore vuoto
            T args = new T();

            // Puoi inizializzare eventuali proprietà qui, ad esempio:
            args.SetBody(Args);
            args.Parse();

            return args;
        }
        public void SetArgs(int methodId, SerializedClass args)
        {
            this.RpcMethodId=   methodId;
            args.Build();
            Args = args.GetBody();
        }
        public void SetArgs(MethodId methodId, SerializedClass args)
        {
            SetArgs((int)methodId, args);
        }
        public override void Build()
        {
            this.WriteByte((byte)Mode);
            if (Mode == UxRpcPacketMode.Invoke)
            {
                this.WriteInt(RpcMethodId);
                this.WriteInt(RpcInvokeId);

            }
            if (Mode == UxRpcPacketMode.Return)
            {
                this.WriteInt(RpcMethodId);
                this.WriteInt(RpcInvokeId);
                this.WriteUInt(RpcRetcode);
                
            }
            if (Mode == UxRpcPacketMode.Notify)
            {
                this.WriteInt(RpcMethodId);
           
            }
            if (Args != null)
                this.WriteRawBytes(Args);
            this.FinalizeBuild();
        }
        public string ToHex2()
        {
            string bodyHex = Args != null ? BitConverter.ToString(Args).Replace("-", " ") : "null";
            return $"Body: {bodyHex}";
        }
        public override string ToString()
        {
            return $"UxMessageType: {Type} RpcPayloadLength: {RpcPayloadLength}, RpcMode: {Mode},RpcRetcode: {(UxMessageRetcode)RpcRetcode},  RpcMethodId: {(MethodId)RpcMethodId}, RpcInvokeId: {RpcInvokeId} {ToHex2()}";
        }
    }
}
