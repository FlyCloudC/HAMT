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
  b.bench(name="new iter", fn() { b.keep(a1.iter().count()) })
  b.bench(name="old iter", fn() { b.keep(a2.iter().count()) })
  b.bench(name="new union", fn() { b.keep(a1.union(b1)) })
  b.bench(name="old union", fn() { b.keep(a2.union(b2)) })
  // b.bench(name="new intersection", fn() { b.keep(a1.intersection(b1)) })
  // b.bench(name="old intersection", fn() { b.keep(a2.intersection(b2)) }) // not impl
  // b.bench(name="new difference", fn() { b.keep(a1.difference(b1)) })
  // b.bench(name="old difference", fn() { b.keep(a2.difference(b2)) }) // not impl
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
// new union      36.59 µs ±   1.02 µs    35.57 µs …  38.72 µs  in 10 ×   2830 runs
// old union     533.49 µs ± 143.71 µs   403.66 µs … 822.63 µs  in 10 ×    122 runs
// new add 2       0.03 µs ±   0.00 µs     0.03 µs …   0.03 µs  in 10 × 100000 runs
// old add 2       0.22 µs ±   0.00 µs     0.22 µs …   0.23 µs  in 10 × 100000 runs
// new add x       0.20 µs ±   0.04 µs     0.17 µs …   0.29 µs  in 10 × 100000 runs
// old add x       0.21 µs ±   0.00 µs     0.21 µs …   0.22 µs  in 10 × 100000 runs
// new rmv 2       0.18 µs ±   0.00 µs     0.18 µs …   0.19 µs  in 10 × 100000 runs
// old rmv 2       0.17 µs ±   0.00 µs     0.17 µs …   0.18 µs  in 10 × 100000 runs
// new rmv x       0.03 µs ±   0.00 µs     0.03 µs …   0.03 µs  in 10 × 100000 runs
// old rmv x       0.16 µs ±   0.00 µs     0.15 µs …   0.17 µs  in 10 × 100000 runs
// new from_arr  602.78 µs ±   9.48 µs   586.60 µs … 615.53 µs  in 10 ×    160 runs
// old from_arr    4.59 ms ± 130.22 µs     4.42 ms …   4.78 ms  in 10 ×     22 runs
// new iter       40.72 µs ±   0.19 µs    40.49 µs …  40.99 µs  in 10 ×   2289 runs
// old iter      896.34 µs ±  67.34 µs   738.98 µs … 979.46 µs  in 10 ×     94 runs

// bench FlyCloudC/hamt/immut_set/bench.mbt::small
// name         time (mean ± σ)         range (min … max)
// new union       0.10 µs ±   0.00 µs     0.10 µs …   0.11 µs  in 10 × 100000 runs
// old union       0.68 µs ±   0.01 µs     0.67 µs …   0.69 µs  in 10 × 100000 runs
// new add 2       0.02 µs ±   0.00 µs     0.02 µs …   0.02 µs  in 10 × 100000 runs
// old add 2       0.13 µs ±   0.00 µs     0.12 µs …   0.13 µs  in 10 × 100000 runs
// new add x       0.04 µs ±   0.00 µs     0.03 µs …   0.04 µs  in 10 × 100000 runs
// old add x       0.11 µs ±   0.00 µs     0.11 µs …   0.12 µs  in 10 × 100000 runs
// new rmv 2       0.04 µs ±   0.00 µs     0.04 µs …   0.05 µs  in 10 × 100000 runs
// old rmv 2       0.06 µs ±   0.00 µs     0.06 µs …   0.06 µs  in 10 × 100000 runs
// new rmv x       0.02 µs ±   0.00 µs     0.02 µs …   0.02 µs  in 10 × 100000 runs
// old rmv x       0.01 µs ±   0.00 µs     0.01 µs …   0.02 µs  in 10 × 100000 runs
// new from_arr    0.09 µs ±   0.00 µs     0.09 µs …   0.10 µs  in 10 × 100000 runs
// old from_arr    0.69 µs ±   0.01 µs     0.67 µs …   0.70 µs  in 10 × 100000 runs
// new iter        0.04 µs ±   0.00 µs     0.04 µs …   0.05 µs  in 10 × 100000 runs
// old iter        0.12 µs ±   0.00 µs     0.12 µs …   0.13 µs  in 10 × 100000 runs

///|
test {
  let rs = @quickcheck/splitmix.new()
  fn f(size) {
    let a : T[Int] = Arbitrary::arbitrary(size, rs)
    let d = [0, 0, 0, 0, 0, 0, 0]
    a.each(fn(x) { d[a.depth_of(x)] += 1 })
    (a.size(), d)
  }

  inspect(f(100), content="(44, [0, 9, 33, 2, 0, 0, 0])")
  inspect(f(1000), content="(31, [0, 17, 14, 0, 0, 0, 0])")
  // inspect(f(10000), content="(4023, [0, 0, 71, 3474, 464, 14, 0])")
  // inspect(f(100000), content="(28305, [0, 0, 0, 11785, 15720, 776, 24])")
  // inspect(f(1000000), content="(322608, [0, 0, 0, 13, 237231, 82405, 2959])")
  // inspect(f(2000000), content="(1149207, [0, 0, 0, 0, 383947, 727437, 37823])")
  // inspect(f(4000000), content="(1513468, [0, 0, 0, 0, 357127, 1089929, 66412])")

  fn g(size) {
    let a : T[MyInt] = from_iter((0).until(size).map(MyInt(_)))
    let d = [0, 0, 0, 0, 0, 0, 0]
    a.each(fn(x) { d[a.depth_of(x)] += 1 })
    (a.size(), d)
  }

  inspect(g(100), content="(100, [0, 5, 89, 6, 0, 0, 0])")
  inspect(g(300), content="(300, [0, 0, 168, 44, 0, 0, 88])")
  inspect(g(500), content="(500, [0, 0, 10, 2, 0, 0, 488])")
}
