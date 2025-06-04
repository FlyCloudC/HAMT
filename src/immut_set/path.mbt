///|
priv type Path UInt derive(Eq)

///|
impl ToJson for Path with to_json(self) {
  self._.to_string(radix=2).to_json()
}

///|
const PATH_END = 0b11U

///|
fn[A : Hash] Path::of(key : A) -> Path {
  key.hash().reinterpret_as_uint() | (0b11 << 30)
}

///|
fn Path::push(self : Path, idx : Int) -> Path {
  (self._ << 5) | idx.reinterpret_as_uint()
}

///|
fn Path::idx(self : Path) -> Int {
  self._.reinterpret_as_int() & 0b11111
}

///|
fn Path::next(self : Path) -> Path {
  self._ >> 5
}
