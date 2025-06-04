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
  Branch(SpArr[Node[A]])
} derive(ToJson)

///|
type T[A] Node[A]? derive(Eq)
