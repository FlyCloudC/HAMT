///|
pub fn[A] T::union_by(self : T[A], other : T[A], f : (A, A) -> A) -> T[A] {
  let bitset : Bitset = self.bitset._ | other.bitset._
  let data = FixedArray::make(bitset.size(), self.data[0])
  for rest = bitset, index = 0; rest != 0; {
    let idx = rest.fitst_idx()
    data[index] = if self.has(idx) {
      if other.has(idx) {
        f(self[idx], other[idx])
      } else {
        self[idx]
      }
    } else {
      other[idx]
    }
    continue rest.remove(idx), index + 1
  }
  { bitset, data }
}

///|
pub fn[A] T::intersection_by(
  self : T[A],
  other : T[A],
  f : (A, A) -> A?
) -> T[A]? {
  let bitset0 : Bitset = self.bitset._ & other.bitset._
  guard bitset0._ > 0 else { return None }
  let data = FixedArray::make(bitset0.size(), self.data[0])
  let bitset = for rest = bitset0, index = 0, bitset = bitset0; rest != 0; {
    let idx = rest.fitst_idx()
    match f(self[idx], other[idx]) {
      Some(value) => {
        data[index] = value
        continue rest.remove(idx), index + 1, bitset
      }
      None => continue rest.remove(idx), index, bitset.remove(idx)
    }
  } else {
    bitset
  }
  {
    bitset,
    data: if bitset == bitset0 {
      data
    } else {
      let len = bitset.size()
      let new_data = FixedArray::make(len, data[0])
      FixedArray::unsafe_blit(new_data, 0, data, 0, len)
      new_data
    },
  }
  |> Some
}
