///|
impl[A : Eq] Eq for Node[A] with op_equal(self, other) {
  match (self, other) {
    (Flat(ka, pa), Flat(kb, pb)) => pa == pb && ka == kb
    (Branch(asa), Branch(bsa)) => asa == bsa
    (Leaf(ka, ra), Leaf(kb, rb)) => {
      guard ra.length() == rb.length() else { return false }
      let ia = Iter::singleton(ka) + ra.iter()
      let ib = Iter::singleton(kb) + rb.iter()
      ia.all(ib.contains(_))
    }
    _ => false
  }
}

///|
traitalias @quickcheck.Arbitrary

///|
pub impl[A : Arbitrary + Eq + Hash] Arbitrary for T[A] with arbitrary(size, rs) {
  Arbitrary::arbitrary(size, rs) |> from_iter
}
