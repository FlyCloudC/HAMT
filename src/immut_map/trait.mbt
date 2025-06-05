///|
impl[K : Eq, V : Eq] Eq for Node[K, V] with op_equal(self, other) {
  match (self, other) {
    (Flat(ka, va, pa), Flat(kb, vb, pb)) => pa == pb && ka == kb && va == vb
    (Branch(asa), Branch(bsa)) => asa == bsa
    (Leaf(ka, va, ra), Leaf(kb, vb, rb)) => {
      guard ra.length() == rb.length() else { return false }
      let ia = Iter::singleton((ka, va)) + ra.iter()
      let ib = Iter::singleton((kb, vb)) + rb.iter()
      ia.all(ib.contains(_))
    }
    _ => false
  }
}

///|
traitalias @quickcheck.Arbitrary

///|
pub impl[K : Arbitrary + Eq + Hash, V : Arbitrary] Arbitrary for T[K, V] with arbitrary(
  size,
  rs
) {
  Arbitrary::arbitrary(size, rs) |> from_iter
}
