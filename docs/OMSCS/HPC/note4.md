# High Performance Computing 4｜Cache Oblivious Algorithms

### 1. Basic Concepts

#### (1) The Definition of Oblivious

Oblivious to the fast memory or cache means the algorithm makes no reference to the fast memory or its parameters (e.g. `Z` or `L`).

#### (2) Cache Hit and Cache Miss

When a load or a store happens in the program, the hardware will first check the cache. If the value it needs exist in the cache, then we will call it a cache hit. Instead, there will be a cache miss, and it will cost a memory transfer.

#### (3) The Ideal Cache Model

- Program issues load & store operations
- Hardware manages `Z/L` cache lines
- Slow and fast memories are **divided into blocks of L words**
- Cache is **fully associative**, which means the block is allowed to go into any block or line of the cache. As real caches don't implement as fully associative, and it will make our ideal cache model more powerful.
- Using **optimal replacement** which means the hardware managing the cache actually knows the future

#### (4) Memory Transfer Costs for Ideal Cache Model

In the ideal cache model, we also calculate the number of transfers, and this will be equal to the number of misses and the number of store evictions.

```
Q(n;Z,L) = # of misses + # of store evictions
```

#### (5) Recall: LRU Replacement

LRU is a common replacement rule and it evicts the least recently used address. The number of evictions of LRU is commonly higher than the ideal number of evictions.

```
# of eviction (Ideal) <= # of eviction (LRU)
```

More specifically, there's a lemma shows that,

```
Q_LRU(n;Z,L) <= 2Q_OPT(n;Z/2,L)
```

Based on this, one corollary called **regularity condition** is that we say `Q_OPT(n;Z,L)` is regular if,

```
Q_OPT(n;Z,L) = O(Q_OPT(n;2Z,L))
```

Then if we can show that the `Q_OPT` is regular in this sense, we are able to show that the LRU will be performing just as well,

```
Q_LRU(n;Z,L) = Θ(Q_OPT(n;Z,L))
```

In this case that we can figure out that the optimal replacement is not a very strong assumption.

#### (7) Example of LRU-OPT Lemma

Now, let's see how to use the lemma. Suppose we have a matrix multiplication problem and we have discussed that,

```
Q_OPT(n;Z,L) = Θ(n^3/(L*sqrt(Z)))
```

Then assume `L = 1` (unit) we have,

```
Q_OPT(n;Z,L=1) = Θ(n^3/(sqrt(Z)))
```

So,

```
2Q_OPT(n;Z/2,L=1) = 2Θ(n^3*sqrt(2)/(sqrt(Z))) = Θ(n^3/(sqrt(Z)))
```

Therefore, the upper bound of LRU that we can have is then,

```
Q_LRU(n;Z,L) <= Θ(n^3/(sqrt(Z)))
```

#### (6) Proof of LRU-OPT Lemma

Recall the lemma,

```
Q_LRU(n;Z,L) <= 2Q_OPT(n;Z/2,L)
```

Now let's prove this. Suppose `L = 1` and the machine has an LRU cache of size `Z`. For any phase `i`, it references exactly `Z` unique address (loads and stores). Then the begining of the phase `i` we may possibly have the cache full and it could cause an eviction. Therefore, the number of cache misses could be as high as `Z`,

```
Q_LRU(Z | phase = i) <= Z
```

Then if we also have a OPT cache in phase `i` of size `Z/2`, for the first `Z/2` addresses, it can presee the future and there will be no cache miss. However, for the next `Z/2` addresses in phase `i`, it can not see the future so that it can at least have `Z/2` cache misses. Therefore,

```
Q_OPT(Z | phase = 1) >= Z/2
```

Based on these two inequations, we can have the lemma,

```
Q_LRU(n;Z,L) <= 2Q_OPT(n;Z/2,L)
```

#### (7) Tall Cache Assumption

The tall cache assumption says that the cache should be taller (aka. the number of lines) than its wide (aka. the number of words per line).

The number of lines are defined as,

```
# of lines = Z / L
```

And the words per line should be,

```
# of words per line = L
```

So,

```
Z / L >= L
```

