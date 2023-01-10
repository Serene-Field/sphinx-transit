# High Performance Computing 1 | Memory Locality Theory

### 1. Memory Locality Theory

#### (1) Definition

Between a processor and a primary storage device, there are layers of memories in between.

#### (2) Von Nevmann Model

Between the slower memory and the processor, there's a fast memory.

#### (3) Two Rules for Von Nevmann Model

- **Local Data Rule**: Processor may only compute the data in the fast memory. Or the processor can not do any operations unless the operands sit in fast memory
- **Block Transfer Rule**: When data moves between the slow memory and the fast memory, it does so by in chunks of size `L` words.

#### (4) Cost of Block Transfers

Suppose we want to transfer `W(n)` number of computation operations. The data transfers in chunks of size `L` words and the fast memory LLC has a size of `Z` words. And we denote the number of block transfers as `Q(n;Z,L)`.

Then let's see an example. Suppose the processor needs to sum an array of `n` elements. So we will have at least `(n-1)` additions. And the work should be,

```
W(n) = (n - 1) additions = Ω(n)
```

So the transfer cost is,

```
Q(n;Z,L) >= Ω(ceil(n/L)) = Ω(n/L)
```

Here we can find out that the cost doesn't rely on the fast memory size `Z` and reduction does not reuse data. However, not reusing data is pad.

#### (5) Maximum Cost of Block Transfers

Now let's consider how alignment can impact the cost transfers. Suppose we have the same case above with a `Z` words fast memory and we have to sum a list of `n` elements. The block size is `L` words and we know nothing about how the words are aligned with respect to the transfer size `L`. Now, let's consider the worst case transfer cost.

Let's see an example. Suppose we have the following assumptions,

```
n = 4
L = 2
```

Then, the alignment can be,

```
   |------|------|-----|-----|
...|------L------|-----L-----|...
```

Or,

```
      |------|------|-----|-----|
...---L------|------L-----|-----L---...
```

In the first case, we need `2` transfers, while in the second case, we need `3 (2+1)` transfers. Therefore, the maximum cost of block transfers should be,

```
Q(n;Z,L) <= ceil(n/L) + 1
```

#### (6) Cost of Block Sorting

Now let's suppose we want to sort a list of `n` words and the work load should be,

```
W(n) = Ω(nlogn)
```

Similarly in this case, the transfer cost should also be,

```
Q(n;Z,L) = Ω(ceil(n/L)) = Ω(n/L)
```

However, in the best case this cost can be,

```
Q(n;Z,L) = Ω(nlog(n/L)/L / log(Z/L))
```

We will reserve this to the later sections.

#### (7) Cost of Matrix-matrix Multiplication

Suppose we have three n by n matrix A, B and C, and

```
C = A * B
```

If we ignore the possibilities of strassen's algorithm, the workload should be,

```
W(n) = O(n^3)
```

The asymptotic lower bound of the transfer cost is,

```
Q(n;Z,L) = Ω(n^2 / L)
```

This is just a trivial version of the lower bound. n^2 is the number of elements in one matrix. However, there's a much tighter lower bound of the following format,

```
Q(n;Z,L) = Ω(n^3 / (L * sqrt(Z)))
```

And we will also save this for the future lessons.

#### (8) Reduction Vs. Block Reduction Algo

Now, let's go back to the reduction case and suppose we have an array `X` of n elements. Assume that `n >> Z` and `X` aligned on the L-word boundary. To summarize this array, normally we have the following algorithm,

```
local S = 0
for i = 0 to (n-1) do
    S = S + X[i]
```

Now let's modify this algorithm to make slow/fast memory expressed explicitly.

```
local S = 0
for i = 0 to (n-1)/L do:
    local i_hat = i * L
    local L_hat = min(n, i_hat + L - 1)
    local y[:(L_hat-1)] = X[i_hat:(i_hat+L_hat-1)]  // line A
    for ii = 0 to (L_hat - 1) do:
        S = S + y[ii]
```

In line A, we load the data of at most L words from the slow memory to the fast memory. By this case, the workload and the transfer cost for this reduction is,

```
W(n) = Θ(n)
Q(n;Z,L) >= Θ(ceil(n/L))
```

#### (9) Matrix-Vector Multiplication

