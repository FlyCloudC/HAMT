///|
fn[K : Eq, V] union_list_with(
  la : List[(K, V)],
  lb : List[(K, V)],
  f : (K, V, V) -> V
) -> List[(K, V)] {
  let la = la.to_array()
  let lb = lb.to_array()
  for i in 0..<la.length() {
    let (ka, va) = la[i]
    for j in 0..<lb.length() {
      let (kb, vb) = lb[j]
      if ka == kb {
        la[i] = (ka, f(ka, va, vb))
        lb.remove(j) |> ignore
        break
      }
    }
  }
  @list.from_iter(la.iter() + lb.iter())
}

///|
pub fn[K : Eq, V] T::union_with(
  self : T[K, V],
  other : T[K, V],
  f : (K, V, V) -> V
) -> T[K, V] {
  fn go(a : Node[K, V], b : Node[K, V]) -> Node[K, V] {
    match (a, b) {
      (a, Flat(k, vb, path)) => a.add_with(k, vb, f, path)
      (Flat(k, va, path), b) =>
        b.add_with(k, va, fn { k, vb, va => f(k, va, vb) }, path)
      (Branch(asa), Branch(bsa)) => Branch(asa.union_by(bsa, go))
      (Leaf(ka, va, ra), Leaf(kb, vb, rb)) =>
        match union_list_with(ra.add((ka, va)), rb.add((kb, vb)), f) {
          Empty => abort("Unreachable")
          More((k, v), tail~) => Leaf(k, v, tail)
        }
      _ => abort("Unreachable")
    }
  }

  match (self._, other._) {
    (None, x) | (x, None) => x
    (Some(a), Some(b)) => Some(go(a, b))
  }
}

///|
fn[K : Eq, V] intersection_list_with(
  la : List[(K, V)],
  lb : List[(K, V)],
  f : (K, V, V) -> V
) -> List[(K, V)] {
  let la = la.to_array()
  let lb = lb.to_array()
  for i = 0; i < la.length(); {
    let (ka, va) = la[i]
    for j in 0..<lb.length() {
      let (kb, vb) = lb[j]
      if ka == kb {
        la[i] = (ka, f(ka, va, vb))
        lb.remove(j) |> ignore
        break
      }
    } else {
      la.remove(i) |> ignore
      continue i
    }
    continue i + 1
  }
  @list.from_array(la)
}

///|
pub fn[K : Eq, V] T::intersection_with(
  self : T[K, V],
  other : T[K, V],
  f : (K, V, V) -> V
) -> T[K, V] {
  fn go(a : Node[K, V], b : Node[K, V]) -> Node[K, V]? {
    match (a, b) {
      (a, Flat(k, vb, path)) =>
        match a.get(k, path) {
          None => None
          Some(va) => Some(Flat(k, f(k, va, vb), path))
        }
      (Flat(k, va, path), b) =>
        match b.get(k, path) {
          None => None
          Some(vb) => Some(Flat(k, f(k, va, vb), path))
        }
      (Branch(asa), Branch(bsa)) =>
        match asa.intersection_by(bsa, go) {
          None => None
          Some(sa) if sa.is_singleton() && sa.first_value() is Flat(k, v, next) =>
            Some(Flat(k, v, next.push(sa.first_index())))
          Some(sa) => Some(Branch(sa))
        }
      (Leaf(ka, va, ra), Leaf(kb, vb, rb)) =>
        match intersection_list_with(ra.add((ka, va)), rb.add((kb, vb)), f) {
          Empty => None
          More((k, v), tail~) => Some(Leaf(k, v, tail))
        }
      _ => abort("Unreachable")
    }
  }

  match (self._, other._) {
    (None, _) | (_, None) => None
    (Some(a), Some(b)) => go(a, b)
  }
}

///|
pub fn[K : Eq, V] T::difference(self : T[K, V], other : T[K, V]) -> T[K, V] {
  fn go(a : Node[K, V], b : Node[K, V]) -> Node[K, V]? {
    match (a, b) {
      (node, Flat(k, _, path)) => node.remove(k, path)
      (Flat(k, _, path) as f, node) =>
        if node.contain(k, path) {
          None
        } else {
          Some(f)
        }
      (Branch(asa), Branch(bsa)) =>
        match asa.difference_by(bsa, go) {
          None => None
          Some(sa) if sa.is_singleton() && sa.first_value() is Flat(k, v, next) =>
            Some(Flat(k, v, next.push(sa.first_index())))
          Some(sa) => Some(Branch(sa))
        }
      (Leaf(ka, va, ra), Leaf(kb, _, rb)) => {
        let la = ra
          .add((ka, va))
          .filter(fn {
            (k, _) => not(k == kb || rb.any(fn { (rkb, _) => k == rkb }))
          })
        match la {
          Empty => None
          More((k, v), tail~) => Some(Leaf(k, v, tail))
        }
      }
      _ => abort("Unreachable")
    }
  }

  match (self._, other._) {
    (None, _) => None
    (_, None) => self
    (Some(a), Some(b)) => go(a, b)
  }
}

///|
priv type MyInt Int derive(Eq)

///|
impl Hash for MyInt with hash_combine(self, hasher) {
  (self._ & 0xff).hash_combine(hasher)
}

///|
test "union" {
  let m = fn { x => (MyInt(x), x) }
  let a = from_iter((0).until(300).map(m))
  let b = from_iter((-200).until(100).map(m))
  inspect(a.depth_of(1), content="6")
  inspect(b.depth_of(1), content="2")
  let f = fn { MyInt(k), va, vb => k + va - vb }
  let c = a.union_with(b, f)
  assert_true(a.iter().all(fn { (k, _) => c.contains(k) }))
  assert_true(b.iter().all(fn { (k, _) => c.contains(k) }))
  assert_true(
    c
    .iter()
    .all(fn {
      (k, vc) =>
        match (a.get(k), b.get(k)) {
          (None, None) => false
          (Some(v), None) | (None, Some(v)) => vc == v
          (Some(va), Some(vb)) => vc == f(k, va, vb)
        }
    }),
  )
}

///|
test "intersection" {
  let m = fn { x => (MyInt(x), x) }
  let a = from_iter((0).until(300).map(m))
  let b = from_iter((-200).until(100).map(m))
  let f = fn { MyInt(k), va, vb => k + va - vb }
  let c = a.intersection_with(b, f)
  assert_true(a.iter().all(fn { (k, _) => b.contains(k) == c.contains(k) }))
  assert_true(b.iter().all(fn { (k, _) => a.contains(k) == c.contains(k) }))
  assert_true(
    c
    .iter()
    .all(fn {
      (k, vc) =>
        a.get(k) is Some(va) && b.get(k) is Some(vb) && vc == f(k, va, vb)
    }),
  )
}

///|
test "difference" {
  let m = fn { x => (MyInt(x), x) }
  let a = from_iter((0).until(300).map(m))
  let b = from_iter((-200).until(100).map(m))
  let c = a.difference(b)
  assert_true(a.iter().all(fn { (k, _) => b.contains(k) != c.contains(k) }))
  assert_true(b.iter().all(fn { (k, _) => not(c.contains(k)) }))
  assert_true(
    c.iter().all(fn { (k, _) => a.contains(k) && not(b.contains(k)) }),
  )
}
