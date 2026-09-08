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
