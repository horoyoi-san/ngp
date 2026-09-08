# Ananta Private Server (.NET 9 C#)

เซิร์ฟเวอร์จำลองภาษา **C# (.NET 9)** พัฒนาให้ตรงกับโครงสร้างภายในของเอนจิน Unity ของเกม Project Mugen / Ananta

---

## 🚀 วิธีเปิดเซิร์ฟเวอร์
1. ดับเบิลคลิกที่:
   ```
   start_server.bat
   ```
   *(หรือเปิด Terminal แล้วพิมพ์ `dotnet run`)*

2. ตรวจสอบสถานะผ่านเบราว์เซอร์ที่:
   👉 **[http://127.0.0.1:8080](http://127.0.0.1:8080)**

---

## 🛠️ การคอมไพล์เป็นไฟล์ .exe สำหรับแจกจ่าย (Standalone Release)
หากต้องการคอมไพล์ออกมาเป็นไฟล์ `.exe` เดี่ยวๆ ที่เครื่องอื่นเปิดได้โดยไม่ต้องติดตั้ง .NET SDK:
```powershell
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```
ไฟล์ `.exe` จะถูกสร้างในโฟลเดอร์ `bin\Release\net9.0\win-x64\publish\`

# Ananta Private Server (Node.js)

เซิร์ฟเวอร์จำลองภาษา **JavaScript / Node.js** พัฒนาด้วย Pure Node.js Standard Library (`net`, `http`, `buffer`) เบา รันไว ไม่ต้อง `npm install` เพิ่ม

---

## 🚀 วิธีเปิดเซิร์ฟเวอร์
1. ดับเบิลคลิกที่:
   ```
   start_server.bat
   ```
   *(หรือเปิด Terminal แล้วพิมพ์ `node main.js`)*

2. ตรวจสอบสถานะผ่านเบราว์เซอร์ที่:
   👉 **[http://127.0.0.1:8080](http://127.0.0.1:8080)**

# คู่มือการใช้งาน Private Server (Project Mugen / Ananta)

โปรเจกต์นี้คือ **Private Server Emulator** สำหรับเกม **Project Mugen (Ananta)** ที่พร้อมใช้งานทันที โดยไม่ต้องติดตั้ง SDK หรือ Compile โค้ดเพิ่ม

---

## 🚀 วิธีเริ่มใช้งานเซิร์ฟเวอร์ (Quick Start)

### วิธีที่ 1: ดับเบิลคลิกไฟล์ Batch
เข้าไปที่โฟลเดอร์ `server/` แล้วดับเบิลคลิกที่:
```
start_server.bat
```

### วิธีที่ 2: รันผ่าน Terminal / PowerShell
```powershell
cd c:\Horoyoi-san\PS\ngp\server
python main.py
```

เมื่อเซิร์ฟเวอร์เริ่มทำงาน จะแสดงข้อความ:
```
============================================================
  [+] HTTP Gateway Server : http://127.0.0.1:8080
  [+] UX RPC Socket Server: 127.0.0.1:8888 (TCP)
  [+] Status               : READY TO CONNECT
============================================================
```

คุณสามารถเปิดเบราว์เซอร์แล้วเข้าไปดูหน้าสถานะเซิร์ฟเวอร์ได้ที่:
👉 **[http://127.0.0.1:8080](http://127.0.0.1:8080)**

---

## ⚙️ การตั้งค่าเซิร์ฟเวอร์ (`config.json`)

คุณสามารถแก้ไขการตั้งค่าต่างๆ ได้ที่ไฟล์ `server/config.json`:

```json
{
  "server": {
    "name": "Ananta Local Server",
    "host": "0.0.0.0",
    "public_ip": "127.0.0.1",
    "http_port": 8080,
    "login_port": 8888,
    "gate_port": 8888,
    "region_name": "Local Private Server"
  },
  "gameplay": {
    "default_player": {
      "name": "Player",
      "level": 90,
      "gold": 999999,
      "diamond": 99999,
      "stamina": 240
    }
  }
}
```

- **`public_ip`**: หากต้องการให้เพื่อนในวง LAN เข้ามาเล่นด้วยได้ ให้เปลี่ยนเป็น IP เครื่องของคุณ (เช่น `192.168.1.xxx`)
- **`default_player`**: ค่าสเตตัส เงิน และเพชรเริ่มต้นสำหรับผู้เล่นใหม่ที่เพิ่งสมัครเข้ามา

---

## 💾 ระบบข้อมูลผู้เล่น (Save Data & Item Modification)

เมื่อมีผู้เล่น Login เข้ามา ข้อมูลจะถูกบันทึกเป็นไฟล์ JSON อัตโนมัติใน:
`server/data/players/{ชื่อไอดี}.json`

คุณสามารถเปิดไฟล์นี้ขึ้นมาแก้ไขได้ตลอดเวลา:
- เปลี่ยนเลเวล (`level`)
- ปรับจำนวนเงิน/เพชร (`gold`, `diamond`, `stamina`)
- เสกไอเทมในกระเป๋า (`inventory`)

---

## 🎮 วิธีเชื่อมต่อตัวเกม (Client Connection)

### วิธีที่ 1: ปลดล็อกปุ่มเลือก Server & ใส่ Account ใน Client (แนะนำ)
รันสคริปต์ Patcher เพื่อเปิดปุ่มเมนูทดสอบในหน้า Login ของเกม:
```powershell
python server/tools/client_patcher.py
```
เมื่อรันเสร็จ หน้าจอ Login ของเกมจะแสดง:
1. **ปุ่ม Server Selection**: เพื่อเลือกหรือเปลี่ยน IP ไปยังเซิร์ฟเวอร์ของคุณ
2. **ปุ่ม Test Account**: สามารถพิมพ์ชื่อไอดีอะไรก็ได้แล้วกดเข้าเล่นได้ทันที

### วิธีที่ 2: ใช้ Network Proxy (Fiddler / mitmproxy)
หากไม่ต้องการแก้ไขไฟล์เกม คุณสามารถใช้ Fiddler ดักจับ HTTP Request ที่เกมส่งไปหา NetEase แล้ว Redirect ไปยัง:
`http://127.0.0.1:8080`

---

## 🧪 การทดสอบระบบ (Automated Test)
ในโฟลเดอร์มีเครื่องมือทดสอบการทำงานของทั้งระบบ HTTP และ TCP RPC โดยไม่ต้องเปิดตัวเกม:
```powershell
python server/tools/test_client.py
```
สคริปต์จะจำลองการต่อเข้าเซิร์ฟเวอร์ ส่ง Packet `CheckVersion`, `TryLogin`, และขอ Token เข้าเกมให้ดูแบบสมบูรณ์

# Ananta Private Server (Rust)

เซิร์ฟเวอร์จำลองภาษา **Rust** ประสิทธิภาพสูงสุด ใช้หน่วยความจำน้อยมาก พัฒนาด้วย Pure Rust Standard Library (`std::net::TcpListener`, `std::thread`) คอมไพล์และรันได้ทันทีโดยไม่ต้องดาวน์โหลด Crates เพิ่มเติม

---

## 🚀 วิธีเปิดเซิร์ฟเวอร์
1. ดับเบิลคลิกที่:
   ```
   start_server.bat
   ```
   *(หรือเปิด Terminal แล้วพิมพ์ `cargo run --release`)*

2. ตรวจสอบสถานะผ่านเบราว์เซอร์ที่:
   👉 **[http://127.0.0.1:8080](http://127.0.0.1:8080)**

---

## 🛠️ การคอมไพล์เป็นไฟล์ .exe แบบ Standalone
```powershell
cargo build --release
```
ไฟล์ `.exe` จะได้ที่ `target\release\server_rust.exe` ขนาดเล็กและทำงานได้อิสระบน Windows
