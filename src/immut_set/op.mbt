///|
pub fn[A : Eq] T::union(self : T[A], other : T[A]) -> T[A] {
  fn go(a : Node[A], b : Node[A]) -> Node[A] {
    match (a, b) {
      (node, Flat(k, path)) | (Flat(k, path), node) => node.add(k, path)
      (Branch(asa), Branch(bsa)) => Branch(asa.union_by(bsa, go))
      (Leaf(ka, ra), Leaf(kb, rb)) => {
        let la = ra
          .add(ka)
          .filter(fn(k) { not(k == kb || rb.any(k.op_equal(_))) })
        match la {
          Empty => b
          More(ka, tail~) => Leaf(kb, rb + tail.add(ka))
        }
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
pub fn[A : Eq] T::intersection(self : T[A], other : T[A]) -> T[A] {
  fn go(a : Node[A], b : Node[A]) -> Node[A]? {
    match (a, b) {
      (node, Flat(k, path) as f) | (Flat(k, path) as f, node) =>
        if node.contain(k, path) {
          Some(f)
        } else {
          None
        }
      (Branch(asa), Branch(bsa)) =>
        match asa.intersection_by(bsa, go) {
          None => None
          Some(sa) if sa.is_singleton() && sa.first_value() is Flat(k, next) =>
            Some(Flat(k, next.push(sa.first_index())))
          Some(sa) => Some(Branch(sa))
        }
      (Leaf(ka, ra), Leaf(kb, rb)) => {
        let la = ra.add(ka).filter(fn(k) { k == kb || rb.any(k.op_equal(_)) })
        match la {
          Empty => None
          More(ka, tail~) => Some(Leaf(ka, tail))
        }
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
pub fn[A : Eq] T::difference(self : T[A], other : T[A]) -> T[A] {
  fn go(a : Node[A], b : Node[A]) -> Node[A]? {
    match (a, b) {
      (node, Flat(k, path)) => node.remove(k, path)
      (Flat(k, path) as f, node) =>
        if node.contain(k, path) {
          None
        } else {
          Some(f)
        }
      (Branch(asa), Branch(bsa)) =>
        match asa.difference_by(bsa, go) {
          None => None
          Some(sa) if sa.is_singleton() && sa.first_value() is Flat(k, next) =>
            Some(Flat(k, next.push(sa.first_index())))
          Some(sa) => Some(Branch(sa))
        }
      (Leaf(ka, ra), Leaf(kb, rb)) => {
        let la = ra
          .add(ka)
          .filter(fn(k) { not(k == kb || rb.any(k.op_equal(_))) })
        match la {
          Empty => None
          More(ka, tail~) => Some(Leaf(ka, tail))
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
test "union" {
  let rs = @quickcheck/splitmix.new()
  let a : T[Int] = T::arbitrary(10000, rs)
  let b : T[Int] = T::arbitrary(10000, rs)
  let c = a.union(b)
  inspect(a.iter().count(), content="5851")
  inspect(b.iter().count(), content="1160")
  inspect(c.iter().count(), content="6120")
  assert_true(a.iter().all(c.contains(_)))
  assert_true(b.iter().all(c.contains(_)))
  assert_true(c.iter().all(fn(k) { a.contains(k) || b.contains(k) }))
}

///|
test "intersection" {
  let rs = @quickcheck/splitmix.new()
  let a : T[Int] = T::arbitrary(10000, rs)
  let b : T[Int] = T::arbitrary(10000, rs)
  let c = a.intersection(b)
  inspect(a.iter().count(), content="5851")
  inspect(b.iter().count(), content="1160")
  inspect(c.iter().count(), content="891")
  assert_true(a.iter().all(fn(k) { b.contains(k) == c.contains(k) }))
  assert_true(b.iter().all(fn(k) { a.contains(k) == c.contains(k) }))
  assert_true(c.iter().all(fn(k) { a.contains(k) && b.contains(k) }))
}

///|
test "difference" {
  let rs = @quickcheck/splitmix.new()
  let a : T[Int] = T::arbitrary(10000, rs)
  let b : T[Int] = T::arbitrary(10000, rs)
  let c = a.difference(b)
  inspect(a.iter().count(), content="5851")
  inspect(b.iter().count(), content="1160")
  inspect(c.iter().count(), content="4960")
  assert_true(a.iter().all(fn(k) { b.contains(k) != c.contains(k) }))
  assert_true(b.iter().all(fn(k) { not(c.contains(k)) }))
  assert_true(c.iter().all(fn(k) { a.contains(k) && not(b.contains(k)) }))
}
