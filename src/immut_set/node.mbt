///|
fn[A : Eq] Node::contain(self : Node[A], key : A, path : Path) -> Bool {
  match (self, path) {
    (Flat(k, path_k), path) => path == path_k && key == k
    (Branch(sa), path) => {
      let idx = path.idx()
      sa.has(idx) && sa[idx].contain(key, path.next())
    }
    (Leaf(k1, rest), _) => key == k1 || rest.any(key.op_equal(_))
  }
}

///|
/// require: k1 != k2, p1 != PATH_END
fn[A] join_2(k1 : A, p1 : Path, k2 : A, p2 : Path) -> SpArr[Node[A]] {
  let idx1 = p1.idx()
  let idx2 = p2.idx()
  if idx1 == idx2 {
    let n = if p1.next() == PATH_END {
      Leaf(k2, @list.singleton(k1))
    } else {
      Branch(join_2(k1, p1.next(), k2, p2.next()))
    }
    SpArr::singleton(idx1, n)
  } else {
    let (n1, n2) = if p1.next() == PATH_END {
      (Leaf(k1, @list.empty()), Leaf(k2, @list.empty()))
    } else {
      (Flat(k1, p1.next()), Flat(k2, p2.next()))
    }
    SpArr::doubleton(idx1, n1, idx2, n2)
  }
}

///|
/// require:
/// - path is key's path || self is Leaf
fn[A : Eq] Node::add(self : Node[A], key : A, path : Path) -> Node[A] {
  let node = self
  loop node, path, fn { x => x } {
    Flat(k, path_k), path, on_replaced =>
      if path == path_k && key == k {
        self
      } else {
        on_replaced(Branch(join_2(k, path_k, key, path)))
      }
    Branch(sa), path, on_replaced => {
      let idx = path.idx()
      if sa.has(idx) {
        continue sa[idx],
          path.next(),
          fn(r) { on_replaced(Branch(sa.replace(idx, r))) }
      } else {
        on_replaced(Branch(sa.add(idx, Flat(key, path.next()))))
      }
    }
    Leaf(k, rest_k), _, on_replaced =>
      if key == k || rest_k.any(key.op_equal(_)) {
        self
      } else {
        on_replaced(Leaf(key, rest_k.add(k)))
      }
  }
}

///|
/// require:
/// - path is key's path || self is Leaf
/// - do not use self after
fn[A : Eq] Node::add_inplace(self : Node[A], key : A, path : Path) -> Node[A] {
  let node = self
  loop node, path, fn { x => x } {
    Flat(k, path_k), path, on_replaced =>
      if path == path_k && key == k {
        self
      } else {
        on_replaced(Branch(join_2(k, path_k, key, path)))
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
        on_replaced(Branch(sa.add(idx, Flat(key, path.next()))))
      }
    }
    Leaf(k, rest_k), _, on_replaced =>
      if key == k || rest_k.any(key.op_equal(_)) {
        self
      } else {
        on_replaced(Leaf(key, rest_k.add(k)))
      }
  }
}

///|
fn[A : Eq] Node::remove(self : Node[A], key : A, path : Path) -> Node[A]? {
  let node = self
  loop node, path, fn { x => x } {
    Flat(k, path_k), path, on_remove =>
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
            if new_sa.is_singleton() && new_sa.first_value() is Flat(k, next) {
              on_remove(Some(Flat(k, next.push(new_sa.first_index()))))
            } else {
              on_remove(Some(Branch(new_sa)))
            }
          }
      } else {
        Some(self)
      }
    }
    Leaf(k, rest_k), _, on_remove =>
      if k == key {
        match rest_k {
          Empty => on_remove(None)
          More(k2, tail~) => on_remove(Some(Leaf(k2, tail)))
        }
      } else if panic()(rest_k, key.op_equal(_)) is Some(index) {
        // TODO: rest_k.find_index
        on_remove(Some(Leaf(k, rest_k.remove_at(index))))
      } else {
        on_remove(None)
      }
  }
}

// -----------------------------------
// iter
// -----------------------------------
///|
fn[A] Node::each(self : Node[A], f : (A) -> Unit) -> Unit {
  match self {
    Flat(k, _) => f(k)
    Leaf(k, rest_k) => {
      f(k)
      rest_k.each(f)
    }
    Branch(sa) => sa.each(_.each(f))
  }
}

///|
fn[A] Node::iter(self : Node[A]) -> Iter[A] {
  Iter::new(fn(yield_) {
    fn go {
      Flat(k, _) => yield_(k)
      Leaf(k, rest_k) =>
        loop k, rest_k {
          k, Empty => yield_(k)
          k, More(k2, tail~) => {
            guard yield_(k) is IterContinue else { return IterEnd }
            continue k2, tail
          }
        }
      Branch(sa) => sa.iter().run(go)
    }

    go(self)
  })
}