Let's now see an example of a matrix `A` (n by n) multiply vector `x` (n by 1). The matrix is supposed to store in a column major order, which means the elements of the matrix are laid out in the memory column-wised, for instance,

```
A = [[1, 2, 3],
     [4, 5, 6],   --->  A' = [1, 4, 7, 2, 5, 8, 3, 6, 9]
     [7, 8, 9]]                
----------------         -------------------------------
    Original                        Column-wised
```

So in this case, the elements have consecutive addressses within a column with one column following the previous column. And we have the following mapping rules,

```
A[i][j] = A'[j * n + i]
```

Then the 1st algo would be,

```
for i = 0 to (n-1) do:
    for j = 0 to (n-1) do:
        y[i] += A[j*n+i] * x[j]
```

We can also have the 2nd algo which is the opposite loop order of the first one,

```
for j = 0 to (n-1) do:
    for i = 0 to (n-1) do:
        y[i] += A[j*n+i] * x[j]
```

If we consider the following assumptions: 1) Z is large enough to hold two vectors with a few more words (`Z = 2n + O(L)`); 2) L divides n; 3) x, y, and A aligned on L. Then let's compare the two algorithms above and consider which one does fewer transfers?

In the beginning of both algos, vector x and y are loaded to the fast memory, which means we have `2n/L` transfer cost. And also in the end, the vector y is stored to the slow memory, which also means we have `n/L` transfer cose. Therefore, we can know the transfer cost will have the following structure,

```
Q(n;Z,L) = 3n / L + f(n;Z,L)
```

Where `f(n;Z,L)` is the additional transfer cost of these two algorithms.

In the first algorithm, when we loop with `j`, the elements we need in two continuous iterations are not consecutive in memory. Thereby, we need to load one time for each of the element so,

```
f(n;Z,L) = n^2
```

However in the second algorithm, because in the loop of `i`, the element we need are consecutive in the memory so we don't have to load for each of them. On average we only need `n/L` loads for each column so that the additional transfer cost would be,

```
f(n;Z,L) = n^2 / L
```

So even through in both of these cases we have `O(f) = n^2`, the second algo shows a better performance by making the transfer L times faster.

#### (10) Algorthmic Design Goals

Another important question about this model is what are the goals with respect to the complexity measures. Basically, there are two goals,

- work optimality: the two level algo should do the same work as the best asymptotic algorithm. This actually means to say we should have parallel algorithms

```
W(n) = Θ(W'(n))
```

- high computational intensity: computational intensity is the amount of work per word transfer. In another way to say it measures the data reuse of the algorithm.

```
max I(n;Z,L) = W(n) / (L * Q(n;Z,L))
```

In the end, what we are saying is that we want our algorithm to max out the computational intensity without messing up with the work, and this should reminding you the concept of **work and span**.

#### (11) Work, Transfers & Execution Time Balance

Now let's consider the relationship between the work, transfers, and the execution time. Suppose we have,

- the processor takes τ time to execute a operation
- the fast-slow memory bus takes ɑ time to transfer a word

Then we can know,

- The computational time: `T_comp = τW`
- The transfer time: `T_mem = ɑLQ`

Based on what we have discuss, we can know the total time is the maxium value of the computational time and the transfer time,

```
T >= max(T_comp, T_mem)
  = max(τW, ɑLQ)
  = τW * max(1, ɑLQ/τW)
  = τW * max(1, (ɑ/τ)/(W/LQ))
  = τW * max(1, (ɑ/τ)/I)
```

Where `I` is the computational intensity we have discussed. The numerator is the time per word devided by the time per operation called the **machine's balance point** which **only depends on the machine** and it has units of operations per word. For a specific machine, the machine balance is a constant `B` so we can replace it by,

```
T >= τW * max(1, B/I)
```

If we also consider the worst case when the computational time and the transfer time have no overlap, we can get a maximum overall time which is the summation of these two times,

```
τW * max(1, B/I) <= T <= τW * (1 + B/I)
```

Sometime when we ask about the overall execution time, we will ask about a certain measure of performance called the **normalized performance** `R`. It is defined by

```
R = τW'/T
```

Where `W'` is the best case workload (computational optimality) and `τW'` is the best case execution time with a pure RAM model. If we replace `T`, this formula can be written to,

```
R <= τW'/τW * min(1, I/B)
  = W'/W * min(1, I/B)
```

