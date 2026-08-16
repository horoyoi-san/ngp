using AnantaTestGameServer.Methods.Return;
using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Reflection.PortableExecutable;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace AnantaTestGameServer.Methods
{
    public class SerializedClass
    {
        protected MemoryStream _buildStream;
        protected BinaryWriter _writer;
        protected BinaryReader _reader;

        protected byte[] Body;
        protected bool onlyFields = false;
        protected byte CustomFlagType;
        public SerializedClass()
        {
            _buildStream = new MemoryStream();
            _writer = new BinaryWriter(_buildStream);
        }
        public string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }

        public void FinalizeBuild()
        {
            Body = _buildStream.ToArray();
            _buildStream = new MemoryStream();
            _writer = new BinaryWriter(_buildStream);
        }

        public void Build() {

            var fields = GetType()
            .GetFields(BindingFlags.Instance | BindingFlags.Public)
            .OrderBy(f => f.MetadataToken);
            if(onlyFields==false)
               WriteByte(CustomFlagType == 0 ? (byte)0xFF : (byte)CustomFlagType);

            foreach (var field in fields)
            {
                object value = field.GetValue(this);
                WriteValue(field.FieldType, value);
            }

            FinalizeBuild();
        }
        public void Parse()
        {
            if (Body != null)
                _reader = new BinaryReader(new MemoryStream(Body));

            var fields = GetType()
                .GetFields(BindingFlags.Instance | BindingFlags.Public)
                .OrderBy(f => f.MetadataToken);
            if (!onlyFields)
            {
                byte sizeIdk = _reader.ReadByte();
                if (sizeIdk != 0xff)
                {
                    _reader.BaseStream.Position -= 1;
                }

            }

            foreach (var field in fields)
            {
                object value = ReadValue(field.FieldType);
                field.SetValue(this, value);
            }
        }

        // ----------------- WRITE -----------------
        protected void WriteValue(Type type, object value)
        {
           
            if (type == typeof(int))
                WriteInt((int)value);
            else if (type == typeof(uint))
                WriteUInt((uint)value);
            else if (type == typeof(short))
                WriteShort((short)value);
            else if (type == typeof(ushort))
                WriteUShort((ushort)value);
            else if (type == typeof(long))
                WriteLong((long)value);
            else if (type == typeof(ulong))
                WriteULong((ulong)value);
            else if (type == typeof(byte))
                WriteByte((byte)value);
            else if (type == typeof(bool))
                WriteBool((bool)value);
            else if (type == typeof(float))
                WriteFloat((float)value);
            else if (type == typeof(double))
                WriteDouble((double)value);

            else if (type == typeof(string))
            {
                var str = (string)value ?? null;
                WriteString(str);
            }
            else if (type == typeof(byte[]))
            {
                var data = (byte[])value ?? Array.Empty<byte>();
                WriteByte(0xFF);
                WriteInt(data.Length);
                WriteRawBytes(data);
            }
            else if (type.IsEnum)
            {
                //WriteByte(0xFF);
                WriteByte(Convert.ToByte(value));
            }
            else if (typeof(SerializedClass).IsAssignableFrom(type))
            {
                var obj = (SerializedClass)value;
                if (obj == null)
                {
                    Console.WriteLine("null class");
                    _writer.Write((byte)0x00);
                    return;
                }
                obj?.Build();
                var body = obj?.Body ?? Array.Empty<byte>();
                _writer.Write(body);
            }
            else if (type.IsArray)
            {
                Type elementType = type.GetElementType();

                Array array = value as Array ?? Array.CreateInstance(elementType, 0);

                WriteByte(0xFF);
                WriteUInt((uint)array.Length);

                for (int i = 0; i < array.Length; i++)
                {
                    object element = array.GetValue(i);
                    WriteValue(elementType, element);
                }
            }
            else if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(List<>))
            {
                Type elementType = type.GetGenericArguments()[0];
                var l = value;
                var list = (IList)l ?? (IList)Activator.CreateInstance(type);
                
                WriteByte(0xFF);
                WriteInt(list.Count);
                foreach (var item in list)
                {
                    WriteValue(elementType, item);
                }
               

            }
            else if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(Dictionary<,>))
            {
                Type keyType = type.GetGenericArguments()[0];
                Type valueType = type.GetGenericArguments()[1];

                var dict = value;
                var dictionary = (System.Collections.IDictionary)dict;
                if (dict == null)
                {
                    Console.WriteLine("null dict");
                    WriteByte(0x0);
                   // WriteInt(0);
                    return;
                }
                WriteByte(0xFF);
                WriteInt(dictionary.Count);
                
                foreach (System.Collections.DictionaryEntry entry in dictionary)
                {
                    // =========================
                    // KEY
                    // =========================
                    WriteValue(keyType, entry.Key);


                    // =========================
                    // VALUE
                    // =========================
                    WriteValue(valueType, entry.Value);
                }
            }

            else
                throw new NotSupportedException($"Unsupported type: {type.Name}");
        }
        protected void WriteByte(byte value) => _writer.Write(value);
        protected void WriteBool(bool value) => _writer.Write(value);
        protected void WriteShort(short value) => _writer.Write(value);
        protected void WriteUShort(ushort value) => _writer.Write(value);
        protected void WriteInt(int value) => _writer.Write(value);
        public void WriteIntBE( int value)
        {
            byte[] bytes = BitConverter.GetBytes(value);

            if (BitConverter.IsLittleEndian)
                Array.Reverse(bytes);

            _writer.Write(bytes);
        }
        protected void WriteUInt(uint value) => _writer.Write(value);
        protected void WriteLong(long value) => _writer.Write(value);
        protected void WriteULong(ulong value) => _writer.Write(value);
        protected void WriteFloat(float value) => _writer.Write(value);
        protected void WriteDouble(double value) => _writer.Write(value);
        protected void WriteBytes(byte[] value)
        {
            if (value == null)
            {
                _writer.Write((byte)0);
                return;
            }
            if (value.Length < 1)
            {
                _writer.Write((byte)0);
                return;
            }
            _writer.Write7BitEncodedInt(value.Length + 1);
            _writer.Write(value);
            
        }
        protected void WriteRawBytes(byte[] value)
        {
           
            _writer.Write(value);
        }

        // Scrive una stringa compatibile con ReadString
        protected void WriteString(string value)
        {
            if (value == null)
            {
                _writer.Write((byte)0);
                return;
            }
            byte[] data = Encoding.UTF8.GetBytes(value);

            // Scrivi la lunghezza come 7-bit encoded int
            _writer.Write7BitEncodedInt(data.Length+1);

            // Scrivi i byte
            _writer.Write(data);
        }

       

        // ----------------- READ -----------------

        // Inizializza il reader da un buffer
        public void InitReader(byte[] buffer)
        {
            _reader = new BinaryReader(new MemoryStream(buffer));
        }
        protected object ReadValue(Type type)
        {
            if (type == typeof(int))
                return _reader.ReadInt32();
            else if (type == typeof(uint))
                return _reader.ReadUInt32();
            else if (type == typeof(short))
                return _reader.ReadInt16();
            else if (type == typeof(ushort))
                return _reader.ReadUInt16();
            else if (type == typeof(long))
                return _reader.ReadInt64();
            else if (type == typeof(ulong))
                return _reader.ReadUInt64();
            else if (type == typeof(byte))
                return _reader.ReadByte();
            else if (type == typeof(bool))
                return _reader.ReadBoolean();
            else if (type == typeof(float))
                return _reader.ReadSingle();
            else if (type == typeof(double))
                return _reader.ReadDouble();

            // string
            else if (type == typeof(string))
            {
                return ReadString();
            }

            // byte[]
            else if (type == typeof(byte[]))
            {
                byte Flag = _reader.ReadByte();
                int len = _reader.ReadInt32();
                return _reader.ReadBytes(len);
            }
            else if (type.IsArray)
            {
                Type elementType = type.GetElementType();
                byte flag = _reader.ReadByte();
                int len = _reader.ReadInt32();

                Array array = Array.CreateInstance(elementType, len);

                for (int i = 0; i < len; i++)
                {
                    array.SetValue(ReadValue(elementType), i);
                }

                return array;
            }
            // enum
            else if (type.IsEnum)
            {
                return Enum.ToObject(type, _reader.ReadByte());
            }
            else if (typeof(SerializedClass).IsAssignableFrom(type))
            {
                
                var obj = (SerializedClass)Activator.CreateInstance(type);
                obj._reader= _reader;
                obj.Parse();
                return obj;
            }
            else if (type == typeof(List<int>))
            {
                byte listFlag = _reader.ReadByte();
                int len = _reader.ReadInt32();
                var list = new List<int>();
                for (int i = 0; i < len; i++)
                {
                    var member = _reader.ReadInt32();
                    list.Add(member);
                }
                return list;
            }
            else if (type == typeof(List<ulong>))
            {
                byte listFlag = _reader.ReadByte();
                int len = _reader.ReadInt32();
                var list = new List<ulong>();
                for (int i = 0; i < len; i++)
                {
                    var member = _reader.ReadUInt64();
                    list.Add(member);
                }
                return list;
            }

            else if (type == typeof(List<string>))
            {
                byte listFlag = _reader.ReadByte();
                int len = _reader.ReadInt32();
                var list = new List<string>();
                for (int i = 0; i < len; i++)
                {
                    var member = ReadString();
                    list.Add(member);
                }
                return list;
            }
            else if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(List<>))
            {
                Type elementType = type.GetGenericArguments()[0];

                byte listFlag = _reader.ReadByte();
                int len = _reader.ReadInt32();

                var list = (IList)Activator.CreateInstance(type);

                for (int i = 0; i < len; i++)
                {
                    object element = ReadValue(elementType);
                    list.Add(element);
                }

                return list;
            }
            else if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(Dictionary<,>))
            {
                Type keyType = type.GetGenericArguments()[0];
                Type valueType = type.GetGenericArguments()[1];

                byte dictFlag = _reader.ReadByte();
                int len = _reader.ReadInt32();

                var dict = (IDictionary)Activator.CreateInstance(type);

                for (int i = 0; i < len; i++)
                {
                    object key = ReadValue(keyType);

                    object value;

                    value = ReadValue(valueType);

                    dict.Add(key, value);
                }

                return dict;
            }
            else
                throw new NotSupportedException($"Unsupported type: {type.Name}");
        }
       
        public string ReadString()
        {
            byte nullFlag = _reader.ReadByte();
            if (nullFlag == 0)
                return null;
            _reader.BaseStream.Position -= 1;
            int length = _reader.Read7BitEncodedInt()-1;
            byte[] bytes = _reader.ReadBytes(length);
            return Encoding.UTF8.GetString(bytes);

        }
        public void SetBody(byte[] args)
        {
            Body = args;
        }

        public byte[] GetBody()
        {
            return Body;
        }
    }
}
