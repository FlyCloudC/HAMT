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
fn[A] cut(arr : FixedArray[A], len : Int) -> FixedArray[A] {
  let res = FixedArray::make(len, arr[0])
  FixedArray::unsafe_blit(res, 0, arr, 0, len)
  res
}

///|
pub fn[A] T::intersection_by(
  self : T[A],
  other : T[A],
  f : (A, A) -> A?
) -> T[A]? {
  let inter_bitset : Bitset = self.bitset._ & other.bitset._
  guard inter_bitset != 0 else { return None }
  let data = FixedArray::make(inter_bitset.size(), self.data[0])
  for rest = inter_bitset, index = 0, bitset = inter_bitset; rest != 0; {
    let idx = rest.fitst_idx()
    match f(self[idx], other[idx]) {
      Some(value) => {
        data[index] = value
        continue rest.remove(idx), index + 1, bitset
      }
      None => continue rest.remove(idx), index, bitset.remove(idx)
    }
  } else {
    if bitset == 0 {
      None
    } else if bitset == inter_bitset {
      Some({ bitset, data })
    } else {
      Some({ bitset, data: cut(data, index) })
    }
  }
}

///|
pub fn[A] T::difference_by(
  self : T[A],
  other : T[A],
  f : (A, A) -> A?
) -> T[A]? {
  let self_bitset = self.bitset
  guard self_bitset != 0 else { return None }
  let data = FixedArray::make(self_bitset.size(), self.data[0])
  for rest = self_bitset, index = 0, bitset = self_bitset; rest != 0; {
    let idx = rest.fitst_idx()
    if other.bitset.has(idx) {
      match f(self[idx], other[idx]) {
        None => continue rest.remove(idx), index, bitset.remove(idx)
        Some(value) => {
          data[index] = value
          continue rest.remove(idx), index + 1, bitset
        }
      }
    } else {
      data[index] = self[idx]
      continue rest.remove(idx), index + 1, bitset
    }
  } else {
    if bitset == 0 {
      None
    } else if bitset == self_bitset {
      Some({ bitset, data })
    } else {
      Some({ bitset, data: cut(data, index) })
    }
  }
}
