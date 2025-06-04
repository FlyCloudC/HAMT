///|
pub fn[A : Eq] T::union(self : T[A], other : T[A]) -> T[A] {
  fn go(a : Node[A], b : Node[A]) -> Node[A] {
    match (a, b) {
      (node, Flat(k, path)) | (Flat(k, path), node) => node.add(k, path)
      (Branch(asa), Branch(bsa)) => Branch(asa.union_by(bsa, go))
      (Leaf(ka, rest_ka), Leaf(kb, rest_kb)) => {
        let la = rest_ka
          .add(ka)
          .filter(fn(k) { not(k == kb || rest_kb.any(k.op_equal(_))) })
        match la {
          Empty => b
          More(ka, tail~) => Leaf(ka, tail + rest_kb.add(kb))
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
      (Leaf(ka, rest_ka), Leaf(kb, rest_kb)) => {
        let la = rest_ka
          .add(ka)
          .filter(fn(k) { k == kb || rest_kb.any(k.op_equal(_)) })
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
test "union" {
  let rs = @quickcheck/splitmix.new()
  let a : T[Int] = T::arbitrary(100, rs)
  let b : T[Int] = T::arbitrary(100, rs)
  let c = a.union(b)
  inspect(a.iter().count(), content="44")
  inspect(b.iter().count(), content="31")
  inspect(a.union(b).iter().count(), content="57")
  assert_true(a.iter().all(c.contains(_)))
  assert_true(b.iter().all(c.contains(_)))
  assert_true(c.iter().all(fn(k) { a.contains(k) || b.contains(k) }))
}
