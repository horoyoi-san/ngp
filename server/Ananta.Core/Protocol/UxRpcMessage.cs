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
            this.Mode=(UxRpcPacketMode)Body[0];
            if (Mode == UxRpcPacketMode.Invoke)
            {
                this.RpcMethodId = BitConverter.ToInt32(Body, 1);
                this.RpcInvokeId = BitConverter.ToInt32(Body, 1 + 4 );
                this.RpcPayloadLength = Body.Length - (1 + 4 + 4);
                this.RpcPayloadOffset = 1 + 4 + 4;
            }
            if (Mode == UxRpcPacketMode.Return)
            {
                this.RpcMethodId = BitConverter.ToInt32(Body, 1);
                this.RpcInvokeId = BitConverter.ToInt32(Body, 1 + 4);
                this.RpcRetcode = BitConverter.ToUInt32(Body, 1+4+4);
                this.RpcPayloadLength = Body.Length - (1 + 4 + 4 + 4);
                this.RpcPayloadOffset = 1 + 4 + 4 + 4;
            }
            
            if (Mode == UxRpcPacketMode.Notify)
            {
                this.RpcMethodId = BitConverter.ToInt32(Body, 1);
               // this.RpcInvokeId = BitConverter.ToInt32(Body, 1 + 4);
                this.RpcPayloadLength = Body.Length - (1 + 4);
                this.RpcPayloadOffset = 1 + 4;
            }
            Args = GetRpcBytes();
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