So,

```
R_max = W'/W * min(1, I/B)
```

#### (12) Roofline Plots

Then to visualize the relationship between I, B, and R, let's consider a roofline plot. Suppose the x-axis is the computational intensity and the y-axis is the maxmium normalized performance R_max. Then we can draw the following plot. 

![roogline plot](https://raw.githubusercontent.com/Sadamingh/notepics/main/hpc/1.png)

This plot is called roofline because of the shape and we should remember the critical point (B, W'/W).

#### (13) Intensity of Conventional Matrix Multiply

Now let's consider back to our matrix muplication problem `C <- C + A * B`. Suppose we have the following algorithm,

```
for i = 0 to n-1 do:                          // load A[i,:]
    for j = 0 to n-1 do:                      // load C[i,j] & B[:,j] 
        for k = 0 to n-1 do:
            C[i, j] += A[i, k] + B[k, j]      // store C[i,j]
```

Now suppose we run this algorithm on a machine with a two level memory of `Z` size. And we also have some simplified assumptions here,

- L = 1 word: No alignment issues
- Z = 2n + O(L) = 2n + O(1)

When we are calculating the asymptotic intensity of this algorithm, let's first consider the computational work. Note that the algorithm has a workload like,

```
W(n) = Θ(n^3)
```

Then for the transfers,

- `load A[i,:]`: load n elements by n times -> n^2
- `load C[i,j]`: load each element in C once because of the extra space O(1) -> n^2
- `store C[i,j]`: store each element in C once because of the extra space O(1) -> n^2
- `load B[:,j]`: load n elements of B for n^2 times because the fast mem can only hold 2n -> n^3

So in total we have,

```
Q(n;Z,L) = 3n^2 + n^3 = Θ(n^3)
```

Therefore,

```
I = W(n) / (L*Q(n;Z,L)) = Θ(1)
```

#### (14) Better Algorithm for Conventional Matrix Multiply

Now let's consider another algorithm for the matrix multiplication problem. Suppose we have the following algorithm,

```
for i = 0 to n-1 by b do:
    for j = 0 to n-1 by b do:
        C' = [i:i+b,j:j+b]           // load C'
        for k = 0 to n-1 by b do:
            A' = [i:i+b,k:k+b]       // load A'
            B' = [k:k+b,j:j+b]       // load B'
            C' += A' * B'            // store C'
C <- C'
```

Let's also assume that,

- L = 1
- L | n
- n | Z
- Z = 3b^2 + O(1)

The algorithm should again have a workload of,

```
W(n) = Θ(n^3)
```

Then for the transfer cost, we have

- load C': b^2 elements in C loaded for (n/b)^2 times `b^2 * (n/b)^2 = n^2`
- load A': b^2 elements in A loaded for (n/b)^3 times `b^2 * (n/b)^3 = n^3/b`
- load B': b^2 elements in B loaded for (n/b)^3 times `b^2 * (n/b)^3 = n^3/b`
- store C': b^2 elements in C stored for (n/b)^3 times `b^2 * (n/b)^3 = n^3/b`

In total, this is,

```
Q(n;Z,L) = n^2 + 3n^3/b = Θ(n^3/b)
```

So,

```
I = W(n) / (L*Q(n;Z,L)) = Θ(n^3)/Θ(n^3/b) = Θ(b)
```

Based on `Z = Θ(b^2)` we can also derive,

```
I = Θ(sqrt(Z))
```

Therefore we can see that the current algorithm is `b` or `sqrt(Z)` times better than the last one.

#### (15) Application: Informing the Arch

Suppose we have a machine that is really good at solving the matrix multiply issues at a particular size. If we have its machine balance doubles, then by how much should the fast memory increase?

To slove this question, let's first recall the machine balance is defined by,

```
B = ɑ / τ
```

where ɑ is time per word transfer the τ is the time per operation. So B is actually how many operations per word and doubling it means we have to speed up the word transfer or to increase the memory size.

Recall we have the maxmium normalized performance defined by,

```
R_max = W'/W * min(1, I/B)
```

If `B' = 2B`, then to keep the same R_max, we need to have `I' = 2I`. By the fact we have discussed that for matrix multiplication we have,

```
I = Θ(sqrt(Z))
```

Then we need to increase `Z' = 4Z` in order to get the same performance. 