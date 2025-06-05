///|
typealias SpArr[A] = @sparse_array.T[A]

///|
typealias List[A] = @list.T[A]

///|
/// Represents a non-empty set
/// 
/// Invariance:
/// - If it can be `Flat`, it must be `Flat`
/// - `Branch` nesting depth <= 5
priv enum Node[K, V] {
  /// require: path != PATH_END
  Flat(K, V, Path)
  Leaf(K, V, List[(K, V)])
  /// require: number of all leaf nodes in a `Branch` > 1
  Branch(SpArr[Node[K, V]])
} derive(ToJson)

///|
type T[K, V] Node[K, V]? derive(Eq)
