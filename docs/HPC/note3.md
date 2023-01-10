# High Performance Computing 3 | I/O Avoiding Algorithms

### 1. I/O Basics

#### (1) I/O Definition

In our case, I/O refers to the transfers of data between slow and fast memories. 

#### (2) A Sense of Scale

Before we start to discuss, let's first see an example. Suppose we are given an input dataset to sort and we have the following inforation,

- Record (item) size: `r = 256 Bytes = 2^8 Bytes`
- Volum of data to sort on disk (slow mem): `r * n = 1 PiB = 2^50 Bytes`
- DRAM size (fast mem): `r * z = 64 GiB = 2^36 Bytes`
- Memory transfer size: `r * L = 32 KiB = 2^15 Bytes`

Now we can find out that,

```
n = 2^42 records = 4 * (2^10)^4 ≈ 4 * (10^3)^4 = 4.4 Tops
nlog2(n) = 185 Tops
Z = 2^28 Tops
L = 2^7 Tops
```

Now we have the baseline `nlog2(n)` and now let's see the improvements relative to the base line when we consider the L size transaction and the Z size fast memory.

```
nlog2(n/L)           = 154.         ~ *1.2
n                    =   4.4        ~ *42
(n/L)log2(n/L)       =   1.2        ~ *154
(n/L)log2(n/Z)       =   0.275      ~ *672
(n/L)log_(Z/L)(n/L)  =   0.0523     ~ *3530
```

From this result, we can find out that one big improvement comes out from reducing `n` to `n/L`. This means when we pass over the data, we do so in L size transactions as much as possible. The other big improvement comes from going from `log2` to `log_(Z/L)` and this improvement involves the capacity of the fast memory `Z`.

#### (3) The Lower Bound

The goal of this lesson is to understand the lower bound on the amount of communication needed to sort on a machine with slow and fast memory. And here's the lower bound,

```
Q(n;Z,L) = Ω((n/L)log_(Z/L)(n/L))
```

### 2. I/O Avoiding Merge Sort

#### (1) Merge Sort Phase 1

Now, let's see a problem of sorting two elements in a two level memory system and we also assume that the processor is sequential (aka. not parallel). So here's the merge sort idea.

- Phase 1
    - Localically dividing the input into chunks of size `fZ` where f is a multiplier in no larger than 1 so that the chunk can fit into the fast memory.
    ```
    f ∈ [0,1)
    # of chunks = n/(fZ)
    ```
    - Read the input of a chunk from the slow memory into the fast memory, producing a **sorted chunk**
    - After the chunk is sorted, write it back to the slow memory
    - To sort all the chunks, we need to get n/(fZ) runs in total

We can also have the following pseudo code of the phase 1,

```
Partition input into n/(fZ) chunks
for each chunk i = 1 to n/(fZ) do:
    load chunk i
    sort chunk i into a sorted run i
    write run i
```

Let's also have a taste of the phase 2 as follows,

- Phase 2
    - Merge the n/(fZ) runs to a single 


#### (2) Merge Sort Phase 1 Asymptotic Cost 

Let's then analyze the asymptotic cost of the merge sort. We assume,

- `f` is a constant so it can be ignored
- `L mod (fZ) = 0`
- `(fZ) mod n = 0`

Then in phase 1,

- `load chunk i` has `O(n/L)` transfers because `n` elements are transferred in `L` words
- `sort chunk i into a sorted run i` has `O(nlogZ)` computations because,
```
O(fZlog(fZ) * n/(fZ)) = O(nlog(fZ)) = O(nlogZ)
```
- `write run i` has `O(n/L)` transfers

#### (3) Merge Sort Phase 2

Then we are going to see how we can merge `m` sorted
runs into a single sorted run. Suppose we each run has a size of `s`, then,

```
n = m * s
```

A classical merge sort idea is to merge pairs of runs until we get a final single run and now let's see what happens at each level. At each level `k` started from 0, we have the sorted run as size `2^k * s`.

#### (4) Merge Sort Phase 2 Cost - One Pair

Considering a pair of runs A and B, each of size `2^(k-1) * s` and our goal is to produce a merged run C which will hold `2^k * s` sorted items.

```
C = merge(A, B)
```

Assume the fast memory of size `Z` holds three buffers and each of them can hold `L` elements. A proportion of A (L sized) and B (L sized) will be loaded into the first buffer and the second buffer, and then the merged result of them will be stored in C. When C is full, then flush to the slow memory and continue until we have merged the pair of runs. The pseudo code should be as follows,

