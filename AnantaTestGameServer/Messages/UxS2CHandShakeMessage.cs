using AnantaTestGameServer.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Messages
{
    public class UxS2CHandShakeMessage : UxMessage
    {

        public int SessionId;
        public int HeartbeatInterval;
        public bool Encryption;
        public byte[] Keys;
        // Constructors
        public UxS2CHandShakeMessage() : base(UxMessageType.S2CHandShake)
        {

        }
        public override void Parse()
        {
            this.SessionId = BitConverter.ToInt32(Body, 0);
            this.HeartbeatInterval = BitConverter.ToInt32(Body, 4);
            this.Encryption = BitConverter.ToBoolean(Body, 8);
            Keys=Body.ToList().GetRange(9, Body.Length-9).ToArray();
        }
        public static PooledArray<byte> GenerateSessionKeys(int MagicNum, DateTime timestamp)
        {
            using (var sha256 = SHA256.Create())
            {
                var keyBuilder = new StringBuilder();
                keyBuilder.Append(MagicNum);
                keyBuilder.Append(timestamp.Ticks.ToString());
                keyBuilder.Append(timestamp.ToString("o"));

                string seed = "SaumaLegs";
                keyBuilder.Append(seed);

                byte[] nanookBytes = new byte[16];
                using (var rng = RandomNumberGenerator.Create())
                {
                    rng.GetBytes(nanookBytes);
                }
                keyBuilder.Append(Convert.ToBase64String(nanookBytes));

                byte[] inputBytes = Encoding.UTF8.GetBytes(keyBuilder.ToString());
                byte[] hashBytes = sha256.ComputeHash(inputBytes);

                var sessionKeys = UXArrayPool<byte>.Rent(16);
                Array.Copy(hashBytes, 0, sessionKeys.GetBuffer()!, 0, 16);
                return sessionKeys;
            }
        }

        public override void Build()
        {
            this.WriteInt(SessionId);
            this.WriteInt(HeartbeatInterval);
            this.WriteBool(Encryption);
            if(Encryption)
                this.WriteBytes(Keys);
            

            this.FinalizeBuild();
        }

        public override string ToString()
        {
            return $"UxMessageType: {Type} SessionId: {SessionId}";
        }
    }
}
