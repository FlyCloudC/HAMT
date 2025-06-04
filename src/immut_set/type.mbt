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
priv enum Node[A] {
  /// require: path != PATH_END
  Flat(A, Path)
  Leaf(A, List[A])
  /// require: number of all leaf nodes in a `Branch` > 1
  Branch(SpArr[Node[A]])
} derive(ToJson)

///|
type T[A] Node[A]? derive(Eq)
