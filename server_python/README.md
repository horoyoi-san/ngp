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
