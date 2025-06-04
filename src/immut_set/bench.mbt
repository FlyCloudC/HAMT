// ///|
// test "t" (b : @bench.T) {
//   let rs = @quickcheck/splitmix.new()
//   let ar : Array[Int] = Array::arbitrary(10000, rs)
//   let br : Array[Int] = Array::arbitrary(10000, rs)
//   let a1 = from_array(ar)
//   let b1 = from_array(br)
//   // b.bench(name="new", fn() { b.keep(a1.union(b1, improve=true)) })
//   b.bench(name="old", fn() { b.keep(a1.union(b1)) })
//   // b.bench(name="new", fn() { b.keep(a1.union(b1, improve=true)) })
//   b.bench(name="old", fn() { b.keep(a1.union(b1)) })
//   // b.bench(name="new", fn() { b.keep(a1.union(b1, improve=true)) })
//   b.bench(name="old", fn() { b.keep(a1.union(b1)) })
// }

///|
fn go(b : @bench.T, size : Int) -> Unit {
  let rs = @quickcheck/splitmix.new()
  let ar : Array[Int] = Array::arbitrary(size, rs)
  let br : Array[Int] = Array::arbitrary(size, rs)
  let a1 = from_array(ar).add(2).remove(3)
  let a2 = @immut/hashset.from_array(ar).add(2).remove(3)
  let b1 = from_array(br)
  let b2 = @immut/hashset.from_array(br)
  b.bench(name="new union", fn() { b.keep(a1.union(b1)) })
  b.bench(name="old union", fn() { b.keep(a2.union(b2)) })
  b.bench(name="new add 2", fn() { b.keep(a1.add(2)) })
  b.bench(name="old add 2", fn() { b.keep(a2.add(2)) })
  b.bench(name="new add x", fn() { b.keep(a1.add(3)) })
  b.bench(name="old add x", fn() { b.keep(a2.add(3)) })
  b.bench(name="new rmv 2", fn() { b.keep(a1.remove(2)) })
  b.bench(name="old rmv 2", fn() { b.keep(a2.remove(2)) })
  b.bench(name="new rmv x", fn() { b.keep(a1.remove(3)) })
  b.bench(name="old rmv x", fn() { b.keep(a2.remove(3)) })
  b.bench(name="new from_arr", fn() { b.keep(from_array(ar)) })
  b.bench(name="old from_arr", fn() { b.keep(@immut/hashset.from_array(ar)) })
}

///|
test "big" (b : @bench.T) {
  go(b, 10000)
}

///|
test "small" (b : @bench.T) {
  go(b, 42)
}

// moon bench -p FlyCloudC/hamt/immut_set -f bench.mbt --target wasm-gc

// bench FlyCloudC/hamt/immut_set/bench.mbt::big
// name         time (mean ± σ)         range (min … max)
// new union      35.13 µs ±   0.59 µs    34.35 µs …  35.93 µs  in 10 ×   2764 runs
// old union     416.83 µs ±  15.56 µs   401.62 µs … 440.10 µs  in 10 ×    247 runs
// new add 2       0.03 µs ±   0.00 µs     0.03 µs …   0.03 µs  in 10 × 100000 runs
// old add 2       0.21 µs ±   0.00 µs     0.21 µs …   0.22 µs  in 10 × 100000 runs
// new add x       0.17 µs ±   0.00 µs     0.17 µs …   0.17 µs  in 10 × 100000 runs
// old add x       0.20 µs ±   0.00 µs     0.20 µs …   0.21 µs  in 10 × 100000 runs
// new rmv 2       0.20 µs ±   0.02 µs     0.18 µs …   0.22 µs  in 10 × 100000 runs
// old rmv 2       0.17 µs ±   0.01 µs     0.17 µs …   0.18 µs  in 10 × 100000 runs
// new rmv x       0.03 µs ±   0.00 µs     0.03 µs …   0.03 µs  in 10 × 100000 runs
// old rmv x       0.15 µs ±   0.00 µs     0.15 µs …   0.16 µs  in 10 × 100000 runs
// new from_arr  587.95 µs ±  14.05 µs   568.22 µs … 609.54 µs  in 10 ×    175 runs
// old from_arr    4.44 ms ± 111.04 µs     4.27 ms …   4.58 ms  in 10 ×     23 runs

// bench FlyCloudC/hamt/immut_set/bench.mbt::small
// name         time (mean ± σ)         range (min … max)
// new union       0.09 µs ±   0.00 µs     0.09 µs …   0.10 µs  in 10 × 100000 runs
// old union       0.66 µs ±   0.01 µs     0.65 µs …   0.68 µs  in 10 × 100000 runs
// new add 2       0.02 µs ±   0.00 µs     0.02 µs …   0.02 µs  in 10 × 100000 runs
// old add 2       0.12 µs ±   0.01 µs     0.12 µs …   0.13 µs  in 10 × 100000 runs
// new add x       0.03 µs ±   0.00 µs     0.03 µs …   0.04 µs  in 10 × 100000 runs
// old add x       0.11 µs ±   0.00 µs     0.11 µs …   0.11 µs  in 10 × 100000 runs
// new rmv 2       0.04 µs ±   0.00 µs     0.04 µs …   0.04 µs  in 10 × 100000 runs
// old rmv 2       0.06 µs ±   0.00 µs     0.05 µs …   0.06 µs  in 10 × 100000 runs
// new rmv x       0.02 µs ±   0.00 µs     0.02 µs …   0.02 µs  in 10 × 100000 runs
// old rmv x       0.01 µs ±   0.00 µs     0.01 µs …   0.02 µs  in 10 × 100000 runs
// new from_arr    0.09 µs ±   0.00 µs     0.09 µs …   0.10 µs  in 10 × 100000 runs
// old from_arr    0.68 µs ±   0.01 µs     0.66 µs …   0.70 µs  in 10 × 100000 runs
