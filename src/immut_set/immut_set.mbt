///|
pub fn[A : Eq + Hash] T::contains(self : T[A], key : A) -> Bool {
  self._ is Some(node) && node.contain(key, Path::of(key))
}

///|
pub fn[A : Eq + Hash] T::add(self : T[A], key : A) -> T[A] {
  match self._ {
    None => T::singleton(key)
    Some(node) => node.add(key, Path::of(key)) |> Some
  }
}

///|
pub fn[A : Eq + Hash] T::remove(self : T[A], key : A) -> T[A] {
  match self._ {
    None => None
    Some(node) => node.remove(key, Path::of(key))
  }
}

// -----------------------------------
// iter
// -----------------------------------
///|
pub fn[A] T::each(self : T[A], f : (A) -> Unit) -> Unit {
  if self._ is Some(node) {
    node.each(f)
  }
}

///|
pub fn[A] T::iter(self : T[A]) -> Iter[A] {
  match self._ {
    None => Iter::empty()
    Some(node) => node.iter()
  }
}
// -----------------------------------
// build
// -----------------------------------

///|
pub fn[A : Hash] T::empty() -> T[A] {
  None
}

///|
pub fn[A : Hash] T::singleton(key : A) -> T[A] {
  Some(Flat(key, Path::of(key)))
}

///|
pub fn[A : Hash + Eq] T::from_array(arr : Array[A]) -> T[A] {
  match arr {
    [] => None
    [x, .. xs] =>
      xs.fold(init=Flat(x, Path::of(x)), fn(acc, y) {
        acc.add_inplace(y, Path::of(y))
      })
      |> Some
  }
}

///|
pub fn[A : Hash + Eq] T::from_iter(iter : Iter[A]) -> T[A] {
  iter.fold(init=T::empty()._, fn {
    None, key => T::singleton(key)._
    Some(node), key => node.add_inplace(key, Path::of(key)) |> Some
  })
}

///|
pub fnalias T::(empty, singleton, from_array, from_iter)

// -----------------------------------
// test
// -----------------------------------
///|
fn[A : Hash] T::depth_of(self : T[A], key : A) -> Int {
  guard self._ is Some(node)
  loop node, Path::of(key), 0 {
    Flat(_) | Leaf(_), _, acc => acc
    Branch(sa), path, acc => {
      let idx = path.idx()
      guard sa.has(idx)
      continue sa[idx], path.next(), acc + 1
    }
  }
}

///|
test {
  let n = 4
  for a = empty().add(1254), i = 1254; a.depth_of(i) <= n; {
    continue a.add(i + 1), i + 1
  } else {
    inspect(i, content="1309")
    inspect(a.depth_of(i), content="5")
  }
  // 1254 to 1309 has depth 5
}

///|
test "add" {
  let a = T::empty()
  let a = a.add(1)
  @json.inspect(a._.unwrap(), content={
    "$tag": "Flat",
    "0": 1,
    "1": "11000100001001110100000111010110",
  })
  let a = a.add(2)
  @json.inspect(a._.unwrap(), content={
    "$tag": "Branch",
    "0": {
      "bitset": "10000000000001000000000",
      "data": [
        { "$tag": "Flat", "0": 2, "1": "111100011101111111101000111" },
        { "$tag": "Flat", "0": 1, "1": "110001000010011101000001110" },
      ],
    },
  })
  let a = a.add(3).add(4)
  @json.inspect(a._.unwrap(), content={
    "$tag": "Branch",
    "0": {
      "bitset": "11000000000001010000000",
      "data": [
        { "$tag": "Flat", "0": 3, "1": "110000001111000010110101010" },
        { "$tag": "Flat", "0": 2, "1": "111100011101111111101000111" },
        { "$tag": "Flat", "0": 4, "1": "110100111010000101011111100" },
        { "$tag": "Flat", "0": 1, "1": "110001000010011101000001110" },
      ],
    },
  })
  let a = a.add(17)
  @json.inspect(a._.unwrap(), content={
    "$tag": "Branch",
    "0": {
      "bitset": "11000000000001010000000",
      "data": [
        { "$tag": "Flat", "0": 3, "1": "110000001111000010110101010" },
        { "$tag": "Flat", "0": 2, "1": "111100011101111111101000111" },
        { "$tag": "Flat", "0": 4, "1": "110100111010000101011111100" },
        {
          "$tag": "Branch",
          "0": {
            "bitset": "10000000000100000000000000",
            "data": [
              { "$tag": "Flat", "0": 1, "1": "1100010000100111010000" },
              { "$tag": "Flat", "0": 17, "1": "1100010100011111010001" },
            ],
          },
        },
      ],
    },
  })
}

///|
test "remove" {
  let ia = (1250).until(1290)
  let ib = (1290).until(1310)
  let a = from_iter(ia + ib)
  let a = ia.fold(init=a, T::remove)
  assert_false(ia.any(a.contains(_)))
  assert_true(ib.all(a.contains(_)))
}

///|
test "from_iter" {
  let iter = (1250).until(1310)
  let a = iter.fold(init=empty(), T::add)
  let b = from_iter(iter)
  assert_true(a == b)
}

///|
test "iter" {
  let iter = (1250).until(1310)
  let a = from_iter(iter)
  let b = from_iter(a.iter())
  assert_true(a == b)
}
