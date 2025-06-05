///|
pub fn[K, V] T::is_empty(self : T[K, V]) -> Bool {
  self._ is None
}

///|
/// O(n)
pub fn[K, V] T::size(self : T[K, V]) -> Int {
  let mut size = 0
  self.each(fn(_, _) { size += 1 })
  size
}

///|
pub fn[K : Eq + Hash, V] T::contains(self : T[K, V], key : K) -> Bool {
  self._ is Some(node) && node.contain(key, Path::of(key))
}

///|
pub fn[K : Eq + Hash, V] T::get(self : T[K, V], key : K) -> V? {
  match self._ {
    None => None
    Some(node) => node.get(key, Path::of(key))
  }
}

///|
pub fn[K : Eq + Hash, V] T::add(self : T[K, V], key : K, val : V) -> T[K, V] {
  match self._ {
    None => T::singleton(key, val)
    Some(node) =>
      node.add_with(key, val, fn { _, _, v => v }, Path::of(key)) |> Some
  }
}

///|
pub fn[K : Eq + Hash, V] T::remove(self : T[K, V], key : K) -> T[K, V] {
  match self._ {
    None => None
    Some(node) => node.remove(key, Path::of(key))
  }
}

// -----------------------------------
// iter
// -----------------------------------
///|
pub fn[K, V] T::each(self : T[K, V], f : (K, V) -> Unit) -> Unit {
  if self._ is Some(node) {
    node.each(f)
  }
}

///|
pub fn[K, V] T::iter(self : T[K, V]) -> Iter[(K, V)] {
  match self._ {
    None => Iter::empty()
    Some(node) => node.iter()
  }
}
// -----------------------------------
// build
// -----------------------------------

///|
pub fn[K : Hash, V] T::new() -> T[K, V] {
  None
}

///|
pub fn[K : Hash, V] T::singleton(key : K, val : V) -> T[K, V] {
  Some(Flat(key, val, Path::of(key)))
}

///|
pub fn[K : Hash + Eq, V] T::of(arr : Array[(K, V)]) -> T[K, V] {
  match arr {
    [] => None
    [x, ..] => {
      let mut acc = Flat(x.0, x.1, Path::of(x.0))
      for i in 1..<arr.length() {
        let y = arr[i]
        acc = acc.add_with_inplace(
          y.0,
          y.1,
          fn { _, _, v2 => v2 },
          Path::of(y.0),
        )
      }
      Some(acc)
    }
  }
}

///|
pub fn[K : Hash + Eq, V] T::from_array(arr : Array[(K, V)]) -> T[K, V] {
  match arr {
    [] => None
    [x, .. xs] =>
      xs.fold(init=Flat(x.0, x.1, Path::of(x.0)), fn(acc, y) {
        acc.add_with_inplace(y.0, y.1, fn { _, _, v2 => v2 }, Path::of(y.0))
      })
      |> Some
  }
}

///|
pub fn[K : Hash + Eq, V] T::from_iter(iter : Iter[(K, V)]) -> T[K, V] {
  iter.fold(init=T::new()._, fn {
    None, (k, v) => T::singleton(k, v)._
    Some(node), (k, v) =>
      node.add_with_inplace(k, v, fn { _, _, v2 => v2 }, Path::of(k)) |> Some
  })
}

///|
pub fnalias T::(new, singleton, of, from_array, from_iter)

// -----------------------------------
// test
// -----------------------------------
///|
fn[K : Hash, V] T::depth_of(self : T[K, V], key : K) -> Int {
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
