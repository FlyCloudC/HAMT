///|
pub(all) type Bitset UInt derive(Eq)

///|
impl ToJson for Bitset with to_json(self) {
  self._.to_string(radix=2).to_json()
}

///|
fn Bitset::empty() -> Bitset {
  0
}

///|
fn Bitset::has(self : Bitset, idx : Int) -> Bool {
  (self._ & (1U << idx)) != 0
}

///|
/// suppose `self.has(idx)`
fn Bitset::index_of(self : Bitset, idx : Int) -> Int {
  (self._ & ((1U << idx) - 1)).popcnt()
}

///|
fn Bitset::fitst_idx(self : Bitset) -> Int {
  self._.ctz()
}

///|
fn Bitset::add(self : Bitset, idx : Int) -> Bitset {
  self._ | (1U << idx)
}

///|
/// require: self.has(idx)
fn Bitset::remove(self : Bitset, idx : Int) -> Bitset {
  self._ ^ (1U << idx)
}

///|
fn Bitset::size(self : Bitset) -> Int {
  self._.popcnt()
}

// ///|
// #locals(f)
// fn Bitset::each(self : Bitset, f : (Int) -> Unit) -> Unit {

// }
