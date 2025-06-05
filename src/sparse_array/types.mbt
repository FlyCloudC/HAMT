///|
/// like a `Array[A?]` with length 32
/// 
/// self[i] is Some(x) <=> (
///   self.bitset.has(i) && 
///   self.data[self.bitset.index_of(i)] is x
/// )
/// 
/// self[i] is None <=> not(self.bitset.has(i))
struct T[A] {
  bitset : Bitset
  /// Use `index` to represent the index of `data`, 
  /// and use `idx` to represent the index of `self`
  data : FixedArray[A]
} derive(Eq, ToJson)
