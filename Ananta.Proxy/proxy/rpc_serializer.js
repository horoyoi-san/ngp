

const fs = require("fs");

class Writer {
  constructor() { this.chunks = []; }
  _push(b) { this.chunks.push(b); }
  WriteByte(v) { const b = Buffer.alloc(1); b.writeUInt8(v & 0xff, 0); this._push(b); }
  WriteBoolean(v) { this.WriteByte(v ? 1 : 0); }
  WriteInt16(v) { const b = Buffer.alloc(2); b.writeInt16LE(v | 0, 0); this._push(b); }
  WriteUInt16(v) { const b = Buffer.alloc(2); b.writeUInt16LE(v & 0xffff, 0); this._push(b); }
  WriteInt32(v) { const b = Buffer.alloc(4); b.writeInt32LE(v | 0, 0); this._push(b); }
  WriteUInt32(v) { const b = Buffer.alloc(4); b.writeUInt32LE(v >>> 0, 0); this._push(b); }
  WriteInt64(v) { const b = Buffer.alloc(8); b.writeBigInt64LE(BigInt(v || 0), 0); this._push(b); }
  WriteUInt64(v) { const b = Buffer.alloc(8); b.writeBigUInt64LE(BigInt(v || 0), 0); this._push(b); }
  WriteSingle(v) { const b = Buffer.alloc(4); b.writeFloatLE(v || 0, 0); this._push(b); }
  WriteDouble(v) { const b = Buffer.alloc(8); b.writeDoubleLE(v || 0, 0); this._push(b); }
  WriteString(v) {
    
    if (v === null || v === undefined) { this.WriteByte(0x00); return; }
    const s = Buffer.from(String(v), "utf8");
    this.WriteByte(0xFF);
    this.WriteInt32(s.length);
    this._push(s);
  }
  WriteRawBuffer(buf) { this._push(Buffer.from(buf)); }
  toBuffer() { return Buffer.concat(this.chunks); }
}

const PRIM = {
  ReadByte: "WriteByte", ReadBoolean: "WriteBoolean",
  ReadInt16: "WriteInt16", ReadUInt16: "WriteUInt16",
  ReadInt32: "WriteInt32", ReadUInt32: "WriteUInt32",
  ReadInt64: "WriteInt64", ReadUInt64: "WriteUInt64",
  ReadSingle: "WriteSingle", ReadDouble: "WriteDouble",
  ReadString: "WriteString",
};

const PRIM_DEFAULT = {
  WriteByte: 0, WriteBoolean: false, WriteInt16: 0, WriteUInt16: 0,
  WriteInt32: 0, WriteUInt32: 0, WriteInt64: 0, WriteUInt64: 0,
  WriteSingle: 0, WriteDouble: 0, WriteString: null,
};

class RpcSerializer {
  constructor(schemaPath) {
    const j = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
    this.schemas = j.schemas;
    this.midToReader = j.midToReader;
    this.midToName = j.midToName;
  }

  
  _writePrim(w, op, val) {
    const fn = PRIM[op];
    if (!fn) throw new Error("unknown prim op " + op);
    if (val === undefined) val = PRIM_DEFAULT[fn];
    w[fn](val);
  }

  
  _writeStruct(w, ref, val) {
    const fields = this.schemas[ref] || [];
    const obj = val || {};
    for (const f of fields) this._writeField(w, f, obj[f.name]);
  }

  
  _writeComplex(w, ref, val) {
    if (val === null || val === undefined) { w.WriteByte(0x00); return; }
    w.WriteByte(0xFF);
    const fields = this.schemas[ref] || [];
    for (const f of fields) this._writeField(w, f, val[f.name]);
  }

  _writeList(w, item, val) {
    if (val === null || val === undefined) { w.WriteByte(0x00); return; }
    w.WriteByte(0xFF);
    const arr = Array.isArray(val) ? val : [];
    w.WriteInt32(arr.length);
    for (const el of arr) this._writeItem(w, item, el);
  }

  _writeItem(w, item, val) {
    if (item.kind === "prim") this._writePrim(w, item.op, val);
    else if (item.kind === "struct") this._writeStruct(w, item.ref, val);
    else if (item.kind === "complex") this._writeComplex(w, item.ref, val);
    else throw new Error("unknown list item kind " + item.kind);
  }

  _writeField(w, f, val) {
    switch (f.kind) {
      case "prim":    this._writePrim(w, f.op, val); break;
      case "struct":  this._writeStruct(w, f.ref, val); break;
      case "complex": this._writeComplex(w, f.ref, val); break;
      case "buffer":
        if (val === null || val === undefined) { w.WriteByte(0x00); }
        else { w.WriteByte(0xFF); w.WriteInt32(val.length); w.WriteRawBuffer(val); }
        break;
      case "list":    this._writeList(w, f.item, val); break;
      case "dict":
        
        if (val === null || val === undefined) { w.WriteByte(0x00); }
        else { w.WriteByte(0xFF); w.WriteInt32(0); } 
        break;
      default: throw new Error("unknown field kind " + f.kind);
    }
  }

  
  
  serializeComplex(ref, obj) {
    const w = new Writer();
    this._writeComplex(w, ref, obj);
    return w.toBuffer();
  }

  
  
  
  
  
  
  
  
  
  
  
  autoDefault(ref, overrides, _depth) {
    _depth = _depth || 0;
    const fields = this.schemas[ref];
    if (!fields || _depth > 24) return {};
    const out = {};
    for (const f of fields) {
      if (overrides && Object.prototype.hasOwnProperty.call(overrides, f.name)) {
        out[f.name] = overrides[f.name];
        continue;
      }
      switch (f.kind) {
        case "prim":
          out[f.name] = (f.op === "ReadBoolean") ? false
                       : (f.op === "ReadString") ? null
                       : 0;
          break;
        case "struct":  out[f.name] = this.autoDefault(f.ref, null, _depth + 1); break;
        case "complex": out[f.name] = this.autoDefault(f.ref, null, _depth + 1); break;
        case "list":    out[f.name] = []; break;
        case "dict":    out[f.name] = {}; break;
        case "buffer":  out[f.name] = null; break;
        default:        out[f.name] = null;
      }
    }
    return out;
  }

  
  serializeStruct(ref, obj) {
    const w = new Writer();
    this._writeStruct(w, ref, obj);
    return w.toBuffer();
  }
}

module.exports = { RpcSerializer, Writer };