So,

```
Z >= L^2
```

This is the assumption hold when we have an ideal cache. In the real case, most of the memory hierarchies are indeed tall but not all of them are.

### 2. Cache Oblivious Algorithms

#### (1) Matrix Multiplication

Recall the cache aware matrix multiply we have discussed. The matrics are divided into blocks of size `b` times `b` and,

```
b = Θ(sqrt(Z))
```

So in this case, the cache misses are,

```
Q = Θ(n^3 / (L * b)) = Θ(n^3 / (L * sqrt(Z)))
```

As we have said, for any non-Strassen algorithms, no algorithms can be better than this.

However, there's a different algorithm that can achieve the same performance but unaware to the cache size. Let's assume for simplity that matrics are `n` by `n` and `n` is an integer power of 2. Then we can recursively divide the matrix to four blocks (2 by 2) until we get the result. Here's the pseudocode,

```
function mm(n, A, B, C):
    if n = 1 then C <- A + B
    else
        Logically partition A, B and C into quadrants
        for i = 1 to 2 do:
            for j = 1 to 2 do:
                 for k = 1 to 2 do:
                     mm(n/2, Aik, Bkj, Cij)
```

Let's now analyze this code. The number of recurrence flops is,

```
F(n) = 8 * F(n/2) if n > 1
     = 2          if n = 1
```

So,

```
F(n) = 2n^3
```

For calculating the cache misses, let's first say that in the level `l` we have the operands fit in the cache so,

```
n_l = n / 2^l
```

And,

```
3n_l^2 <= Z
```

If we assume tall cache in this case, we will then have,

```
n_l <= c * sqrt(Z)
```

Where `c` is a constant fraction.

Then we can write,

```
Q(n;Z,L) = Θ(n^2/L)             if n <= c * sqrt(Z)
         = 8Q(n/2;Z,L) + O(1)   if else
```

Where `O(1)` means we assume a constant number within the function call itself. To solve this recurrence we can have,

```
Q(n;Z,L) = Θ(n^3/(L*sqrt(Z)))
```

This matches the lower bound.

#### (2) Binary Search

Also, let's first recall the binary search. The number of cache misses is,

```
Q(n;Z,L) = 1 + Q(n/2;Z,L) if n > L
         = 1              if n <= L
```

Solving this recurrence we have,

```
Q(n;Z,L) = O(log(n/L))
```

However, the lower bound is `O(log_L(n))`. So the algorithm is not optimal but it is still one nice thing. One thing to see is that the algorithm is already cache oblivious.

But how to achieve the lower bound? There's a way out if we change the data layout. Let's replace the array to a binary search tree and then let's see how we can achieve it.

#### (3) Binary Tree

Because the binary search tree maintains some ordering of its elements and we can number a tree to its in-order traversal. Then we can interpret these numbers as addresses or index positions.

However, there's nothing secret about this layout and let's consider a different ordering called the Van Emde Boas layout or a Van Emde Boas tree.

#### (4) Van Emde Boas layout

If we have a complete binary tree of `n` nodes, then we will have `logn` levels. If we split the levels in half, then we have two parts of the levels and each of them has `logn/2` levels. Above the split line, there will be `sqrt(n)` nodes and below the split line, there will be about `sqrt(n)` subtrees and each of size `sqrt(n)`.

The idea of a Van Emde Boas layout is to put a binary tree linearly in the slow memory by,

- partitioning the levels
- layout all the upper subtree elements together
- concatenate with the lower subtree elements

When we say "layout together", we mean recursively apply the Van Emde Boas layout to each subtree.

Now let's see how it works. Let's zoom in the tree and looking at the point where the subtrees fit within the cache lines (# of nodes in a subtree <= L). Then a binary search, as defined, takes some path from the root to the leaf and we only generate a cache miss when we hit the root of one of the subtrees. The hight of a subtree should be,

```
h_sub = Θ(logL)
```

And the total height of the tree should be,

```
h = logN
```

Then the maximum cache miss we can have by this case should be,

```
Q = h / h_sub = Ω(logN/logL)
```

And we can see that this is the best case we have.
