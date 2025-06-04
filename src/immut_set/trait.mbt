///|
impl[A : Eq] Eq for Node[A] with op_equal(self, other) {
  match (self, other) {
    (Flat(ka, pa), Flat(kb, pb)) => pa == pb && ka == kb
    (Branch(asa), Branch(bsa)) => asa == bsa
    (Leaf(ka, rest_ka), Leaf(kb, rest_kb)) => {
      guard rest_ka.length() == rest_kb.length() else { return false }
      let ia = Iter::singleton(ka) + rest_ka.iter()
      let ib = Iter::singleton(kb) + rest_kb.iter()
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