```
read L-sized blocks of A, B to _A and _B
while any unmerged items in A and B do:
    _A, _B -> _C as possible
    if _A empty:
        load more A to _A
    if _B empty:
        load more B to _B
    if _C full:
        flush _C to C
Flush any unmerged items in A or B
```

The cost to merge A and B should be,

```
                          A              B             C
                     ------------   ------------   ----------
Pair Transfer Cost = 2^(k-1)s / L + 2^(k-1)s / L + 2^(k)s / L
                   = 2^(k+1)s / L
```

Considering the comparisons, the asymptotic upper-bound cost should be,

```
Pair Comparison Cost = Θ(2^ks)
```

#### (5) Merge Sort Phase 2 Cost - Total

The calcualtions above is just for merging one pair and for the original merge tree, we have the number of merged pairs at level `k` as,

```
# of pairs = n/(2^ks)
```

When `# of pairs = 1`, we reach the maximum of `k`, so,

```
# of levels = max(k) = log(n/s)
```

Therefore, in total we have the costs as,

```
Transfer Cost = (Pair Transfer Cost * # of pairs per level) * # of levels
              = (2^(k+1)s / L * n/(2^ks)) * log(n/s)
              = 2n/L * log(n/s)

Comparison Cost = (Pair Comparison Cost * # of pairs per level) * # of levels
                = (Θ(2^ks) * n/(2^ks)) * log(n/s)
                = Θ(nlog(n/s))
```

#### (6) General Costs for Two-way Merge Sort on Two Levels

Now if we cosider this problem in a two-level condition with two phases. In phase 1 and 2, the costs are,

```
Phase           Transfer              Comparison
1                O(n/L)                O(nlogZ) 
2            O(n/L*log(n/Z))         O(nlog(n/Z))
```

So in total we have,

```
Transfer Cost = O(n/L) + O(n/L*log(n/Z))
              = O(n/L*log(n/Z))
             
Comparison Cost = O(nlogZ) + O(nlog(n/Z))
                = O(n(logZ + log(n/Z)))
                = O(nlog(Z * n/Z))
                = O(nlogn)
```

#### (7) Problem of Two-way Merge Sort

We can find out that the transfer cost `Q(n;Z,L)` we have here above as we discussed is,

```
Q(n;Z,L) = O(n/L*log(n/Z))
```

And we can also write it fancier as,

```
Q(n;Z,L) = O(n/L*log(n/Z)) = O(n/L * (log(n/L) - log(Z/L)))
```

This is also,

```
Q(n;Z,L) = O(n/L * log(Z/L) * (log(n/L)/log(Z/L) - 1))
```

Compared with the lower bound we have as,

```
Q(n;Z,L) = Ω(n/L * log_(Z/L)(n/L)) = Ω(n/L * log(n/L)/log(Z/L))
```

We can find the improvement of the lower bound is,

```
log(Z/L) * (1 - log(Z/L)/log(n/L))
```

The reason for that is because we only uses three L-sized buffers in the fast memory instead of the total size of `Z`. More specifically, the 2-way merge uses just 3 of the total `Z/L` available blocks of the fast memory. In order to improve that, we have to consider the **multiway merging**.

#### (8) Multiway Merge Sort

So the idea to improve the two way merging is to merge more than two runs at a time to fully utilize the fast memory. Let's say we are merging `k` runs of `s` size each at a time to a single run we must staisify,

```
(k + 1) L <= Z
```

In each add, we will first find the smallest item across all the `k` runs and then add it to the `output` (e.g. `k+1`) buffer. When the output buffer gets filled, the only thing we have to do is to flush it. 

Now the only question is how to pick the next smallest item across `k` buffers. We have several options,

- Linear Scan
- Min-heap (aka. priority queue)

If we go with the min-heap, we will have the following costs. 

- building: `O(k)`
- extractMin: `O(logk)`
- insert: `O(logk)`

Then, let's have a look at the cost of a single k-way merge,

- Transfers: `2ks/L`
    - `ks/L` for a load
    - `ks/L` for a write
- Comparisions: `O(k + kslogk)`
    - O(k) to build the heap
    - every `ks` items are either inserted or extracted, so O(kslogk)

If we look into the whole picture, the number of a multiway merge includes,

- total comparisions numbers: `O(nlogn)`
    - this is similar to any compare based sorting algorithms
