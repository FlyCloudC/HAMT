///|
fn[K : Eq, V] Node::get(self : Node[K, V], key : K, path : Path) -> V? {
  match (self, path) {
    (Flat(k, v, path_k), path) =>
      if path == path_k && key == k {
        Some(v)
      } else {
        None
      }
    (Branch(sa), path) => {
      let idx = path.idx()
      if sa.has(idx) {
        sa[idx].get(key, path.next())
      } else {
        None
      }
    }
    (Leaf(k1, v1, r), _) => if key == k1 { Some(v1) } else { r.lookup(key) }
  }
}

///|
fn[K : Eq, V] Node::contain(self : Node[K, V], key : K, path : Path) -> Bool {
  match (self, path) {
    (Flat(k, _, path_k), path) => path == path_k && key == k
    (Branch(sa), path) => {
      let idx = path.idx()
      sa.has(idx) && sa[idx].contain(key, path.next())
    }
    (Leaf(k1, _, r), _) => key == k1 || r.any(fn { (k, _) => key == k })
  }
}

///|
/// require: k1 != k2, p1 != PATH_END
fn[K, V] join_2(
  k1 : K,
  v1 : V,
  p1 : Path,
  k2 : K,
  v2 : V,
  p2 : Path
) -> SpArr[Node[K, V]] {
  let idx1 = p1.idx()
  let idx2 = p2.idx()
  if idx1 == idx2 {
    let n = if p1.next() == PATH_END {
      Leaf(k2, v2, @list.singleton((k1, v1)))
    } else {
      Branch(join_2(k1, v1, p1.next(), k2, v2, p2.next()))
    }
    SpArr::singleton(idx1, n)
  } else {
    let (n1, n2) = if p1.next() == PATH_END {
      (Leaf(k1, v1, @list.empty()), Leaf(k2, v2, @list.empty()))
    } else {
      (Flat(k1, v1, p1.next()), Flat(k2, v2, p2.next()))
    }
    SpArr::doubleton(idx1, n1, idx2, n2)
  }
}

///|
fn[K : Eq, V] lookup_index(ls : List[(K, V)], key : K) -> (Int, K, V)? {
  loop ls, 0 {
    Empty, _ => None
    More((k, v), tail~), index =>
      if key == k {
        Some((index, k, v))
      } else {
        continue tail, index + 1
      }
  }
}

///|
/// require:
/// - path is key's path || self is Leaf
fn[K : Eq, V] Node::add_with(
  self : Node[K, V],
  key : K,
  new_val : V,
  f : (K, V, V) -> V,
  path : Path
) -> Node[K, V] {
  let node = self
  loop node, path, fn { x => x } {
    Flat(k, v, path_k), path, on_replaced =>
      if path == path_k && key == k {
        on_replaced(Flat(k, f(k, v, new_val), path))
      } else {
        on_replaced(Branch(join_2(k, v, path_k, key, new_val, path)))
      }
    Branch(sa), path, on_replaced => {
      let idx = path.idx()
      if sa.has(idx) {
        continue sa[idx],
          path.next(),
          fn(r) { on_replaced(Branch(sa.replace(idx, r))) }
      } else {
        on_replaced(Branch(sa.add(idx, Flat(key, new_val, path.next()))))
      }
    }
    Leaf(k, v, r), _, on_replaced =>
      if key == k {
        on_replaced(Leaf(k, f(k, v, new_val), r))
      } else if lookup_index(r, key) is Some((index, old_key, old_val)) {
        on_replaced(
          // Should we keep old_key?
          Leaf(
            old_key,
            f(old_key, old_val, new_val),
            r.remove_at(index).add((k, v)),
          ),
        )
      } else {
        on_replaced(Leaf(key, new_val, r.add((k, v))))
      }
  }
}

