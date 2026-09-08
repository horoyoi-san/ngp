pub const MODE_INVOKE: u8 = 1;
pub const MODE_RETURN: u8 = 2;
pub const MODE_NOTIFY: u8 = 3;

pub const MARK_NULL: u8 = 0;
pub const MARK_COMMON: u8 = 255;

pub struct BinaryWriter {
    pub buffer: Vec<u8>,
}

impl BinaryWriter {
    pub fn new() -> Self {
        Self { buffer: Vec::new() }
    }

    pub fn write_byte(&mut self, val: u8) {
        self.buffer.push(val);
    }

    pub fn write_int32(&mut self, val: i32) {
        self.buffer.extend_from_slice(&val.to_le_bytes());
    }

    pub fn write_uint32(&mut self, val: u32) {
        self.buffer.extend_from_slice(&val.to_le_bytes());
    }

    pub fn write_uint64(&mut self, val: u64) {
        self.buffer.extend_from_slice(&val.to_le_bytes());
    }

    pub fn write_double(&mut self, val: f64) {
        self.buffer.extend_from_slice(&val.to_le_bytes());
    }

    pub fn write_7bit_encoded_int(&mut self, mut val: u32) {
        while val >= 0x80 {
            self.buffer.push(((val | 0x80) & 0xFF) as u8);
            val >>= 7;
        }
        self.buffer.push((val & 0xFF) as u8);
    }

    pub fn write_string(&mut self, val: &str, nullable: bool) {
        if nullable {
            self.write_byte(MARK_COMMON);
        }
        let bytes = val.as_bytes();
        self.write_7bit_encoded_int(bytes.len() as u32);
        self.buffer.extend_from_slice(bytes);
    }

    pub fn into_bytes(self) -> Vec<u8> {
        self.buffer
    }
}

pub struct BinaryReader<'a> {
    pub data: &'a [u8],
    pub offset: usize,
}

impl<'a> BinaryReader<'a> {
    pub fn new(data: &'a [u8]) -> Self {
        Self { data, offset: 0 }
    }

    pub fn remaining(&self) -> usize {
        self.data.len().saturating_sub(self.offset)
    }

    pub fn read_byte(&mut self) -> Result<u8, &'static str> {
        if self.offset >= self.data.len() {
            return Err("Unexpected EOF");
        }
        let b = self.data[self.offset];
        self.offset += 1;
        Ok(b)
    }

    pub fn read_int32(&mut self) -> Result<i32, &'static str> {
        if self.remaining() < 4 {
            return Err("Unexpected EOF");
        }
        let val = i32::from_le_bytes(self.data[self.offset..self.offset + 4].try_into().unwrap());
        self.offset += 4;
        Ok(val)
    }

    pub fn read_uint64(&mut self) -> Result<u64, &'static str> {
        if self.remaining() < 8 {
            return Err("Unexpected EOF");
        }
        let val = u64::from_le_bytes(self.data[self.offset..self.offset + 8].try_into().unwrap());
        self.offset += 8;
        Ok(val)
    }

    pub fn read_7bit_encoded_int(&mut self) -> Result<u32, &'static str> {
        let mut count = 0u32;
        let mut shift = 0;
        while shift < 35 {
            let b = self.read_byte()?;
            count |= ((b & 0x7F) as u32) << shift;
            shift += 7;
            if (b & 0x80) == 0 {
                return Ok(count);
            }
        }
        Err("Invalid 7-bit encoded int")
    }

    pub fn read_string(&mut self, nullable: bool) -> Result<String, &'static str> {
        if nullable {
            let mark = self.read_byte()?;
            if mark == MARK_NULL {
                return Ok(String::new());
            }
        }

        let len = self.read_7bit_encoded_int()? as usize;
        if len == 0 {
            return Ok(String::new());
        }
        if self.remaining() < len {
            return Err("String length out of bounds");
        }
        let s = String::from_utf8_lossy(&self.data[self.offset..self.offset + len]).to_string();
        self.offset += len;
        Ok(s)
    }
}

pub struct RpcPacket {
    pub mode: u8,
    pub method_id: i32,
    pub invoke_id: i32,
    pub err_id: i32,
    pub payload: Vec<u8>,
}

impl RpcPacket {
    pub fn new(mode: u8, method_id: i32, invoke_id: i32, err_id: i32, payload: Vec<u8>) -> Self {
        Self {
            mode,
            method_id,
            invoke_id,
            err_id,
            payload,
        }
    }

    pub fn encode(&self, include_framing: bool) -> Vec<u8> {
        let mut body = BinaryWriter::new();
        body.write_byte(self.mode);
        body.write_int32(self.method_id);

        if self.mode == MODE_INVOKE || self.mode == MODE_RETURN {
            body.write_int32(self.invoke_id);
        }

        if self.mode == MODE_RETURN {
            body.write_int32(self.err_id);
        }

        body.buffer.extend_from_slice(&self.payload);

        let body_bytes = body.into_bytes();
        if !include_framing {
            return body_bytes;
        }

        let mut framed = BinaryWriter::new();
        framed.write_uint32(body_bytes.len() as u32);
        framed.buffer.extend_from_slice(&body_bytes);
        framed.into_bytes()
    }

    pub fn decode(data: &[u8]) -> Result<Self, &'static str> {
        if data.len() < 5 {
            return Err("Packet too short");
        }

        let mut reader = BinaryReader::new(data);
        let mode = reader.read_byte()?;
        let method_id = reader.read_int32()?;
        let mut invoke_id = 0;
        let mut err_id = 0;

        if mode == MODE_INVOKE || mode == MODE_RETURN {
            invoke_id = reader.read_int32()?;
        }

        if mode == MODE_RETURN {
            err_id = reader.read_int32()?;
        }

        let payload = reader.data[reader.offset..].to_vec();
        Ok(Self::new(mode, method_id, invoke_id, err_id, payload))
    }
}
