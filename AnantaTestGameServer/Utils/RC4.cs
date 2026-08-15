using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Utils
{
    public class RC4
    {
        public byte[] S = new byte[256];
        private int x = 0;
        private int y = 0;

        public RC4(byte[] key)
        {
            Init(key);
        }

        private void Init(byte[] key)
        {
            for (int i = 0; i < 256; i++)
                S[i] = (byte)i;

            int j = 0;
            for (int i = 0; i < 256; i++)
            {
                j = (j + S[i] + key[i % key.Length]) & 255;
                (S[i], S[j]) = (S[j], S[i]);
            }
        }

        public byte[] Crypt(byte[] data)
        {
            byte[] result = new byte[data.Length];

            for (int i = 0; i < data.Length; i++)
            {
                x = (x + 1) & 255;
                y = (y + S[x]) & 255;

                (S[x], S[y]) = (S[y], S[x]);

                byte k = S[(S[x] + S[y]) & 255];
                result[i] = (byte)(data[i] ^ k);
            }

            return result;
        }
    }

}