- total transfers numbers: `Q(n;Z,L) = Θ((n/L)*log_(Z/L)(n/L))`
    - assume we can always do a k way merge in fast memory so `k = Θ(Z/L) < Z/L`
    - the **maximum numbe of levels** of the merge tree should be `l = Θ(log_(Z/L)(n/L))`, use this as a hint
    - for the `i-1` line, there should be `k` amount `k^(i-1)s` items being merged to a single run of `k^i*s` items
        - Number of transfers per run at level i: `Θ(k^i*s/L)`
        - Number of runs at level i: `n/(k^i*s)`
        - So **total transfers** at level i： `Θ(k^i*s/L) * n/(k^i*s) = Θ(n/L)`
    - So the totoal transfer numbers should be `Θ(n/L) * Θ(log_(Z/L)(n/L)) = Θ((n/L)*log_(Z/L)(n/L))`

#### (9) Performance of Multiway Merge Sort

Now is this multiway merge sort good enough to the theoritical lower bound? The answer is yes and let's see a proof here. 

Let's say we have `n` items in an array for sorting, so,

```
# of possible orderings = n!
```

Let's also suppose we have a two-level memory with the fast memory of size `Z` and the transfer size `L`. For each transfer, `L` items comes to the fast memory and we can know something new about the orderings. Suppose we have the number of orderings after `t-1` transfers as `K(t-1)` and,

```
K(0) = n!
```

To put the new `L` items in the new transfer to the fast memory, at most we can have the number of ways to order items in fast memory as,

```
\tbinom{Z}{L} * L!
```

So that,

```
K(t) >= K(t-1) / (\tbinom{Z}{L} * L!)
```

Consider this in `t` transfers,

```
K(t) >= K(0) / (\tbinom{Z}{L} * L!)^t
```

So,

```
K(t) >= n! / (\tbinom{Z}{L} * L!)^t
```

However, this count is a little bit conservative than necessary because `L!` assumes that we don't know the order of `L`. However, we do know something about `L` because we only have `n/L` of possibilities, so the number of L-sized unseen items per read is smaller or equal to `n/L`. This is to say that,

```
K(t) >= n! / (\tbinom{Z}{L} * L!)^t = n! / (\tbinom{Z}{L})^t * (L!)^t = n! / ((\tbinom{Z}{L})^t * (L!)^t) >= n! / (\tbinom{Z}{L})^t * (L!)^(n/L)
```

So,

```
K(t) >= n! / (\tbinom{Z}{L})^t * (L!)^(n/L)
```

Suppose we want to have the ordered result after t transfers, we need to have `K(t) = 1! = 1`, so,

```
1 >= n! / (\tbinom{Z}{L})^t * (L!)^(n/L)
```

Add `log` to both size,

```
log(n!) <= log((\tbinom{Z}{L})^t * (L!)^(n/L))
```

Here we have two properties,

- `log(x!) ~ xlogx`
- `log(\tbinom{a}{b}) ~ blog(a/b)`

Put this inside our inequation above, we have,

```
nlogn <= tLlog(Z/L) + n/L * LlogL
```

Move `t` to one side of this inequation and the rest to another side, we can then have,

```
t >~ (n/L)*log_(Z/L)(n/L)
```

This is to say that `(n/L)*log_(Z/L)(n/L)` is the theorical lower bound and the algorithm reached to the best performance.

### 3. I/O Avoiding Binary Search

#### (1) Number of Transfers in Binary Search

Suppose we have a sorted list of `n` items. The fast memory size is `Z` and transfer size is `L`. When `n <= L`, we only need one transfer so,

```
Q(n;Z,L) = 1,    when n <= L
```

However, when `n > L`, what we have to do is to find the median item and then load `L` items before or after it. In this case we have,

```
Q(n;Z,L) = 1 + Q(n/2;Z,L),        when n > L
```

The solution to this recurrence is,

```
Q(n;Z,L) = O(log(n/L))
```

But can we do better?

#### (2) Lower Bound for Search

Let's think about the binary search in another way. To find the index `i` we want to search, it takes,

```
O(logn) bits
```

Also, the maximum number of bits we learn per `L` sized read should be `logL`,

```
Q(n;Z,L) = Ω(logn/logL) = Ω(log_L(n))
```

So compared with the lower bounds for the binary search O(log(n/L)) = O(log(n)-log(L)) ~ O(logn) that we can see a speedup of `logL`.


#### (3) Lower Bound for Binary Tree

However, the binary search can not reach the lower bound, but the binary tree can reach the lower bound. We will skip this part here.
