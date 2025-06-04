///|
pub fn[A] T::has(self : T[A], idx : Int) -> Bool {
  self.bitset.has(idx)
}

///|
/// require: `self.has(idx)`
pub fn[A] T::op_get(self : T[A], idx : Int) -> A {
  self.data[self.bitset.index_of(idx)]
}

///|
/// require: `not(self.has(idx))`
pub fn[A] T::add(self : T[A], idx : Int, value : A) -> T[A] {
  let old_data = self.data
  let old_len = old_data.length()
  let added_index = self.bitset.index_of(idx)
  let new_data = FixedArray::make(old_len + 1, value)
  FixedArray::unsafe_blit(new_data, 0, old_data, 0, added_index)
  FixedArray::unsafe_blit(
    new_data,
    added_index + 1,
    old_data,
    added_index,
    old_len - added_index,
  )
  { bitset: self.bitset.add(idx), data: new_data }
}

///|
/// require: `self.has(idx)`
pub fn[A] T::remove(self : T[A], idx : Int) -> T[A] {
  let old_data = self.data
  let old_len = old_data.length()
  let removed_index = self.bitset.index_of(idx)
  let new_data = FixedArray::make(old_len - 1, old_data.unsafe_get(0))
  FixedArray::unsafe_blit(new_data, 0, old_data, 0, removed_index)
  FixedArray::unsafe_blit(
    new_data,
    removed_index,
    old_data,
    removed_index + 1,
    old_len - removed_index - 1,
  )
  { bitset: self.bitset.remove(idx), data: new_data }
}

///|
/// require: `self.has(idx)`
pub fn[A] T::replace(self : T[A], idx : Int, value : A) -> T[A] {
  let old_data = self.data
  let len = old_data.length()
  let new_data = FixedArray::make(len, value)
  FixedArray::unsafe_blit(new_data, 0, old_data, 0, len)
  new_data.unsafe_set(self.bitset.index_of(idx), value)
  { bitset: self.bitset, data: new_data }
}

///|
/// require: `self.has(idx)`
pub fn[A] T::replace_inplace(self : T[A], idx : Int, value : A) -> Unit {
  self.data.unsafe_set(self.bitset.index_of(idx), value)
}

// -----------------------------------
// build
// -----------------------------------
///|
pub fn[A] T::singleton(idx : Int, value : A) -> T[A] {
  { bitset: Bitset::empty().add(idx), data: [value] }
}

///|
pub fn[A] T::doubleton(idx1 : Int, value1 : A, idx2 : Int, value2 : A) -> T[A] {
  {
    bitset: Bitset::empty().add(idx1).add(idx2),
    data: if idx1 < idx2 {
      [value1, value2]
    } else {
      [value2, value1]
    },
  }
}

// -----------------------------------
// iter
// -----------------------------------
///|
pub fn[A] T::each(self : T[A], f : (A) -> Unit) -> Unit {
  self.data.each(f)
}

///|
pub fn[A] T::iter(self : T[A]) -> Iter[A] {
  self.data.iter()
}

// -----------------------------------
// other
// -----------------------------------
///|
// pub fn[A] T::size(self : T[A]) -> Int {
//   self.bitset._.popcnt()
// }

///|
pub fn[A] T::is_singleton(self : T[A]) -> Bool {
  let idx = self.bitset.fitst_idx()
  Bitset::empty().add(idx) == self.bitset
}

///|
pub fn[A] T::first_index(self : T[A]) -> Int {
  self.bitset.fitst_idx()
}

///|
pub fn[A] T::first_value(self : T[A]) -> A {
  self.data[0]
}