///|
/// require:
/// - path is key's path || self is Leaf
/// - do not use self after
fn[K : Eq, V] Node::add_with_inplace(
  self : Node[K, V],
  key : K,
  new_val : V,
  f : (K, V, V) -> V,
  path : Path
) -> Node[K, V] {
  let node = self
  loop node, path, fn { x => x } {
    Flat(k, v, path_k), path, on_replaced =>
      if path == path_k && key == k {
        on_replaced(Flat(k, f(k, v, new_val), path))
      } else {
        on_replaced(Branch(join_2(k, v, path_k, key, new_val, path)))
      }
    Branch(sa), path, on_replaced => {
      let idx = path.idx()
      if sa.has(idx) {
        continue sa[idx],
          path.next(),
          fn(r) {
            sa.replace_inplace(idx, r)
            self
          }
      } else {
        on_replaced(Branch(sa.add(idx, Flat(key, new_val, path.next()))))
      }
    }
    Leaf(k, v, r), _, on_replaced =>
      if key == k {
        on_replaced(Leaf(k, f(k, v, new_val), r))
      } else if lookup_index(r, key) is Some((index, old_key, old_val)) {
        on_replaced(
          // Should we keep old_key?
          Leaf(
            old_key,
            f(old_key, old_val, new_val),
            r.remove_at(index).add((k, v)),
          ),
        )
      } else {
        on_replaced(Leaf(key, new_val, r.add((k, v))))
      }
  }
}

///|
fn[K : Eq, V] find_index(ls : List[(K, V)], key : K) -> Int? {
  loop ls, 0 {
    Empty, _ => None
    More((k, _), tail~), index =>
      if key == k {
        Some(index)
      } else {
        continue tail, index + 1
      }
  }
}

///|
fn[K : Eq, V] Node::remove(
  self : Node[K, V],
  key : K,
  path : Path
) -> Node[K, V]? {
  let node = self
  loop node, path, fn { x => x } {
    Flat(k, _, path_k), path, on_remove =>
      if path == path_k && key == k {
        on_remove(None)
      } else {
        Some(self)
      }
    Branch(sa), path, on_remove => {
      let idx = path.idx()
      if sa.has(idx) {
        continue sa[idx],
          path.next(),
          fn(r) {
            let new_sa = match r {
              None if sa.is_singleton() => return on_remove(None)
              None => sa.remove(idx)
              Some(r) => sa.replace(idx, r)
            }
            if new_sa.is_singleton() && new_sa.first_value() is Flat(k, v, next) {
              on_remove(Some(Flat(k, v, next.push(new_sa.first_index()))))
            } else {
              on_remove(Some(Branch(new_sa)))
            }
          }
      } else {
        Some(self)
      }
    }
    Leaf(k, v, r), _, on_remove =>
      if k == key {
        match r {
          Empty => on_remove(None)
          More((k2, v2), tail~) => on_remove(Some(Leaf(k2, v2, tail)))
        }
      } else if find_index(r, key) is Some(index) {
        on_remove(Some(Leaf(k, v, r.remove_at(index))))
      } else {
        Some(self)
      }
  }
}

// -----------------------------------
// iter
// -----------------------------------
///|
fn[K, V] Node::each(self : Node[K, V], f : (K, V) -> Unit) -> Unit {
  match self {
    Flat(k, v, _) => f(k, v)
    Leaf(k, v, r) => {
      f(k, v)
      r.each(fn { (k, v) => f(k, v) })
    }
    Branch(sa) => sa.each(_.each(f))
  }
}

///|
fn[K, V] Node::iter(self : Node[K, V]) -> Iter[(K, V)] {
  Iter::new(fn(yield_) {
    fn go {
      Flat(k, v, _) => yield_((k, v))
      Leaf(k, v, r) =>
        loop (k, v), r {
          kv, Empty => yield_(kv)
          kv, More(kv2, tail~) => {
            guard yield_(kv) is IterContinue else { return IterEnd }
            continue kv2, tail
          }
        }
      Branch(sa) => sa.iter().run(go)
    }

    go(self)
  })
}
