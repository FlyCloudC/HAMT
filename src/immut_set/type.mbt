///|
typealias SpArr[A] = @sparse_array.T[A]

///|
typealias List[A] = @list.T[A]

///|
/// Represents a non-empty set
/// 
/// Invariance:
/// - If it can repr by `Line`, it must repr by `Line`
/// - `Branch` nesting depth <= 5
priv enum Node[A] {
  /// require: path != PATH_END
  Flat(A, Path)
  Leaf(A, List[A])
  Branch(SpArr[Node[A]])
} derive(ToJson)

///|
type T[A] Node[A]? derive(Eq)
